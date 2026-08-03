import '../../domain/enums/catalog_category.dart';
import '../../domain/models/catalog_item.dart';
import '../../domain/models/catalog_page.dart';
import 'catalog_http.dart';

/// 游戏王图鉴真实数据源（YGOProDeck API）。
///
/// 接口：`https://db.ygoprodeck.com/api/v7/cardinfo.php`
/// - 按卡名：`fname=xxx`；留空返回全部（分页）。
/// - 分页参数为公开接口的 `num` / `offset`（多取一条以判定是否有下一页）。
/// - 高清图：`card_images[0].image_url`。
class YugiohCatalogDatasource {
  const YugiohCatalogDatasource();

  static const String _base = 'https://db.ygoprodeck.com/api/v7/cardinfo.php';
  static const int pageSize = 20;

  static Future<CatalogPage> search(String query, int page) async {
    final int offset = (page - 1) * pageSize;
    final Map<String, String> qp = <String, String>{
      'num': (pageSize + 1).toString(),
      'offset': offset.toString(),
    };
    final String q = query.trim();
    if (q.isNotEmpty) qp['fname'] = q;
    final Uri uri = Uri.parse(_base).replace(queryParameters: qp);
    final Map<String, dynamic>? json = await catalogGetJson(uri.toString());
    final List<dynamic>? data =
        json?['data'] is List ? json!['data'] as List<dynamic> : null;
    if (data == null || data.isEmpty) {
      return const CatalogPage(items: <CatalogItem>[], hasMore: false);
    }
    final bool hasMore = data.length > pageSize;
    final List<dynamic> slice = hasMore ? data.sublist(0, pageSize) : data;
    final List<CatalogItem> items = slice
        .map((e) => _toItem(e as Map<String, dynamic>))
        .where((CatalogItem i) => i.imageUrl.isNotEmpty)
        .toList();
    return CatalogPage(items: items, hasMore: hasMore);
  }

  static CatalogItem _toItem(Map<String, dynamic> c) {
    final List<dynamic> images =
        c['card_images'] is List ? c['card_images'] as List<dynamic> : <dynamic>[];
    final String imageUrl = images.isNotEmpty
        ? (images.first['image_url']?.toString() ?? '')
        : '';
    final List<dynamic> sets =
        c['card_sets'] is List ? c['card_sets'] as List<dynamic> : <dynamic>[];
    final String setName =
        sets.isNotEmpty ? sets.first['set_name']?.toString() ?? '' : '';
    return CatalogItem(
      id: c['id']?.toString() ?? '',
      name: c['name']?.toString() ?? '',
      category: CatalogCategory.tcgYugioh.key,
      cardSet: setName,
      cardNumber: c['card_number']?.toString() ?? '',
      imageUrl: imageUrl,
      rarity: c['card_rarity']?.toString() ?? '',
      releaseYear: 0,
      extraFields: <String, dynamic>{
        'type': c['type']?.toString() ?? '',
        'attribute': c['attribute']?.toString() ?? '',
        'race': c['race']?.toString() ?? '',
        'level': c['level']?.toString() ?? '',
        'atk': c['atk']?.toString() ?? '',
        'def': c['def']?.toString() ?? '',
      },
    );
  }
}
