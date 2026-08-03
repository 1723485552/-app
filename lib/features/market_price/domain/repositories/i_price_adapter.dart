import '../models/price_comp_item.dart';

/// 价格适配器接口（领域层契约）。
///
/// 解耦 UI 与具体行情源（国内：集换社 / 闲鱼；国外：eBay / 130point / TCGplayer）。
/// 真实实现 [DomesticPriceAdapter] 与 [ForeignPriceAdapter] 各自封装协议，
/// [PriceService] 仅依赖本接口聚合双引擎数据。
abstract class IPriceAdapter {
  /// 拉取指定卡牌的成交记录列表。
  Future<List<PriceCompItem>> fetchSales(String cardName, String cardNo);

  /// 是否国内平台（用于行情组件国内外 Tab 分流）。
  bool get isDomestic;
}
