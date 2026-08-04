import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// 卡牌本地表（Drift / SQLite，本地优先架构的核心存储）。
///
/// [id] 存 CardItem.id 的字符串形式（当前保持与既有 int id 一致，避免破坏 UI 与
/// Isar 镜像；后续可平滑改为 UUID）。除任务约定的核心列（name / buyPrice /
/// centeringData / imagePaths / createdAt / isSynced）外，扩展保留了其余 CardItem
/// 字段，确保 UI 从 Drift 读取时不丢失任何展示所需数据。
///
/// 数据类命名为 [CardRow] 而非默认的 `Card`，避免与 Flutter Material 的 `Card`
/// 组件重名冲突。
@DataClassName('CardRow')
class Cards extends Table {
  TextColumn get id => text()();

  TextColumn get catalogId => text().withDefault(const Constant(''))();

  TextColumn get name => text()();

  TextColumn get cardNumber => text().withDefault(const Constant(''))();

  /// 卡牌所属系列/卡组名（透传到公共主图鉴 ID，H-4 新增；默认空串兼容历史数据）。
  TextColumn get setName => text().withDefault(const Constant(''))();

  TextColumn get imageUrl => text().withDefault(const Constant(''))();

  TextColumn get grading => text().withDefault(const Constant('raw'))();

  TextColumn get category => text().withDefault(const Constant('all'))();

  RealColumn get gradeScore => real().nullable()();

  TextColumn get certNumber => text().nullable()();

  RealColumn get buyPrice => real()();

  RealColumn get marketPrice => real().withDefault(const Constant(0.0))();

  DateTimeColumn get buyDate =>
      dateTime().withDefault(Constant(DateTime.fromMillisecondsSinceEpoch(0)))();

  BoolColumn get isCollected => boolean().withDefault(const Constant(true))();

  RealColumn get volume => real().withDefault(const Constant(0.0))();

  BoolColumn get isWishlist => boolean().withDefault(const Constant(false))();

  RealColumn get targetPrice => real().nullable()();

  IntColumn get wishlistPriority => integer().withDefault(const Constant(0))();

  TextColumn get priceHistoryJson => text().withDefault(const Constant(''))();

  /// 居中度测量结果明细（对应 CardItem.centeringResult，JSON 序列化）。
  TextColumn get centeringData => text().nullable()();

  /// 本地高清图路径列表（JSON 序列化）。
  TextColumn get imagePaths => text().withDefault(const Constant('[]'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 是否已同步至云端（本地写入后为 false，Supabase 增量同步成功后置 true）。
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// 图鉴本地缓存表（任务约定结构：id / name / category / setName / cardNumber / imageUrl）。
@DataClassName('CatalogRow')
class Catalogs extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get category => text().withDefault(const Constant(''))();

  TextColumn get setName => text().withDefault(const Constant(''))();

  TextColumn get cardNumber => text().withDefault(const Constant(''))();

  TextColumn get imageUrl => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(tables: [Cards, Catalogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 供测试 / 内存库注入使用。
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 2;

  /// 数据库版本迁移策略（H-6）。
  ///
  /// 预留 step-by-step 迁移回调：后续加列/改表时在此按 `from` 版本递增补充，
  /// 避免老用户升级后因 schema 不匹配而启动崩溃。当前仅有 v1 → v2 的加列迁移。
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(cards, cards.setName);
      }
      // 未来版本演进：在此按 `from` 递增补充迁移步骤。
    },
  );

  // ---------------- Cards DAO ----------------

  /// 写入或覆盖一张卡牌（按 id 主键去重）。
  ///
  /// 使用 `ON CONFLICT DO UPDATE` 而非 `INSERT OR REPLACE`：后者是「删除 + 重插」，
  /// 会改变 SQLite rowid，导致列表默认顺序在编辑后跳到末尾；前者原地更新，
  /// 保持既有 UI 展示顺序不变。
  Future<void> upsertCard(CardRow entry) =>
      into(cards).insertOnConflictUpdate(entry);

  /// 按 id 查询单张（更新时用于保留 createdAt / isSynced）。
  Future<CardRow?> getCardById(String id) =>
      (select(cards)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<CardRow>> getAllCards() => select(cards).get();

  /// 实时监听全部卡牌变化（UI 直接订阅此流，写入即刷新，无网络延迟）。
  Stream<List<CardRow>> watchAllCards() => select(cards).watch();

  Future<void> deleteCardById(String id) =>
      (delete(cards)..where((t) => t.id.equals(id))).go();

  /// 云端同步完成后回填同步状态。
  Future<void> setSynced(String id, bool synced) =>
      (update(cards)..where((t) => t.id.equals(id)))
          .write(CardsCompanion(isSynced: Value(synced)));

  /// 查询尚未同步到云端的卡牌（增量同步用）。
  Future<List<CardRow>> getUnsyncedCards() =>
      (select(cards)..where((t) => t.isSynced.equals(false))).get();

  /// 整体替换（备份恢复用）。
  Future<void> replaceAllCards(List<CardRow> entries) async {
    await delete(cards).go();
    await batch((b) => b.insertAll(cards, entries, mode: InsertMode.replace));
  }

  // ---------------- Catalogs DAO ----------------

  Future<void> upsertCatalog(CatalogRow entry) =>
      into(catalogs).insertOnConflictUpdate(entry);

  Future<void> upsertCatalogs(List<CatalogRow> entries) => batch(
        (b) => b.insertAll(catalogs, entries, mode: InsertMode.replace),
      );

  Future<List<CatalogRow>> getAllCatalogs() => select(catalogs).get();

  Stream<List<CatalogRow>> watchAllCatalogs() => select(catalogs).watch();
}

/// 打开本地 SQLite 文件（应用文档目录下的 card_collector.sqlite）。
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'card_collector.sqlite'));
    return NativeDatabase(file);
  });
}
