import 'dart:math' as math;

/// 居中度评级（与 PSA 视觉标准对齐的简化映射）。
enum CenteringGrade { gem, mint, off }

/// 一次居中度评估的结果（纯数据，无 UI 依赖）。
class CenteringEvaluation {
  const CenteringEvaluation({
    required this.leftPct,
    required this.rightPct,
    required this.topPct,
    required this.bottomPct,
    required this.grade,
    required this.label,
  });

  final double leftPct;
  final double rightPct;
  final double topPct;
  final double bottomPct;
  final CenteringGrade grade;
  final String label;
}

const String _gemLabel = 'GEM MINT (PSA 10 潜质)';
const String _mintLabel = 'MINT (PSA 9 范围)';
const String _offLabel = 'Off-Center (偏心扣分)';

/// 依据四条边的间隙（任意单位，比例即可）计算左右/上下百分比与评级。
///
/// [l]/[r] 为内框左/右到外框的间隙，[t]/[b] 为内框上/下到外框的间隙。
CenteringEvaluation evaluateCentering(double l, double r, double t, double b) {
  final double lr = l + r;
  final double tb = t + b;
  if (lr <= 0 || tb <= 0) {
    // 防御：间隙和为 0（如内框与外框重合）时回退为居中，避免除零。
    return const CenteringEvaluation(
      leftPct: 50,
      rightPct: 50,
      topPct: 50,
      bottomPct: 50,
      grade: CenteringGrade.gem,
      label: _gemLabel,
    );
  }
  final double leftPct = (l / lr) * 100;
  final double topPct = (t / tb) * 100;
  final CenteringEvaluation result = CenteringEvaluation(
    leftPct: leftPct,
    rightPct: 100 - leftPct,
    topPct: topPct,
    bottomPct: 100 - topPct,
    grade: _gradeOf(leftPct, topPct),
    label: _labelOf(_gradeOf(leftPct, topPct)),
  );
  return result;
}

/// 评级预测：左右与上下均在 50/50~55/45 为 GEM；56/44~60/40 为 MINT；
/// 任一超出 60/40 为 Off-Center。以偏离中心更大的轴为准。
CenteringGrade _gradeOf(double leftPct, double topPct) {
  final double dev = <double>[
    (leftPct - 50).abs(),
    (topPct - 50).abs(),
  ].reduce(math.max);
  if (dev <= 5) return CenteringGrade.gem;
  if (dev <= 10) return CenteringGrade.mint;
  return CenteringGrade.off;
}

String _labelOf(CenteringGrade grade) {
  switch (grade) {
    case CenteringGrade.gem:
      return _gemLabel;
    case CenteringGrade.mint:
      return _mintLabel;
    case CenteringGrade.off:
      return _offLabel;
  }
}

/// 将测量结果格式化为可写入数据模型的字符串，如 "L/R: 52/48 | T/B: 51/49"。
String formatCentering(double l, double r, double t, double b) {
  final CenteringEvaluation e = evaluateCentering(l, r, t, b);
  final int lp = e.leftPct.round();
  final int rp = e.rightPct.round();
  final int tp = e.topPct.round();
  final int bp = e.bottomPct.round();
  return 'L/R: $lp/$rp | T/B: $tp/$bp';
}
