import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_menu_list.dart';

/// 我的 / Profile。
///
/// 顶部黑金高奢个人 Header，下方为数据管理 / 偏好设置 / 关于 三大菜单分区，
/// 全部通过 Riverpod 真实联动（指标、货币、主题、导出备份恢复）。
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.gold.bgDark,
      appBar: AppBar(
        backgroundColor: context.gold.bgDark,
        elevation: 0,
        centerTitle: false,
        title: Text(
          '我的',
          style: TextStyle(
            color: context.gold.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          ProfileHeader(),
          SizedBox(height: 16),
          ProfileMenuList(),
        ],
      ),
    );
  }
}
