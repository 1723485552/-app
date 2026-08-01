import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/card_item.dart';
import '../../domain/enums/currency_unit.dart';
import '../providers/card_providers.dart';

/// 偏好：货币单位（CNY ¥ / USD $），切换后全页资产估值实时联动。
final StateProvider<CurrencyUnit> profileCurrencyProvider =
    StateProvider<CurrencyUnit>((ref) => CurrencyUnit.cny);

/// 个人收藏生涯核心指标（由 [allCardsProvider] 真实派生，非硬编码）。
class ProfileStats {
  const ProfileStats({
    required this.collectedCount,
    required this.totalCards,
    required this.daysSinceFirst,
    required this.maxReturnPct,
    required this.totalAssetValue,
  });

  final int collectedCount;
  final int totalCards;
  final int daysSinceFirst;
  final double maxReturnPct;
  final double totalAssetValue;

  /// 资产总称号（按已收集卡牌总估值分档）。
  String get title {
    if (totalAssetValue < 1500) return '初级黑金收藏家';
    if (totalAssetValue < 3000) return '中级黑金收藏家';
    return '特级黑金收藏家';
  }
}

/// 由全量卡牌实时计算个人指标，切换货币/数据变更时随 [allCardsProvider] 自动刷新。
final Provider<AsyncValue<ProfileStats>> profileStatsProvider =
    Provider<AsyncValue<ProfileStats>>((ref) {
  final AsyncValue<List<CardItem>> asyncCards = ref.watch(allCardsProvider);
  return asyncCards.whenData((List<CardItem> cards) {
    if (cards.isEmpty) {
      return const ProfileStats(
        collectedCount: 0,
        totalCards: 0,
        daysSinceFirst: 0,
        maxReturnPct: 0,
        totalAssetValue: 0,
      );
    }
    final List<CardItem> collected =
        cards.where((CardItem c) => c.isCollected).toList();
    final double asset =
        collected.fold<double>(0, (double s, CardItem c) => s + c.marketPrice);
    final DateTime firstBuy = cards
        .map((CardItem c) => c.buyDate)
        .reduce((DateTime a, DateTime b) => a.isBefore(b) ? a : b);
    final double maxPct = cards
        .map((CardItem c) => c.profitPercentage)
        .reduce((double a, double b) => a > b ? a : b);
    return ProfileStats(
      collectedCount: collected.length,
      totalCards: cards.length,
      daysSinceFirst: DateTime.now().difference(firstBuy).inDays,
      maxReturnPct: maxPct,
      totalAssetValue: asset,
    );
  });
});
