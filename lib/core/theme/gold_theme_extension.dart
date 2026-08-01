import 'package:flutter/material.dart';

/// 高奢黑金主题拓展（ThemeExtension）。取代 [AppColors] 的全局可变亮度状态，
/// 将随主题切换的色板收敛为可经 [ThemeData.extensions] 注入、并支持 [lerp]
/// 平滑过渡的响应式配色；组件经 [GoldThemeX.gold]（`context.gold`）读取。
class GoldThemeExtension extends ThemeExtension<GoldThemeExtension> {
  final Color bgDark;
  final Color bgPure;
  final Color bgNav;
  final Color surfaceDark;
  final Color goldPrimary;
  final Color goldDark;
  final Color goldBorder;
  final Color textWhite;
  final Color textMuted;
  final Color textInactive;
  final Color scrim;
  final Color chartBgs;

  const GoldThemeExtension({
    required this.bgDark,
    required this.bgPure,
    required this.bgNav,
    required this.surfaceDark,
    required this.goldPrimary,
    required this.goldDark,
    required this.goldBorder,
    required this.textWhite,
    required this.textMuted,
    required this.textInactive,
    required this.scrim,
    required this.chartBgs,
  });

  @override
  GoldThemeExtension copyWith({
    Color? bgDark, Color? bgPure, Color? bgNav, Color? surfaceDark,
    Color? goldPrimary, Color? goldDark, Color? goldBorder,
    Color? textWhite, Color? textMuted, Color? textInactive,
    Color? scrim, Color? chartBgs,
  }) => GoldThemeExtension(
        bgDark: bgDark ?? this.bgDark,
        bgPure: bgPure ?? this.bgPure,
        bgNav: bgNav ?? this.bgNav,
        surfaceDark: surfaceDark ?? this.surfaceDark,
        goldPrimary: goldPrimary ?? this.goldPrimary,
        goldDark: goldDark ?? this.goldDark,
        goldBorder: goldBorder ?? this.goldBorder,
        textWhite: textWhite ?? this.textWhite,
        textMuted: textMuted ?? this.textMuted,
        textInactive: textInactive ?? this.textInactive,
        scrim: scrim ?? this.scrim,
        chartBgs: chartBgs ?? this.chartBgs,
      );

  @override
  GoldThemeExtension lerp(ThemeExtension<GoldThemeExtension>? other, double t) {
    if (other is! GoldThemeExtension) return this;
    return GoldThemeExtension(
      bgDark: Color.lerp(bgDark, other.bgDark, t)!,
      bgPure: Color.lerp(bgPure, other.bgPure, t)!,
      bgNav: Color.lerp(bgNav, other.bgNav, t)!,
      surfaceDark: Color.lerp(surfaceDark, other.surfaceDark, t)!,
      goldPrimary: Color.lerp(goldPrimary, other.goldPrimary, t)!,
      goldDark: Color.lerp(goldDark, other.goldDark, t)!,
      goldBorder: Color.lerp(goldBorder, other.goldBorder, t)!,
      textWhite: Color.lerp(textWhite, other.textWhite, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textInactive: Color.lerp(textInactive, other.textInactive, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      chartBgs: Color.lerp(chartBgs, other.chartBgs, t)!,
    );
  }

  static const GoldThemeExtension dark = GoldThemeExtension(
    bgDark: Color(0xFF1A1A1A), bgPure: Color(0xFF0E0E0E), bgNav: Color(0xFF181818),
    surfaceDark: Color(0xFF2A2A2A), goldPrimary: Color(0xFFD4AF37),
    goldDark: Color(0xFFB8932E), goldBorder: Color(0x26D4AF37),
    textWhite: Color(0xFFEDEDED), textMuted: Color(0xFF9E9E9E),
    textInactive: Color(0xFF757575), scrim: Color(0xEE121212), chartBgs: Color(0xFF3D3D3D),
  );

  static const GoldThemeExtension light = GoldThemeExtension(
    bgDark: Color(0xFFF8F9FA), bgPure: Color(0xFFFFFFFF), bgNav: Color(0xFFF1F3F5),
    surfaceDark: Color(0xFFFFFFFF), goldPrimary: Color(0xFFD4AF37),
    goldDark: Color(0xFFB8932E), goldBorder: Color(0x26D4AF37),
    textWhite: Color(0xFF1A1A1A), textMuted: Color(0xFF5A5A5A),
    textInactive: Color(0xFF9E9E9E), scrim: Color(0xEEF8F9FA), chartBgs: Color(0xFF2B2B2B),
  );
}

/// 便捷读取当前主题黑金色板，组件内以 `context.gold` 响应式获取配色。
extension GoldThemeX on BuildContext {
  GoldThemeExtension get gold =>
      Theme.of(this).extension<GoldThemeExtension>()!;
}
