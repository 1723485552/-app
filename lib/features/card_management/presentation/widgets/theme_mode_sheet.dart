import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:card_management/core/theme/app_colors.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:card_management/core/theme/theme_provider.dart';

/// 拉起黑金高奢「外观主题模式」三态切换 Sheet。
///
/// 提供【跟随系统 / 暗黑黑金 / 明亮香槟金】三态，点击即时写入
/// [themeProvider] 并触发全局换肤，附带 [HapticFeedback.lightImpact]。
void showThemeModeSheet(BuildContext context) {
  HapticFeedback.lightImpact();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext ctx) => const _ThemeModeSheet(),
  );
}

/// 黑金高奢主题模式 Sheet。
class _ThemeModeSheet extends ConsumerWidget {
  const _ThemeModeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode current = ref.watch(themeProvider);
    return Container(
      decoration: BoxDecoration(
        color: context.gold.bgDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: AppColors.goldGlow, blurRadius: 24, spreadRadius: -8),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sheetHandle(),
          const SizedBox(height: 14),
          _sheetTitle(context, current),
          const SizedBox(height: 18),
          for (final ThemeMode mode in const <ThemeMode>[
            ThemeMode.system,
            ThemeMode.dark,
            ThemeMode.light,
          ])
            _ThemeModeOption(
              mode: mode,
              selected: mode == current,
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(themeProvider.notifier).setMode(mode);
                Navigator.of(context).pop();
              },
            ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _sheetHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.goldPrimary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _sheetTitle(BuildContext context, ThemeMode current) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '外观主题模式',
            style: TextStyle(
              color: context.gold.textWhite,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '当前：${themeModeLabel[current]}',
            style: const TextStyle(
              color: AppColors.goldPrimary,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// 单个主题模式选项行。
class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IconData icon = themeModeIcon[mode]!;
    final String label = themeModeLabel[mode]!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.goldGlow,
        highlightColor: AppColors.goldGlow.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.goldPrimary : AppColors.goldBorder,
              width: selected ? 1 : 0.5,
            ),
            color: selected ? AppColors.goldGlow.withValues(alpha: 0.12) : null,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.goldBorder, width: 0.5),
                  color: context.gold.surfaceDark,
                ),
                child: Icon(icon, size: 20, color: AppColors.goldPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? AppColors.goldPrimary
                        : context.gold.textWhite,
                    fontSize: 15,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_outline
                    : Icons.circle_outlined,
                size: 20,
                color: selected
                    ? AppColors.goldPrimary
                    : context.gold.textInactive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
