import '../../domain/enums/catalog_category.dart';
import '../../domain/models/catalog_item.dart';
import '../../domain/models/catalog_page.dart';
import 'catalog_http.dart';

/// 宝可梦图鉴真实数据源（PokémonTCG.io v2）。
///
/// 接口：`https://api.pokemontcg.io/v2/cards`
/// - 按卡名：`q=name:xxx`；留空则返回全量（分页）。
/// - 高清图：`images.large`。
/// - 鉴权：可选，通过 `--dart-define=POKEMON_TCG_API_KEY=xxx` 注入 `X-Api-Key`，
///   不注入时仍可访问（仅受公共速率限制）。
class PokemonCatalogDatasource {
  const PokemonCatalogDatasource();

  static const String _base = 'https://api.pokemontcg.io/v2/cards';
  static const String _apiKey = String.fromEnvironment('POKEMON_TCG_API_KEY');
  static const int pageSize = 20;

  static Future<CatalogPage> search(String query, int page) async {
    final Map<String, String> qp = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    final String q = query.trim();
    if (q.isNotEmpty) qp['q'] = 'name:$q';
    final Uri uri = Uri.parse(_base).replace(queryParameters: qp);
    final Map<String, String>? headers =
        _apiKey.isNotEmpty ? <String, String>{'X-Api-Key': _apiKey} : null;
    final Map<String, dynamic>? json =
        await catalogGetJson(uri.toString(), headers: headers);
    final List<dynamic>? data =
        json?['data'] is List ? json!['data'] as List<dynamic> : null;
    if (data == null) return const CatalogPage(items: <CatalogItem>[], hasMore: false);
    final List<CatalogItem> items = data
        .map((e) => _toItem(e as Map<String, dynamic>))
        .where((CatalogItem i) => i.imageUrl.isNotEmpty)
        .toList();
    final int total = json?['totalCount'] is int ? json!['totalCount'] as int : 0;
    final bool hasMore = total == 0 ? false : page * pageSize < total;
    return CatalogPage(items: items, hasMore: hasMore);
  }

  static CatalogItem _toItem(Map<String, dynamic> c) {
    final Map<String, dynamic> set =
        c['set'] is Map ? Map<String, dynamic>.from(c['set']) : <String, dynamic>{};
    final Map<String, dynamic> images = c['images'] is Map
        ? Map<String, dynamic>.from(c['images'])
        : <String, dynamic>{};
    final String release = set['releaseDate']?.toString().split('-').first ?? '';
    return CatalogItem(
      id: c['id']?.toString() ?? '',
      name: c['name']?.toString() ?? '',
      category: CatalogCategory.tcgPokemon.key,
      cardSet: set['name']?.toString() ?? '',
      cardNumber: c['number']?.toString() ?? '',
      imageUrl: images['large']?.toString() ?? images['small']?.toString() ?? '',
      rarity: c['rarity']?.toString() ?? '',
      releaseYear: int.tryParse(release) ?? 0,
      extraFields: <String, dynamic>{
        'hp': c['hp']?.toString() ?? '',
        'types': (c['types'] as List?)?.join('/') ?? '',
      },
    );
  }
}
