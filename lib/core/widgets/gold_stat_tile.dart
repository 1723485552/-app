import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

/// 统一黑金指标小卡片（标题 + 数值 + 可选涨跌/比率 Label + 0.5px 金边）。
///
/// 抽离自 [AssetBanner] / [CardDetailLightbox] / [CardSharePoster] 中重复出现的
/// 指标卡片，统一黑金质感，保证三态主题下一致呈现（RULES.md 防重复硬规）。
class GoldStatTile extends StatelessWidget {
  const GoldStatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.sublabel,
    this.valueSize = 14,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? sublabel;
  final double valueSize;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: context.gold.textMuted, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: valueColor ?? context.gold.textWhite,
                  fontSize: valueSize,
                  fontWeight: FontWeight.w600)),
          if (sublabel != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(sublabel!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.gold.textInactive, fontSize: 10)),
          ],
        ],
      );
}
