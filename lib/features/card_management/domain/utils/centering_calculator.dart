import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

enum CenteringGrade { gem, mint, nearMint, good, poor }

class CenteringResult {
  final double leftWidth;
  final double rightWidth;
  final double topWidth;
  final double bottomWidth;
  final double lrRatioLeft;
  final double lrRatioRight;
  final double tbRatioTop;
  final double tbRatioBottom;
  final String psaGrade;
  final String bgsGrade;
  final double confidence;
  final ui.Rect? autoDetectedInnerRect;

  const CenteringResult({
    required this.leftWidth,
    required this.rightWidth,
    required this.topWidth,
    required this.bottomWidth,
    required this.lrRatioLeft,
    required this.lrRatioRight,
    required this.tbRatioTop,
    required this.tbRatioBottom,
    required this.psaGrade,
    required this.bgsGrade,
    this.confidence = 1.0,
    this.autoDetectedInnerRect,
  });

  factory CenteringResult.fromMargins({
    required double left,
    required double right,
    required double top,
    required double bottom,
    double confidence = 1.0,
    ui.Rect? innerRect,
  }) {
    final double totalLR = (left + right) <= 0 ? 1 : (left + right);
    final double totalTB = (top + bottom) <= 0 ? 1 : (top + bottom);

    final double lrLeft = (left / totalLR) * 100;
    final double lrRight = 100 - lrLeft;
    final double tbTop = (top / totalTB) * 100;
    final double tbBottom = 100 - tbTop;

    return CenteringResult(
      leftWidth: left,
      rightWidth: right,
      topWidth: top,
      bottomWidth: bottom,
      lrRatioLeft: lrLeft,
      lrRatioRight: lrRight,
      tbRatioTop: tbTop,
      tbRatioBottom: tbBottom,
      psaGrade: _calculatePsaGrade(lrLeft, lrRight, tbTop, tbBottom),
      bgsGrade: _calculateBgsGrade(lrLeft, lrRight, tbTop, tbBottom),
      confidence: confidence,
      autoDetectedInnerRect: innerRect,
    );
  }

  static String _calculatePsaGrade(double lrL, double lrR, double tbT, double tbB) {
    final double maxLR = math.max(lrL, lrR);
    final double maxTB = math.max(tbT, tbB);

    if (maxLR <= 55 && maxTB <= 55) return 'PSA 10 (Gem Mint)';
    if (maxLR <= 60 && maxTB <= 60) return 'PSA 10 (Standard)';
    if (maxLR <= 65 && maxTB <= 65) return 'PSA 9 (Mint)';
    if (maxLR <= 70 && maxTB <= 70) return 'PSA 8 (NM-MT)';
    return 'PSA 7 或更低';
  }

  static String _calculateBgsGrade(double lrL, double lrR, double tbT, double tbB) {
    final double maxDiff = math.max((lrL - 50).abs(), (tbT - 50).abs());
    if (maxDiff <= 1.5) return 'BGS 10 (Black Label Candidate)';
    if (maxDiff <= 3.5) return 'BGS 9.5 (Gem Mint)';
    if (maxDiff <= 6.0) return 'BGS 9.0 (Mint)';
    return 'BGS 8.5 或更低';
  }
}

class CenteringCalculator {
  static Future<CenteringResult> autoDetectCentering({
    required ui.Image image,
    ui.Rect? outerCropRect,
  }) async {
    try {
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        return _fallbackDefaultResult(image.width.toDouble(), image.height.toDouble());
      }

      final int width = image.width;
      final int height = image.height;
      final Uint8List pixels = byteData.buffer.asUint8List();

      final ui.Rect outer = outerCropRect ?? ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
      final double midX = outer.left + outer.width / 2;
      final double midY = outer.top + outer.height / 2;

      final double detectedLeft = _scanEdgeRegion(
        pixels,
        width,
        height,
        outer.left.toInt(),
        midX.toInt(),
        midY.toInt(),
        isHorizontal: true,
      );
      final double detectedRight = _scanEdgeRegion(
        pixels,
        width,
        height,
        outer.right.toInt(),
        midX.toInt(),
        midY.toInt(),
        isHorizontal: true,
      );
      final double detectedTop = _scanEdgeRegion(
        pixels,
        width,
        height,
        outer.top.toInt(),
        midY.toInt(),
        midX.toInt(),
        isHorizontal: false,
      );
      final double detectedBottom = _scanEdgeRegion(
        pixels,
        width,
        height,
        outer.bottom.toInt(),
        midY.toInt(),
        midX.toInt(),
        isHorizontal: false,
      );

      final double leftMargin = (detectedLeft - outer.left).abs();
      final double rightMargin = (outer.right - detectedRight).abs();
      final double topMargin = (detectedTop - outer.top).abs();
      final double bottomMargin = (outer.bottom - detectedBottom).abs();

      final ui.Rect innerRect = ui.Rect.fromLTRB(detectedLeft, detectedTop, detectedRight, detectedBottom);

      return CenteringResult.fromMargins(
        left: leftMargin,
        right: rightMargin,
        top: topMargin,
        bottom: bottomMargin,
        confidence: 0.92,
        innerRect: innerRect,
      );
    } catch (e) {
      debugPrint('Auto edge detection error: $e');
      return _fallbackDefaultResult(image.width.toDouble(), image.height.toDouble());
    }
  }

  static double _scanEdgeRegion(
    Uint8List pixels,
    int imageWidth,
    int imageHeight,
    int start,
    int end,
    int fixed,
    {
    required bool isHorizontal,
    int sampleRows = 5,
  }) {
    final List<double> candidates = [];
    final int halfRows = sampleRows ~/ 2;

    for (int offset = -halfRows; offset <= halfRows; offset++) {
      final int line = isHorizontal ? (fixed + offset).clamp(0, imageHeight - 1) : (fixed + offset).clamp(0, imageWidth - 1);
      final double edge = _findEdge(
        pixels,
        imageWidth,
        imageHeight,
        startX: isHorizontal ? start : 0,
        endX: isHorizontal ? end : imageWidth - 1,
        startY: isHorizontal ? 0 : start,
        endY: isHorizontal ? imageHeight - 1 : end,
        x: isHorizontal ? 0 : line,
        y: isHorizontal ? line : 0,
        isHorizontal: isHorizontal,
      );
      candidates.add(edge);
    }

    if (candidates.isEmpty) {
      return start.toDouble();
    }

    candidates.removeWhere((value) => value.isNaN);
    return candidates.isEmpty ? start.toDouble() : candidates.reduce((a, b) => a + b) / candidates.length;
  }

  static double _findEdge(
    Uint8List pixels,
    int imageWidth,
    int imageHeight, {
    int startX = 0,
    int endX = 0,
    int startY = 0,
    int endY = 0,
    int x = 0,
    int y = 0,
    required bool isHorizontal,
  }) {
    double maxGradient = 0;
    int bestPos = isHorizontal ? startX : startY;

    if (isHorizontal) {
      final int dir = startX < endX ? 1 : -1;
      double previous = _getLuminance(pixels, imageWidth, startX, y);
      for (int curX = startX + dir; curX != endX; curX += dir) {
        final double current = _getLuminance(pixels, imageWidth, curX, y);
        final double gradient = (current - previous).abs();
        if (gradient > maxGradient && gradient > 22.0) {
          maxGradient = gradient;
          bestPos = curX;
        }
        previous = current;
      }
    } else {
      final int dir = startY < endY ? 1 : -1;
      double previous = _getLuminance(pixels, imageWidth, x, startY);
      for (int curY = startY + dir; curY != endY; curY += dir) {
        final double current = _getLuminance(pixels, imageWidth, x, curY);
        final double gradient = (current - previous).abs();
        if (gradient > maxGradient && gradient > 22.0) {
          maxGradient = gradient;
          bestPos = curY;
        }
        previous = current;
      }
    }

    return bestPos.toDouble();
  }

  static double _getLuminance(Uint8List pixels, int width, int x, int y) {
    final int index = (y * width + x) * 4;
    if (index < 0 || index + 2 >= pixels.length) return 0.0;
    final int r = pixels[index];
    final int g = pixels[index + 1];
    final int b = pixels[index + 2];
    return 0.299 * r + 0.587 * g + 0.114 * b;
  }

  static CenteringResult _fallbackDefaultResult(double width, double height) {
    return CenteringResult.fromMargins(
      left: width * 0.08,
      right: width * 0.08,
      top: height * 0.08,
      bottom: height * 0.08,
      confidence: 0.50,
    );
  }
}

class CenteringEvaluation extends CenteringResult {
  final double leftPct;
  final double rightPct;
  final double topPct;
  final double bottomPct;
  final CenteringGrade grade;
  final String label;

  CenteringEvaluation({
    required this.leftPct,
    required this.rightPct,
    required this.topPct,
    required this.bottomPct,
    required this.grade,
    required this.label,
    required super.leftWidth,
    required super.rightWidth,
    required super.topWidth,
    required super.bottomWidth,
    required super.lrRatioLeft,
    required super.lrRatioRight,
    required super.tbRatioTop,
    required super.tbRatioBottom,
    required super.psaGrade,
    required super.bgsGrade,
    required super.confidence,
    super.autoDetectedInnerRect,
  });
}

CenteringEvaluation evaluateCentering(
  double left,
  double right,
  double top,
  double bottom,
) {
  final CenteringResult result = CenteringResult.fromMargins(
    left: left,
    right: right,
    top: top,
    bottom: bottom,
  );

  final CenteringGrade grade = _gradeFromRatios(
    result.lrRatioLeft,
    result.lrRatioRight,
    result.tbRatioTop,
    result.tbRatioBottom,
  );

  return CenteringEvaluation(
    leftPct: result.lrRatioLeft,
    rightPct: result.lrRatioRight,
    topPct: result.tbRatioTop,
    bottomPct: result.tbRatioBottom,
    grade: grade,
    label: _gradeLabel(grade),
    leftWidth: result.leftWidth,
    rightWidth: result.rightWidth,
    topWidth: result.topWidth,
    bottomWidth: result.bottomWidth,
    lrRatioLeft: result.lrRatioLeft,
    lrRatioRight: result.lrRatioRight,
    tbRatioTop: result.tbRatioTop,
    tbRatioBottom: result.tbRatioBottom,
    psaGrade: result.psaGrade,
    bgsGrade: result.bgsGrade,
    confidence: result.confidence,
    autoDetectedInnerRect: result.autoDetectedInnerRect,
  );
}

String formatCentering(
  double left,
  double right,
  double top,
  double bottom,
) {
  return '${left.toStringAsFixed(3)},${right.toStringAsFixed(3)},${top.toStringAsFixed(3)},${bottom.toStringAsFixed(3)}';
}

CenteringGrade _gradeFromRatios(
  double leftPct,
  double rightPct,
  double topPct,
  double bottomPct,
) {
  final double maxDiff = [
    (leftPct - 50).abs(),
    (rightPct - 50).abs(),
    (topPct - 50).abs(),
    (bottomPct - 50).abs(),
  ].reduce(math.max);

  if (maxDiff <= 1.0) return CenteringGrade.gem;
  if (maxDiff <= 2.5) return CenteringGrade.mint;
  if (maxDiff <= 4.0) return CenteringGrade.nearMint;
  if (maxDiff <= 6.5) return CenteringGrade.good;
  return CenteringGrade.poor;
}

String _gradeLabel(CenteringGrade grade) {
  switch (grade) {
    case CenteringGrade.gem:
      return 'Gem Mint';
    case CenteringGrade.mint:
      return 'Mint';
    case CenteringGrade.nearMint:
      return 'Near Mint';
    case CenteringGrade.good:
      return 'Good';
    case CenteringGrade.poor:
      return 'Poor';
  }
}
