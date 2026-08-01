import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/card_management/data/datasources/card_local_datasource.dart';
import '../../features/card_management/data/models/card_item.dart';
import '../../features/card_management/data/services/profile_export.dart';

/// 卡牌资产备份 / 恢复服务（原生平台）。
///
/// - 导出 JSON 备份并调起系统原生分享面板（SharePlus.instance.share）。
/// - 从本地选择 JSON 备份文件，整体覆盖写回 Isar 本地库。
/// - 复用 [profile_export] 的 JSON 序列化与 [CardLocalDatasource] 的持久化能力，
///   不重复实现底层逻辑（RULES.md「禁止重复」硬规）。
class DataBackupService {
  /// 导出备份：生成 JSON -> 写入应用文档目录 -> 调起系统分享面板。
  static Future<String> exportBackup(List<CardItem> cards) async {
    final String json = buildCardsBackupJson(cards);
    final String stamp = _stamp();
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = '${dir.path}/card_backup_$stamp.json';
    await File(path).writeAsString(json);
    final Uint8List bytes = Uint8List.fromList(utf8.encode(json));
    final XFile xfile = XFile.fromData(
      bytes,
      mimeType: 'application/json',
      name: 'card_backup_$stamp.json',
    );
    await SharePlus.instance.share(
      ShareParams(
        text: '卡牌收藏资产备份',
        subject: '卡牌收藏备份',
        files: <XFile>[xfile],
      ),
    );
    return '备份已生成并调起分享：$path';
  }

  /// 从本地选择 JSON 备份，整体覆盖写回本地库。返回 -1 表示用户取消，>=0 为恢复数量。
  static Future<int> importBackup() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['json'],
    );
    if (result == null || result.files.single.path == null) return -1;
    final String content = await File(result.files.single.path!).readAsString();
    final List<CardItem> cards = parseBackupJson(content);
    await CardLocalDatasource().replaceAllCards(cards);
    return cards.length;
  }

  static String _stamp() {
    final DateTime n = DateTime.now();
    String p(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${p(n.month)}${p(n.day)}_${p(n.hour)}${p(n.minute)}${p(n.second)}';
  }
}
