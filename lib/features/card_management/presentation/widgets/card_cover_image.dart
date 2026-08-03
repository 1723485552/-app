import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/hd_image_actions.dart';
import '../../../../core/widgets/hd_image_viewer.dart';
import '../helpers/card_image.dart';

/// 高颜值默认卡背（纯 Widget 绘制，零资源依赖）。
///
/// 当 [CardCoverImage.imageUrl] 为空（用户未上传图片）或图片加载失败 /
/// 断网时自动降级展示，保证任意尺寸下均呈现一致的黑金质感，不塌陷。
class DefaultCardBack extends StatelessWidget {
  const DefaultCardBack({super.key, this.width, this.height});
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final double w = width ?? double.infinity;
    final double h = height ?? double.infinity;
    final double base = width ?? height ?? 120;
    final double iconSize = (base * 0.24).clamp(22, 56);
    final double labelSize = (base * 0.085).clamp(9, 16);
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF262626), Color(0xFF0E0E0E)],
        ),
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.style_outlined,
                size: iconSize,
                color: AppColors.goldPrimary.withValues(alpha: 0.85)),
            SizedBox(height: (base * 0.04).clamp(4, 12)),
            Text('CARD COLLECTOR',
                style: TextStyle(
                    color: AppColors.goldPrimary.withValues(alpha: 0.85),
                    fontSize: labelSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}

/// 卡面封面图（带降级逻辑）。
///
/// - [imageUrl] 为空字符串时直接渲染 [DefaultCardBack]；
/// - 加载失败 / 断网时通过 [Image.errorBuilder] 自动降级为 [DefaultCardBack]；
/// - 复用 [cardImageProvider] 统一解析本地 / 远程路径，并以 [ResizeImage]
///   限制解码尺寸（列表内存防爆）。
class CardCoverImage extends StatelessWidget {
  const CardCoverImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.cacheSize = 300,
    this.enableHdPreview = false,
  });
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int cacheSize;

  /// 开启后点击缩略图跳转 [HdImageViewer] 全屏高清预览（全局接入要求）。
  final bool enableHdPreview;

  @override
  Widget build(BuildContext context) {
    final Widget fallback = DefaultCardBack(width: width, height: height);
    if (imageUrl.isEmpty) return fallback;
    final Widget img = Image(
      image: ResizeImage(cardImageProvider(imageUrl),
          width: cacheSize, height: cacheSize),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
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
}
