import 'package:flutter/foundation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/app_database_provider.dart';
import '../../../../core/utils/silent_background.dart';
import '../../data/datasources/card_local_datasource_native.dart';
import '../../data/datasources/master_catalog_sync_service.dart';
import '../../data/datasources/supabase_card_sync.dart';
import '../../data/mappers/card_row_mapper.dart';
import '../../data/models/card_item.dart';
import 'card_repository.dart';

/// 原生平台卡牌仓库实现：**SQLite(Drift) 本地优先 + Supabase 后台增量同步**。
///
/// 写入路径（用户点「保存」到 UI 刷新，全程不等网络）：
/// 1. 落 Isar 镜像取得自增主键 —— Isar 仍是 id 权威来源，且既有「整库文件云备份 /
///    恢复」（[uploadBackup] / [restoreBackup]）完全依赖它，必须保留，否则备份功能失效；
/// 2. 落本地 SQLite —— Drift 的 [AppDatabase.watchAllCards] 是响应式流，写入即触发
///    UI 重建，这是「零延迟」的来源；
/// 3. 经 [runSilently] 后台推送 Supabase，成功后回填 `isSynced = true`。失败静默降级，
///    数据保留 `isSynced = false` 等待下次补偿，用户完全无感。
///
/// 所有云端动作一律走 [runSilently] 而非裸 `unawaited`：后者不捕获异常，失败会逃逸成
/// unhandled async error（debug 红屏 / release 崩溃上报），破坏「静默降级」约定。
///
/// 读取路径一律走 Drift，永不阻塞在网络上。
class CardRepositoryImpl implements CardRepository {
  final AppDatabase _db = appDatabase;
  final CardLocalDatasource _mirror = CardLocalDatasource();
  final SupabaseCardSync _sync = SupabaseCardSync();

  /// 一次性迁移句柄：保证 Isar → Drift 的搬运在整个进程内只执行一次。
  Future<void>? _migration;

  /// 冷启动补偿互斥锁：防止多次冷启动 / 初始化竞态触发重复扫描。
  bool _compensating = false;

  @override
  Future<List<CardItem>> getAllCards() async {
    await _ensureMigrated();
    final List<CardRow> rows = await _db.getAllCards();
    return rows.map(CardRowMapper.toItem).toList();
  }

  @override
  Future<void> saveCard(CardItem card) async {
    await _ensureMigrated();
    // 1) Isar 镜像先行：拿到真实自增主键，同时保住整库云备份能力。
    final int assignedId = await _mirror.saveCardReturningId(card);
    // 2) 本地 SQLite 写入 —— 保留既有行的 createdAt / catalogId / imagePaths，
    //    避免「编辑一次就把创建时间刷成现在」。
    final CardRow? existing = await _db.getCardById(assignedId.toString());
    final CardRow row = CardRowMapper.toRow(
      card.copyWith(id: assignedId),
      catalogId: existing?.catalogId,
      imagePaths: existing?.imagePaths,
      createdAt: existing?.createdAt,
    );
    await _db.upsertCard(row);
    // 3) 后台增量同步，不阻塞返回。
    runSilently(() => _pushInBackground(row), tag: 'CardSync');
    // 4) 后台众包上报：把卡牌元数据（及可选卡面图）共享到公共主图鉴，静默降级，
    //    不影响用户本地保存与 UI。
    runSilently(() => _contributeToMaster(card), tag: 'MasterCatalog');
  }

  @override
  Future<void> updateCard(CardItem card) => saveCard(card);

  @override
  Future<void> deleteCard(int id) async {
    await _ensureMigrated();
    await _db.deleteCardById(id.toString());
    await _mirror.deleteCard(id);
    runSilently(() => _sync.deleteCard(id.toString()), tag: 'CardSync');
  }

  @override
  Future<void> replaceAllCards(List<CardItem> cards) async {
    // 备份恢复场景：整体覆盖两侧本地库，保持 Isar 与 Drift 一致。
    await _mirror.replaceAllCards(cards);
    final List<CardItem> persisted = await _mirror.getAllCards();
    await _db.replaceAllCards(
      persisted.map((CardItem e) => CardRowMapper.toRow(e)).toList(),
    );
    // 恢复后的全量数据视为待同步，交由后台补偿推送。
    runSilently(_pushPending, tag: 'CardSync');
    _migration = Future<void>.value();
  }

  @override
  Stream<List<CardItem>> watchAll() async* {
    await _ensureMigrated();
    yield* _db.watchAllCards().map(
          (List<CardRow> rows) => rows.map(CardRowMapper.toItem).toList(),
        );
  }

  // ---------------- 内部：同步与迁移 ----------------

  /// 后台推送单张卡牌，成功才回填同步标记。
  Future<void> _pushInBackground(CardRow row) async {
    final bool ok = await _sync.pushCard(row);
    if (ok) {
      await _db.setSynced(row.id, true);
    }
  }

  /// 后台众包上报单张卡牌到公共主图鉴（UGC）。
  ///
  /// 仅做尽力而为的上报：失败（凭证缺失 / 表未建 / 网络异常）全部在
  /// [MasterCatalogSyncService] 内部静默降级，不会抛异常、不会阻塞本地保存。
  /// 本地模型当前未单独建模「系列/卡组」，故 [setName] 传空串；接入系列字段后
  /// 在此透传即可，主图鉴 ID 生成逻辑无需改动。
  Future<void> _contributeToMaster(CardItem card) async {
    await MasterCatalogSyncService.contributeToMasterCatalog(
      card: card,
      setName: card.setName,
      localImagePath: card.imageUrl,
    );
  }

  /// 补偿推送：把所有 `isSynced = false` 的卡牌批量上行。
  Future<void> _pushPending() async {
    final List<CardRow> pending = await _db.getUnsyncedCards();
    if (pending.isEmpty) return;
    final bool ok = await _sync.pushCards(pending);
    if (!ok) return;
    for (final CardRow row in pending) {
      await _db.setSynced(row.id, true);
    }
  }

  /// 冷启动补偿：扫描本地所有 `isSynced = false` 的卡片，后台静默重试推送。
  ///
  /// 同时覆盖两条云链路：
  /// 1. 私有表 `cards` 的增量同步（批量 upsert，成功后回填 `isSynced = true`）；
  /// 2. 公共主图鉴 `master_catalogs` 的贡献上报（[_contributeToMaster]，幂等
  ///    insert-or-fill-empty，失败已在服务内部静默降级）。
  ///
  /// 以 [_compensating] 互斥，重复调用（多次冷启动 / 初始化竞态）只触发一次真实扫描，
  /// 绝不重复上行。调用方须用 [runSilently] 包络并打 'StartupCompensation' 标签，
  /// 本方法自身异常也被 catch 透传给护栏，仅输出带堆栈日志，不阻断 App 启动。
  ///
  /// 注意：补偿范围以 `isSynced` 为准——即「本次保存曾尝试上报」的卡片。若某卡私有表
  /// 推送成功（`isSynced` 已置真）但主图鉴贡献失败，属极少数边缘，本次不补偿；这是为
  /// 避免对上千张已同步卡牌全量重报而做的可接受的众包去重取舍，无需为此新增迁移列。
  @override
  Future<void> compensateUnsynced() async {
    if (_compensating) return;
    _compensating = true;
    try {
      await _ensureMigrated();
      final List<CardRow> pending = await _db.getUnsyncedCards();
      if (pending.isEmpty) return;
      // 1) 私有表增量同步（批量 upsert）。
      final bool ok = await _sync.pushCards(pending);
      if (ok) {
        for (final CardRow row in pending) {
          await _db.setSynced(row.id, true);
        }
      }
      // 2) 公共主图鉴贡献补偿：同一批未同步卡牌的上报若曾失败，此处重试。
      for (final CardRow row in pending) {
        await _contributeToMaster(CardRowMapper.toItem(row));
      }
    } catch (e, st) {
      // 扫描/上行自身异常（如 DB 读取失败）不向外抛，交给 runSilently 护栏记录堆栈。
      debugPrint('[CardRepository] 冷启动补偿扫描异常（已降级）: $e\n$st');
    } finally {
      _compensating = false;
    }
  }

  /// Isar → Drift 一次性数据迁移（幂等）。
  ///
  /// 老用户升级后 Drift 库为空而 Isar 有历史卡牌，若不搬运会「数据凭空消失」。
  /// 仅在 Drift 为空且 Isar 非空时执行，执行结果缓存，进程内不重复触发。
  Future<void> _ensureMigrated() => _migration ??= _migrateFromIsar();

  Future<void> _migrateFromIsar() async {
    try {
      final List<CardRow> existing = await _db.getAllCards();
      if (existing.isNotEmpty) return;
      final List<CardItem> legacy = await _mirror.getAllCards();
      if (legacy.isEmpty) return;
      await _db.replaceAllCards(
        legacy.map((CardItem e) => CardRowMapper.toRow(e)).toList(),
      );
    } catch (e) {
      // 迁移失败不得阻断 App 使用：清空句柄允许后续调用重试，本次按空库继续。
      _migration = null;
      debugPrint('[CardRepository] Isar → Drift 迁移失败（本次按空库继续）: $e');
    }
  }
}
