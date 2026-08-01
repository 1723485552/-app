/// TCGdex 宝可梦卡牌数据模型（领域层）。
///
/// 字段对齐 TCGdex v2 API 的卡牌对象：`id` 全局唯一、`localId` 系列内编号、
/// `name` 卡名、`rarity` 稀有度、`image` 图床基础地址。
///
/// 价格字段来自详情接口的 `pricing` 子树：
/// - [tcgplayerUsd]：`pricing.tcgplayer.{holofoil|normal}.marketPrice`（美元）
/// - [cardmarketEur]：`pricing.cardmarket.avg`（欧元均价）
/// 列表搜索摘要不含 `pricing`，故两字段在摘要中为 null；经详情补全后填充。
///
/// 注意：API 返回的 [image] 仅为图床基础 URL（如
/// `https://assets.tcgdex.net/en/swsh/swsh1/1`），**不含图片文件后缀**，
/// 需经 [highImage] 拼接 `/high.png` 加载高清大图。
class TcgdexCard {
  const TcgdexCard({
    required this.id,
    required this.localId,
    this.name,
    this.image,
    this.rarity,
    this.tcgplayerUsd,
    this.cardmarketEur,
  });

  /// 全局唯一卡牌 ID（如 `swsh1-1`）。
  final String id;

  /// 系列内本地编号（如 `1`）。
  final String localId;

  /// 卡牌名称（可能为 null，部分特殊条目缺失）。
  final String? name;

  /// 图床基础地址（不含后缀），可能为 null（部分条目无图）。
  final String? image;

  /// 稀有度（如 `Holo Rare V`）；列表摘要可能缺省。
  final String? rarity;

  /// TCGplayer 市场价（美元）；仅详情接口提供，摘要为 null。
  final double? tcgplayerUsd;

  /// Cardmarket 均价（欧元）；仅详情接口提供，摘要为 null。
  final double? cardmarketEur;

  /// 由 [image] 拼接 `/high.png` 得到的高清大图完整 URL。
  ///
  /// 无 [image] 时返回 null，由 UI 降级为黑金矢量占位。
  String? get highImage {
    if (image == null || image!.isEmpty) return null;
    return '$image/high.png';
  }

  /// 价格高亮标签：优先 TCGplayer 美元，其次 Cardmarket 欧元。
  ///
  /// 如 `$12.50` / `€10.00`；两者皆无返回 null，由 UI 显示「暂无报价」。
  String? get priceLabel {
    if (tcgplayerUsd != null) {
      return '\$${tcgplayerUsd!.toStringAsFixed(2)}';
    }
    if (cardmarketEur != null) {
      return '€${cardmarketEur!.toStringAsFixed(2)}';
    }
    return null;
  }

  /// 从 TCGdex 卡牌 JSON 构建；对任意缺失字段做安全兜底，绝不抛异常。
  factory TcgdexCard.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['id'];
    final dynamic localValue = json['localId'];
    final (double? usd, double? eur) = _parsePricing(json);
    return TcgdexCard(
      id: idValue?.toString() ?? '',
      localId: localValue?.toString() ?? '',
      name: json['name'] as String?,
      image: json['image'] as String?,
      rarity: json['rarity'] as String?,
      tcgplayerUsd: usd,
      cardmarketEur: eur,
    );
  }

  /// 列表摘要专用工厂：仅取 id / localId / name / image / rarity，忽略深层字段。
  factory TcgdexCard.fromSummaryJson(Map<String, dynamic> json) =>
      TcgdexCard.fromJson(json);

  /// 安全解析 pricing 子树，返回 (TCGplayer 美元价, Cardmarket 欧元均价)。
  ///
  /// 防御性处理：pricing / tcgplayer / cardmarket / 各变体缺失或类型异常时
  /// 对应字段返回 null，不抛异常。
  static (double?, double?) _parsePricing(Map<String, dynamic> json) {
    final dynamic pricing = json['pricing'];
    if (pricing is! Map) return (null, null);

    double? usd;
    final dynamic tp = pricing['tcgplayer'];
    if (tp is Map) {
      final dynamic variant = tp['holofoil'] is Map
          ? tp['holofoil']
          : (tp['normal'] is Map ? tp['normal'] : null);
      final dynamic src = variant is Map ? variant : tp;
      final dynamic mp = src is Map ? src['marketPrice'] : null;
      if (mp is num) usd = mp.toDouble();
    }

    double? eur;
    final dynamic cm = pricing['cardmarket'];
    if (cm is Map) {
      final dynamic avg = cm['avg'];
      if (avg is num) eur = avg.toDouble();
    }

    return (usd, eur);
  }
}
