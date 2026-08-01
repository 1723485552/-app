import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/card_item.dart';
import '../../domain/enums/card_category.dart';
import '../../domain/repositories/card_repository.dart';

/// 当前选中的卡牌分类（首页分类切片导航的状态源）。
final StateProvider<CardCategory> selectedCategoryProvider =
    StateProvider<CardCategory>((ref) => CardCategory.all);

/// 全量卡牌（来自本地数据源，首次进入为空，不注入任何 Mock 数据）。
final FutureProvider<List<CardItem>> allCardsProvider =
    FutureProvider<List<CardItem>>((ref) async {
  final CardRepository repo = ref.read(cardRepositoryProvider);
  return repo.getAllCards();
});

/// 按选中分类过滤后的卡牌流（全页联动核心）。
///
/// [AssetBanner] 与 [GradePieChart] 均监听此 Provider，
/// 切换分类时自动重算并驱动各自动画重播。
final Provider<AsyncValue<List<CardItem>>> categoryFilteredCardsProvider =
    Provider<AsyncValue<List<CardItem>>>((ref) {
  final AsyncValue<List<CardItem>> asyncCards = ref.watch(allCardsProvider);
  final CardCategory category = ref.watch(selectedCategoryProvider);
  return asyncCards.whenData((List<CardItem> cards) {
    if (category == CardCategory.all) return cards;
    return cards.where((CardItem c) => c.category == category).toList();
  });
});
