import '../../../../core/database/app_database.dart';
import '../../domain/enums/card_category.dart';
import '../../domain/enums/grading_company.dart';
import '../models/card_item.dart';

/// [CardItem]（领域模型 / Isar 集合）与 [CardRow]（Drift SQLite 行）之间的双向映射。
///
/// 映射约定：
/// - Drift `id` 存 [CardItem.id] 的字符串形式，Isar 自增主键仍是 id 的唯一权威来源；
/// - Drift `name` ↔ [CardItem.cardName]，`centeringData` ↔ [CardItem.centeringResult]；
/// - 枚举一律按 `name` 字符串存取，未知值兜底为默认项，杜绝历史数据解析崩溃；
/// - `catalogId` / `imagePaths` / `createdAt` / `isSynced` 为 Drift 侧新增列，
///   [CardItem] 暂无对应字段，写入时给出安全默认值，读取时忽略，确保 UI 不受影响。
class CardRowMapper {
  const CardRowMapper._();

  /// 领域模型 → Drift 行。
  ///
  /// [createdAt] / [catalogId] / [imagePaths] 传入既有行的值可避免更新时被重置；
  /// 不传则使用首次写入的默认值。
  static CardRow toRow(
    CardItem item, {
    String? catalogId,
    String? imagePaths,
    DateTime? createdAt,
    bool isSynced = false,
  }) {
    return CardRow(
      id: item.id.toString(),
      catalogId: catalogId ?? '',
      name: item.cardName,
      cardNumber: item.cardNumber,
      setName: item.setName,
      imageUrl: item.imageUrl,
      grading: item.grading.name,
      category: item.category.name,
      gradeScore: item.gradeScore,
      certNumber: item.certNumber,
      buyPrice: item.buyPrice,
      marketPrice: item.marketPrice,
      buyDate: item.buyDate,
      isCollected: item.isCollected,
      volume: item.volume,
      isWishlist: item.isWishlist,
      targetPrice: item.targetPrice,
      wishlistPriority: item.wishlistPriority,
      priceHistoryJson: item.priceHistoryJson,
      centeringData: item.centeringResult,
      imagePaths: imagePaths ?? '[]',
      createdAt: createdAt ?? DateTime.now(),
      isSynced: isSynced,
    );
  }

  /// Drift 行 → 领域模型。
  static CardItem toItem(CardRow row) {
    return CardItem(
      cardName: row.name,
      cardNumber: row.cardNumber,
      setName: row.setName,
      imageUrl: row.imageUrl,
      grading: _parseGrading(row.grading),
      category: _parseCategory(row.category),
      gradeScore: row.gradeScore,
      certNumber: row.certNumber,
      buyPrice: row.buyPrice,
      marketPrice: row.marketPrice,
      buyDate: row.buyDate,
      isCollected: row.isCollected,
      volume: row.volume,
      isWishlist: row.isWishlist,
      targetPrice: row.targetPrice,
      wishlistPriority: row.wishlistPriority,
      priceHistoryJson: row.priceHistoryJson,
      centeringResult: row.centeringData,
    )..id = int.tryParse(row.id) ?? 0;
  }

  /// 未知评级公司兜底为裸卡，避免旧数据/脏数据导致解析异常。
  static GradingCompany _parseGrading(String raw) {
    for (final GradingCompany value in GradingCompany.values) {
      if (value.name == raw) return value;
    }
    return GradingCompany.raw;
  }

  /// 未知分类兜底为「全部」。
  static CardCategory _parseCategory(String raw) {
    for (final CardCategory value in CardCategory.values) {
      if (value.name == raw) return value;
    }
    return CardCategory.all;
  }
}
