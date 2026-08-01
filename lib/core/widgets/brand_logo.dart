import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import '../../core/theme/app_colors.dart';

/// 品牌 Logo 组件（黑金描边 / 圆角）。
///
/// 统一加载 [assets/images/app_logo.png]，资产缺失或解码失败时回退为金色矢量图标，
/// 防止旧包 / 未注册资源导致崩溃（Null Guard）。
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 36, this.bordered = true});

  final double size;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      'assets/images/app_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (BuildContext _, Object __, StackTrace? ___) => Icon(
        Icons.diamond_outlined,
        color: AppColors.goldPrimary,
        size: size * 0.6,
      ),
    );
    if (!bordered) return image;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.gold.surfaceDark,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: image,
      ),
    );
  }
}
