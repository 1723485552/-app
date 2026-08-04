import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/card_item.dart';
import '../../domain/enums/collection_tab.dart';
import '../../domain/enums/grading_company.dart';
import '../providers/card_providers.dart';

/// 攒卡页当前 Tab（心愿单 / 已收集）。
final StateProvider<CollectionTab> collectionTabProvider =
    StateProvider<CollectionTab>((ref) => CollectionTab.collected);

/// 搜卡关键词（实时联动全页卡牌数据源）。
final StateProvider<String> cardSearchQueryProvider =
    StateProvider<String>((ref) => '');

/// 评级筛选（null = 全部；否则限定 PSA / BGS / CGC）。
final StateProvider<GradingCompany?> cardGradingFilterProvider =
    StateProvider<GradingCompany?>((ref) => null);

/// 按 Tab + 搜索 + 评级筛选后的卡牌流（攒卡页核心联动）。
///
/// 复用 [allCardsProvider] 作为唯一数据源，避免重复拉取；
/// 切换 Tab / 输入关键词 / 切换评级时自动重算并驱动列表刷新。
final Provider<AsyncValue<List<CardItem>>> filteredCollectionProvider =
    Provider<AsyncValue<List<CardItem>>>((ref) {
  final AsyncValue<List<CardItem>> asyncCards =
      ref.watch(allCardsProvider) ?? const AsyncLoading();
  final CollectionTab tab = ref.watch(collectionTabProvider);
  final String query = ref.watch(cardSearchQueryProvider).trim().toLowerCase();
  final GradingCompany? grading = ref.watch(cardGradingFilterProvider);
  return asyncCards.whenData((List<CardItem> cards) {
    return cards.where((CardItem c) {
      if (tab == CollectionTab.collected) {
        if (!c.isCollected) return false;
      } else {
        if (!c.isWishlist) return false;
      }
      if (grading != null && c.grading != grading) return false;
      if (query.isNotEmpty && !c.cardName.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
  });
});
