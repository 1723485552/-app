import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import '../theme/app_colors.dart';

/// 统一空状态占位（黑金矢量提示 + 文案 + 可选行动按钮）。
///
/// 抽离自各页空态（[EmptyCollection] / [LedgerView] 异常态等），统一极简黑金风格，
/// 避免重复实现与布局塌陷（RULES.md 边界状态硬规）。
class EmptyStatePlaceholder extends StatelessWidget {
  const EmptyStatePlaceholder({
    super.key,
    this.icon = Icons.style_outlined,
    required this.title,
    this.hint,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? hint;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.gold.surfaceDark,
                  border: Border.all(color: AppColors.goldBorder, width: 0.5),
                ),
                child: Icon(icon,
                    size: 40, color: AppColors.goldPrimary.withValues(alpha: 0.9)),
              ),
              const SizedBox(height: 16),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: context.gold.textWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              if (hint != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(hint!,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: context.gold.textMuted, fontSize: 13)),
              ],
              if (actionLabel != null && onAction != null) ...<Widget>[
                const SizedBox(height: 20),
                SizedBox(
                  width: 180,
                  child: FilledButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(actionLabel!,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      foregroundColor: context.gold.bgPure,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}
