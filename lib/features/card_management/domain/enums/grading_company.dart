/// 卡牌评级公司枚举。
///
/// 与 [CardItem.grading] 的持久化方式保持一致：以 `EnumType.name` 存储，
/// 可安全向后扩展新公司而无需迁移历史数据。
enum GradingCompany {
  /// 裸卡（未评级）
  raw,

  /// Professional Sports Authenticator
  psa,

  /// Beckett Grading Services
  bgs,

  /// Certified Guaranty Company
  cgc,
}
