import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/card_item.dart';
import '../providers/card_providers.dart';
import '../widgets/asset_banner.dart';
import '../widgets/card_showcase_widget.dart';
import '../widgets/category_card_section.dart';
import '../widgets/category_nav_bar.dart';
import '../widgets/empty_collection.dart';
import '../widgets/grade_pie_chart.dart';

/// 首页下方整体藏品网格，随分类切片全页联动（监听 [categoryFilteredCardsProvider]）。
///
/// 统一处理 loading / error / empty 三态，避免布局塌陷（RULES.md 边界状态硬规）。
class DashboardCollectionGrid extends ConsumerWidget {
  const DashboardCollectionGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CardItem>> asyncCards =
        ref.watch(categoryFilteredCardsProvider);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: asyncCards.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.goldPrimary,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (Object e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text('藏品加载失败',
                  style: TextStyle(color: context.gold.textMuted, fontSize: 13)),
            ),
          ),
          data: (List<CardItem> cards) => cards.isEmpty
              ? const EmptyCollection()
              : CardGrid(cards: cards),
        ),
      ),
    );
  }
}

/// 首页滚动内容（顶部常量化，避免 Sliver 嵌套的 const 分析冲突）。
const List<Widget> _dashboardSlivers = <Widget>[
  SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: CategoryNavBar(),
    ),
  ),
  SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: AssetBanner(),
    ),
  ),
  SliverToBoxAdapter(
    child: CardShowcaseWidget(),
  ),
  SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: GradePieChart(),
    ),
  ),
  DashboardCollectionGrid(),
  SliverToBoxAdapter(child: SizedBox(height: 16)),
];

/// 首页 / Dashboard。
///
/// 信息层级：分类切片 [CategoryNavBar] → 资产大盘 [AssetBanner] →
/// 评级占比 [GradePieChart] → 整体藏品网格 [DashboardCollectionGrid]。
/// 四者均监听 [categoryFilteredCardsProvider]，实现分类切换的全页联动。
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.gold.bgDark,
      appBar: AppBar(
        title: const Text('资产总览'),
        centerTitle: false,
      ),
      body: const CustomScrollView(slivers: _dashboardSlivers),
    );
  }
}
