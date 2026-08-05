import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../../../services/cloud_sync_service.dart';

/// Supabase 单卡增量同步数据源（本地优先架构的「后台异步」一侧）。
///
/// 设计红线：
/// 1. **绝不抛异常**——所有方法失败时返回 `false`。同步是本地写入之后的补充动作，
///    离线 / 未配置凭证 / 表不存在都只能静默降级，不得影响本地数据与 UI；
///    为此设备 ID 读取（走 SharedPreferences 平台通道，可能抛异常）也必须放在
///    [_guard] **内部**，否则该异常会绕过护栏逃逸成 unhandled async error；
/// 2. 未配置 `--dart-define=SUPABASE_URL/ANON_KEY` 时直接判定不可用，不产生网络请求；
/// 3. 与既有整库文件备份（[uploadBackup]）互不干扰，二者共用同一份 Supabase 初始化。
class SupabaseCardSync {
  /// 云端卡牌表名（需在 Supabase 后台预建，主键 id + user_id）。
  static const String tableName = 'cards';

  /// 上行单张卡牌（存在则更新）。成功返回 true。
  Future<bool> pushCard(CardRow row) {
    return _guard(() async {
      final String userId = await DeviceIdentityService.getDeviceId();
      await Supabase.instance.client
          .from(tableName)
          .upsert(_toRemoteJson(row, userId), onConflict: 'id');
    });
  }

  /// 批量上行（用于补偿未同步队列）。
  Future<bool> pushCards(List<CardRow> rows) {
    if (rows.isEmpty) return Future<bool>.value(true);
    return _guard(() async {
      final String userId = await DeviceIdentityService.getDeviceId();
      await Supabase.instance.client
          .from(tableName)
          .upsert(rows.map((CardRow r) => _toRemoteJson(r, userId)).toList(),
              onConflict: 'id');
    });
  }

  /// 删除云端记录。
  Future<bool> deleteCard(String id) {
    return _guard(() async {
      final String userId = await DeviceIdentityService.getDeviceId();
      await Supabase.instance.client
          .from(tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    });
  }

  /// 统一异常护栏：初始化 + 业务调用全部包起来，任何失败仅记录日志。
  Future<bool> _guard(Future<void> Function() action) async {
    try {
      await ensureSupabaseInitialized();
      await action();
      return true;
    } on CloudBackupConfigException {
      // 凭证未配置属预期状态（纯本地模式），不打扰用户、不刷日志噪音。
      debugPrint('[SupabaseCardSync] 未配置 Supabase 凭证，跳过云端同步（纯本地模式）');
      return false;
    } catch (e, st) {
      debugPrint('[SupabaseCardSync] 同步失败（已降级为纯本地）: $e\n$st');
      return false;
    }
  }

  /// 行 → 云端 JSON（列名使用 snake_case，与 Postgres 习惯一致）。
  ///
  /// [userId] 为设备级 UUID（[DeviceIdentityService]，H-1），作为云端隔离命名空间，
  /// 避免多设备数据互相覆盖；无登录体系时回落到稳定的单用户本地 ID。
  Map<String, dynamic> _toRemoteJson(CardRow row, String userId) {
    return <String, dynamic>{
      'id': row.id,
      'user_id': userId,
      'catalog_id': row.catalogId,
      'name': row.name,
      'card_number': row.cardNumber,
      'image_url': row.imageUrl,
      'grading': row.grading,
      'category': row.category,
      'grade_score': row.gradeScore,
      'cert_number': row.certNumber,
      'buy_price': row.buyPrice,
      'market_price': row.marketPrice,
      'buy_date': row.buyDate.toIso8601String(),
      'is_collected': row.isCollected,
      'volume': row.volume,
      'is_wishlist': row.isWishlist,
      'target_price': row.targetPrice,
      'wishlist_priority': row.wishlistPriority,
      'price_history_json': row.priceHistoryJson,
      'centering_data': row.centeringData,
      'image_paths': row.imagePaths,
      'created_at': row.createdAt.toIso8601String(),
    };
  }
}
