import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/card_item.dart';
import '../../domain/enums/card_category.dart';
import '../helpers/card_meta.dart';
import 'card_tile.dart';

/// 折叠卡牌网格：按分类分组，支持平滑展开 / 收起。
///
/// 头部显示分类图标 + 文案 + 数量徽标 + 展开态图标；主体为 [CardGrid]，
/// 通过 [AnimatedSize] 实现 250ms 平滑过渡，避免生硬跳变（RULES.md 微交互硬规）。
class CategoryCardSection extends ConsumerStatefulWidget {
  const CategoryCardSection({
    super.key,
    required this.category,
    required this.cards,
  });

  final CardCategory category;
  final List<CardItem> cards;

  @override
  ConsumerState<CategoryCardSection> createState() =>
      _CategoryCardSectionState();
}

class _CategoryCardSectionState extends ConsumerState<CategoryCardSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: context.gold.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
      ),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _expanded = !_expanded);
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: <Widget>[
                  Icon(cardCategoryIcon(widget.category),
                      size: 20, color: AppColors.goldPrimary),
                  const SizedBox(width: 10),
                  Text(cardCategoryLabel(widget.category),
                      style: TextStyle(
                          color: context.gold.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.goldGlow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${widget.cards.length}',
                        style: const TextStyle(
                            color: AppColors.goldPrimary, fontSize: 11)),
                  ),
                  const Spacer(),
                  Icon(
                      _expanded
                          ? Icons.expand_less_outlined
                          : Icons.expand_more_outlined,
                      color: context.gold.textMuted,
                      size: 22),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: CardGrid(cards: widget.cards),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// 卡牌网格（3 列紧凑微型贴纸框，自适应父级高度，禁止内部滚动）。
class CardGrid extends StatelessWidget {
  const CardGrid({super.key, required this.cards});

  final List<CardItem> cards;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.66,
      ),
      itemCount: cards.length,
      itemBuilder: (BuildContext ctx, int i) =>
          CardTile(cards: cards, index: i),
    );
  }
}
