/// Scrydex 行情 API 配置（核心层）。
///
/// Scrydex 是 pokemontcg.io 团队的付费继任者，覆盖 Pokémon / One Piece /
/// Magic / Lorcana / Gundam / Riftbound 等多游戏实时行情与历史走势。
/// 鉴权需 `X-Api-Key` 与 `X-Team-ID` 两个 Header，且**无免费额度**，
/// 故密钥经编译期环境变量注入；缺失时 [MarketPriceApiService] 优雅降级为
/// 「暂无行情历史」，**绝不伪造任何曲线**误导用户决策。
const String scrydexBaseUrl = 'https://api.scrydex.com';

/// 编译期注入的 Scrydex 密钥；未配置则为空串，触发优雅降级。
const String scrydexApiKey =
    String.fromEnvironment('SCRYDEX_API_KEY', defaultValue: '');
const String scrydexTeamId =
    String.fromEnvironment('SCRYDEX_TEAM_ID', defaultValue: '');

/// USD → CNY 展示汇率（Scrydex 行情以美元报价，App 资产以人民币计量）。
/// TODO(step3): 接入实时汇率 API 替换该近似常量。
const double usdToCnyRate = 7.2;
