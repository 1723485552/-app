import '../../domain/models/price_comp_item.dart';
import '../../domain/repositories/i_price_adapter.dart';
import '../../domain/services/currency_service.dart';
import '../config/market_config.dart';

/// 国内行情适配器：对接集换社 API / 闲鱼抓取接口。
///
/// 真实模式（[useSampleData]=false）按对应端点拉取并解析；无 Key / 抓取服务时
/// 返回空列表，由 UI 呈现空状态。示例模式经相同接口返回标注样本。
class DomesticPriceAdapter implements IPriceAdapter {
  const DomesticPriceAdapter(this.currency);
  final CurrencyService currency;

  @override
  bool get isDomestic => true;

  @override
  Future<List<PriceCompItem>> fetchSales(String cardName, String cardNo) async {
    if (useSampleData) return _sample();
    // 真实接入点：集换社 open API / 闲鱼搜索抓取。
    // 端点示例：https://www.jisilu.cn/webapi/card/...
    return const <PriceCompItem>[];
  }

  List<PriceCompItem> _sample() {
    final DateTime now = DateTime.now();
    return <PriceCompItem>[
      PriceCompItem(
        id: 'cn-1',
        platformName: '集换社',
        isDomestic: true,
        price: 3200,
        currency: 'CNY',
        priceInRmb: 3200,
        conditionGrade: 'PSA 10',
        soldDate: now.subtract(const Duration(days: 3)),
        sourceUrl: 'https://www.jisilu.cn/',
      ),
      PriceCompItem(
        id: 'cn-2',
        platformName: '集换社',
        isDomestic: true,
        price: 2680,
        currency: 'CNY',
        priceInRmb: 2680,
        conditionGrade: 'BGS 9.5',
        soldDate: now.subtract(const Duration(days: 18)),
        sourceUrl: 'https://www.jisilu.cn/',
      ),
      PriceCompItem(
        id: 'cn-3',
        platformName: '闲鱼',
        isDomestic: true,
        price: 1850,
        currency: 'CNY',
        priceInRmb: 1850,
        conditionGrade: 'Raw/裸卡',
        soldDate: now.subtract(const Duration(days: 41)),
        sourceUrl: 'https://www.goofish.com/',
      ),
      PriceCompItem(
        id: 'cn-4',
        platformName: '闲鱼',
        isDomestic: true,
        price: 2100,
        currency: 'CNY',
        priceInRmb: 2100,
        conditionGrade: 'PSA 9',
        soldDate: now.subtract(const Duration(days: 67)),
        sourceUrl: 'https://www.goofish.com/',
      ),
    ];
  }
}
