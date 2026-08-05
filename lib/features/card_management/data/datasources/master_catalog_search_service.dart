import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../services/cloud_sync_service.dart';

/// 公共主图鉴（`master_catalogs`）云端实时搜索服务。
///
/// 与 [MasterCatalogSyncService] 共用同一份 Supabase 初始化与匿名密钥。
/// 所有网络请求统一经 [ensureSupabaseInitialized] 守卫；任何失败（凭证缺失 /
/// 表未建 / 网络异常）一律返回空列表并带堆栈打印，绝不抛出，
/// 交由调用方决定 UI 表现，从而保证图鉴页永远不会因接口错误而红屏崩溃。
class MasterCatalogSearchService {
  const MasterCatalogSearchService._();

  /// 公共主图鉴表名（需在 Supabase 后台预建）。
  static const String _table = 'master_catalogs';

  /// 单次请求最大返回行数，防止大结果集拖垮客户端内存。
  static const int defaultLimit = 20;

  /// 在公共主图鉴中做不区分大小写的联合模糊搜索。
  ///
  /// 覆盖 [name] / [set_name] / [card_number] 三字段。
  /// [query] 为空或仅空白时**直接返回空列表**（防御性查询，避免无意义的远端请求）。
  ///
  /// [offset] / [limit] 用于分页；单次返回最多 [limit] 行。
  static Future<List<Map<String, dynamic>>> searchMasterCatalogs(
    String query, {
    int offset = 0,
    int limit = defaultLimit,
  }) async {
    final String trimmed = query.trim();
    // 防御性查询：空关键词不发请求，避免对全表做无意义扫描。
    if (trimmed.isEmpty) return const <Map<String, dynamic>>[];
    if (!SupabaseConfig.isConfigured) {
      debugPrint('[MasterCatalogSearch] 未配置 Supabase 凭证，跳过搜索（纯本地模式）');
      return const <Map<String, dynamic>>[];
    }
    try {
      await ensureSupabaseInitialized();
      final SupabaseClient client = Supabase.instance.client;
      final String like = '%$trimmed%';
      const String columns =
          'id, name, category, set_name, card_number, image_url, status';
      late final List<dynamic> raw;
      if (offset <= 0) {
        // 首屏：显式 .limit() 限制单次最大返回行数。
        raw = await client
            .from(_table)
            .select(columns)
            .or('name.ilike.$like,set_name.ilike.$like,card_number.ilike.$like')
            .order('updated_at', ascending: false)
            .limit(limit);
      } else {
        // 翻页：用 .range() 取后续页，语义等价于每页 limit 行。
        raw = await client
            .from(_table)
            .select(columns)
            .or('name.ilike.$like,set_name.ilike.$like,card_number.ilike.$like')
            .order('updated_at', ascending: false)
            .range(offset, offset + limit - 1);
      }
      return raw.cast<Map<String, dynamic>>();
    } on CloudBackupConfigException {
      // 凭证未配置属预期（纯本地模式），静默降级，不抛异常。
      debugPrint('[MasterCatalogSearch] 未配置 Supabase 凭证，跳过搜索（纯本地模式）');
      return const <Map<String, dynamic>>[];
    } catch (e, st) {
      // 统一异常处理：严禁静默吞错，带堆栈打印后返回空列表。
      debugPrint('[MasterCatalogSearch] 云端搜索失败: $e\n$st');
      return const <Map<String, dynamic>>[];
    }
  }
}
