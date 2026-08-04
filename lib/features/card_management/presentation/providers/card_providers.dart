import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/card_item.dart';
import '../../domain/enums/card_category.dart';
import '../../domain/repositories/card_repository.dart';

/// 当前选中的卡牌分类（首页分类切片导航的状态源）。
final StateProvider<CardCategory> selectedCategoryProvider =
    StateProvider<CardCategory>((ref) => CardCategory.all);

/// 全量卡牌响应式流（来自本地 SQLite，写入即自动推送刷新，无手动 invalidate）。
///
/// 底层绑定 [CardRepository.watchAll]，由 Drift 的 [AppDatabase.watchAllCards]
/// 原生驱动；增 / 删 / 改 / 恢复（replaceAllCards）均会触发下游 UI 重建。
final StreamProvider<List<CardItem>> allCardsProvider =
    StreamProvider<List<CardItem>>((ref) {
  final CardRepository repo = ref.watch(cardRepositoryProvider);
  return repo.watchAll();
});

/// 按选中分类过滤后的卡牌流（全页联动核心）。
///
/// [AssetBanner] 与 [GradePieChart] 均监听此 Provider，
/// 切换分类时自动重算并驱动各自动画重播。
final Provider<AsyncValue<List<CardItem>>> categoryFilteredCardsProvider =
    Provider<AsyncValue<List<CardItem>>>((ref) {
  final AsyncValue<List<CardItem>> asyncCards =
      ref.watch(allCardsProvider) ?? const AsyncLoading();
  final CardCategory category = ref.watch(selectedCategoryProvider);
  return asyncCards.whenData((List<CardItem> cards) {
    if (category == CardCategory.all) return cards;
    return cards.where((CardItem c) => c.category == category).toList();
  });
});
