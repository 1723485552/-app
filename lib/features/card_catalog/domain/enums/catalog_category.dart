/// 图鉴品类（独立于收藏库的 [CardCategory]，按外部数据源维度划分）。
///
/// [key] 为与数据源 / 模型字段对齐的稳定字符串；[isSports] 标识球星卡分支，
/// 用于服务层在 TCG 与 Sports 适配器之间路由。
enum CatalogCategory {
  /// 宝可梦
  tcgPokemon('tcg_pokemon', '宝可梦', false),

  /// 游戏王
  tcgYugioh('tcg_yugioh', '游戏王', false),

  /// 万智牌
  tcgMtg('tcg_mtg', '万智牌', false),

  /// NBA 球星卡
  sportsNba('sports_nba', 'NBA 球星卡', true),

  /// 足球球星卡
  sportsSoccer('sports_soccer', '足球球星卡', true);

  const CatalogCategory(this.key, this.label, this.isSports);

  /// 稳定字符串键（与 [CatalogItem.category] 对应）。
  final String key;

  /// 中文展示文案（顶部分类 Tab 使用）。
  final String label;

  /// 是否为球星卡（决定路由到 [SportsCatalogAdapter]）。
  final bool isSports;
}
