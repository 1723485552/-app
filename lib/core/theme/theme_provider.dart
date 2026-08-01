import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 三态主题（跟随系统 / 暗黑黑金 / 明亮香槟金）Riverpod 状态管理。
///
/// 经 [SharedPreferences] 持久化用户选择，应用重启后自动恢复，
/// 并与根 [MaterialApp.themeMode] 双向绑定，切换即时生效、无毁树重建。
final NotifierProvider<ThemeNotifier, ThemeMode> themeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _prefsKey = 'theme_mode';

  @override
  ThemeMode build() {
    // 同步返回默认，异步从持久化恢复（restore 后自动通知监听者刷新 UI）。
    unawaited(_restore());
    return ThemeMode.system;
  }

  Future<void> _restore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? stored = prefs.getString(_prefsKey);
    if (stored == null) return;
    state = ThemeMode.values.firstWhere(
      (ThemeMode m) => m.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  /// 切换并持久化主题模式。
  Future<void> setMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}

/// 主题模式 → 中文展示名。
const Map<ThemeMode, String> themeModeLabel = <ThemeMode, String>{
  ThemeMode.system: '跟随系统',
  ThemeMode.dark: '暗黑黑金',
  ThemeMode.light: '明亮香槟金',
};

/// 主题模式 → 黑金高奢图标。
const Map<ThemeMode, IconData> themeModeIcon = <ThemeMode, IconData>{
  ThemeMode.system: Icons.brightness_auto_outlined,
  ThemeMode.dark: Icons.dark_mode_outlined,
  ThemeMode.light: Icons.light_mode_outlined,
};
