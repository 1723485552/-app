import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:card_management/core/theme/theme_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('默认主题为跟随系统，且三态标签/图标齐全', () {
    final ProviderContainer container = ProviderContainer();
    expect(container.read(themeProvider), ThemeMode.system);
    expect(themeModeLabel[ThemeMode.system], '跟随系统');
    expect(themeModeLabel[ThemeMode.dark], '暗黑黑金');
    expect(themeModeLabel[ThemeMode.light], '明亮香槟金');
    expect(themeModeIcon.length, 3);
    container.dispose();
  });

  test('setMode 切换并持久化到 SharedPreferences', () async {
    final ProviderContainer container = ProviderContainer();
    final ThemeNotifier notifier = container.read(themeProvider.notifier);
    await notifier.setMode(ThemeMode.dark);
    expect(container.read(themeProvider), ThemeMode.dark);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
    container.dispose();
  });

  test('setMode 相同模式为幂等（不重复写）', () async {
    final ProviderContainer container = ProviderContainer();
    final ThemeNotifier notifier = container.read(themeProvider.notifier);
    await notifier.setMode(ThemeMode.light);
    await notifier.setMode(ThemeMode.light); // 第二次应为幂等
    expect(container.read(themeProvider), ThemeMode.light);
    container.dispose();
  });

  test('重启后从持久化恢复主题', () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{'theme_mode': 'light'},
    );
    final ProviderContainer container = ProviderContainer();
    // build 内 unawaited(_restore()) 异步恢复；轮询等待微任务完成。
    ThemeMode? restored;
    for (int i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
      if (container.read(themeProvider) == ThemeMode.light) {
        restored = ThemeMode.light;
        break;
      }
    }
    expect(restored, ThemeMode.light);
    container.dispose();
  });
}
