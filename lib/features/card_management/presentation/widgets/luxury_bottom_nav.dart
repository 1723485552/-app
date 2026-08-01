import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// 单个导航项的静态描述。
class _NavItem {
  const _NavItem(this.label, this.iconActive, this.iconInactive);

  final String label;
  final IconData iconActive;
  final IconData iconInactive;
}

/// 黑金底部导航栏（中间凹槽容纳悬浮加号，4 个真实 Tab 对称分布）。
///
/// - 纯黑底（`bgNav`）+ 顶部 0.5px 香槟金微边框。
/// - [CircularNotchedRectangle] 平滑下凹弧形槽，与悬浮加号按钮自然融合。
/// - 选中态：图标 + 文字转为香槟金（200ms 平滑过渡）；未选中为灰。
/// - 点击带 [HapticFeedback.lightImpact] 微反馈。
class LuxuryBottomNav extends StatelessWidget {
  const LuxuryBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem('首页', Icons.grid_view_rounded, Icons.grid_view_outlined),
    _NavItem('攒卡', Icons.style_rounded, Icons.style_outlined),
    _NavItem('账单', Icons.receipt_long_rounded, Icons.receipt_long_outlined),
    _NavItem('我的', Icons.person_rounded, Icons.person_outline_rounded),
  ];

  static const double _barHeight = 60.0;
  static const double _fabGap = 48.0;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      elevation: 0,
      color: context.gold.bgNav,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
                color: AppColors.goldPrimary.withValues(alpha: 0.35), width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: _barHeight,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < 2; i++)
                  _NavTab(
                    item: _items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                const SizedBox(width: _fabGap),
                for (int i = 2; i < _items.length; i++)
                  _NavTab(
                    item: _items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 底部导航栏的单个 Tab（图标 + 文案 + 微反馈）。
class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? AppColors.goldPrimary : context.gold.textInactive;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        splashColor: AppColors.goldGlow,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder:
                  (Widget child, Animation<double> animation) =>
                      ScaleTransition(scale: animation, child: child),
              child: Icon(
                selected ? item.iconActive : item.iconInactive,
                key: ValueKey<bool>(selected),
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                height: 1.2,
                letterSpacing: 0.5,
                color: color,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
