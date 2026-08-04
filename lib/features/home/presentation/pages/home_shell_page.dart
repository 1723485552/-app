import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:card_management/core/theme/app_colors.dart';
import 'master_catalog_view.dart';
import 'my_binder_view.dart';

/// 首页双视图壳层：在“我的卡盒”和“全网图鉴”之间切换。
class HomeShellPage extends ConsumerStatefulWidget {
  const HomeShellPage({super.key});

  @override
  ConsumerState<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends ConsumerState<HomeShellPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gold.bgDark,
      appBar: AppBar(
        backgroundColor: context.gold.bgDark,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 8, right: 16),
          child: _SegmentedToggle(
            value: _tabIndex,
            onChanged: (int value) => setState(() => _tabIndex = value),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: const <Widget>[
          MyBinderView(),
          MasterCatalogView(),
        ],
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<_ToggleOption> options = <_ToggleOption>[
      const _ToggleOption(label: '我的卡盒', value: 0),
      const _ToggleOption(label: '图鉴/探索', value: 1),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.gold.bgPure,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final bool selected = option.value == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.goldPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  option.label,
                  style: TextStyle(
                    color: selected ? context.gold.bgDark : context.gold.textMuted,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ToggleOption {
  const _ToggleOption({required this.label, required this.value});
  final String label;
  final int value;
}
