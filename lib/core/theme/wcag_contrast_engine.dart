import 'dart:math' as math;
import 'package:flutter/material.dart';

class WcagContrastEngine {
  static const double aaaNormalTextMinRatio = 7.0;
  static const double aaaLargeTextMinRatio = 4.5;
  static const double aaNormalTextMinRatio = 4.5;

  static double calculateLuminance(Color color) {
    // 入参为已归一化的 0.0~1.0 通道值（Color.r/g/b），与旧的 8bit/255 完全等价。
    double transform(double channel) {
      return channel <= 0.03928
          ? channel / 12.92
          : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
    }

    final double r = transform(color.r);
    final double g = transform(color.g);
    final double b = transform(color.b);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double calculateContrastRatio(Color foreground, Color background) {
    final double l1 = calculateLuminance(foreground);
    final double l2 = calculateLuminance(background);
    final double lighter = math.max(l1, l2);
    final double darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static Color ensureContrast({
    required Color foreground,
    required Color background,
    double minRatio = aaaNormalTextMinRatio,
    Color? fallbackLighter,
    Color? fallbackDarker,
  }) {
    final double currentRatio = calculateContrastRatio(foreground, background);
    if (currentRatio >= minRatio) {
      return foreground;
    }

    final Color lighter = fallbackLighter ?? Colors.white;
    final Color darker = fallbackDarker ?? const Color(0xFF0A0A0C);

    final double lighterRatio = calculateContrastRatio(lighter, background);
    final double darkerRatio = calculateContrastRatio(darker, background);

    if (lighterRatio >= minRatio) {
      return lighter;
    } else if (darkerRatio >= minRatio) {
      return darker;
    }

    return lighterRatio > darkerRatio ? lighter : darker;
  }
}

class GradientScrim extends StatelessWidget {
  final Widget child;
  final Alignment begin;
  final Alignment end;
  final double baseOpacity;
  final List<double>? stops;

  const GradientScrim({
    super.key,
    required this.child,
    this.begin = Alignment.bottomCenter,
    this.end = Alignment.topCenter,
    this.baseOpacity = 0.85,
    this.stops,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: begin,
                end: end,
                stops: stops ?? const [0.0, 0.45, 1.0],
                colors: [
                  Colors.black.withValues(alpha: baseOpacity),
                  Colors.black.withValues(alpha: baseOpacity * 0.45),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
