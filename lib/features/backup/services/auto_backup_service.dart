import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../card_management/data/models/card_item.dart';
import '../../card_management/data/services/profile_export.dart';
import '../../card_management/domain/repositories/card_repository.dart';

/// 静默本地自动备份服务。
///
/// - 写入应用私有目录（[getApplicationSupportDirectory] /backups），对用户不可见；
/// - 24h 节流：距上次备份不足 24h 直接跳过，避免频繁写盘；
/// - 7 天滚动保留：每次备份后清理 7 天前的旧备份文件；
/// - 全程静默，失败仅吞掉异常，绝不打断主流程。
class AutoBackupService {
  AutoBackupService._();
  static const String _spKey = 'auto_backup_last_ms';
  static const Duration _interval = Duration(hours: 24);
  static const int _retainDays = 7;

  /// 启动 / 切前台时调用：超过 24h 才静默执行一次。
  ///
  /// 整体包在 try 内 —— [SharedPreferences.getInstance] 走平台通道，插件未就绪或
  /// 存储异常时会抛出。该调用位于 try 之外的话，异常将绕过护栏逃逸成 unhandled
  /// async error（调用方以 `runSilently` 后台触发，无人接手），App 启动即红屏。
  static Future<void> backupIfDue(CardRepository repo) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int last = prefs.getInt(_spKey) ?? 0;
      final int now = DateTime.now().millisecondsSinceEpoch;
      if (last != 0 && now - last < _interval.inMilliseconds) return;
      await _backupNow(repo);
      await prefs.setInt(_spKey, now);
    } catch (_) {
      // 静默失败：不影响主流程。
    }
  }

  static Future<String> _backupNow(CardRepository repo) async {
    final List<CardItem> cards = await repo.getAllCards();
    final String json = buildCardsBackupJson(cards);
    final Directory dir = await _backupDir();
    final File file = File('${dir.path}/auto_backup_${_stamp()}.json');
    await file.writeAsString(json);
    await _purgeOld(dir);
    return file.path;
  }

  static Future<Directory> _backupDir() async {
    final Directory base = await getApplicationSupportDirectory();
    final Directory dir = Directory('${base.path}/backups');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// 删除 7 天前的备份（优先按文件名日期戳，失败回退文件修改时间）。
  static Future<void> _purgeOld(Directory dir) async {
    final DateTime cutoff =
        DateTime.now().subtract(const Duration(days: _retainDays));
    final List<File> files = dir
        .listSync()
        .whereType<File>()
        .where((File f) => f.path.contains('auto_backup_'))
        .toList();
    for (final File f in files) {
      final DateTime? t = _parseStamp(f.path) ?? await _safeModified(f);
      if (t != null && t.isBefore(cutoff)) {
        try {
          await f.delete();
        } catch (e) {
          debugPrint('[AutoBackup] 删除旧备份失败（可忽略）: $e');
        }
      }
    }
  }

  static DateTime? _parseStamp(String path) {
    final RegExp re = RegExp(r'auto_backup_(\d{8})');
    final Match? m = re.firstMatch(path);
    if (m == null) return null;
    final String s = m.group(1)!;
    return DateTime.tryParse(
        '${s.substring(0, 4)}-${s.substring(4, 6)}-${s.substring(6, 8)}');
  }

  static Future<DateTime?> _safeModified(File f) async {
    try {
      return await f.lastModified();
    } catch (_) {
      return null;
    }
  }

  static String _stamp() {
    final DateTime n = DateTime.now();
    String p(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${p(n.month)}${p(n.day)}';
  }
}
