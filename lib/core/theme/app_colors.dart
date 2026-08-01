import 'package:flutter/material.dart';

/// 卡牌资产 App 静态黑金调色板（无状态 Theme Token System）。
///
/// 仅保留**跨主题恒定**的品牌色（金色系 / 涨跌 / 图表专属 / 按钮渐变）。
/// 随主题切换的「亮度相关色」已迁移至 [GoldThemeExtension]，由主题响应式注入，
/// 彻底消除原有 [setBrightness] 全局可变状态。组件如需亮度相关色，
/// 请使用 `Theme.of(context).extension<GoldThemeExtension>()!.xxx` 或 `context.gold`。
class AppColors {
  AppColors._();

  /// 香槟金 / 高奢金（选中态、高亮、细微边框点缀色），跨主题恒定。
  static const Color goldPrimary = Color(0xFFD4AF37);

  /// 深金（金色暗一档，用于渐变收尾与按压态），跨主题恒定。
  static const Color goldDark = Color(0xFFB8932E);

  /// 0.5px 香槟金微边框（等价 Color(0xFFD4AF37).withOpacity(0.15)），恒定。
  static const Color goldBorder = Color(0x26D4AF37);

  /// 香槟金发光 / 微交互底色（等价 withOpacity(0.30)），恒定。
  static const Color goldGlow = Color(0x4DD4AF37);

  /// 涨幅红（中国市场惯例：涨为红，用于行情榜与盈亏展示），恒定。
  static const Color trendUp = Color(0xFFE25C5C);

  /// 跌幅绿（中国市场惯例：跌为绿，用于行情榜与盈亏展示），恒定。
  static const Color trendDown = Color(0xFF4CAF7D);

  /// 饼图百分比徽标底（跨主题恒定的暗色半透明，香槟黑金家族 0xFF242424）。
  static const Color chartBadgeBg = Color(0xCC242424);

  /// 饼图百分比徽标文字：恒定纯白加粗。
  static const Color chartBadgeText = Color(0xFFFFFFFF);

  /// 饼图评级专属 CGC 高奢钛银蓝。
  static const Color chartCgc = Color(0xFF4A6FA5);

  /// 裸卡 极简高灰。
  static const Color chartRaw = Color(0xFF8D99AE);

  /// 加号按钮渐变：上 0xFF242424 -> 下 0xFF121212（黑金微渐变悬浮质感）。
  static const Color addBtnTop = Color(0xFF242424);
  static const Color addBtnBottom = Color(0xFF121212);
}
