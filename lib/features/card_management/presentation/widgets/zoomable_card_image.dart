import 'package:flutter/material.dart';
import 'card_cover_image.dart';

/// 可缩放卡图：双击放大/还原 + 双指捏合（[InteractiveViewer]）。
///
/// 仅在放大态（scale>1）启用平移，从而让根级「下拉退出」手势在 1× 时正常工作；
/// 缩放状态通过 [onScaleChanged] 上抛，供父级决定是否禁用下拉退出。
class ZoomableCardImage extends StatefulWidget {
  const ZoomableCardImage({
    super.key,
    required this.imageUrl,
    required this.onScaleChanged,
    this.size,
  });
  final String imageUrl;
  final ValueChanged<bool> onScaleChanged;
  final Size? size;

  @override
  State<ZoomableCardImage> createState() => _ZoomableCardImageState();
}

class _ZoomableCardImageState extends State<ZoomableCardImage>
    with SingleTickerProviderStateMixin {
  final TransformationController _ctrl = TransformationController();
  late final AnimationController _anim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 220));
  bool _zoomed = false;
  VoidCallback? _scaleListener;

  @override
  void dispose() {
    _ctrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  Matrix4 _aroundCenter(double s) {
    final Size sz = widget.size ?? MediaQuery.of(context).size;
    final double cx = sz.width / 2;
    final double cy = sz.height / 2;
    final double tx = cx * (1 - s);
    final double ty = cy * (1 - s);
    // 绕中心按 s 缩放的 2D 仿射矩阵（行主序，避开 deprecated translate/scale）。
    return Matrix4(s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, tx, ty, 0, 1);
  }

  void _onUpdate(ScaleUpdateDetails d) {
    final bool z = _ctrl.value.getMaxScaleOnAxis() > 1.02;
    if (z != _zoomed) {
      _zoomed = z;
      widget.onScaleChanged(z);
    }
  }

  void _toggleZoom() {
    final double cur = _ctrl.value.getMaxScaleOnAxis();
    _animateScale(cur > 1.02 ? 1.0 : 2.5);
  }

  void _animateScale(double target) {
    _anim.stop();
    if (_scaleListener != null) _anim.removeListener(_scaleListener!);
    final double from = _ctrl.value.getMaxScaleOnAxis();
    final Animation<double> a = Tween<double>(begin: from, end: target)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    void listener() => _ctrl.value = _aroundCenter(a.value);
    _scaleListener = listener;
    _anim.addListener(listener);
    _anim.forward(from: 0).then((_) {
      if (_scaleListener == listener) {
        _anim.removeListener(listener);
        _scaleListener = null;
        final bool z = _ctrl.value.getMaxScaleOnAxis() > 1.02;
        if (z != _zoomed) {
          _zoomed = z;
          widget.onScaleChanged(z);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size sz = widget.size ?? MediaQuery.of(context).size;
    final double h = sz.height * 0.82;
    return GestureDetector(
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _ctrl,
        panEnabled: _zoomed,
        scaleEnabled: true,
        minScale: 1,
        maxScale: 4,
        onInteractionUpdate: _onUpdate,
        child: Container(
          width: sz.width,
          height: h,
          alignment: Alignment.center,
          child: CardCoverImage(
            imageUrl: widget.imageUrl,
            fit: BoxFit.contain,
            width: sz.width,
            height: h,
            cacheSize: 1200,
          ),
        ),
      ),
    );
  }
}
