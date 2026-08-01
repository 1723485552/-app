import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/card_item.dart';
import '../../domain/enums/collection_tab.dart';
import '../providers/card_providers.dart';
import '../providers/collection_providers.dart';

/// 攒卡页双 Tab 分段控件：已收集 / 心愿单。
///
/// 黑金胶囊容器 + 0.5px 金边；选中态以香槟金微光底色 + 金色图标呈现，
/// 200ms 平滑过渡，点击带 Haptic 微反馈。
class CollectionTabBar extends ConsumerWidget {
  const CollectionTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CollectionTab tab = ref.watch(collectionTabProvider);
    final AsyncValue<List<CardItem>> asyncAll = ref.watch(allCardsProvider);
    int collected = 0, wishlist = 0;
    asyncAll.whenData((List<CardItem> list) {
      collected = list.where((CardItem c) => c.isCollected).length;
      wishlist = list.where((CardItem c) => c.isWishlist).length;
    });
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.gold.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
      ),
      child: Row(
        children: <Widget>[
          _tabButton(context, ref, CollectionTab.collected, tab, '已收集 ($collected)',
              Icons.checkroom_outlined),
          _tabButton(context, ref, CollectionTab.wishlist, tab, '心愿单 ($wishlist)',
              Icons.bookmark_outline_rounded),
        ],
      ),
    );
  }

  Widget _tabButton(BuildContext context, WidgetRef ref, CollectionTab value, CollectionTab current,
      String label, IconData icon) {
    final bool active = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(collectionTabProvider.notifier).state = value;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.goldGlow : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon,
                  size: 18,
                  color: active
                      ? AppColors.goldPrimary
                      : context.gold.textInactive),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? AppColors.goldPrimary
                      : context.gold.textInactive,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
