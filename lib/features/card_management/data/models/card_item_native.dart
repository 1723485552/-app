import 'package:isar/isar.dart';

import '../../domain/enums/card_category.dart';
import '../../domain/enums/grading_company.dart';

// 运行前需执行代码生成：flutter pub run build_runner build
// 该命令会生成 card_item_native.g.dart，其中包含 CardItemSchema 与 Isar 适配器。
part 'card_item_native.g.dart';

/// 卡牌条目数据模型（Isar 持久化集合）
@collection
class CardItem {
  /// Isar 自增主键
  Id id = Isar.autoIncrement;

  /// 卡牌名称
  final String cardName;

  /// 卡牌编号
  final String cardNumber;

  /// 图片地址
  final String imageUrl;

  /// 评级公司，默认裸卡（以 name 形式存储为字符串）
  @Enumerated(EnumType.name)
  final GradingCompany grading;

  /// 卡牌分类（以 name 形式存储为字符串）
  @Enumerated(EnumType.name)
  final CardCategory category;

  /// 评级分数（可空）
  final double? gradeScore;

  /// 评级证书号（可空）
  final String? certNumber;

  /// 买入价格
  final double buyPrice;

  /// 当前市场价格
  final double marketPrice;

  /// 买入日期
  final DateTime buyDate;

  /// 是否已收入收藏（true=已收集，false=心愿单）
  final bool isCollected;

  /// 成交热度（行情榜单维度，模拟真实成交体量）
  final double volume;

  /// 是否为心愿单（true=心愿单，不计入已投入总资产）
  final bool isWishlist;

  /// 目标心理价位（心愿单专用，可空）
  final double? targetPrice;

  /// 心愿等级 1~5 星
  final int wishlistPriority;

  /// 近 30 日价格走势（JSON 数组字符串，行情模块使用；空串表示尚无数据）
  final String priceHistoryJson;

  /// 居中度测量结果（格式化字符串，如 "L/R: 52/48 | T/B: 51/49"；未测量为 null）
  final String? centeringResult;

  CardItem({
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

  /// 利润 = 市场价格 - 买入价格。
  ///
  /// 以 [@ignore] 声明：Isar 3.1 不持久化该计算型 getter（无 `@Computed()` 注解），
  /// 仅作为 Dart 运行期派生值使用，避免生成器误将其当作存储字段。
  @ignore
  double get profit => marketPrice - buyPrice;

  /// 基于买入价格的百分比收益率。
  ///
  /// 同 [profit]，以 [@ignore] 声明，纯运行期派生值，不参与 Isar 持久化。
  @ignore
  double get profitPercentage {
    if (buyPrice == 0) return 0.0;
    return (profit / buyPrice) * 100;
  }

  /// 返回一个新的 [CardItem]，用提供的非 null 参数覆盖对应字段
  CardItem copyWith({
    Id? id,
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
    )..id = id ?? this.id;
  }
}
