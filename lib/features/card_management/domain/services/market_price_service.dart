import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'market_price_api_service.dart';

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

/// 行情服务 Provider：注入真实 Scrydex 实现（原 Stub 已下架）。
final Provider<MarketPriceService> marketPriceServiceProvider =
    Provider<MarketPriceService>((ref) => MarketPriceApiService());
