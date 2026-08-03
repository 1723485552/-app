import '../models/price_comp_item.dart';
import '../repositories/i_price_adapter.dart';
import 'currency_service.dart';

/// 行情服务（领域层编排）。
///
/// 聚合国内 + 国外双引擎成交数据，统一经 [CurrencyService] 折算人民币，
/// 对 UI 屏蔽平台差异，保证国内外 Tab 与走势图同源联动。
class PriceService {
  const PriceService({
    required this.domestic,
    required this.foreign,
    required this.currency,
  });

  final IPriceAdapter domestic;
  final IPriceAdapter foreign;
  final CurrencyService currency;

  /// 拉取全部成交记录（国内 + 国外合并）。
  Future<List<PriceCompItem>> fetchAll(String cardName, String cardNo) async {
    final List<PriceCompItem> d = await domestic.fetchSales(cardName, cardNo);
    final List<PriceCompItem> f = await foreign.fetchSales(cardName, cardNo);
    return <PriceCompItem>[...d, ...f];
  }
}
