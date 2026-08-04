import 'package:flutter/material.dart';

import 'package:card_management/features/card_management/presentation/pages/dashboard_page.dart';

/// 首页“我的卡盒”视图：保留现有资产总览布局与数据源。
class MyBinderView extends StatelessWidget {
  const MyBinderView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPage(showAppBar: false, showToggle: false);
  }
}
