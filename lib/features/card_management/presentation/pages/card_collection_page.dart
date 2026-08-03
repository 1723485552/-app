import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/enums/card_category.dart';
import '../../data/models/card_item.dart';
import '../providers/collection_providers.dart';
import '../widgets/card_search_filter_bar.dart';
import '../widgets/category_card_section.dart';
import '../widgets/collection_tab_bar.dart';
import '../widgets/empty_collection.dart';
import 'package:card_management/features/card_catalog/presentation/pages/catalog_center_page.dart';

/// 攒卡 / Card Collection。
///
/// 顶部搜索 + 评级筛选栏，中部双 Tab 分段（已收集 / 心愿单），
/// 主体按分类分组为可折叠的卡牌网格，全部通过 Riverpod 真实联动。
class CardCollectionPage extends ConsumerWidget {
  const CardCollectionPage({super.key});

  static const List<CardCategory> _order = <CardCategory>[
    CardCategory.pokemon,
    CardCategory.onePiece,
    CardCategory.yugioh,
    CardCategory.sportsOther,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CardItem>> asyncCards =
        ref.watch(filteredCollectionProvider);
    return Scaffold(
      backgroundColor: context.gold.bgDark,
      appBar: AppBar(
        backgroundColor: context.gold.bgDark,
        elevation: 0,
        title: Text('攒卡',
            style: TextStyle(
                color: context.gold.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            tooltip: '全图鉴',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CatalogCenterPage(),
              ),
            ),
            icon: Icon(Icons.auto_awesome_mosaic_outlined,
                color: context.gold.textWhite, size: 22),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const CardSearchFilterBar(),
          const CollectionTabBar(),
          Expanded(
            child: asyncCards.when(
              loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.goldPrimary)),
              error: (_, __) => _emptyState(context, '加载失败', Icons.cloud_off_outlined),
              data: (List<CardItem> cards) {
                if (cards.isEmpty) {
                  return const EmptyCollection();
                }
                final Map<CardCategory, List<CardItem>> grouped =
                    <CardCategory, List<CardItem>>{};
                for (final CardItem c in cards) {
                  grouped.putIfAbsent(c.category, () => <CardItem>[]).add(c);
                }
                final List<Widget> sections = _order
                    .where((CardCategory cat) => grouped.containsKey(cat))
                    .map((CardCategory cat) =>
                        CategoryCardSection(category: cat, cards: grouped[cat]!))
                    .toList();
                return ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: sections,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 48, color: context.gold.textInactive),
          const SizedBox(height: 12),
          Text(text,
              style: TextStyle(color: context.gold.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}
