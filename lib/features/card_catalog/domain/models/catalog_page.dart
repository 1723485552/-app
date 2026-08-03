import 'catalog_item.dart';

/// 图鉴分页结果（单页检索输出）。
///
/// [items] 为本页条目；[hasMore] 标识是否仍存在后续页，供无限滚动判定。
class CatalogPage {
  const CatalogPage({
    required this.items,
    required this.hasMore,
  });

  final List<CatalogItem> items;
  final bool hasMore;
}
