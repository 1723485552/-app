import '../models/card_item.dart';

/// Web 端内存存储（Isar 3.x 已移除 Web 支持，预览时以内存列表替代持久化）。
final List<CardItem> _webCards = <CardItem>[];
int _webNextId = 1;

/// 初始化数据库（Web 端：无持久化，仅占位以满足原生端调用契约）。
Future<void> initCardDatabase() async {}

/// 卡牌本地数据操作服务（Web 端：封装内存列表）。
class CardLocalDatasource {
  /// 查询所有卡牌
  Future<List<CardItem>> getAllCards() =>
      Future<List<CardItem>>.value(<CardItem>[..._webCards]);

  /// 写入或更新一张卡牌
  Future<void> saveCard(CardItem card) async {
    final int i = _webCards.indexWhere((CardItem c) => c.id == card.id);
    if (i >= 0) {
      _webCards[i] = card;
    } else {
      card.id = _webNextId++;
      _webCards.add(card);
    }
  }

  /// 根据 id 删除卡牌
  Future<void> deleteCard(int id) async {
    _webCards.removeWhere((CardItem c) => c.id == id);
  }

  /// 用给定列表整体替换内存卡牌（备份恢复时调用）。
  Future<void> replaceAllCards(List<CardItem> cards) async {
    _webCards.clear();
    for (final CardItem m in cards) {
      final CardItem c = m.copyWith();
      c.id = _webNextId++;
      _webCards.add(c);
    }
  }
}
