import 'dart:convert';

/// 统一图鉴模型（跨 TCG 与球星卡的品类无关数据契约）。
///
/// 设计为纯 Dart 模型（非 Isar 集合）：图鉴与成交行情属外部参考数据源，
/// 不写入本地收藏库，从而完全不触及既有 Isar 持久化层与 Supabase 备份服务。
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.cardSet,
    required this.cardNumber,
    required this.imageUrl,
    required this.rarity,
    required this.releaseYear,
    this.extraFields = const <String, dynamic>{},
  });

  /// 数据源侧唯一标识（如 pokemontcg 卡 id、scryfall oracle id）。
  final String id;

  /// 卡牌名称。
  final String name;

  /// 品类键：tcg_pokemon / tcg_yugioh / tcg_mtg / sports_nba / sports_soccer。
  final String category;

  /// 所属系列 / 扩军（如 Base、Alpha、Prizm）。
  final String cardSet;

  /// 卡号（如 4、LOB-001、232）。
  final String cardNumber;

  /// 封面图地址（远程优先，加载失败自动降级为黑金卡背）。
  final String imageUrl;

  /// 稀有度（如 Rare Holo、Ultra Rare、Prizm）。
  final String rarity;

  /// 发行年份。
  final int releaseYear;

  /// 扩展字段：球星卡的球员 / 球队 / 编数，或 TCG 的额外属性（hp、属性等）。
  final Map<String, dynamic> extraFields;

  CatalogItem copyWith({
    String? id,
    String? name,
    String? category,
    String? cardSet,
    String? cardNumber,
    String? imageUrl,
    String? rarity,
    int? releaseYear,
    Map<String, dynamic>? extraFields,
  }) =>
      CatalogItem(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        cardSet: cardSet ?? this.cardSet,
        cardNumber: cardNumber ?? this.cardNumber,
        imageUrl: imageUrl ?? this.imageUrl,
        rarity: rarity ?? this.rarity,
        releaseYear: releaseYear ?? this.releaseYear,
        extraFields: extraFields ?? this.extraFields,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'category': category,
        'set': cardSet,
        'cardNumber': cardNumber,
        'imageUrl': imageUrl,
        'rarity': rarity,
        'releaseYear': releaseYear,
        'extraFields': extraFields,
      };

  /// 由 JSON 构造（Null Guard：缺省字段回落到安全默认值）。
  factory CatalogItem.fromJson(Map<String, dynamic> json) => CatalogItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        cardSet: json['set']?.toString() ?? json['cardSet']?.toString() ?? '',
        cardNumber: json['cardNumber']?.toString() ?? '',
        imageUrl: json['imageUrl']?.toString() ?? '',
        rarity: json['rarity']?.toString() ?? '',
        releaseYear: json['releaseYear'] is int
            ? json['releaseYear'] as int
            : int.tryParse(json['releaseYear']?.toString() ?? '') ?? 0,
        extraFields: json['extraFields'] is Map
            ? Map<String, dynamic>.from(json['extraFields'] as Map)
            : const <String, dynamic>{},
      );

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());
}
