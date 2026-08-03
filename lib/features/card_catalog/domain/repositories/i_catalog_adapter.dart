import '../models/catalog_item.dart';
import '../models/catalog_page.dart';
import '../enums/catalog_category.dart';

/// 图鉴适配器接口（领域层契约）。
///
/// 解耦 UI 与具体数据源（PokémonTCG.io / Scryfall / YGOProDeck / TCDB）。
/// 真实实现 [TcgCatalogAdapter] 与 [SportsCatalogAdapter] 各自封装对应协议，
/// UI 仅依赖本接口，新增数据源只需新增实现并注入 [CatalogService]。
abstract class ICatalogAdapter {
  /// 按关键词 + 品类分页检索图鉴条目。
  ///
  /// [query] 支持卡名 / 卡号 / 球员 / 系列；空串表示不过滤。
  /// [category] 指定目标品类（已限定为单一 TCG 或球星卡分支）。
  /// [page] 从 1 开始的页码。返回 [CatalogPage]（含是否还有更多）。
  Future<CatalogPage> searchPage(
    String query,
    CatalogCategory category,
    int page,
  );

  /// 拉取单条图鉴详情（当前复用检索路径；真实模式可独立请求详情接口）。
  Future<CatalogItem?> getById(String id);

  /// 是否服务球星卡分支（用于 [CatalogService] 路由）。
  bool get supportsSports;
}
