import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import 'package:card_management/core/theme/theme_provider.dart';
import '../../../../core/widgets/gold_snack_bar.dart';
import '../../domain/enums/currency_unit.dart';
import '../../data/models/card_item.dart';
import '../../data/services/profile_service.dart';
import '../providers/card_providers.dart';
import '../providers/profile_providers.dart';
import './profile_about_dialog.dart';
import './profile_menu_item.dart';
import './profile_menu_section.dart';
import './theme_mode_sheet.dart';
import '../../../../features/backup/data_backup_service.dart';
import '../../../../features/backup/confirm_danger_dialog.dart';
import '../../../../screens/card_search_screen.dart';

/// 个人中心快捷功能与资产工具列表。
///
/// 数据管理（导出 / 备份 / 恢复）真实调用 [ProfileService]；
/// 偏好设置（主题微调 / 货币单位）联动 Riverpod Provider 全页生效；
/// 关于弹窗展示版本号与 RULES.md 规范说明。
class ProfileMenuList extends ConsumerStatefulWidget {
  const ProfileMenuList({super.key});

  @override
  ConsumerState<ProfileMenuList> createState() => _ProfileMenuListState();
}

class _ProfileMenuListState extends ConsumerState<ProfileMenuList> {
  @override
  Widget build(BuildContext context) {
    final CurrencyUnit unit = ref.watch(profileCurrencyProvider);
    final ThemeMode themeMode = ref.watch(themeProvider);

    return Column(
      children: <Widget>[
        ProfileMenuSection(
          title: '数据管理',
          children: <Widget>[
            ProfileMenuItem(
              icon: Icons.file_download_outlined,
              title: '导出资产账单 CSV',
              subtitle: '导出全部卡牌资产明细',
              onTap: () => _onExportCsv(context),
            ),
            ProfileMenuItem(
              icon: Icons.backup_outlined,
              title: '备份本地数据库',
              subtitle: '备份 Isar 本地库与 JSON',
              divider: true,
              onTap: () => _onBackup(context),
            ),
            ProfileMenuItem(
              icon: Icons.restore_outlined,
              title: '恢复本地数据库',
              subtitle: '从本地备份覆盖当前数据',
              divider: true,
              onTap: () => _onRestore(context),
            ),
            ProfileMenuItem(
              icon: Icons.style_outlined,
              title: 'TCGdex 卡牌查询',
              subtitle: '在线检索宝可梦卡牌',
              onTap: () => _onTcgdex(context),
            ),
          ],
        ),
        ProfileMenuSection(
          title: '偏好设置',
          children: <Widget>[
            ProfileMenuItem(
              icon: themeModeIcon[themeMode]!,
              title: '外观主题模式',
              subtitle: themeModeLabel[themeMode],
              divider: true,
              trailing: Icon(Icons.chevron_right_outlined,
                  color: context.gold.textInactive, size: 18),
              onTap: () => showThemeModeSheet(context),
            ),
            ProfileMenuItem(
              icon: Icons.attach_money_outlined,
              title: '货币单位切换',
              subtitle: currencyLabel(unit),
              divider: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    currencySymbol(unit),
                    style: TextStyle(
                      color: context.gold.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_outlined,
                      color: context.gold.textInactive, size: 18),
                ],
              ),
              onTap: () => _onCurrency(context),
            ),
          ],
        ),
        ProfileMenuSection(
          title: '关于与版本',
          children: <Widget>[
            ProfileMenuItem(
              icon: Icons.info_outline,
              title: '关于与版本',
              subtitle: '规范说明 · v0.1.0',
              onTap: () => _onAbout(context),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onExportCsv(BuildContext context) async {
    try {
      final List<CardItem> cards = await ref.read(allCardsProvider.future);
      final String msg = await ProfileService.exportCsv(cards);
      if (context.mounted) _toast(context, msg);
    } catch (e) {
      if (context.mounted) _toast(context, '导出失败：$e');
    }
  }

  Future<void> _onBackup(BuildContext context) async {
    try {
      final List<CardItem> cards = await ref.read(allCardsProvider.future);
      final String msg = await DataBackupService.exportBackup(cards);
      if (context.mounted) _toast(context, msg);
    } catch (e) {
      if (context.mounted) _toast(context, '备份失败：$e');
    }
  }

  Future<void> _onRestore(BuildContext context) async {
    final bool? ok = await showConfirmDangerDialog(
      context,
      title: '恢复数据库',
      content: '将用本地备份覆盖当前全部卡牌数据，此操作不可撤销。请在输入框键入「确认」以继续。',
      actionLabel: '恢复',
    );
    if (ok != true) return;
    try {
      final int n = await DataBackupService.importBackup();
      ref.invalidate(allCardsProvider);
      if (context.mounted) {
        _toast(context,
            n > 0 ? '已恢复 $n 张卡牌' : n == -1 ? '已取消' : '未找到本地备份');
      }
    } catch (e) {
      if (context.mounted) _toast(context, '恢复失败：$e');
    }
  }

  Future<void> _onCurrency(BuildContext context) async {
    final CurrencyUnit? pick = await showDialog<CurrencyUnit>(
      context: context,
      builder: (BuildContext ctx) {
        final CurrencyUnit cur = ref.read(profileCurrencyProvider);
        return SimpleDialog(
          backgroundColor: context.gold.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.goldBorder, width: 0.5),
          ),
          title: Text('货币单位',
              style: TextStyle(
                  color: context.gold.textWhite, fontSize: 16, fontWeight: FontWeight.w600)),
          children: <Widget>[
            for (final CurrencyUnit u in CurrencyUnit.values)
              SimpleDialogOption(
                onPressed: () => Navigator.of(ctx).pop(u),
                child: Row(
                  children: <Widget>[
                    Icon(
                      u == cur ? Icons.check_circle_outline : Icons.circle_outlined,
                      color: u == cur
                          ? AppColors.goldPrimary
                          : context.gold.textInactive,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      currencyLabel(u),
                      style: TextStyle(
                        color: u == cur
                            ? AppColors.goldPrimary
                            : context.gold.textWhite,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
    if (pick != null) ref.read(profileCurrencyProvider.notifier).state = pick;
  }

  void _onAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const ProfileAboutDialog(),
    );
  }

  void _onTcgdex(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute<CardSearchScreen>(
        builder: (_) => const CardSearchScreen(),
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    GoldSnackBar.show(context, msg);
  }
}
