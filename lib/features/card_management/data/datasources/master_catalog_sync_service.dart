import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../services/cloud_sync_service.dart';
import '../../data/models/card_item.dart';

/// 公共主图鉴（UGC 众包）上报服务。
///
/// 功能：把用户本地卡牌的元数据（及可选卡面图）共享到 Supabase 公共主图鉴库
/// `master_catalogs`，供社区共建。核心约束是「补充而非覆盖」：
/// - 主图鉴里没有这张卡 → 插入新行并标记 `status = 'community'`；
/// - 已经存在 → 仅填补空缺字段，且**绝不**改动 `status = 'verified'` 的官方已验证数据；
/// - 任何失败（凭证缺失 / 表未建 / 网络异常 / 图片上传失败）一律静默降级返回 false，
///   绝不抛异常，也绝不阻塞本地保存链路。
///
/// 与既有卡牌增量同步（[SupabaseCardSync]）、整库文件备份（[uploadBackup]）
/// 共用同一份 Supabase 初始化与同一把 publishable 密钥。
class MasterCatalogSyncService {
  const MasterCatalogSyncService._();

  /// 公共主图鉴表名（需在 Supabase 后台预建，主键 id = 标准化主图鉴 ID）。
  static const String _table = 'master_catalogs';

  /// 公共卡面图片桶（公开读、匿名可写）。
  static const String _imageBucket = 'catalog_images';

  /// 由「分类 + 系列 + 卡号」生成标准化、稳定的主图鉴唯一 ID。
  ///
  /// 例：`category=pokemon, set_name=base-set, card_number=004`
  /// → `pokemon_base-set_004`。空字段会被跳过，保证退化场景下 ID 仍唯一。
  static String generateMasterId({
    required String category,
    required String setName,
    required String cardNumber,
  }) {
    final List<String> parts = <String>[
      _slug(category),
      _slug(setName),
      _slug(cardNumber),
    ].where((String s) => s.isNotEmpty).toList();
    return parts.join('_');
  }

  /// 把任意字符串规范为小写、连字符分隔、仅保留字母数字的 slug。
  static String _slug(String input) {
    final String trimmed = input.trim().toLowerCase();
    if (trimmed.isEmpty) return '';
    return trimmed
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
  }

  /// 把一张本地卡牌共享上报到公共主图鉴。
  ///
  /// [card] 为本地卡牌模型；[setName] 为卡牌所属系列/卡组名（当前本地模型未单独
  /// 建模，调用方可按需传入，缺省为空串）；[localImagePath] 为可选的本地卡面图路径，
  /// 传入且为可读的本地文件时，会自动上传至公开桶并取 [publicUrl]。
  ///
  /// 返回 true 表示已成功触达云端逻辑（无论最终是否产生写入）；false 表示静默降级。
  static Future<bool> contributeToMasterCatalog({
    required CardItem card,
    String setName = '',
    String? localImagePath,
  }) async {
    if (!SupabaseConfig.isConfigured) return false;
    try {
      await ensureSupabaseInitialized();
      final SupabaseClient client = Supabase.instance.client;

      final String category = card.category.name;
      final String cardNumber = card.cardNumber;
      final String masterId = generateMasterId(
        category: category,
        setName: setName,
        cardNumber: cardNumber,
      );
      // 连分类和卡号都缺失则无法定位，直接跳过（也不算失败）。
      if (masterId.isEmpty) return false;
      // 防污染（H-4）：系列名缺失或主键段不足时放弃上报，
      // 避免公共主图鉴被退化条目污染、或把不同卡面误并到同一 ID。
      if (setName.isEmpty) return false;
      if (masterId.split('_').where((String s) => s.isNotEmpty).length < 2) {
        return false;
      }

      // 1) 先看主图鉴里有没有这张卡。
      final Map<String, dynamic>? existing = await client
          .from(_table)
          .select('id, status, name, image_url')
          .eq('id', masterId)
          .maybeSingle();

      // 2) 云端图片公共化（仅当本地确实存在可读图片文件时）。
      final String? publicImageUrl =
          await _uploadImageIfLocal(client, masterId, localImagePath ?? card.imageUrl);

      if (existing == null) {
        // 新卡：插入并标记为社区贡献。
        await client.from(_table).insert(<String, dynamic>{
          'id': masterId,
          'category': category,
          'set_name': setName,
          'card_number': cardNumber,
          'name': card.cardName,
          'image_url': publicImageUrl ?? _asUrl(card.imageUrl) ?? '',
          'grading': card.grading.name,
          'status': 'community',
          'contributed_by': 'local-user',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        debugPrint('[MasterCatalog] 已新增社区图鉴条目: $masterId');
      } else {
        // 已存在：官方验证数据不可动；社区数据仅填补空缺，绝不覆盖已有内容。
        if (existing['status'] == 'verified') {
          debugPrint('[MasterCatalog] $masterId 为官方验证数据，跳过补充');
          return true;
        }
        final Map<String, dynamic> patch = <String, dynamic>{};
        if (_isEmpty(existing['name']) && card.cardName.isNotEmpty) {
          patch['name'] = card.cardName;
        }
        final String? candidateImage = publicImageUrl ?? _asUrl(card.imageUrl);
        if (_isEmpty(existing['image_url']) && candidateImage != null) {
          patch['image_url'] = candidateImage;
        }
        if (patch.isNotEmpty) {
          await client.from(_table).update(patch).eq('id', masterId);
          debugPrint('[MasterCatalog] 已补充 $masterId 空缺字段: ${patch.keys}');
        } else {
          debugPrint('[MasterCatalog] $masterId 无空缺可补，跳过');
        }
      }
      return true;
    } on CloudBackupConfigException {
      // 凭证未配置属预期（纯本地模式），静默降级。
      return false;
    } catch (e) {
      debugPrint('[MasterCatalog] 上报失败（已静默降级）: $e');
      return false;
    }
  }

  /// 对图片字节计算短哈希（FNV-1a，32 位），用于公共图床对象路径去重/防覆盖（H-4）。
  static String _contentHash(Uint8List bytes) {
    int hash = 0x811c9dc5;
    for (final int byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  /// 若 [path] 是磁盘上可读的本地图片文件，上传到公开桶并返回公开 URL；
  /// 否则（远程 URL / 空 / 不存在 / 上传失败）返回 null，不阻断主流程。
  static Future<String?> _uploadImageIfLocal(
    SupabaseClient client,
    String masterId,
    String? path,
  ) async {
    final String? local = _resolveLocalImagePath(path);
    if (local == null) return null;
    try {
      final File file = File(local);
      final Uint8List bytes = await file.readAsBytes();
      final String ext = p.extension(local).replaceFirst('.', '');
      // 对象路径追加内容哈希，避免不同卡面图因 ID 相同而互相覆盖（H-4）。
      final String objectPath =
          '$masterId-${_contentHash(bytes)}${ext.isNotEmpty ? '.$ext' : '.jpg'}';
      await client.storage.from(_imageBucket).uploadBinary(
            objectPath,
            bytes,
            fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
          );
      return client.storage.from(_imageBucket).getPublicUrl(objectPath);
    } catch (e) {
      debugPrint('[MasterCatalog] 图片公共化失败（仅上报元数据）: $e');
      return null;
    }
  }

  /// 若 [path] 是磁盘上可读的本地文件，返回它；否则（远程 URL / 空 / `file://` 不存在）返回 null。
  static String? _resolveLocalImagePath(String? path) {
    if (path == null || path.isEmpty) return null;
    String candidate = path;
    if (candidate.startsWith('file://')) candidate = candidate.substring(7);
    if (candidate.startsWith('http://') || candidate.startsWith('https://')) {
      return null;
    }
    try {
      final File file = File(candidate);
      return file.existsSync() && file.lengthSync() > 0 ? candidate : null;
    } catch (_) {
      return null;
    }
  }

  /// 若 [value] 是 http(s) 链接则原样作为图片地址返回，否则返回 null。
  static String? _asUrl(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    return null;
  }

  /// 判断字段是否为空（null 或空串）。
  static bool _isEmpty(dynamic value) =>
      value == null || (value is String && value.isEmpty);
}
