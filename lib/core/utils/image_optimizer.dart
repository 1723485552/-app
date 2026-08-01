import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// 图片与存储性能优化工具（原生平台）。
///
/// - [compressImage]：拍照 / 相册原图保存前压缩至最大 1080px、质量 80%，
///   目标体积 ≤ 300KB，显著降低本地存储与列表内存占用，阻断 OOM 隐患。
/// - [kListCacheSize]：网格 / 列表封面统一解码尺寸（配合 Image.cacheWidth/Height）。
class ImageOptimizer {
  static const int maxDimension = 1080;
  static const int quality = 80;
  static const int maxBytes = 300 * 1024;
  static const int kListCacheSize = 300;

  /// 将 [file] 解码、等比缩放、压缩后覆盖写回原路径，返回压缩后的文件。
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
    int q = quality;
    List<int> out = img.encodeJpg(resized, quality: q);
    while (out.length > maxBytes && q > 40) {
      q -= 10;
      out = img.encodeJpg(resized, quality: q);
    }
    await file.writeAsBytes(out, flush: true);
    return file;
  }
}
