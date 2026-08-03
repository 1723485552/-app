import '../../domain/enums/catalog_category.dart';
import '../../domain/models/catalog_item.dart';
import '../../domain/models/catalog_page.dart';
import '../../domain/repositories/i_catalog_adapter.dart';
import '../datasources/sports_catalog_datasource.dart';

/// 球星卡图鉴适配器：适配 TCDB 真实数据源（需 `--dart-define=TCDB_API_KEY`）。
///
/// 未配置 Key 时返回空列表并由 UI 呈现「数据源未配置」空状态；
/// 已配置 Key 时发起真实请求并按品类（NBA / 足球）过滤结果。
class SportsCatalogAdapter implements ICatalogAdapter {
  const SportsCatalogAdapter();

  @override
  bool get supportsSports => true;

  @override
  Future<CatalogPage> searchPage(
    String query,
    CatalogCategory category,
    int page,
  ) async {
    if (!category.isSports) {
      return const CatalogPage(items: <CatalogItem>[], hasMore: false);
    }
    final CatalogPage pageResult =
        await SportsCatalogDatasource.search(query, page);
    if (query.trim().isEmpty) return pageResult;
    final String q = query.trim().toLowerCase();
    final List<CatalogItem> filtered = pageResult.items.where((CatalogItem i) {
      final String hay =
          '${i.name} ${i.cardSet} ${(i.extraFields['player'] ?? '')} '
          '${(i.extraFields['team'] ?? '')}'.toLowerCase();
      return hay.contains(q);
    }).toList();
    return CatalogPage(items: filtered, hasMore: pageResult.hasMore);
  }

  @override
  Future<CatalogItem?> getById(String id) async => null;
}
