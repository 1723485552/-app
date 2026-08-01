import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import '../theme/app_colors.dart';

/// 统一黑金 SnackBar（支持撤销动作按钮）。
///
/// 抽离各处置换的 [ScaffoldMessenger.showSnackBar] 调用，统一黑金浮层风格；
/// [actionLabel] 非空时渲染「撤销」类香槟金动作按钮。
/// [showOn] 接收已捕获的 [ScaffoldMessengerState]，便于在 async 间隙后安全弹层
/// （避免跨 await 使用 [BuildContext] 触发 use_build_context_synchronously）。
class GoldSnackBar {
  GoldSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) =>
      showOn(ScaffoldMessenger.of(context), message,
          actionLabel: actionLabel, onAction: onAction, duration: duration);

  static void showOn(
    ScaffoldMessengerState messenger,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    messenger.showSnackBar(_build(messenger.context, message,
        actionLabel: actionLabel, onAction: onAction, duration: duration));
  }

  static SnackBar _build(BuildContext context, String message,
      {String? actionLabel, VoidCallback? onAction, Duration? duration}) {
    return SnackBar(
      content: Text(message,
          style: TextStyle(color: context.gold.textWhite, fontSize: 13)),
      backgroundColor: context.gold.bgNav,
      behavior: SnackBarBehavior.floating,
      duration: duration ?? const Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.goldBorder, width: 0.5),
      ),
      action: actionLabel == null
          ? null
          : SnackBarAction(
              label: actionLabel,
              onPressed: () => onAction?.call(),
              textColor: AppColors.goldPrimary,
            ),
    );
  }
}
