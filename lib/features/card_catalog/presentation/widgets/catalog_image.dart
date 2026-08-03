import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_management/core/theme/app_colors.dart';
import 'package:card_management/core/widgets/hd_image_actions.dart';
import 'package:card_management/core/widgets/hd_image_viewer.dart';

/// 图鉴网络图片（带磁盘缓存 + 微光骨架屏 + 破损重试图标）。
///
/// 使用 [CachedNetworkImage] 替换裸 [Image.network]：默认开启磁盘缓存，
/// 用户查过的卡图离线可秒开；[memCacheWidth] 限制解码尺寸以压低内存占用
/// （与列表内存防爆规范一致）。点击跳转 [HdImageViewer] 全屏高清预览。
class CatalogImage extends StatelessWidget {
  const CatalogImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.enableHdPreview = false,
  });
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final bool enableHdPreview;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _cardBack();
    final Widget img = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: 600,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) => const _Shimmer(),
      errorWidget: (_, __, ___) => _cardBack(),
    );
    if (!enableHdPreview) return img;
    return GestureDetector(
      onTap: () => showHdImage(
            context,
            imageUrl,
            actions: <HdImageAction>[
              hdShareAction(context, imageUrl),
              hdSaveAction(context, imageUrl),
            ],
          ),
      child: img,
    );
  }

  Widget _cardBack() => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF262626), Color(0xFF0E0E0E)],
          ),
          border: Border.all(color: AppColors.goldBorder, width: 0.5),
        ),
        child: Center(
          child: Icon(
            Icons.style_outlined,
            size: ((width ?? height ?? 80) * 0.28).clamp(22, 56),
            color: AppColors.goldPrimary.withValues(alpha: 0.8),
          ),
        ),
      );
}

/// 微光骨架屏（黑金渐变扫描），加载图鉴卡图时占位。
class _Shimmer extends StatefulWidget {
  const _Shimmer();

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final double p = _c.value;
          return ShaderMask(
            shaderCallback: (Rect bounds) => LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: <double>[
                (p - 0.4).clamp(0.0, 1.0),
                p.clamp(0.0, 1.0),
                (p + 0.4).clamp(0.0, 1.0),
              ],
              colors: const <Color>[
                Color(0xFF1A1A1A),
                AppColors.goldGlow,
                Color(0xFF1A1A1A),
              ],
            ).createShader(bounds),
            child: Container(color: const Color(0xFF1A1A1A)),
          );
        },
      );
}
