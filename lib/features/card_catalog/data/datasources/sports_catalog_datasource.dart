import '../../domain/enums/catalog_category.dart';
import '../../domain/models/catalog_item.dart';
import '../../domain/models/catalog_page.dart';
import 'catalog_http.dart';

/// 球星卡图鉴真实数据源（TCDB 兼容）。
///
/// 球星卡（Panini / Topps / TCDB）无统一免费公开 API。本数据源在通过
/// `--dart-define=TCDB_API_KEY=xxx` 注入 Key 时发起真实请求；未配置 Key
/// 时返回空列表，由 UI 呈现「数据源未配置」空状态——**绝不以下载失败的
/// 脏数据或示例数据冒充真实结果**。
///
/// 接入真实 TCDB 时，请按你的套餐把端点 / 字段映射对齐下方解析逻辑
/// （约定响应含 `data[]`，每项含 `name` / `image` / `set` / `player` 等）。
class SportsCatalogDatasource {
  const SportsCatalogDatasource();

  static const String _apiKey = String.fromEnvironment('TCDB_API_KEY');
  static const String _base = 'https://www.tcdb.com/api/v1/cards';
  static const int pageSize = 20;

  static Future<CatalogPage> search(String query, int page) async {
    if (_apiKey.isEmpty) {
      return const CatalogPage(items: <CatalogItem>[], hasMore: false);
    }
    final int offset = (page - 1) * pageSize;
    final Map<String, String> qp = <String, String>{
      'apiKey': _apiKey,
      'limit': pageSize.toString(),
      'offset': offset.toString(),
    };
    final String q = query.trim();
    if (q.isNotEmpty) qp['search'] = q;
    final Uri uri = Uri.parse(_base).replace(queryParameters: qp);
    final Map<String, dynamic>? json = await catalogGetJson(uri.toString());
    final List<dynamic>? data =
        json?['data'] is List ? json!['data'] as List<dynamic> : null;
    if (data == null || data.isEmpty) {
      return const CatalogPage(items: <CatalogItem>[], hasMore: false);
    }
    final bool hasMore = data.length >= pageSize;
    final List<CatalogItem> items = data
        .map((e) => _toItem(e as Map<String, dynamic>))
        .where((CatalogItem i) => i.imageUrl.isNotEmpty)
        .toList();
    return CatalogPage(items: items, hasMore: hasMore);
  }

  static CatalogItem _toItem(Map<String, dynamic> c) {
    final dynamic img = c['image'] ?? c['imageUrl'] ?? c['images'];
    final String imageUrl = img is String
        ? img
        : (img is List && img.isNotEmpty ? img.first.toString() : '');
    return CatalogItem(
      id: c['id']?.toString() ?? '',
      name: c['name']?.toString() ?? '',
      category: CatalogCategory.sportsNba.key,
      cardSet: c['set']?.toString() ?? c['setName']?.toString() ?? '',
      cardNumber: c['number']?.toString() ?? '',
      imageUrl: imageUrl,
      rarity: c['rarity']?.toString() ?? '',
      releaseYear: int.tryParse(c['year']?.toString() ?? '') ?? 0,
      extraFields: <String, dynamic>{
        'player': c['player']?.toString() ?? '',
        'team': c['team']?.toString() ?? '',
        'serial': c['serial']?.toString() ?? '',
      },
    );
  }
}
