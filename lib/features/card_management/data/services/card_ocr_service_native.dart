import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/enums/card_category.dart';
import '../../domain/enums/grading_company.dart';
import '../../presentation/widgets/manual_add_card_sheet.dart';
import '../../../../core/utils/image_optimizer.dart';

/// 设备端 OCR 识卡结果：本地落盘照片路径 + 解析出的预填数据 + 原始文本。
class OcrResult {
  const OcrResult({required this.imagePath, required this.prefill, this.rawText});
  final String imagePath;
  final ManualAddPrefill prefill;
  final String? rawText;
}

/// 真实的设备端拍照 / 相册识卡服务。
///
/// 流程：image_picker 取图 -> 落盘 app 私有目录（持久化封面）-> ML Kit 文本识别
/// -> 正则智能提取评级机构 / 分数 / 卡号 / 卡名 -> 组装 [ManualAddPrefill]。
///
/// 纯设备端、不依赖网络推理；但因离线 Gradle 环境无法拉取原生制品，集成后需联网
/// 执行 `flutter pub get` 与 `flutter run` 方可编译运行（详见 QA 验收清单）。
class CardOcrService {
  CardOcrService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;

  /// 拍照或从相册选择并识别；用户取消返回 null。
  Future<OcrResult?> captureAndRecognize(ImageSource source) async {
    final XFile? picked =
        await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return null;
    final String path = await _saveImage(picked);
    final String? text = await _recognize(path);
    final ManualAddPrefill prefill = _parse(text ?? '', path);
    return OcrResult(imagePath: path, prefill: prefill, rawText: text);
  }

  Future<String> _saveImage(XFile picked) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final Directory cardsDir = Directory('${dir.path}/cards');
    if (!await cardsDir.exists()) await cardsDir.create(recursive: true);
    final String name = 'card_${DateTime.now().microsecondsSinceEpoch}.jpg';
    final File saved = await File(picked.path).copy('${cardsDir.path}/$name');
    final File optimized = await ImageOptimizer.compressImage(saved);
    return optimized.path;
  }

  Future<String?> _recognize(String path) async {
    final TextRecognizer recognizer = TextRecognizer();
    try {
      final RecognizedText text =
          await recognizer.processImage(InputImage.fromFilePath(path));
      return text.text;
    } catch (_) {
      return null;
    } finally {
      recognizer.close();
    }
  }

  ManualAddPrefill _parse(String text, String path) {
    final String upper = text.toUpperCase();

    GradingCompany? company;
    if (upper.contains('PSA')) {
      company = GradingCompany.psa;
    } else if (upper.contains('BGS') || upper.contains('BECKETT')) {
      company = GradingCompany.bgs;
    } else if (upper.contains('CGC') || upper.contains('SGC')) {
      company = GradingCompany.cgc;
    }

    double? score;
    final RegExpMatch? gem =
        RegExp(r'GEM[\s-]?MT\s*(\d+(?:\.\d+)?)').firstMatch(upper);
    if (gem != null) {
      score = double.tryParse(gem.group(1)!);
    } else {
      final RegExpMatch? numMatch =
          RegExp(r'\b(10|9\.5|9|8\.5|8|7\.5|7)\b').firstMatch(text);
      if (numMatch != null) score = double.tryParse(numMatch.group(1)!);
    }
    if (score == null && upper.contains('GEM') && upper.contains('MT')) {
      score = 10;
    }

    String? number;
    final RegExpMatch? hash =
        RegExp(r'#\s*([0-9A-Za-z\-]+)').firstMatch(text);
    if (hash != null) {
      number = '#${hash.group(1)}';
    } else {
      final RegExpMatch? no =
          RegExp(r'NO\.?\s*([0-9A-Za-z\-]+)').firstMatch(text);
      if (no != null) number = no.group(1);
    }

    String? name;
    for (final String line in text.split('\n')) {
      final String t = line.trim();
      if (t.isEmpty) continue;
      final String u = t.toUpperCase();
      if (u.contains('PSA') ||
          u.contains('BGS') ||
          u.contains('BECKETT') ||
          u.contains('CGC') ||
          u.contains('SGC') ||
          u.contains('GEM') ||
          u.contains('CERT') ||
          u.contains('MT')) {
        continue;
      }
      if (RegExp(r'^[A-Z][a-zA-Z]+( [A-Z][a-zA-Z]+)+').hasMatch(t)) {
        name = t;
        break;
      }
    }

    CardCategory? category;
    final String lower = text.toLowerCase();
    if (lower.contains('pokemon') ||
        lower.contains('charizard') ||
        lower.contains('pikachu')) {
      category = CardCategory.pokemon;
    } else if (lower.contains('one piece') || lower.contains('luffy')) {
      category = CardCategory.onePiece;
    } else if (lower.contains('yu-gi-oh') || lower.contains('yugioh')) {
      category = CardCategory.yugioh;
    }

    return ManualAddPrefill(
      cardName: name,
      cardNumber: number,
      grading: company,
      gradeScore: score,
      category: category,
      imagePath: path,
    );
  }
}
