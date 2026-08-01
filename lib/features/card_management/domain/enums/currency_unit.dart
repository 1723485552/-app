/// 货币单位枚举（偏好设置：CNY ¥ / USD $）。
enum CurrencyUnit {
  /// 人民币
  cny,

  /// 美元
  usd,
}

/// 货币符号（¥ / $）。
String currencySymbol(CurrencyUnit unit) => unit == CurrencyUnit.cny ? '¥' : '\$';

/// 货币中文标签（偏好设置展示用）。
String currencyLabel(CurrencyUnit unit) =>
    unit == CurrencyUnit.cny ? '人民币 CNY' : '美元 USD';
