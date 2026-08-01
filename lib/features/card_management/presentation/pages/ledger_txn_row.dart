import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/card_item.dart';
import '../../domain/enums/currency_unit.dart';
import '../widgets/card_cover_image.dart';
import '../helpers/card_meta.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 单条交易流水（缩略图 + 卡名 + 金额 + 日期，时间倒序）。
///
/// 从 [LedgerView] 抽离为独立组件，使主文件收控在 250 行内（RULES 硬规）。
class LedgerTxnRow extends StatelessWidget {
  const LedgerTxnRow({super.key, required this.card, required this.currency});
  final CardItem card;
  final CurrencyUnit currency;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.gold.surfaceDark,
          border: Border.all(color: AppColors.goldBorder, width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CardCoverImage(
                imageUrl: card.imageUrl,
                width: 48,
                height: 48,
                cacheSize: 300,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(card.cardName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.gold.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.goldGlow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(cardGradingLabel(card.grading),
                            style: const TextStyle(
                              color: AppColors.goldPrimary, fontSize: 10)),
                      ),
                      const SizedBox(width: 8),
                      Text('买入',
                          style: TextStyle(
                            color: context.gold.textMuted, fontSize: 11)),
                      const SizedBox(width: 8),
                      Text(_fmtDate(card.buyDate),
                          style: TextStyle(
                            color: context.gold.textInactive, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(CurrencyFormatter.formatCny(card.buyPrice, currency),
                style: const TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      );
}

/// 日期格式化（YYYY.MM.DD），避免引入 intl 依赖。
String _fmtDate(DateTime d) =>
    '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
