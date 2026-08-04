import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/card_item.dart';

/// 全局 Isar 实例。
///
/// 仅原生平台构建会包含此文件；Web 构建走 [card_local_datasource_web] 的内存实现，
/// 因此 `dart:ffi` 相关代码不会被编译进 Web 包。
late Isar isar;

/// 初始化数据库（原生平台：打开 Isar，须在 runApp 之前调用）。
Future<void> initCardDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    <CollectionSchema<Object>>[CardItemSchema],
    directory: dir.path,
  );
}

/// 卡牌本地数据操作服务（原生平台：封装 Isar）。
class CardLocalDatasource {
  /// 查询所有卡牌
  Future<List<CardItem>> getAllCards() => isar.cardItems.where().findAll();

  /// 写入或更新一张卡牌
  Future<void> saveCard(CardItem card) async {
    await isar.writeTxn(() async {
      await isar.cardItems.put(card);
    });
  }

  /// 写入或更新一张卡牌，并返回 Isar 实际分配的主键 id。
  ///
  /// 新增卡牌时 [CardItem.id] 为 `Isar.autoIncrement` 哨兵值，只有 `put` 之后才能
  /// 拿到真实自增 id。Drift 侧需要用同一个 id 作为主键以保持两库一致，故提供此
  /// 纯新增方法（不改动既有 [saveCard] 签名，对现有调用方 100% 无影响）。
  Future<int> saveCardReturningId(CardItem card) async {
    late int assignedId;
    await isar.writeTxn(() async {
      assignedId = await isar.cardItems.put(card);
    });
    return assignedId;
  }

  /// 根据 id 删除卡牌
  Future<void> deleteCard(int id) async {
    await isar.writeTxn(() async {
      await isar.cardItems.delete(id);
    });
  }

  /// 用给定列表整体替换本地卡牌（备份恢复时调用）。
  Future<void> replaceAllCards(List<CardItem> cards) async {
    await isar.writeTxn(() async {
      await isar.cardItems.clear();
      await isar.cardItems.putAll(cards);
    });
  }
}
