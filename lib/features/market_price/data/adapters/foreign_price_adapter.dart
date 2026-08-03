import '../../domain/models/price_comp_item.dart';
import '../../domain/repositories/i_price_adapter.dart';
import '../../domain/services/currency_service.dart';
import '../config/market_config.dart';

/// 国外行情适配器：对接 eBay Completed Sales / 130point / TCGplayer。
///
/// 真实模式（[useSampleData]=false）按对应端点拉取（eBay 需 OAuth、130point /
/// TCGplayer 需 Key），无凭证时返回空列表；示例模式经相同接口返回标注样本，
/// 价格按 [currency] 经 [CurrencyService] 折算为人民币。
class ForeignPriceAdapter implements IPriceAdapter {
  const ForeignPriceAdapter(this.currency);
  final CurrencyService currency;

  @override
  bool get isDomestic => false;

  @override
  Future<List<PriceCompItem>> fetchSales(String cardName, String cardNo) async {
    if (useSampleData) return _sample();
    // 真实接入点：eBay Browse API (completed)、130point、TCGplayer API。
    return const <PriceCompItem>[];
  }

  List<PriceCompItem> _sample() {
    final DateTime now = DateTime.now();
    final double rate = currency.usdToCny;
    PriceCompItem mk(
      String id,
      String platform,
      double usd,
      String grade,
      int daysAgo,
    ) =>
        PriceCompItem(
          id: id,
          platformName: platform,
          isDomestic: false,
          price: usd,
          currency: 'USD',
          priceInRmb: usd * rate,
          conditionGrade: grade,
          soldDate: now.subtract(Duration(days: daysAgo)),
          sourceUrl: 'https://www.ebay.com/',
        );
    return <PriceCompItem>[
      mk('us-1', 'eBay', 520, 'PSA 10', 2),
      mk('us-2', '130point', 470, 'PSA 10', 12),
      mk('us-3', 'TCGplayer', 410, 'Raw/裸卡', 29),
      mk('us-4', 'eBay', 388, 'PSA 9', 55),
      mk('us-5', '130point', 350, 'BGS 9', 83),
    ];
  }
}
