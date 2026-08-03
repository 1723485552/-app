import 'package:flutter/material.dart';
import 'package:card_management/core/theme/app_colors.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import '../../domain/utils/centering_calculator.dart';

/// 居中度测量底部数据面板：实时左右/上下比例、PSA 评级预测 Chip、保存按钮。
class CenteringResultPanel extends StatelessWidget {
  const CenteringResultPanel({
    super.key,
    required this.evaluation,
    required this.onSave,
  });

  final CenteringEvaluation evaluation;
  final VoidCallback onSave;

  Color _gradeColor(CenteringGrade g) =>
      g == CenteringGrade.gem ? Colors.green.shade400
      : g == CenteringGrade.mint ? Colors.amber.shade400
      : Colors.red.shade400;

  @override
  Widget build(BuildContext context) {
    final CenteringEvaluation e = evaluation;
    final int lp = e.leftPct.round();
    final int rp = e.rightPct.round();
    final int tp = e.topPct.round();
    final int bp = e.bottomPct.round();
    final Color c = _gradeColor(e.grade);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.gold.surfaceDark,
        border: const Border(
          top: BorderSide(color: AppColors.goldBorder, width: 0.5),
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: _metric(context, '左右 L/R', '$lp / $rp')),
              Expanded(child: _metric(context, '上下 T/B', '$tp / $bp')),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              e.label,
              style: TextStyle(
                color: c,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
              ),
              child: const Text('保存测量结果',
                  style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style: TextStyle(color: context.gold.textMuted, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: context.gold.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
}
