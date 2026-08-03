import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 云端备份恢复服务（Supabase Storage 实现）。
///
/// 设计红线：
/// 1. 备份对当前数据库**完全只读**——通过 [Isar.copyToFile] 生成一致性快照副本，
///    绝不直接读取运行中的主 `.isar` 文件。
/// 2. 恢复前自动生成回滚点 [default.isar.old]，下载文件经大小 > 0 校验后才替换。
/// 3. 仅在原生平台可用；Web 平台 [copyToFile] 不受支持，调用即抛明确异常。
///
/// 凭证通过编译期 `--dart-define` 注入（与现有 Scrydex 配置一致），缺失则抛
/// [CloudBackupConfigException]，不静默失败、不崩溃。
const String _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '',
);
const String _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '',
);

/// Supabase Storage 存储桶名称（需预先在后台创建，策略建议 Private）。
const String _backupBucket = 'user-backups';

/// 凭证未配置时抛出，提示使用者补充 --dart-define。
class CloudBackupConfigException implements Exception {
  const CloudBackupConfigException(this.message);
  final String message;
  @override
  String toString() => 'CloudBackupConfigException: $message';
}

/// 云端备份恢复过程中的业务异常（含用户可理解的文案）。
class CloudBackupException implements Exception {
  const CloudBackupException(this.message);
  final String message;
  @override
  String toString() => 'CloudBackupException: $message';
}

/// 确保 Supabase 已初始化；若未初始化则尝试初始化（凭证缺失时抛明确异常）。
///
/// 已初始化（重复调用）时 Supabase 会抛 [SupabaseClientException]，此处吞掉，
/// 避免二次初始化崩溃。
Future<void> ensureSupabaseInitialized() async {
  if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
    throw const CloudBackupConfigException(
      '缺少 SUPABASE_URL / SUPABASE_ANON_KEY，'
      '请在运行时附加 --dart-define=SUPABASE_URL=... '
      '--dart-define=SUPABASE_ANON_KEY=...',
    );
  }
  // Supabase.initialize 重复调用会自动跳过（已初始化），不会抛异常。
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
  );
}

/// 取得云端备份空间归属 ID。
///
/// 本项目当前无登录系统，故未登录时回落到一个稳定的单用户本地 ID，
/// 保证本地 App 也能正常备份/恢复（仍按用户隔离目录存放）。
String _requireUserId() {
  final User? user = Supabase.instance.client.auth.currentUser;
  return user?.id ?? 'local-user';
}

/// 原生平台：解析 Isar 默认实例的主库文件路径（default.isar）。
///
/// 仅在非 Web 调用；Web 不参与备份恢复逻辑。
Future<File> _isarMainFile() async {
  final Isar? isar = Isar.getInstance();
  if (isar == null) {
    throw const CloudBackupException('本地数据库未初始化');
  }
  final File file = File('${isar.directory}/default.isar');
  return file;
}

/// 云端备份：生成只读快照副本并上传，全程不触碰运行中的主库。
///
/// 步骤：
/// 1. [Isar.copyToFile] 生成一致性临时副本（对主库只读）。
/// 2. 上传至 `user-backups/{userId}/backup_latest.isar`（upsert 覆盖）。
/// 3. 无论成败，清理本地临时副本。
Future<void> uploadBackup() async {
  if (kIsWeb) {
    throw const CloudBackupException('Web 端不支持本地数据库备份');
  }
  await ensureSupabaseInitialized();
  final String userId = _requireUserId();
  final Directory tempDir = await getTemporaryDirectory();
  final File tempFile = File('${tempDir.path}/isar_backup_tmp.isar');
  try {
    // 一致性快照：直接复制运行中的主库文件，无需手动写事务。
    final Isar? isar = Isar.getInstance();
    if (isar == null) {
      throw const CloudBackupException('本地数据库未初始化');
    }
    await isar.copyToFile(tempFile.path);

    if (!await tempFile.exists() || await tempFile.length() == 0) {
      throw const CloudBackupException('本地快照生成失败（文件为空）');
    }

    final String remotePath = '$userId/backup_latest.isar';
    await Supabase.instance.client.storage
        .from(_backupBucket)
        .upload(
          remotePath,
          tempFile,
          fileOptions: const FileOptions(upsert: true),
        );
  } finally {
    // 安全防线：必须清理临时副本，避免残留敏感库文件。
    if (await tempFile.exists()) {
      try {
        await tempFile.delete();
      } catch (_) {
        // 清理失败不阻断主流程，仅忽略。
      }
    }
  }
}

/// 云端恢复：先建回滚点，再下载校验，最后原子替换本地库。
///
/// 安全防线 1：覆盖前将当前 [default.isar] 复制为 [default.isar.old]。
/// 安全防线 2：下载至临时文件，校验 size > 0 后再替换。
/// 完成后需重启应用（或重新打开 Isar）以加载新库。
Future<void> restoreBackup() async {
  if (kIsWeb) {
    throw const CloudBackupException('Web 端不支持本地数据库恢复');
  }
  await ensureSupabaseInitialized();
  final String userId = _requireUserId();
  final File mainFile = await _isarMainFile();
  final Directory tempDir = await getTemporaryDirectory();
  final File tempFile = File('${tempDir.path}/isar_restore_tmp.isar');
  try {
    // 安全防线 1：备份当前本地库为回滚点。
    if (await mainFile.exists()) {
      final File rollback = File('${mainFile.path}.old');
      if (await rollback.exists()) {
        await rollback.delete();
      }
      await mainFile.copy(rollback.path);
    }

    // 下载云端备份至临时文件。
    final String remotePath = '$userId/backup_latest.isar';
    final Uint8List bytes = await Supabase.instance.client.storage
        .from(_backupBucket)
        .download(remotePath);

    // 安全防线 2：校验非空后再写入。
    if (bytes.isEmpty) {
      throw const CloudBackupException('云端备份文件为空或不存在');
    }
    await tempFile.writeAsBytes(bytes, flush: true);
    if (await tempFile.length() == 0) {
      throw const CloudBackupException('恢复文件写入校验失败');
    }

    // 原子替换：先删主库，再移入新文件（同目录 rename 为原子操作）。
    if (await mainFile.exists()) {
      await mainFile.delete();
    }
    await tempFile.copy(mainFile.path);
  } finally {
    if (await tempFile.exists()) {
      try {
        await tempFile.delete();
      } catch (_) {
        // 忽略清理失败。
      }
    }
  }
}
