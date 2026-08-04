import 'package:flutter/material.dart';

class ProgressiveCardImage extends StatelessWidget {
  final String imageUrl;
  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProgressiveCardImage({
    super.key,
    required this.imageUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Widget imageContent = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingBuilderDone(loadingProgress)) {
          return FadeTransition(
            opacity: const AlwaysStoppedAnimation(1.0),
            child: child,
          );
        }
        return _buildSkeletonPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorPlaceholder(context);
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageContent,
      );
    }

    return imageContent;
  }

  bool loadingBuilderDone(ImageChunkEvent? progress) => progress == null;

  Widget _buildSkeletonPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF1E1E26),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF252530),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image_rounded,
            color: Color(0xFFD4AF37),
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            '图片加载失败',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
