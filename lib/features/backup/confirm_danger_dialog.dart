import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import '../../core/theme/app_colors.dart';

/// 危险操作二次确认弹窗（防误删保护）。
///
/// 在输入框手动键入指定口令（默认「确认」）后，确认按钮放行；取消返回 false。
/// 纯 Flutter 实现，原生 / Web 共用，零平台依赖。
Future<bool?> showConfirmDangerDialog(
  BuildContext context, {
  required String title,
  required String content,
  String actionLabel = '确认',
  String confirmText = '确认',
}) =>
    showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => _ConfirmDangerDialog(
        title: title,
        content: content,
        actionLabel: actionLabel,
        confirmText: confirmText,
      ),
    );

class _ConfirmDangerDialog extends StatefulWidget {
  const _ConfirmDangerDialog({
    required this.title,
    required this.content,
    required this.actionLabel,
    required this.confirmText,
  });
  final String title;
  final String content;
  final String actionLabel;
  final String confirmText;

  @override
  State<_ConfirmDangerDialog> createState() => _ConfirmDangerDialogState();
}

class _ConfirmDangerDialogState extends State<_ConfirmDangerDialog> {
  final TextEditingController _ctrl = TextEditingController();
  bool _typeMatched = false;

  void _onType(String v) {
    final bool matched = v.trim() == widget.confirmText;
    if (matched != _typeMatched) setState(() => _typeMatched = matched);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: context.gold.bgPure,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.goldBorder, width: 0.5),
        ),
        title: Text(widget.title,
            style: TextStyle(
                color: context.gold.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.content,
                style: TextStyle(color: context.gold.textMuted, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              onChanged: _onType,
              style: TextStyle(color: context.gold.textWhite, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: context.gold.surfaceDark,
                hintText: '请输入「${widget.confirmText}」以解锁',
                hintStyle:
                    TextStyle(color: context.gold.textInactive, fontSize: 12),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: AppColors.goldPrimary.withValues(alpha: 0.2),
                      width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.goldPrimary, width: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _typeMatched
                    ? () => Navigator.of(context).pop(true)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.trendDown,
                  foregroundColor: context.gold.bgPure,
                  disabledBackgroundColor: context.gold.surfaceDark,
                  disabledForegroundColor: context.gold.textInactive,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(widget.actionLabel,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                Text('取消', style: TextStyle(color: context.gold.textMuted)),
          ),
        ],
      );
}
