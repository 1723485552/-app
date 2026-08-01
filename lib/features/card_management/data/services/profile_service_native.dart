import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/card_item.dart';
import 'profile_export.dart';

/// 个人中心数据服务（原生平台）。
///
/// - 导出账单：写入应用文档目录的 CSV 文件。
/// - 备份：导出 JSON 备份，并尝试同步拷贝 Isar 物理库文件。
/// - 恢复：读取文档目录下的 JSON 备份，整体写回本地库。
class ProfileService {
  /// 导出资产账单 CSV，返回面向用户的成功文案（含文件路径）。
  static Future<String> exportCsv(List<CardItem> cards) async {
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/card_assets_${_stamp()}.csv';
    await File(path).writeAsString(buildCardsCsv(cards));
    return '资产账单已导出至：\n$path';
  }

  // 备份 / 恢复已迁移至 features/backup/data_backup_service.dart（含系统分享与原生文件选择），
  // 此处不再重复实现，避免与 DataBackupService 逻辑分叉（RULES.md「禁止重复」）。

  static String _stamp() {
    final DateTime n = DateTime.now();
    String p(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${p(n.month)}${p(n.day)}_${p(n.hour)}${p(n.minute)}${p(n.second)}';
  }
}
