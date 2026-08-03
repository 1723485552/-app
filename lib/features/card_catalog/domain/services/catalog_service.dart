import '../enums/catalog_category.dart';
import '../models/catalog_page.dart';
import '../repositories/i_catalog_adapter.dart';

/// 图鉴服务（领域层编排）。
///
/// 依据品类在 TCG 与球星卡适配器之间路由，对 UI 屏蔽数据源差异；
/// 真实网络检索均经此唯一入口下发，保证全页数据联动一致。
class CatalogService {
  const CatalogService({
    required this.tcg,
    required this.sports,
  });

  final ICatalogAdapter tcg;
  final ICatalogAdapter sports;

  /// 分页检索；球星卡分支路由到 [sports]，其余路由到 [tcg]。
  Future<CatalogPage> searchPage(
    String query,
    CatalogCategory category,
    int page,
  ) {
    final ICatalogAdapter adapter = category.isSports ? sports : tcg;
    return adapter.searchPage(query, category, page);
  }
}
