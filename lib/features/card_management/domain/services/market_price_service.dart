import '../../domain/enums/card_category.dart';

/// 单卡实时行情报价（真实 API 来源）。
///
/// [priceCny] 最新市场价（已折算人民币）；[historyJson] 近 30 日真实价格序列的
/// JSON 数组字符串，无数据时为 ''。
class MarketQuote {
  const MarketQuote({required this.priceCny, required this.historyJson});
  final double priceCny;
  final String historyJson;
}

/// 行情价格服务抽象（领域层契约）。
///
/// 解耦 UI 与具体行情数据源。真实实现 [MarketPriceApiService] 对接 Scrydex API；
/// 原 [StubMarketPriceService] 占位与 `seedPriceHistoryJson` 随机种子伪造逻辑
/// 已彻底下架（见 CODE_ANALYSIS_REPORT.md 方案 4），杜绝「假数据当真数据展示」。
abstract class MarketPriceService {
  /// 拉取指定卡牌的最新行情价（人民币）。
  Future<double> fetchLatestPrice(String cardName, String cardNo);

  /// 拉取实时报价（含最新价与近 30 日真实走势）；无数据 / 异常时返回 null。
  Future<MarketQuote?> fetchQuote(String cardName, String cardNo,
      {CardCategory? category});
}
