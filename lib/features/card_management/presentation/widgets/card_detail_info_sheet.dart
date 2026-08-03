import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/gold_theme_extension.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/gold_stat_tile.dart';
import '../../data/models/card_item.dart';
import '../../domain/enums/currency_unit.dart';
import 'price_trend_chart.dart';

/// 详情「信息」底部卡片：默认不展示，仅在全屏看图点击 ⓘ 时从底部拉出，
/// 承载买入成本 / 当前估值 / 盈亏率 / 行情历史 / 居中度等全部财务与数据字段。
void showCardDetailInfoSheet(
  BuildContext context,
  CardItem card,
  CurrencyUnit currency,
  VoidCallback onCentering,
) {
  final double pct = card.profitPercentage;
  final bool up = pct >= 0;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext ctx) => Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.gold.bgPure.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(card.cardName,
              style: TextStyle(
                  color: context.gold.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('卡号 ${card.cardNumber}',
              style: TextStyle(color: context.gold.textMuted, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _stat('买入成本',
                  CurrencyFormatter.formatCny(card.buyPrice, currency)),
              _stat('当前估值',
                  CurrencyFormatter.formatCny(card.marketPrice, currency)),
              _stat('盈亏率', '${up ? '+' : ''}${pct.toStringAsFixed(1)}%',
                  color: up ? AppColors.trendUp : AppColors.trendDown),
            ],
          ),
          const SizedBox(height: 12),
          PriceTrendCard(priceHistoryJson: card.priceHistoryJson),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onCentering,
            child: Row(
              children: <Widget>[
                const Icon(Icons.center_focus_strong_outlined,
                    color: AppColors.goldPrimary, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    card.centeringResult == null
                        ? '居中度：未测量（点击测量）'
                        : '居中度: ${card.centeringResult}',
                    style: TextStyle(
                        color: context.gold.textWhite, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ),
  );
}

Widget _stat(String label, String value, {Color? color}) => Expanded(
      child: GoldStatTile(label: label, value: value, valueColor: color),
    );
