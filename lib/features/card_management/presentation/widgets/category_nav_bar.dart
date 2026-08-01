import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/enums/card_category.dart';
import '../helpers/card_meta.dart';
import '../providers/card_providers.dart';

/// 首页顶部分类切片导航栏。
///
/// 统一采用 Outlined 矢量图标（禁止默认 Emoji）；选中切片显示香槟金高亮 +
/// 0.5px 香槟金微边框，并以 200ms 平滑过渡；点击带 Haptic 微反馈。
class CategoryNavBar extends ConsumerWidget {
  const CategoryNavBar({super.key});

  static const double _chipHeight = 40.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CardCategory selected = ref.watch(selectedCategoryProvider);
    return SizedBox(
      height: _chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: CardCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final CardCategory category = CardCategory.values[index];
          final bool isSelected = category == selected;
          return _CategoryChip(
            category: category,
            selected: isSelected,
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(selectedCategoryProvider.notifier).state = category;
            },
          );
        },
      ),
    );
  }
}

/// 分类切片单颗 Chip（图标 + 文案 + 微交互）。
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final CardCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? AppColors.goldPrimary : context.gold.textInactive;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected ? AppColors.goldGlow : context.gold.surfaceDark,
        border: Border.all(
          color: selected ? AppColors.goldPrimary : AppColors.goldBorder,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                Icon(cardCategoryIcon(category), size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  cardCategoryLabel(category),
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
