import 'package:flutter/material.dart';

/// 居中度测量画布绘制：外框（卡片边缘）+ 内框（图案边界）+ 四向辅助线。
///
/// 坐标以像素为单位（由调用方把归一化矩形换算到画布尺寸后传入）。
class CenteringPainter extends CustomPainter {
  const CenteringPainter({
    required this.outer,
    required this.inner,
    required this.outerColor,
    required this.innerColor,
  });

  final Rect outer;
  final Rect inner;
  final Color outerColor;
  final Color innerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint outerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final Paint innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(outer, outerPaint);
    canvas.drawRect(inner, innerPaint);

    // 四向辅助线：从内框各边延伸到外框，直观呈现偏心量。
    final Paint guide = Paint()
      ..color = innerColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(inner.left, outer.top), Offset(inner.left, outer.bottom), guide);
    canvas.drawLine(
        Offset(inner.right, outer.top), Offset(inner.right, outer.bottom), guide);
    canvas.drawLine(
        Offset(outer.left, inner.top), Offset(outer.right, inner.top), guide);
    canvas.drawLine(
        Offset(outer.left, inner.bottom), Offset(outer.right, inner.bottom), guide);
  }

  @override
  bool shouldRepaint(covariant CenteringPainter old) => true;
}
