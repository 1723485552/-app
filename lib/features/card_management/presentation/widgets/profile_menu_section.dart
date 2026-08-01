import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import '../../../../core/theme/app_colors.dart';

/// 个人中心菜单分组卡片（标题 + 一组菜单行）。
class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.gold.surfaceDark,
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                color: context.gold.textMuted,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
