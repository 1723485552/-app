import 'package:flutter/material.dart';

/// 下拉退出容器：iOS 相册式「下拉图片缩小并退出预览」。
///
/// 包裹全屏内容，监听纵向拖拽：拖拽时内容随手指下移并缩小、背景渐隐；松手若超过
/// 阈值（或快速下拉）则 [onDismiss]，否则平滑回弹。放大态（[locked]）下禁用下拉，
/// 让 [InteractiveViewer] 独占手势。单击由 [onTap] 透传给父级（控制栏显隐）。
class DragDismissStack extends StatefulWidget {
  const DragDismissStack({
    super.key,
    required this.child,
    required this.onTap,
    required this.onDismiss,
    this.locked = false,
    this.onDragStart,
  });
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final bool locked;
  final VoidCallback? onDragStart;

  @override
  State<DragDismissStack> createState() => _DragDismissStackState();
}

class _DragDismissStackState extends State<DragDismissStack>
    with SingleTickerProviderStateMixin {
  double _dragY = 0;
  double _dragScale = 1;
  double _dragBg = 1;
  final double _dragNorm = 400;
  late final AnimationController _anim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 240));
  VoidCallback? _listener;

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _start(DragStartDetails _) {
    _anim.stop();
    if (_listener != null) {
      _anim.removeListener(_listener!);
      _listener = null;
    }
    widget.onDragStart?.call();
  }

  void _update(DragUpdateDetails d) {
    if (widget.locked) return;
    _dragY = (_dragY + d.delta.dy).clamp(0.0, _dragNorm * 3);
    _apply();
    setState(() {});
  }

  void _end(DragEndDetails d) {
    if (widget.locked) {
      _animateTo(0);
      return;
    }
    final double thresh = MediaQuery.of(context).size.height * 0.22;
    if (_dragY > thresh || (d.primaryVelocity ?? 0) > 700) {
      _animateTo(_dragNorm * 3, dismiss: true);
    } else {
      _animateTo(0);
    }
  }

  void _apply() {
    final double f = (_dragY / _dragNorm).clamp(0.0, 1.0);
    _dragScale = 1 - f * 0.18;
    _dragBg = 1 - f * 0.85;
  }

  void _animateTo(double endY, {bool dismiss = false}) {
    _anim.stop();
    if (_listener != null) _anim.removeListener(_listener!);
    final double from = _dragY;
    final Animation<double> a = Tween<double>(begin: from, end: endY).animate(
        CurvedAnimation(
            parent: _anim,
            curve: dismiss ? Curves.easeInCubic : Curves.easeOutCubic));
    void listener() {
      _dragY = a.value;
      _apply();
      setState(() {});
    }
    _listener = listener;
    _anim.addListener(listener);
    _anim.forward(from: 0).then((_) {
      if (_listener == listener) {
        _anim.removeListener(listener);
        _listener = null;
        if (dismiss) {
          if (mounted) widget.onDismiss();
        } else {
          _dragY = 0;
          _apply();
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onTap,
        onVerticalDragStart: _start,
        onVerticalDragUpdate: _update,
        onVerticalDragEnd: _end,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: <Widget>[
            Container(color: Colors.black.withValues(alpha: _dragBg)),
            Transform.translate(
              offset: Offset(0, _dragY),
              child: Transform.scale(
                scale: _dragScale,
                child: widget.child,
              ),
            ),
          ],
        ),
      );
}
