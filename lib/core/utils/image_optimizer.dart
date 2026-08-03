import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// 图片与存储性能优化工具（原生平台）。
///
/// - [compressImage]：拍照 / 相册原图保存前等比缩放至最大 [maxDimension] px、质量
///   [quality]，保留高清原图（≥2048px / 85%）以避免过度压缩成模糊小图；
///   同时设体积上限 [maxBytes] 防止极端大图撑爆本地存储。
/// - 显示端的「内存防爆」不依赖此处压缩，而由 [CardCoverImage] 的 [ResizeImage]
///   （cacheSize）在解码层限制列表 / 网格缩略图尺寸，两者分离互不冲突。
/// - [kListCacheSize]：网格 / 列表封面统一解码尺寸（配合 Image.cacheWidth/Height）。
class ImageOptimizer {
  static const int maxDimension = 2048;
  static const int quality = 88;
  static const int maxBytes = 1024 * 1024;
  static const int kListCacheSize = 300;

  /// 将 [file] 解码、等比缩放、压缩后覆盖写回原路径，返回压缩后的文件。
  ///
  /// 质量下限固定在 [quality]（不低于 85%），绝不为了压体积牺牲清晰度。
  static Future<File> compressImage(File file) async {
    final Uint8List raw = await file.readAsBytes();
    final img.Image? decoded = img.decodeImage(raw);
    if (decoded == null) return file;
    if (decoded.width <= maxDimension &&
        decoded.height <= maxDimension &&
        raw.lengthInBytes <= maxBytes) {
      return file;
    }
    final int longest =
        decoded.width >= decoded.height ? decoded.width : decoded.height;
    final double scale = longest > maxDimension ? maxDimension / longest : 1.0;
    final img.Image resized = img.copyResize(
      decoded,
      width: (decoded.width * scale).round(),
      height: (decoded.height * scale).round(),
    );
    // 质量只升不降：从 quality 起，仅在仍超 maxBytes 时极小幅下调，但绝不跌破 85。
    int q = quality;
    List<int> out = img.encodeJpg(resized, quality: q);
    while (out.length > maxBytes && q > 85) {
      q -= 3;
      out = img.encodeJpg(resized, quality: q);
    }
    await file.writeAsBytes(out, flush: true);
    return file;
  }
}
