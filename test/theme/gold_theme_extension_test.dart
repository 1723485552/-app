import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:card_management/core/theme/gold_theme_extension.dart';

void main() {
  group('GoldThemeExtension 数据类与静态实例', () {
    test('dark / light 静态实例关键色板正确', () {
      expect(GoldThemeExtension.dark.bgDark, const Color(0xFF1A1A1A));
      expect(GoldThemeExtension.dark.goldPrimary, const Color(0xFFD4AF37));
      expect(GoldThemeExtension.light.bgDark, const Color(0xFFF8F9FA));
      expect(GoldThemeExtension.light.goldPrimary, const Color(0xFFD4AF37));
    });

    test('copyWith 仅覆盖传入字段，其余保持原值', () {
      const GoldThemeExtension base = GoldThemeExtension.dark;
      const Color overridden = Color(0xFFFF0000);
      final GoldThemeExtension next = base.copyWith(goldPrimary: overridden);
      expect(next.goldPrimary, overridden);
      expect(next.bgDark, base.bgDark);
      expect(next.textWhite, base.textWhite);
    });

    test('lerp t=0/t=1 收敛于端点，t=0.5 处于中间', () {
      const GoldThemeExtension a = GoldThemeExtension.dark;
      const GoldThemeExtension b = GoldThemeExtension.light;
      expect(a.lerp(b, 0).bgDark, a.bgDark);
      expect(a.lerp(b, 1).bgDark, b.bgDark);
      final GoldThemeExtension mid = a.lerp(b, 0.5);
      expect(mid.bgDark, isNot(equals(a.bgDark)));
      expect(mid.bgDark, isNot(equals(b.bgDark)));
    });

    test('lerp 对 null other 安全返回 this', () {
      const GoldThemeExtension a = GoldThemeExtension.dark;
      expect(a.lerp(null, 0.5), same(a));
    });
  });

  group('context.gold 扩展读取', () {
    testWidgets('带 extension 的 ThemeData 下可读出黑金色板', (
      WidgetTester tester,
    ) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[GoldThemeExtension.dark],
          ),
          home: Builder(
            builder: (BuildContext context) {
              captured = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      final GoldThemeExtension gold = captured.gold;
      expect(gold, isA<GoldThemeExtension>());
      expect(gold.goldPrimary, const Color(0xFFD4AF37));
    });
  });
}
