import 'package:card_management/features/market_price/data/config/market_config.dart';

/// 汇率换算服务（USD ➔ CNY 实时 / 缓存折算）。
///
/// 提供统一口径的人民币折算，使国内外成交价可在同一图表与列表中对比。
/// 真实场景可接入汇率行情接口刷新 [usdToCny]；当前以演示档位初始化。
class CurrencyService {
  CurrencyService({double? usdToCny})
      : usdToCny = usdToCny ?? demoUsdToCny;

  /// 1 美元兑人民币。
  final double usdToCny;

  /// 将 [amount] 按 [currency]（'CNY' | 'USD'）折算为人民币。
  double toRmb(double amount, String currency) {
    final String c = currency.toUpperCase();
    if (c == 'USD') return amount * usdToCny;
    return amount;
  }

  /// 以新汇率派生服务实例（用于汇率刷新）。
  CurrencyService copyWithRate(double rate) => CurrencyService(usdToCny: rate);
}
