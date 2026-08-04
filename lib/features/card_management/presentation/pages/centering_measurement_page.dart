import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_management/core/theme/app_colors.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:card_management/core/widgets/gold_snack_bar.dart';
import '../../data/models/card_item.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/utils/centering_calculator.dart';
import '../../presentation/helpers/card_image.dart';
import '../widgets/centering_painter.dart';
import '../widgets/centering_result_panel.dart';

/// 卡片居中度交互式测量工具。
///
/// 画布支持缩放/平移；内框四条边可手势拖动对齐图案边界，底部面板实时显示
/// 左右/上下比例与 PSA 评级预测，并可保存结果到本地数据模型。
class CenteringMeasurementPage extends ConsumerStatefulWidget {
  const CenteringMeasurementPage({super.key, required this.card});
  final CardItem card;

  @override
  ConsumerState<CenteringMeasurementPage> createState() =>
      _CenteringMeasurementPageState();
}

class _CenteringMeasurementPageState
    extends ConsumerState<CenteringMeasurementPage> {
  // 归一化矩形（相对画布 0..1）。外框固定贴合画布边缘。
  static const Rect _outer = Rect.fromLTRB(0, 0, 1, 1);
  Rect _inner = const Rect.fromLTRB(0.12, 0.12, 0.88, 0.88);
  Size _box = Size.zero;
  bool _dragging = false;

  CenteringEvaluation get _eval => evaluateCentering(
        _inner.left - _outer.left,
        _outer.right - _inner.right,
        _inner.top - _outer.top,
        _outer.bottom - _inner.bottom,
      );

  void _drag(Offset delta, String edge) {
    if (_box == Size.zero) return;
    final double dx = delta.dx / _box.width;
    final double dy = delta.dy / _box.height;
    const double min = 0.05;
    setState(() {
      double l = _inner.left;
      double r = _inner.right;
      double t = _inner.top;
      double b = _inner.bottom;
      if (edge == 'left') l = (_inner.left + dx).clamp(0.0, _inner.right - min);
      if (edge == 'right') r = (_inner.right + dx).clamp(_inner.left + min, 1.0);
      if (edge == 'top') t = (_inner.top + dy).clamp(0.0, _inner.bottom - min);
      if (edge == 'bottom') {
        b = (_inner.bottom + dy).clamp(_inner.top + min, 1.0);
      }
      _inner = Rect.fromLTRB(l, t, r, b);
    });
  }

  Future<void> _save() async {
    final String formatted = formatCentering(
      _inner.left - _outer.left,
      _outer.right - _inner.right,
      _inner.top - _outer.top,
      _outer.bottom - _inner.bottom,
    );
    try {
      await ref
          .read(cardRepositoryProvider)
          .updateCard(widget.card.copyWith(centeringResult: formatted));
      if (mounted) {
        GoldSnackBar.showOn(ScaffoldMessenger.of(context), '居中度结果已保存');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        GoldSnackBar.showOn(ScaffoldMessenger.of(context), '保存失败：$e');
      }
    }
  }

  List<Widget> _handles(Rect r) => <Widget>[
        _edgeHandle(
            pos: r.left, start: r.top, end: r.bottom, vertical: true, edge: 'left'),
        _edgeHandle(
            pos: r.right,
            start: r.top,
            end: r.bottom,
            vertical: true,
            edge: 'right'),
        _edgeHandle(
            pos: r.top, start: r.left, end: r.right, vertical: false, edge: 'top'),
        _edgeHandle(
            pos: r.bottom,
            start: r.left,
            end: r.right,
            vertical: false,
            edge: 'bottom'),
      ];

  @override
  Widget build(BuildContext context) {
    final CenteringEvaluation e = _eval;
    return Scaffold(
      backgroundColor: context.gold.bgPure,
      appBar: AppBar(
        backgroundColor: context.gold.bgPure,
        title: const Text('居中度测量'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: InteractiveViewer(
              panEnabled: !_dragging,
              minScale: 0.5,
              maxScale: 4,
              child: LayoutBuilder(
                builder: (BuildContext ctx, BoxConstraints c) {
                  _box = Size(c.maxWidth, c.maxHeight);
                  final Rect outerPx = Rect.fromLTRB(
                    _outer.left * _box.width,
                    _outer.top * _box.height,
                    _outer.right * _box.width,
                    _outer.bottom * _box.height,
                  );
                  final Rect innerPx = Rect.fromLTRB(
                    _inner.left * _box.width,
                    _inner.top * _box.height,
                    _inner.right * _box.width,
                    _inner.bottom * _box.height,
                  );
                  return Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Center(
                        child: Image(
                          image: cardImageProvider(widget.card.imageUrl),
                          fit: BoxFit.contain,
                        ),
                      ),
                      CustomPaint(
                        painter: CenteringPainter(
                          outerRect: outerPx,
                          innerRect: innerPx,
                        ),
                      ),
                      ..._handles(innerPx),
                    ],
                  );
                },
              ),
            ),
          ),
          CenteringResultPanel(evaluation: e, onSave: _save),
        ],
      ),
    );
  }

  Widget _edgeHandle({
    required double pos,
    required double start,
    required double end,
    required bool vertical,
    required String edge,
  }) {
    return Positioned(
      left: vertical ? pos - 14 : start - 14,
      top: vertical ? start - 14 : pos - 14,
      width: vertical ? 28 : (end - start) + 28,
      height: vertical ? (end - start) + 28 : 28,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => setState(() => _dragging = true),
        onPanEnd: (_) => setState(() => _dragging = false),
        onPanUpdate: (DragUpdateDetails d) => _drag(d.delta, edge),
        child: Center(
          child: Container(
            width: vertical ? 4 : double.infinity,
            height: vertical ? double.infinity : 4,
            decoration: BoxDecoration(
              color: AppColors.goldGlow.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
