import '../../domain/enums/catalog_category.dart';
import '../../domain/models/catalog_item.dart';
import '../../domain/models/catalog_page.dart';
import 'catalog_http.dart';

/// 万智牌图鉴真实数据源（Scryfall API）。
///
/// 接口：`https://api.scryfall.com/cards/search`
/// - 按关键词：`q=xxx`（留空时默认 `year>=2023` 取近期）；
/// - 分页：`page`，响应 `has_more` 标识后续页；
/// - 高清图：`image_uris.large` / `png`（多面卡回退至首面）。
/// - 需设置 `User-Agent`（Scryfall 规范要求）。
class MtgCatalogDatasource {
  const MtgCatalogDatasource();

  static const String _base = 'https://api.scryfall.com/cards/search';

  static Future<CatalogPage> search(String query, int page) async {
    final String q = query.trim().isNotEmpty ? query.trim() : 'year>=2023';
    final Uri uri = Uri.parse(_base).replace(queryParameters: <String, String>{
      'q': q,
      'page': page.toString(),
    });
    final Map<String, String> headers =
        <String, String>{'User-Agent': 'card-collector-app'};
    final Map<String, dynamic>? json =
        await catalogGetJson(uri.toString(), headers: headers);
    final List<dynamic>? data =
        json?['data'] is List ? json!['data'] as List<dynamic> : null;
    if (data == null) {
      return const CatalogPage(items: <CatalogItem>[], hasMore: false);
    }
    final bool hasMore = json?['has_more'] == true;
    final List<CatalogItem> items = data
        .map((e) => _toItem(e as Map<String, dynamic>))
        .where((CatalogItem i) => i.imageUrl.isNotEmpty)
        .toList();
    return CatalogPage(items: items, hasMore: hasMore);
  }

  static CatalogItem _toItem(Map<String, dynamic> c) {
    final Map<String, dynamic> images = c['image_uris'] is Map
        ? Map<String, dynamic>.from(c['image_uris'])
        : <String, dynamic>{};
    String imageUrl = images['large']?.toString() ?? images['png']?.toString() ?? '';
    if (imageUrl.isEmpty) {
      final List<dynamic> faces =
          c['card_faces'] is List ? c['card_faces'] as List<dynamic> : <dynamic>[];
      final Map<String, dynamic> faceImages = faces.isNotEmpty &&
              faces.first is Map
          ? Map<String, dynamic>.from(faces.first['image_uris'] ?? <String, dynamic>{})
          : <String, dynamic>{};
      imageUrl =
          faceImages['large']?.toString() ?? faceImages['png']?.toString() ?? '';
    }
    final Map<String, dynamic> set =
        c['set'] is Map ? Map<String, dynamic>.from(c['set']) : <String, dynamic>{};
    final String released = c['released_at']?.toString().split('-').first ?? '';
    return CatalogItem(
      id: c['id']?.toString() ?? '',
      name: c['name']?.toString() ?? '',
      category: CatalogCategory.tcgMtg.key,
      cardSet: set['name']?.toString() ?? '',
      cardNumber: c['collector_number']?.toString() ?? '',
      imageUrl: imageUrl,
      rarity: c['rarity']?.toString() ?? '',
      releaseYear: int.tryParse(released) ?? 0,
      extraFields: <String, dynamic>{
        'mana_cost': c['mana_cost']?.toString() ?? '',
        'type_line': c['type_line']?.toString() ?? '',
        'price_usd': c['prices'] is Map
            ? (c['prices']['usd']?.toString() ?? '')
            : '',
      },
    );
  }
}
