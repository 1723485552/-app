import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_logo.dart';

/// 大厂 Style 关于弹窗（含版本号与 RULES.md 规范说明）。
class ProfileAboutDialog extends StatelessWidget {
  const ProfileAboutDialog({super.key});

  static const String _version = 'v0.1.0 (1)';
  static const List<String> _rules = <String>[
    '简洁而不简单：极简视觉 + 8dp 网格 + 细腻微交互',
    '防偷懒架构：Clean Architecture 拆分 + 真实 Riverpod 联动',
    '静态零容忍：dart analyze 0 Error / 0 Warning / 0 Info',
    '强制 QA 自查：每次交付附《QA 严格自我验收清单》',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.gold.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.goldBorder, width: 0.5),
      ),
      title: Row(
        children: <Widget>[
          const Icon(Icons.verified_user_outlined,
              color: AppColors.goldPrimary, size: 22),
          const SizedBox(width: 10),
          Text(
            '关于卡牌资产',
            style: TextStyle(
              color: context.gold.textWhite,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Center(child: BrandLogo(size: 64)),
            const SizedBox(height: 12),
            const Text(
              '卡牌资产 · Card Collector',
              style: TextStyle(
                color: AppColors.goldPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '版本 $_version',
              style: TextStyle(color: context.gold.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text(
              '开发规范（RULES.md）',
              style: TextStyle(
                color: context.gold.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            for (final String r in _rules)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('· ',
                        style: TextStyle(
                            color: AppColors.goldPrimary, fontSize: 13)),
                    Expanded(
                      child: Text(
                        r,
                        style: TextStyle(
                          color: context.gold.textMuted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            '知道了',
            style: TextStyle(color: AppColors.goldPrimary, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
