import 'package:image_picker/image_picker.dart';

import '../../presentation/widgets/manual_add_card_sheet.dart';

/// Web 端 OCR 结果占位（与 native 同名同构，便于条件导出无缝切换）。
class OcrResult {
  const OcrResult({required this.imagePath, required this.prefill, this.rawText});
  final String imagePath;
  final ManualAddPrefill prefill;
  final String? rawText;
}

/// Web 端占位实现：浏览器不支持 ML Kit 设备端识卡 / 原生相机。
///
/// 预览环境下 [captureAndRecognize] 直接返回 null，调用方按「用户取消」处理，
/// 按钮无副作用，从而让整个 App 在 Web 平台可正常编译与预览其余 UI。
class CardOcrService {
  CardOcrService({Object? picker});

  Future<OcrResult?> captureAndRecognize(ImageSource source) async => null;
}
