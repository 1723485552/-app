import '../../features/card_management/domain/enums/currency_unit.dart';

/// 全局货币格式化工具（黑金资产统一展示）。
///
/// 合并原 [money_format] 的单元换算与 [AssetBanner] 内的 [_formatYuan]，
/// 提供「千分位 + 货币符号切换」的统一入口，供全项目复用，杜绝重复实现。
class CurrencyFormatter {
  CurrencyFormatter._();

  /// 静态汇率：1 USD = 7.2 CNY（演示用固定档位，真实场景应接入行情接口）。
  static const double _usdRate = 7.2;

  /// 将数值格式化为带货币符号的千分位字符串（整数金额，与旧实现语义一致）。
  ///
  /// 例：format(1610) -> '¥1,610'；format(1234567, symbol: '\$') -> '\$1,234,567'。
  static String format(num value, {String symbol = '¥'}) =>
      '$symbol${_group(value)}';

  /// 以人民币计的价值按所选 [unit] 换算并格式化（兼容旧 [formatMoney] 语义）。
  static String formatCny(double cnyValue, CurrencyUnit unit) {
    final double value =
        unit == CurrencyUnit.cny ? cnyValue : cnyValue / _usdRate;
    return format(value, symbol: currencySymbol(unit));
  }

  /// 千分位分组（整数，负数符号保持在最前）。
  static String _group(num value) {
    final String raw = value.round().toString();
    final bool negative = raw.startsWith('-');
    final String digits = negative ? raw.substring(1) : raw;
    final StringBuffer out = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) out.write(',');
      out.write(digits[i]);
      count++;
    }
    final String grouped = out.toString().split('').reversed.join();
    return negative ? '-$grouped' : grouped;
  }
}
