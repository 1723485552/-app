import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/catalog_category.dart';
import '../../domain/services/catalog_service.dart';
import '../../data/adapters/sports_catalog_adapter.dart';
import '../../data/adapters/tcg_catalog_adapter.dart';

/// 图鉴服务（注入 TCG + 球星卡双适配器，直连真实数据源）。
final Provider<CatalogService> catalogServiceProvider =
    Provider<CatalogService>((ref) => const CatalogService(
          tcg: TcgCatalogAdapter(),
          sports: SportsCatalogAdapter(),
        ));

/// 顶部分类 Tab 选中态。
final StateProvider<CatalogCategory> selectedCatalogCategoryProvider =
    StateProvider<CatalogCategory>(
        (ref) => CatalogCategory.tcgPokemon);

/// 搜索关键词（卡名 / 卡号 / 球员 / 系列），防抖由页面层处理。
final StateProvider<String> catalogSearchQueryProvider =
    StateProvider<String>((ref) => '');
