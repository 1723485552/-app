import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:card_management/core/theme/app_colors.dart';
import 'package:card_management/core/widgets/gold_snack_bar.dart';
import 'package:card_management/services/cloud_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_menu_list.dart';
import '../widgets/network_probe_debug.dart';

/// 我的 / Profile。
///
/// 顶部黑金高奢个人 Header，下方为数据管理 / 偏好设置 / 关于 三大菜单分区，
/// 全部通过 Riverpod 真实联动（指标、货币、主题、导出备份恢复）。
/// 末尾追加独立的「数据云端备份」卡片（Supabase 备份 / 恢复入口）。
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
          NetworkProbeDebug(),
          SizedBox(height: 16),
          CloudBackupCard(),
        ],
      ),
    );
  }
}

/// 数据云端备份卡片：包含「立即备份」与「从云端恢复」两个入口。
///
/// - 备份：静默执行，完成后 Toast 提示。
/// - 恢复：覆盖本地数据，先弹二次确认弹窗，确认后方可执行。
class CloudBackupCard extends ConsumerWidget {
  const CloudBackupCard({super.key});

  static const String _title = '数据云端备份';

  Future<void> _backup(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await uploadBackup();
      GoldSnackBar.showOn(messenger, '已备份到云端');
    } catch (e) {
      GoldSnackBar.showOn(messenger, '备份失败：$e');
    }
  }

  Future<void> _restore(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: context.gold.surfaceDark,
        title: Text('确认从云端恢复？',
            style: TextStyle(color: context.gold.textWhite)),
        content: Text(
          '恢复操作将覆盖当前本地数据，是否继续？',
          style: TextStyle(color: context.gold.textMuted, fontSize: 13),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('取消',
                style: TextStyle(color: context.gold.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('继续',
                style: TextStyle(color: AppColors.goldPrimary)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await restoreBackup();
      GoldSnackBar.showOn(messenger, '已从云端恢复，请重启应用生效');
    } catch (e) {
      GoldSnackBar.showOn(messenger, '恢复失败：$e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.gold.surfaceDark,
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_title,
                style: TextStyle(
                  color: context.gold.textMuted,
                  fontSize: 12,
                  letterSpacing: 1,
                )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _backup(context),
                icon: const Icon(Icons.cloud_upload_outlined,
                    color: AppColors.goldPrimary, size: 18),
                label: const Text('立即备份到云端',
                    style: TextStyle(color: AppColors.goldPrimary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.goldBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _restore(context),
                icon: const Icon(Icons.cloud_download_outlined,
                    color: AppColors.goldPrimary, size: 18),
                label: Text('从云端恢复备份',
                    style: TextStyle(color: context.gold.textWhite)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.goldBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
