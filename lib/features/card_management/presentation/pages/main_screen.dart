import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:card_management/core/theme/app_colors.dart';
import '../providers/nav_providers.dart';
import '../widgets/luxury_bottom_nav.dart';
import '../widgets/add_card_sheet.dart';
import '../widgets/add_wishlist_sheet.dart';
import '../widgets/manual_add_card_sheet.dart';
import '../widgets/scan_add_card_dialog.dart';
import 'card_collection_page.dart';
import 'dashboard_page.dart';
import 'ledger_view.dart';
import 'profile_page.dart';

/// 应用主壳：承载四个分页 + 黑金底部导航栏 + 中间悬浮加号按钮。
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    CardCollectionPage(),
    LedgerView(),
    ProfilePage(),
  ];

  /// 打开加号快捷弹层，按枚举返回值路由到对应业务弹窗。
  ///
  /// 采用 await 接收 [QuickActionType] 的枚举解耦模式：弹层关闭、上下文
  /// 完全安全后再拉起业务弹窗，彻底规避嵌套弹窗的 [BuildContext] 竞态。
  Future<void> _openQuickMenu(BuildContext context) async {
    final QuickActionType? action = await showAddCardSheet(context);
    if (!context.mounted || action == null) return;
    switch (action) {
      case QuickActionType.ocr:
        showScanAddCardDialog(context);
      case QuickActionType.addCard:
        showManualAddCardSheet(context);
      case QuickActionType.addWishlist:
        showAddWishlistSheet(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int index = ref.watch(navIndexProvider);
    return Scaffold(
      backgroundColor: context.gold.bgDark,
      body: IndexedStack(
        index: index,
        children: _pages,
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _openQuickMenu(context);
          },
          elevation: 4,
          backgroundColor: AppColors.goldPrimary,
          splashColor: context.gold.bgDark.withValues(alpha: 0.25),
          shape: const CircleBorder(),
          child: Icon(Icons.add_rounded,
              color: context.gold.bgDark, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: LuxuryBottomNav(
        currentIndex: index,
        onTap: (int i) => ref.read(navIndexProvider.notifier).state = i,
      ),
    );
  }
}
