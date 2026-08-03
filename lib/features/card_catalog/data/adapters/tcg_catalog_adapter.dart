import '../../domain/enums/catalog_category.dart';
import '../../domain/models/catalog_item.dart';
import '../../domain/models/catalog_page.dart';
import '../../domain/repositories/i_catalog_adapter.dart';
import '../datasources/mtg_catalog_datasource.dart';
import '../datasources/pokemon_catalog_datasource.dart';
import '../datasources/yugioh_catalog_datasource.dart';

/// TCG 图鉴适配器：按品类路由到 PokémonTCG / Scryfall / YGOProDeck 真实数据源。
///
/// 无 Mock 数据：任何查询均发起真实网络请求；网络异常 / 限流 / 无结果时
/// 返回空列表，由 UI 呈现空状态（绝不以下载失败的脏数据冒充真实结果）。
class TcgCatalogAdapter implements ICatalogAdapter {
  const TcgCatalogAdapter();

  @override
  bool get supportsSports => false;

  @override
  Future<CatalogPage> searchPage(
    String query,
    CatalogCategory category,
    int page,
  ) async {
    if (category.isSports) {
      return const CatalogPage(items: <CatalogItem>[], hasMore: false);
    }
    switch (category) {
      case CatalogCategory.tcgPokemon:
        return PokemonCatalogDatasource.search(query, page);
      case CatalogCategory.tcgYugioh:
        return YugiohCatalogDatasource.search(query, page);
      case CatalogCategory.tcgMtg:
        return MtgCatalogDatasource.search(query, page);
      default:
        return const CatalogPage(items: <CatalogItem>[], hasMore: false);
    }
  }

  @override
  Future<CatalogItem?> getById(String id) async => null;
}
