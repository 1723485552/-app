import 'dart:convert';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 黑金极简价格走势图（CustomPainter 绘制，无第三方图表库依赖）。
///
/// 输入 [prices]（近 30 日价格序列），自适应宽度绘制金色折线 + 香槟金渐变填充。
class PriceTrendChart extends StatelessWidget {
  const PriceTrendChart({super.key, required this.prices, this.height = 56});
  final List<double> prices;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _TrendPainter(prices, AppColors.goldPrimary),
          size: Size.infinite,
        ),
      );
}

/// 将 [priceHistoryJson] 解析为价格序列；空或非法返回空列表（Null Guard）。
List<double> parsePriceHistory(String json) {
  if (json.isEmpty) return const <double>[];
  try {
    final List<dynamic> raw = jsonDecode(json) as List<dynamic>;
    return raw.map((e) => (e as num).toDouble()).toList();
  } catch (_) {
    return const <double>[];
  }
}

/// 走势图卡片：含「近 30 日价格走势」标题与涨跌百分比，无数据时返回空。
class PriceTrendCard extends StatelessWidget {
  const PriceTrendCard({super.key, required this.priceHistoryJson});
  final String priceHistoryJson;

  @override
  Widget build(BuildContext context) {
    final List<double> history = parsePriceHistory(priceHistoryJson);
    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
            Icon(Icons.show_chart_outlined,
                size: 18, color: context.gold.textInactive),
            const SizedBox(width: 8),
            Text('暂无行情历史',
                style: TextStyle(
                    color: context.gold.textInactive, fontSize: 12)),
          ],
        ),
      );
    }
    final double first = history.first;
    final double last = history.last;
    final bool up = last >= first;
    final double r = first == 0 ? 0 : (last - first) / first * 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('近 30 日价格走势',
                style: TextStyle(color: context.gold.textMuted, fontSize: 12)),
            Text('${up ? '+' : ''}${r.toStringAsFixed(1)}%',
                style: TextStyle(
                    color: up ? AppColors.trendUp : AppColors.trendDown,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        PriceTrendChart(prices: history),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.prices, this.color);
  final List<double> prices;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;
    final double min = prices.reduce(math.min);
    final double max = prices.reduce(math.max);
    final double range = (max - min).abs();
    const double pad = 10;
    final double w = size.width;
    final double h = size.height;
    final List<Offset> pts = <Offset>[];
    for (int i = 0; i < prices.length; i++) {
      final double x = pad + (w - 2 * pad) * i / (prices.length - 1);
      final double norm = range == 0 ? 0.5 : (prices[i] - min) / range;
      final double y = h - pad - (h - 2 * pad) * norm;
      pts.add(Offset(x, y));
    }
    final Path line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      line.lineTo(pts[i].dx, pts[i].dy);
    }
    // 渐变填充
    final Path fill = Path()..addPath(line, Offset.zero);
    fill.lineTo(pts.last.dx, h);
    fill.lineTo(pts.first.dx, h);
    fill.close();
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          color.withValues(alpha: 0.22),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fill, fillPaint);
    // 折线描边
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line, stroke);
    // 末点高亮 + 光晕
    canvas.drawCircle(pts.last, 3.2, Paint()..color = color);
    canvas.drawCircle(pts.last, 3.2,
        Paint()..color = color.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.prices != prices || old.color != color;
}
