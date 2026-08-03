import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import 'package:card_management/core/theme/app_colors.dart';

/// 黑金极简成交价走势图（fl_chart 折线 + 香槟金渐变填充）。
///
/// [prices] 为按时间升序排列的人民币成交价序列；不足 2 个点时返回空状态提示。
class PriceTrendChartCard extends StatelessWidget {
  const PriceTrendChartCard({
    super.key,
    required this.prices,
    this.height = 168,
  });
  final List<double> prices;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (prices.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text('样本不足，暂无法绘制走势',
              style: TextStyle(color: context.gold.textInactive, fontSize: 12)),
        ),
      );
    }
    final double min = prices.reduce(math.min);
    final double max = prices.reduce(math.max);
    final double pad = (max - min) * 0.15 + 1;
    final double avg = prices.reduce((double a, double b) => a + b) / prices.length;
    final List<FlSpot> spots = <FlSpot>[
      for (int i = 0; i < prices.length; i++)
        FlSpot(i.toDouble(), prices[i]),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            _stat(context, '均价',
                '¥${avg.round()}', context.gold.textWhite),
            const SizedBox(width: 16),
            _stat(context, '最新',
                '¥${prices.last.round()}', AppColors.goldPrimary),
            const SizedBox(width: 16),
            _stat(context, '区间',
                '¥${min.round()}–${max.round()}', context.gold.textMuted),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: min - pad,
              maxY: max + pad,
              lineBarsData: <LineChartBarData>[
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: AppColors.goldPrimary,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.goldPrimary.withValues(alpha: 0.14),
                  ),
                ),
              ],
              titlesData: const FlTitlesData(
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> spots) => spots
                      .map((LineBarSpot s) => LineTooltipItem(
                            '¥${s.y.round()}',
                            const TextStyle(
                                color: Colors.white, fontSize: 11),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color color) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style: TextStyle(color: context.gold.textMuted, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      );
}
