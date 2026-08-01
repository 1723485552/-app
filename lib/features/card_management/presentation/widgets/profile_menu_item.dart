import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// 个人中心菜单单行（统一 Outlined 矢量图标 + 0.5px 金边微交互）。
///
/// [trailing] 用于承载开关 / 取值等控件；[divider] 为 true 时在上方绘制极细金线分隔。
class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.divider = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool divider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget row = InkWell(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      splashColor: AppColors.goldGlow,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 22, color: AppColors.goldPrimary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: context.gold.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          color: context.gold.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );

    if (!divider) return row;
    return Column(
      children: <Widget>[
        const Divider(
          height: 1,
          thickness: 0.5,
          indent: 54,
          endIndent: 0,
          color: AppColors.goldBorder,
        ),
        row,
      ],
    );
  }
}
