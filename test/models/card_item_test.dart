import 'package:flutter_test/flutter_test.dart';

import 'package:card_management/features/card_management/data/models/card_item_native.dart';
import 'package:card_management/features/card_management/presentation/widgets/price_trend_chart.dart';

/// Isar 模型数据转换与派生值单测（纯 Dart，无需打开 Isar 实例）。
///
/// 覆盖三个维度：
/// 1. [CardItem] 的派生 getter（profit / profitPercentage）—— 运行期计算、不持久化。
/// 2. [CardItem.copyWith] 的字段级覆盖语义（含 id 独立覆盖）。
/// 3. [parsePriceHistory] 的 JSON ↔ 裸 double 数组转换（空 / 非法 / 非数组 Null Guard）。
void main() {
  group('CardItem 派生数据与转换', () {
    final CardItem base = CardItem(
      cardName: 'Pikachu',
      cardNumber: '001',
      imageUrl: 'https://example.com/p.png',
      buyPrice: 100,
      marketPrice: 150,
      buyDate: DateTime(2026, 1, 1),
    );

    test('profit = marketPrice - buyPrice（亏损为负）', () {
      expect(base.profit, 50);
      final CardItem loss = base.copyWith(marketPrice: 80);
      expect(loss.profit, -20);
    });

    test('profitPercentage = profit / buyPrice * 100；buyPrice=0 安全返回 0', () {
      expect(base.profitPercentage, 50);
      final CardItem zero = base.copyWith(buyPrice: 0, marketPrice: 10);
      expect(zero.profitPercentage, 0.0);
    });

    test('copyWith 仅覆盖传入字段，id 可独立覆盖', () {
      final CardItem next = base.copyWith(cardName: 'Raichu', id: 7);
      expect(next.cardName, 'Raichu'); // 覆盖生效
      expect(next.cardNumber, '001'); // 原值保留
      expect(next.id, 7); // id 独立覆盖生效
      expect(next.buyPrice, 100); // 派生值来源保留
      expect(next.profit, 50);
    });

    test('枚举与可空字段默认值 / 持久化字段正确', () {
      // @Enumerated(EnumType.name) → 以 name 字符串存储。
      expect(base.grading.name, 'raw');
      expect(base.category.name, 'all');
      expect(base.isCollected, isTrue);
      expect(base.isWishlist, isFalse);
      expect(base.priceHistoryJson, '');
      expect(base.targetPrice, isNull);
      expect(base.wishlistPriority, 0);
    });
  });

  group('parsePriceHistory 转换（裸 double 数组 / 空 / 非法）', () {
    test('合法 JSON 数组 → 裸 double 列表', () {
      final List<double> r = parsePriceHistory('[100, 110.5, 120]');
      expect(r, <double>[100, 110.5, 120]);
    });

    test('整型 / 数字统一 toDouble', () {
      final List<double> r = parsePriceHistory('[1, 2, 3]');
      expect(r, <double>[1, 2, 3]);
    });

    test('空串 → 空列表', () {
      expect(parsePriceHistory(''), isEmpty);
    });

    test('非法 JSON → 空列表（不抛）', () {
      expect(parsePriceHistory('not json'), isEmpty);
    });

    test('JSON 非数组（对象）→ 空列表', () {
      expect(parsePriceHistory('{"price": 1}'), isEmpty);
    });

    test('模型 priceHistoryJson 经 parsePriceHistory 往返一致', () {
      final CardItem item = CardItem(
        cardName: 'X',
        cardNumber: '1',
        imageUrl: 'u',
        buyPrice: 1,
        marketPrice: 2,
        buyDate: DateTime(2026),
        priceHistoryJson: '[720.0, 792.0]',
      );
      expect(parsePriceHistory(item.priceHistoryJson), <double>[720, 792]);
    });
  });
}
