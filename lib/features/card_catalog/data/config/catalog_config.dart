/// 图鉴模块运行配置。
///
/// 已从「示例模式」迁移为「真实 API 直连」：各适配器直接请求公开数据源
/// （PokémonTCG.io / Scryfall / YGOProDeck / TCDB），无本地 Mock 数据。
/// 可选鉴权 Key 通过编译期 `--dart-define` 注入（详见各数据源文件）。
const int catalogPageSize = 20;

/// 各数据源基址（仅供端点说明与后续扩展参考）。
const Map<String, String> catalogEndpoints = <String, String>{
  'pokemon': 'https://api.pokemontcg.io/v2/cards',
  'yugioh': 'https://db.ygoprodeck.com/api/v7/cardinfo.php',
  'mtg': 'https://api.scryfall.com/cards/search',
  'sports': 'https://www.tcdb.com/',
};
