/// 成交记录模型（国内外双引擎统一数据契约）。
class PriceCompItem {
  const PriceCompItem({
    required this.id,
    required this.platformName,
    required this.isDomestic,
    required this.price,
    required this.currency,
    required this.priceInRmb,
    required this.conditionGrade,
    required this.soldDate,
    this.sourceUrl,
  });

  /// 记录唯一标识。
  final String id;

  /// 成交平台（集换社 / 闲鱼 / eBay / 130point / TCGplayer）。
  final String platformName;

  /// 是否国内平台（true=国内成交，false=国外成交）。
  final bool isDomestic;

  /// 原始成交价（按 [currency] 计价）。
  final double price;

  /// 计价币种：'CNY' | 'USD'。
  final String currency;

  /// 汇率折算后的人民币价格（已统一口径，便于跨平台对比）。
  final double priceInRmb;

  /// 成交品相（如 'PSA 10'、'BGS 9.5'、'Raw/裸卡'）。
  final String conditionGrade;

  /// 成交时间。
  final DateTime soldDate;

  /// 原文 / 原链接（可空；为空时列表项不可跳转）。
  final String? sourceUrl;

  @override
  String toString() =>
      '$platformName | ${price.toStringAsFixed(0)} $currency | $conditionGrade';
}
