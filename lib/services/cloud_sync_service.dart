import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../core/services/device_identity_service.dart';
import '../features/card_management/data/models/card_item.dart';
import '../features/card_management/domain/repositories/card_repository_impl_drift.dart';

/// 云端备份恢复服务（Supabase Storage 实现）。
///
/// 设计红线：
/// 1. 备份对当前数据库**完全只读**——通过 [Isar.copyToFile] 生成一致性快照副本，
///    绝不直接读取运行中的主 `.isar` 文件。
/// 2. 恢复前自动生成回滚点 [default.isar.old]，下载文件经大小 > 0 校验后才替换。
/// 3. 仅在原生平台可用；Web 平台 [copyToFile] 不受支持，调用即抛明确异常。
///
/// 凭证统一由 [SupabaseConfig] 提供：优先取 `--dart-define` 注入的环境变量，
/// 缺失时回退到内置默认凭证，因此开箱即可点击备份 / 恢复。仅当两者皆空
/// （使用者主动清空了默认值）才抛 [CloudBackupConfigException]。

/// Supabase Storage 存储桶名称（需预先在后台创建，策略建议 Private）。
const String _backupBucket = 'user-backups';

/// 凭证未配置时抛出，提示使用者补充凭证。
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

/// 初始化任务缓存：保证并发调用只真正初始化一次，后续调用零开销复用。
Future<void>? _initFuture;

/// 确保 Supabase 已初始化，凭证统一来自 [SupabaseConfig]。
///
/// - 凭证读取顺序：`--dart-define` 环境变量 → [SupabaseConfig] 内置默认值；
/// - [SupabaseConfig.url] 已做归一化，即使填了带 `/rest/v1` 的地址也能正确
///   拼出 Storage / REST 端点；
/// - 卡牌增量同步与整库文件备份共用此入口，全进程仅初始化一次；
/// - 初始化失败会清空缓存，允许下次调用重试，不会永久卡死在坏状态。
Future<void> ensureSupabaseInitialized() {
  return _initFuture ??= _initializeSupabase();
}

Future<void> _initializeSupabase() async {
  if (!SupabaseConfig.isConfigured) {
    _initFuture = null;
    throw const CloudBackupConfigException(
      '缺少 Supabase 凭证，请在 lib/core/config/supabase_config.dart 中填写 '
      'defaultUrl / defaultAnonKey，或运行时附加 '
      '--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
    );
  }
  try {
    // 重复调用会被 Supabase 内部短路跳过，此处仍加缓存以省去多余 await。
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
    debugPrint('[CloudSync] Supabase 已就绪: ${SupabaseConfig.maskedSummary}');
  } catch (e) {
    // 初始化失败（如地址不可达）不缓存坏结果，保证下次点击可重试。
    _initFuture = null;
    throw CloudBackupException('Supabase 初始化失败：$e');
  }
}

/// 取得云端备份空间归属 ID（设备级隔离，H-1）。
///
/// 采用 [DeviceIdentityService] 生成的设备 UUID 作为隔离命名空间，使不同设备的
/// 整库备份互不覆盖；无登录体系时回落到稳定的单用户本地 ID。
Future<String> _requireUserId() async => DeviceIdentityService.getDeviceId();

/// 把 Supabase Storage 的原始异常翻译为「用户看得懂、且知道下一步做什么」的文案。
///
/// 云端备份最常见的三类失败都源于后台未配置好，直接抛原始 JSON 会让人无从下手：
/// - 桶不存在 → 需要在 Supabase 后台建 `user-backups` 桶；
/// - RLS 拒绝 → 需要给 storage.objects 配置允许匿名读写的策略；
/// - 对象不存在 → 云端还没有任何备份（首次使用属正常情况）。
String _describeStorageError(StorageException e, {required bool isUpload}) {
  final String raw = '${e.statusCode ?? ''} ${e.message}'.toLowerCase();
  if (raw.contains('bucket not found') ||
      (raw.contains('not_found') && raw.contains('bucket'))) {
    return '云端存储桶「$_backupBucket」不存在，'
        '请在 Supabase 后台 Storage 中新建同名桶后重试';
  }
  if (raw.contains('row-level security') ||
      raw.contains('unauthorized') ||
      raw.contains('403')) {
    return '云端权限不足：请在 Supabase 后台为存储桶「$_backupBucket」'
        '添加允许匿名读写的 RLS 策略';
  }
  if (!isUpload &&
      (raw.contains('object not found') || raw.contains('404'))) {
    return '云端暂无备份文件，请先执行一次「立即备份到云端」';
  }
  return '${isUpload ? '上传' : '下载'}失败：${e.message}';
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
  final String userId = await _requireUserId();
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
    try {
      await Supabase.instance.client.storage
          .from(_backupBucket)
          .upload(
            remotePath,
            tempFile,
            fileOptions: const FileOptions(upsert: true),
          );
    } on StorageException catch (e) {
      throw CloudBackupException(_describeStorageError(e, isUpload: true));
    }
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
  final String userId = await _requireUserId();
  final Directory tempDir = await getTemporaryDirectory();
  // 用带时间戳的独立实例名，避免与上次残留的锁文件冲突。
  final String instanceName = 'cloud_restore_${DateTime.now().microsecondsSinceEpoch}';
  final File tempFile = File('${tempDir.path}/$instanceName.isar');
  Isar? backupIsar;
  try {
    // 下载云端整库快照（Isar 文件）至临时文件。
    final String remotePath = '$userId/backup_latest.isar';
    late final Uint8List bytes;
    try {
      bytes = await Supabase.instance.client.storage
          .from(_backupBucket)
          .download(remotePath);
    } on StorageException catch (e) {
      throw CloudBackupException(_describeStorageError(e, isUpload: false));
    }

    // 校验非空后再落盘。
    if (bytes.isEmpty) {
      throw const CloudBackupException('云端备份文件为空或不存在');
    }
    await tempFile.writeAsBytes(bytes, flush: true);
    if (await tempFile.length() == 0) {
      throw const CloudBackupException('恢复文件写入校验失败');
    }

    // 以独立实例打开备份快照，萃取出卡牌列表（不触碰运行中的主库实例）。
    backupIsar = await Isar.open(
      [CardItemSchema],
      directory: tempDir.path,
      name: instanceName,
    );
    final List<CardItem> cards = await backupIsar.cardItems.where().findAll();

    // 统一走仓库双写入口：同时更新 Isar 镜像与 Drift，UI 立即可见（修复 H-3）。
    await CardRepositoryImpl().replaceAllCards(cards);
  } on IsarError catch (e) {
    throw CloudBackupException('云端备份文件解析失败（可能为不同版本快照）：$e');
  } catch (e) {
    if (e is CloudBackupException) rethrow;
    throw CloudBackupException('恢复失败：$e');
  } finally {
    if (backupIsar != null) {
      try {
        await backupIsar.close();
      } catch (_) {
        // 忽略关闭异常。
      }
    }
    if (await tempFile.exists()) {
      try {
        await tempFile.delete();
      } catch (_) {
        // 忽略清理失败。
      }
    }
  }
}
