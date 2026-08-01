import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:card_management/main.dart';

void main() {
  testWidgets('应用可启动并渲染黑金底部导航栏', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CardManagementApp()));
    await tester.pumpAndSettle();

    // 根 MaterialApp 与四个黑金导航 Tab 应存在。
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('攒卡'), findsOneWidget);
    expect(find.text('账单'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
  });
}
