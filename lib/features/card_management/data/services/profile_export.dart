import 'dart:convert';

import '../../domain/enums/card_category.dart';
import '../../domain/enums/grading_company.dart';
import '../models/card_item.dart';

/// 共享纯函数：卡牌资产导出 / 备份的序列化与解析（无任何平台依赖，原生与 Web 共用）。
///
/// CSV 用于「导出资产账单」，JSON 用于「备份 / 恢复本地数据库」。

/// 生成资产账单 CSV（含表头，字段与 [CardItem] 一一对应）。
String buildCardsCsv(List<CardItem> cards) {
  final StringBuffer sb = StringBuffer();
  sb.writeln(<String>[
    '卡牌名称',
    '卡牌编号',
    '评级公司',
    '分类',
    '评级分数',
    '买入价',
    '当前价',
    '收益率%',
    '已收集',
    '成交热度',
    '买入日期',
  ].join(','));
  for (final CardItem c in cards) {
    sb.writeln(<String>[
      c.cardName,
      c.cardNumber,
      c.grading.name,
      c.category.name,
      (c.gradeScore ?? 0).toStringAsFixed(1),
      c.buyPrice.toStringAsFixed(2),
      c.marketPrice.toStringAsFixed(2),
      c.profitPercentage.toStringAsFixed(1),
      c.isCollected ? '是' : '否',
      c.volume.toStringAsFixed(0),
      '${c.buyDate.year}-${c.buyDate.month}-${c.buyDate.day}',
    ].join(','));
  }
  return sb.toString();
}

/// 生成数据库备份 JSON（保留全部字段，含 id 以便溯源）。
String buildCardsBackupJson(List<CardItem> cards) {
  final List<Map<String, Object?>> list = cards.map((CardItem c) => <String, Object?>{
        'cardName': c.cardName,
        'cardNumber': c.cardNumber,
        'imageUrl': c.imageUrl,
        'grading': c.grading.name,
        'category': c.category.name,
        'gradeScore': c.gradeScore,
        'certNumber': c.certNumber,
        'buyPrice': c.buyPrice,
        'marketPrice': c.marketPrice,
        'buyDate': c.buyDate.toIso8601String(),
        'isCollected': c.isCollected,
        'volume': c.volume,
        'isWishlist': c.isWishlist,
        'targetPrice': c.targetPrice,
        'wishlistPriority': c.wishlistPriority,
        'priceHistoryJson': c.priceHistoryJson,
      }).toList();
  return const JsonEncoder.withIndent('  ')
      .convert(<String, Object?>{'cards': list});
}

/// 解析备份 JSON 为卡牌列表（id 由本地库重新分配，故不回填）。
List<CardItem> parseBackupJson(String json) {
  final Map<String, Object?> data =
      jsonDecode(json) as Map<String, Object?>;
  final List<Object?> raw = (data['cards'] as List<Object?>?) ?? <Object?>[];
  return raw.map((Object? e) {
    final Map<String, Object?> m = e as Map<String, Object?>;
    return CardItem(
      cardName: m['cardName'] as String,
      cardNumber: m['cardNumber'] as String,
      imageUrl: m['imageUrl'] as String? ?? '',
      grading: GradingCompany.values.firstWhere(
        (GradingCompany g) => g.name == m['grading'],
        orElse: () => GradingCompany.raw,
      ),
      category: CardCategory.values.firstWhere(
        (CardCategory c) => c.name == m['category'],
        orElse: () => CardCategory.all,
      ),
      gradeScore: (m['gradeScore'] as num?)?.toDouble(),
      certNumber: m['certNumber'] as String?,
      buyPrice: (m['buyPrice'] as num?)?.toDouble() ?? 0,
      marketPrice: (m['marketPrice'] as num?)?.toDouble() ?? 0,
      buyDate: DateTime.tryParse(m['buyDate'] as String? ?? '') ?? DateTime.now(),
      isCollected: m['isCollected'] as bool? ?? true,
      volume: (m['volume'] as num?)?.toDouble() ?? 0,
      isWishlist: m['isWishlist'] as bool? ?? false,
      targetPrice: (m['targetPrice'] as num?)?.toDouble(),
      wishlistPriority: (m['wishlistPriority'] as num?)?.toInt() ?? 0,
      priceHistoryJson: m['priceHistoryJson'] as String? ?? '',
    );
  }).toList();
}
