import 'package:flutter/material.dart';

class CenteringPainter extends CustomPainter {
  final Rect outerRect;
  final Rect innerRect;
  final bool isAutoDetected;
  final Offset? activeDragHandle;

  CenteringPainter({
    required this.outerRect,
    required this.innerRect,
    this.isAutoDetected = false,
    this.activeDragHandle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint maskPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final Path maskPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRect(outerRect),
    );
    canvas.drawPath(maskPath, maskPaint);

    final Paint outerBorderPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(outerRect, outerBorderPaint);

    final Paint innerBorderPaint = Paint()
      ..color = isAutoDetected ? Colors.greenAccent : const Color(0xFFE6C687)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(innerRect, innerBorderPaint);
    _drawDashedRect(canvas, innerRect, innerBorderPaint, dashWidth: 8.0, gapWidth: 4.0);

    final Paint guidePaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.75)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(outerRect.left, innerRect.center.dy),
      Offset(innerRect.left, innerRect.center.dy),
      guidePaint,
    );
    canvas.drawLine(
      Offset(innerRect.right, innerRect.center.dy),
      Offset(outerRect.right, innerRect.center.dy),
      guidePaint,
    );
    canvas.drawLine(
      Offset(innerRect.center.dx, outerRect.top),
      Offset(innerRect.center.dx, innerRect.top),
      guidePaint,
    );
    canvas.drawLine(
      Offset(innerRect.center.dx, innerRect.bottom),
      Offset(innerRect.center.dx, outerRect.bottom),
      guidePaint,
    );

    final Paint handlePaint = Paint()
      ..color = isAutoDetected ? Colors.greenAccent : Colors.orangeAccent
      ..style = PaintingStyle.fill;

    final Paint handleBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final List<Offset> handles = [
      Offset(innerRect.left, innerRect.top + innerRect.height / 2),
      Offset(innerRect.right, innerRect.top + innerRect.height / 2),
      Offset(innerRect.left + innerRect.width / 2, innerRect.top),
      Offset(innerRect.left + innerRect.width / 2, innerRect.bottom),
    ];

    for (final Offset handle in handles) {
      canvas.drawCircle(handle, 6.5, handlePaint);
      canvas.drawCircle(handle, 8.5, handleBorderPaint);
    }

    if (activeDragHandle != null) {
      canvas.drawCircle(
        activeDragHandle!,
        14.0,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.14)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        activeDragHandle!,
        12.0,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint,
      {required double dashWidth, required double gapWidth}) {
    final Path path = Path();
    void addSegment(Offset start, Offset end) {
      final double distance = (end - start).distance;
      if (distance <= 0) return;
      final int count = (distance / (dashWidth + gapWidth)).floor();
      final Offset direction = (end - start) / distance;
      for (int i = 0; i < count; i++) {
        final Offset dashStart = start + direction * (i * (dashWidth + gapWidth));
        final Offset dashEnd = dashStart + direction * dashWidth;
        path.moveTo(dashStart.dx, dashStart.dy);
        path.lineTo(dashEnd.dx, dashEnd.dy);
      }
    }

    addSegment(rect.topLeft, rect.topRight);
    addSegment(rect.topRight, rect.bottomRight);
    addSegment(rect.bottomRight, rect.bottomLeft);
    addSegment(rect.bottomLeft, rect.topLeft);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CenteringPainter oldDelegate) {
    return oldDelegate.outerRect != outerRect ||
        oldDelegate.innerRect != innerRect ||
        oldDelegate.isAutoDetected != isAutoDetected ||
        oldDelegate.activeDragHandle != activeDragHandle;
  }
}
