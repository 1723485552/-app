import 'package:flutter/material.dart';
import 'package:card_management/features/card_management/presentation/helpers/card_image.dart';

/// 全屏预览页可选操作按钮。
///
/// 由调用方按需组装（如分享 / 保存 / 居中度测量 / 编辑 / 删除等），
/// 渲染在底部半透明渐变工具条中；点击按钮不会触发“单击退出全屏”。
class HdImageAction {
  const HdImageAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// 全局高清全屏图片预览页。
///
/// 特性：
/// - 纯黑背景沉浸式展示，顶部关闭按钮（也可系统返回键退出）；
/// - 单击任意位置（未放大时）直接退出全屏；放大态下单击不退出，避免误触；
/// - [InteractiveViewer] 原生支持双指捏合缩放、拖拽平移查看细节；
/// - 双击在 1× / 2.6× 间平滑切换（围绕屏幕中心缩放）；
/// - [actions] 非空时在底部叠加半透明渐变功能条（分享 / 保存等），按钮点击不穿透退出。
///
/// 通过 [showHdImage] 便捷方法从任意页面路由进入。
class HdImageViewer extends StatefulWidget {
  const HdImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.actions = const <HdImageAction>[],
  });
  final String imageUrl;
  final String? heroTag;
  final List<HdImageAction> actions;

  @override
  State<HdImageViewer> createState() => _HdImageViewerState();
}

class _HdImageViewerState extends State<HdImageViewer>
    with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  late final AnimationController _anim;
  double _beginScale = 1.0;
  double _endScale = 1.0;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(duration: const Duration(milliseconds: 240), vsync: this)
      ..addListener(_onAnimTick);
  }

  @override
  void dispose() {
    _anim.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// 围绕屏幕中心构造缩放矩阵（保证双击放大从中心展开），避免 Matrix4 已废弃的 translate/scale API。
  Matrix4 _centerMatrix(double scale) {
    final Size size = MediaQuery.of(context).size;
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final Matrix4 m = Matrix4.identity();
    m.setEntry(0, 0, scale);
    m.setEntry(1, 1, scale);
    m.setEntry(2, 2, scale);
    m.setEntry(0, 3, cx * (1 - scale));
    m.setEntry(1, 3, cy * (1 - scale));
    return m;
  }

  void _onAnimTick() {
    final double s = _beginScale + (_endScale - _beginScale) * _anim.value;
    _controller.value = _centerMatrix(s);
  }

  void _onDoubleTap() {
    _beginScale = _controller.value.getMaxScaleOnAxis();
    _endScale = _zoomed ? 1.0 : 2.6;
    _zoomed = !_zoomed;
    _anim.forward(from: 0);
  }

  void _onBackgroundTap() {
    // 放大态下不退出，避免查看细节时误触；未放大时单击任意位置退出全屏。
    if (_controller.value.getMaxScaleOnAxis() > 1.02) return;
    _close();
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final Widget image = Image(
      image: cardImageProvider(widget.imageUrl),
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
      ),
    );
    final Widget viewer = InteractiveViewer(
      transformationController: _controller,
      minScale: 0.5,
      maxScale: 5.0,
      child: widget.heroTag != null
          ? Hero(tag: widget.heroTag!, child: image)
          : image,
    );
    final Widget body = GestureDetector(
      onTap: _onBackgroundTap,
      onDoubleTap: _onDoubleTap,
      child: viewer,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: body),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: _close,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Color(0x99000000), shape: BoxShape.circle),
                child: const Icon(Icons.close_outlined,
                    color: Colors.white, size: 22),
              ),
            ),
          ),
          if (widget.actions.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ActionToolbar(actions: widget.actions),
            ),
        ],
      ),
    );
  }
}

/// 底部半透明渐变功能条：吸收单击，避免穿透触发“退出全屏”。
class _ActionToolbar extends StatelessWidget {
  const _ActionToolbar({required this.actions});
  final List<HdImageAction> actions;

  @override
  Widget build(BuildContext context) {
    final double padBottom = MediaQuery.of(context).padding.bottom;
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 18, 16, padBottom + 18),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.transparent, Colors.black45],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: actions
              .map((HdImageAction a) => _ActionButton(action: a))
              .toList(),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});
  final HdImageAction action;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: action.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(action.icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(action.label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85), fontSize: 11)),
          ],
        ),
      );
}

/// 便捷方法：从任意 [BuildContext] 路由进入高清全屏预览。
///
/// [url] 为空时直接忽略，避免无图场景误触。[actions] 可挂接底部功能条按钮。
void showHdImage(BuildContext context, String url,
    {String? heroTag, List<HdImageAction>? actions}) {
  if (url.isEmpty) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => HdImageViewer(
        imageUrl: url,
        heroTag: heroTag,
        actions: actions ?? const <HdImageAction>[],
      ),
    ),
  );
}
