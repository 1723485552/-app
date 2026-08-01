import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state_placeholder.dart';
import 'manual_add_card_sheet.dart';

/// 空收藏状态（黑金矢量提示 + 「添加卡牌」主行动按钮）。
///
/// 卡册数据为空时渲染（RULES.md 边界状态硬规：空态不得塌陷、须极简干净）。
/// 点击「添加卡牌」直接拉起录入抽屉，降低首次使用的心智负担。
/// 复用统一 [EmptyStatePlaceholder] 保证全局空态风格一致。
class EmptyCollection extends StatelessWidget {
  const EmptyCollection({super.key, this.hint = '暂无收藏卡牌，点击添加'});
  final String hint;

  @override
  Widget build(BuildContext context) => EmptyStatePlaceholder(
        icon: Icons.style_outlined,
        title: '收藏还是空的',
        hint: hint,
        actionLabel: '添加卡牌',
        onAction: () => showManualAddCardSheet(context),
      );
}
