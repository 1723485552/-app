import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_logo.dart';

/// 大厂 Style 关于弹窗，仅展示版本信息。
class ProfileAboutDialog extends StatelessWidget {
  const ProfileAboutDialog({
    super.key,
    required this.version,
  });

  final String version;

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
              '版本 $version',
              style: TextStyle(color: context.gold.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
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
