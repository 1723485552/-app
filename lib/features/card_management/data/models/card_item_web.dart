import '../../domain/enums/card_category.dart';
import '../../domain/enums/grading_company.dart';

/// Web 端卡牌模型（纯 Dart，无 Isar 依赖）。
///
/// 字段与方法与原生 [card_item_native] 的 CardItem 保持一致，仅去除
/// `@collection` / `Id` / `Isar` 等 Web 不支持的注解与类型，使 Web 构建可编译。
class CardItem {
  int id;
  final String cardName;
  final String cardNumber;
  final String imageUrl;
  final GradingCompany grading;
  final CardCategory category;
  final double? gradeScore;
  final String? certNumber;
  final double buyPrice;
  final double marketPrice;
  final DateTime buyDate;
  final bool isCollected;
  final double volume;
  final bool isWishlist;
  final double? targetPrice;
  final int wishlistPriority;
  final String priceHistoryJson;
  final String? centeringResult;

  CardItem({
    this.id = 0,
    required this.cardName,
    required this.cardNumber,
    required this.imageUrl,
    this.grading = GradingCompany.raw,
    this.category = CardCategory.all,
    this.gradeScore,
    this.certNumber,
    required this.buyPrice,
    required this.marketPrice,
    required this.buyDate,
    this.isCollected = true,
    this.volume = 0.0,
    this.isWishlist = false,
    this.targetPrice,
    this.wishlistPriority = 0,
    this.priceHistoryJson = '',
    this.centeringResult,
  });

  /// 利润 = 市场价格 - 买入价格
  double get profit => marketPrice - buyPrice;

  /// 基于买入价格的百分比收益率
  double get profitPercentage {
    if (buyPrice == 0) return 0.0;
    return (profit / buyPrice) * 100;
  }

  /// 返回一个新的 [CardItem]，用提供的非 null 参数覆盖对应字段
  CardItem copyWith({
    int? id,
    String? cardName,
    String? cardNumber,
    String? imageUrl,
    GradingCompany? grading,
    CardCategory? category,
    double? gradeScore,
    String? certNumber,
    double? buyPrice,
    double? marketPrice,
    DateTime? buyDate,
    bool? isCollected,
    double? volume,
    bool? isWishlist,
    double? targetPrice,
    int? wishlistPriority,
    String? priceHistoryJson,
    String? centeringResult,
  }) {
    return CardItem(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      cardNumber: cardNumber ?? this.cardNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      grading: grading ?? this.grading,
      category: category ?? this.category,
      gradeScore: gradeScore ?? this.gradeScore,
      certNumber: certNumber ?? this.certNumber,
      buyPrice: buyPrice ?? this.buyPrice,
      marketPrice: marketPrice ?? this.marketPrice,
      buyDate: buyDate ?? this.buyDate,
      isCollected: isCollected ?? this.isCollected,
      volume: volume ?? this.volume,
      isWishlist: isWishlist ?? this.isWishlist,
      targetPrice: targetPrice ?? this.targetPrice,
      wishlistPriority: wishlistPriority ?? this.wishlistPriority,
      priceHistoryJson: priceHistoryJson ?? this.priceHistoryJson,
      centeringResult: centeringResult ?? this.centeringResult,
    );
  }
}
