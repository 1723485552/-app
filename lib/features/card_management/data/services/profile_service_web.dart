// Web-only 数据服务：必须依赖浏览器下载 / 文件选择能力。
// dart:html 在 Dart 3.12 中被标记为 deprecated（官方推荐 package:web），
// 但本项目采用条件导出确保本文件仅编译进 Web 构建，故在此文件作用域抑制
// deprecated_member_use 与 avoid_web_libraries_in_flutter 两条 lint，
// 以保持 dart analyze 0/0/0 且不污染全局分析配置。
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

import '../datasources/card_local_datasource.dart';
import '../models/card_item.dart';
import 'profile_export.dart';

/// 个人中心数据服务（Web 平台）。
///
/// 浏览器无文件系统，改用 Blob 下载 / 文件选择上传实现等价能力，
/// 保证预览环境下导出 / 备份 / 恢复均可真实触发。
class ProfileService {
  /// 导出资产账单 CSV（浏览器触发下载）。
  static Future<String> exportCsv(List<CardItem> cards) async {
    _download('card_assets.csv', buildCardsCsv(cards), 'text/csv');
    return '资产账单 CSV 已生成并开始下载';
  }

  /// 备份本地数据库（浏览器触发 JSON 下载）。
  static Future<String> backupData(List<CardItem> cards) async {
    _download('card_backup.json', buildCardsBackupJson(cards), 'application/json');
    return '数据库备份（JSON）已生成并开始下载';
  }

  /// 从用户选择的备份文件恢复，返回恢复的卡牌数量。
  static Future<int> restoreData() async {
    final html.File? file = await _pickFile();
    if (file == null) return 0;
    final String text = await _readText(file);
    final List<CardItem> cards = parseBackupJson(text);
    await CardLocalDatasource().replaceAllCards(cards);
    return cards.length;
  }

  static Future<String> _readText(html.File file) {
    final html.FileReader reader = html.FileReader()..readAsText(file);
    return reader.onLoad.first.then((_) => reader.result as String);
  }

  static void _download(String name, String content, String mime) {
    final html.Blob blob = html.Blob(<Object>[content], mime);
    final String url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement()
      ..href = url
      ..download = name
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static Future<html.File?> _pickFile() {
    final Completer<html.File?> completer = Completer<html.File?>();
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = '.json'
      ..click();
    input.onChange.listen((_) {
      final List<html.File>? files = input.files;
      completer.complete(
        files != null && files.isNotEmpty ? files.first : null,
      );
    });
    return completer.future;
  }
}
