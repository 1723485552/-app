/// Supabase 云端凭证统一配置入口。
///
/// 读取优先级：
/// 1. **编译期环境变量**（推荐，凭证不入库）：
///    `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
/// 2. 环境变量为空时回退到下方写死的默认凭证，保证开箱即用。
///
/// 全项目（整库文件备份 [uploadBackup] / [restoreBackup]、卡牌增量同步
/// [SupabaseCardSync]）只允许从这里取凭证，杜绝多处硬编码不一致。
class SupabaseConfig {
  const SupabaseConfig._();

  // ===================== 默认凭证（可直接替换） =====================
  // TODO(替换): 更换 Supabase 项目时，只需修改下面两个常量即可，
  // 或改用 --dart-define 注入（环境变量优先级更高，无需改动代码）。
  //
  // 注意：这里填写「项目 URL」即可，带不带 /rest/v1 后缀都能正确工作，
  // 归一化逻辑见 [_normalizeProjectUrl]。

  /// 默认 Supabase 项目地址。
  static const String defaultUrl =
      'https://tnayodtcpaetkcyrjuye.supabase.co/rest/v1/';

  /// 默认发布密钥（publishable / anon key，可安全内置于客户端）。
  ///
  /// 安全说明：该密钥设计上就是暴露给前端的公开密钥，真正的数据访问边界由
  /// Supabase 后台的 RLS（行级安全策略）保证。**切勿**把 service_role 密钥
  /// 写进这里。
  static const String defaultAnonKey =
      'sb_publishable_qc4BUbn3xz_ebV7Mre7XBg_95Pc-i20';

  // ===================== 编译期环境变量 =====================

  static const String _envUrl = String.fromEnvironment('SUPABASE_URL');

  static const String _envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // ===================== 对外读取入口 =====================

  /// Supabase 项目根地址（已归一化，可直接传给 `Supabase.initialize`）。
  static String get url =>
      _normalizeProjectUrl(_envUrl.isNotEmpty ? _envUrl : defaultUrl);

  /// Supabase 发布密钥。
  static String get anonKey => _envAnonKey.isNotEmpty ? _envAnonKey : defaultAnonKey;

  /// 凭证是否可用（两项均非空）。为空时上层应降级为纯本地模式，而非崩溃。
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// 当前凭证是否来自 `--dart-define` 注入（用于设置页 / 日志排查展示）。
  static bool get isFromEnvironment =>
      _envUrl.isNotEmpty && _envAnonKey.isNotEmpty;

  /// 脱敏后的凭证摘要，可安全打印到日志或展示在调试面板。
  static String get maskedSummary {
    final String key = anonKey;
    final String tail = key.length > 6 ? key.substring(key.length - 6) : '***';
    return '$url (key: ****$tail)';
  }

  // ===================== 内部工具 =====================

  /// 已知的 Supabase 子服务路径后缀。
  ///
  /// `SupabaseClient` 内部会自行拼接这些路径（`$url/rest/v1`、`$url/storage/v1`、
  /// `$url/auth/v1`、`$url/realtime/v1`）。若传入的 URL 已经带了后缀，就会拼成
  /// `.../rest/v1/storage/v1` 这种非法地址，导致 Storage 备份与数据库同步全部 404。
  static const List<String> _serviceSuffixes = <String>[
    '/rest/v1',
    '/storage/v1',
    '/auth/v1',
    '/realtime/v1',
  ];

  /// 把任意形态的 Supabase 地址归一化为「项目根地址」。
  ///
  /// 例：`https://xxx.supabase.co/rest/v1/` → `https://xxx.supabase.co`
  ///
  /// 处理内容：去首尾空白 → 去末尾斜杠 → 循环剥离子服务后缀（兼容误填多层）。
  static String _normalizeProjectUrl(String raw) {
    String result = raw.trim();
    if (result.isEmpty) return '';

    // 反复剥离，兼容 `/rest/v1/rest/v1/` 这类重复粘贴的异常输入。
    bool stripped = true;
    while (stripped) {
      stripped = false;
      while (result.endsWith('/')) {
        result = result.substring(0, result.length - 1);
      }
      for (final String suffix in _serviceSuffixes) {
        if (result.toLowerCase().endsWith(suffix)) {
          result = result.substring(0, result.length - suffix.length);
          stripped = true;
          break;
        }
      }
    }

    while (result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }
}
