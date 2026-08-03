import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/price_comp_item.dart';
import '../../domain/repositories/i_price_adapter.dart';
import '../../domain/services/currency_service.dart';
import '../../domain/services/price_service.dart';
import '../../data/adapters/domestic_price_adapter.dart';
import '../../data/adapters/foreign_price_adapter.dart';

/// 汇率换算服务（演示档位初始化，可后续接入实时汇率）。
final Provider<CurrencyService> currencyServiceProvider =
    Provider<CurrencyService>((ref) => CurrencyService());

/// 国内行情适配器。
final Provider<IPriceAdapter> domesticPriceAdapterProvider =
    Provider<IPriceAdapter>(
        (ref) => DomesticPriceAdapter(ref.read(currencyServiceProvider)));

/// 国外行情适配器。
final Provider<IPriceAdapter> foreignPriceAdapterProvider =
    Provider<IPriceAdapter>(
        (ref) => ForeignPriceAdapter(ref.read(currencyServiceProvider)));

/// 行情服务（聚合双引擎）。
final Provider<PriceService> priceServiceProvider = Provider<PriceService>(
  (ref) => PriceService(
    domestic: ref.read(domesticPriceAdapterProvider),
    foreign: ref.read(foreignPriceAdapterProvider),
    currency: ref.read(currencyServiceProvider),
  ),
);

/// 行情 Tab：true=国内成交，false=国外成交。
final StateProvider<bool> selectedMarketTabProvider =
    StateProvider<bool>((ref) => true);

/// 走势区间：30 / 90 天。
final StateProvider<int> selectedPriceRangeProvider =
    StateProvider<int>((ref) => 30);

/// 指定卡牌的成交记录（卡名 + 卡号双键，自动释放）。
final AutoDisposeFutureProviderFamily<List<PriceCompItem>, (String, String)>
    priceSalesProvider =
    FutureProvider.autoDispose.family<List<PriceCompItem>, (String, String)>(
  (ref, args) =>
      ref.read(priceServiceProvider).fetchAll(args.$1, args.$2),
);
