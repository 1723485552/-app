import 'package:flutter/material.dart';

import 'gold_theme_extension.dart';

/// 应用全局主题。
///
/// 严格贯彻 RULES.md 的「黑金暗黑调色板」硬规：纯黑背景 + 香槟金点缀，
/// 禁止任何大面积金色填充与粗重实线。
///
/// 提供 [dark]（暗黑黑金）与 [light]（明亮香槟金）双主题；亮度相关色直接取自
/// [GoldThemeExtension] 静态实例，并经 [ThemeData.extensions] 注入主题树。
/// 切换 [ThemeMode] 时由 Flutter 自动重建主题子树，[ThemeExtension.lerp]
/// 驱动背景 / 文字 / 表面色平滑过渡，实现零毁树的原生级无缝换肤。
class AppTheme {
  AppTheme._();

  /// 暗色主题：深邃黑金风格。
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GoldThemeExtension.dark.bgDark,
        colorScheme: ColorScheme.dark(
          surface: GoldThemeExtension.dark.surfaceDark,
          primary: GoldThemeExtension.dark.goldPrimary,
        ),
        extensions: const <ThemeExtension<dynamic>>[GoldThemeExtension.dark],
        appBarTheme: AppBarTheme(
          backgroundColor: GoldThemeExtension.dark.bgDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: GoldThemeExtension.dark.goldPrimary),
          titleTextStyle: TextStyle(
            color: GoldThemeExtension.dark.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        dividerTheme: DividerThemeData(
          color: GoldThemeExtension.dark.goldBorder,
          thickness: 0.5,
          space: 0,
        ),
      );

  /// 亮色主题：明亮香槟金风格（强光高对比度白金）。
  ///
  /// 背景近白 0xFFF8F9FA，卡片纯白 0xFFFFFFFF 配 0.5px 香槟金微边框，
  /// 主文字深近黑 0xFF1A1A1A 保证强光下高对比易读，点缀色保留香槟金。
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: GoldThemeExtension.light.bgDark,
        colorScheme: ColorScheme.light(
          surface: GoldThemeExtension.light.surfaceDark,
          primary: GoldThemeExtension.light.goldPrimary,
          onPrimary: GoldThemeExtension.light.bgPure,
          onSurface: GoldThemeExtension.light.textWhite,
        ),
        extensions: const <ThemeExtension<dynamic>>[GoldThemeExtension.light],
        appBarTheme: AppBarTheme(
          backgroundColor: GoldThemeExtension.light.bgDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: GoldThemeExtension.light.goldPrimary),
          titleTextStyle: TextStyle(
            color: GoldThemeExtension.light.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        dividerTheme: DividerThemeData(
          color: GoldThemeExtension.light.goldBorder,
          thickness: 0.5,
          space: 0,
        ),
      );
}
