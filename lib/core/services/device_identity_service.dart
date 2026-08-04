import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// 设备级身份服务（H-1）。
///
/// 在首次启动时生成并持久化一个稳定 UUID，作为云端备份 / 增量同步的隔离命名空间
/// （`user_id`），避免多设备数据互相覆盖。
///
/// 设计取向：本项目当前无登录体系，采用「每设备安装即获唯一 ID」的轻量隔离方案，
/// 而非引入 Supabase Auth。云端按此 ID 分目录存放，配合 `supabase_setup.sql` 中
/// `user_id = '<device_uuid>'` 的 RLS 即可实现设备级数据隔离。未来若接入登录，
/// 仅需把 [deviceUserId] 的回落值改为 `auth.uid()` 即可平滑升级。
class DeviceIdentityService {
  const DeviceIdentityService._();

  static const String _storageKey = 'device_uuid_v1';
  static String? _cachedId;

  /// 取得本机设备 UUID（首次调用会异步落盘，之后读内存缓存）。
  static Future<String> getDeviceId() async {
    if (_cachedId != null && _cachedId!.isNotEmpty) return _cachedId!;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_storageKey);
    if (id == null || id.isEmpty) {
      id = _generateUuidV4();
      await prefs.setString(_storageKey, id);
    }
    _cachedId = id;
    return id;
  }

  /// 同步读取（已初始化后）；未初始化时回落到稳定的单用户本地 ID。
  static String get deviceUserId => _cachedId ?? 'local-user';

  /// 生成符合 RFC 4122 的 v4 UUID（不引入额外依赖，避免 pub 解析冲突）。
  static String _generateUuidV4() {
    final Random rng = Random.secure();
    final List<int> bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10xx
    final StringBuffer sb = StringBuffer();
    for (int i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) sb.write('-');
      sb.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }
}
