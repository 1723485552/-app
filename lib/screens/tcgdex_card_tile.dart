import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../models/tcgdex_card.dart';
import '../features/card_management/presentation/widgets/card_cover_image.dart';

/// TCGdex 卡牌列表项（黑金紧凑瓦片）。
///
/// 复用项目既有 [CardCoverImage] 渲染高清卡图（自动降级黑金卡背），
/// 底部展示卡名 + 系列编号 + 稀有度；点击时触发轻量触觉反馈并回调。
class TcgdexCardTile extends StatelessWidget {
  const TcgdexCardTile({
    super.key,
    required this.card,
    required this.onTap,
  });

  final TcgdexCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String? high = card.highImage;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.gold.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.goldBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CardCoverImage(
                imageUrl: high ?? '',
                width: double.infinity,
                height: 132,
                cacheSize: 300,
                enableHdPreview: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(card.name ?? '未知卡牌',
                      style: TextStyle(
                          color: context.gold.textWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('#${card.localId}',
                      style: TextStyle(
                          color: context.gold.textInactive, fontSize: 11)),
                  const SizedBox(height: 4),
                  if (card.rarity != null && card.rarity!.isNotEmpty)
                    Text(card.rarity!,
                        style: const TextStyle(
                            color: AppColors.goldPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  _priceRow(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 价格高亮行：有价显示 `$12.50` / `€10.00`（金色粗体），无价显示「暂无报价」。
  Widget _priceRow(BuildContext context) {
    final String? label = card.priceLabel;
    if (label == null) {
      return Text('暂无报价',
          style: TextStyle(color: context.gold.textMuted, fontSize: 12));
    }
    return Text(label,
        style: const TextStyle(
            color: AppColors.goldPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700));
  }
}
