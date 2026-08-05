import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/enums/currency_unit.dart';

/// 货币单位选择弹窗。
///
/// 从 `ProfileMenuList` 抽出为独立组件：菜单页承载的是「入口编排」职责，
/// 具体弹窗的视觉与交互属于可复用的展示层，混在一起会让菜单页持续膨胀
/// 并突破单文件 250 行的规范上限。
///
/// 返回用户选中的单位；点击遮罩取消时返回 null，调用方需自行判空。
Future<CurrencyUnit?> showCurrencyPickerDialog(
  BuildContext context,
  CurrencyUnit current,
) {
  return showDialog<CurrencyUnit>(
    context: context,
    builder: (BuildContext ctx) => _CurrencyPickerDialog(current: current),
  );
}

class _CurrencyPickerDialog extends StatelessWidget {
  const _CurrencyPickerDialog({required this.current});

  final CurrencyUnit current;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: context.gold.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.goldBorder, width: 0.5),
      ),
      title: Text(
        '货币单位',
        style: TextStyle(
          color: context.gold.textWhite,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: <Widget>[
        for (final CurrencyUnit u in CurrencyUnit.values)
          _CurrencyOption(unit: u, selected: u == current),
      ],
    );
  }
}

/// 单个货币选项行：选中态用金色 + 实心勾选图标区分。
class _CurrencyOption extends StatelessWidget {
  const _CurrencyOption({required this.unit, required this.selected});

  final CurrencyUnit unit;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        selected ? AppColors.goldPrimary : context.gold.textInactive;
    return SimpleDialogOption(
      onPressed: () => Navigator.of(context).pop(unit),
      child: Row(
        children: <Widget>[
          Icon(
            selected ? Icons.check_circle_outline : Icons.circle_outlined,
            color: activeColor,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            currencyLabel(unit),
            style: TextStyle(
              color: selected ? AppColors.goldPrimary : context.gold.textWhite,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
