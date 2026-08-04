import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/app_database_provider.dart';
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
/// 3. `unawaited` 后台推送 Supabase，成功后回填 `isSynced = true`。失败静默降级，
///    数据保留 `isSynced = false` 等待下次补偿，用户完全无感。
///
/// 读取路径一律走 Drift，永不阻塞在网络上。
class CardRepositoryImpl implements CardRepository {
  final AppDatabase _db = appDatabase;
  final CardLocalDatasource _mirror = CardLocalDatasource();
  final SupabaseCardSync _sync = SupabaseCardSync();

  /// 一次性迁移句柄：保证 Isar → Drift 的搬运在整个进程内只执行一次。
  Future<void>? _migration;

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
    unawaited(_pushInBackground(row));
    // 4) 后台众包上报：把卡牌元数据（及可选卡面图）共享到公共主图鉴，静默降级，
    //    不影响用户本地保存与 UI。
    unawaited(_contributeToMaster(card));
  }

  @override
  Future<void> updateCard(CardItem card) => saveCard(card);

  @override
  Future<void> deleteCard(int id) async {
    await _ensureMigrated();
    await _db.deleteCardById(id.toString());
    await _mirror.deleteCard(id);
    unawaited(_sync.deleteCard(id.toString()));
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
    unawaited(_pushPending());
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
