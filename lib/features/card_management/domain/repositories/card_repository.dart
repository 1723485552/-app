import 'dart:async';

import '../../data/models/card_item.dart';

export 'card_repository_provider.dart';

/// 卡牌数据仓库抽象（Clean Architecture 领域层）。
///
/// 解耦 UI 与具体持久化实现（Isar 原生 / 内存 Web），统一 CRUD、查询与监听流。
/// 通过 [cardRepositoryProvider] 注入具体实现，杜绝 Widget 直接 new 数据源。
abstract class CardRepository {
  /// 查询全部卡牌。
  Future<List<CardItem>> getAllCards();

  /// 新增或覆盖写入一张卡牌（按 id 主键）。
  Future<void> saveCard(CardItem card);

  /// 更新已有卡牌（语义化显式更新，内部等价于覆盖写入）。
  Future<void> updateCard(CardItem card);

  /// 按 id 删除卡牌。
  Future<void> deleteCard(int id);

  /// 整体替换全量卡牌（备份恢复用）。
  Future<void> replaceAllCards(List<CardItem> cards);

  /// 监听全量卡牌变化流（实时联动 UI）。
  Stream<List<CardItem>> watchAll();
}
