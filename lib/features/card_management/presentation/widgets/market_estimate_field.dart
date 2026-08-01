import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gold_snack_bar.dart';
import '../../domain/enums/card_category.dart';
import '../../domain/services/market_price_api_service.dart';

/// 估值输入框 + 香槟金「自动估值」按钮。
///
/// 点击发起真实 Scrydex 行情请求，自动回填估值并回调真实走势 JSON；
/// 无密钥 / 无数据 / 异常时以 [GoldSnackBar] 提示，绝不伪造任何数值。
class MarketEstimateField extends ConsumerStatefulWidget {
  const MarketEstimateField({
    super.key,
    required this.marketController,
    required this.nameController,
    required this.numberController,
    this.category,
    required this.onHistoryFetched,
  });
  final TextEditingController marketController;
  final TextEditingController nameController;
  final TextEditingController numberController;
  final CardCategory? category;
  final ValueChanged<String> onHistoryFetched;

  @override
  ConsumerState<MarketEstimateField> createState() => _MarketEstimateFieldState();
}

class _MarketEstimateFieldState extends ConsumerState<MarketEstimateField> {
  bool _loading = false;

  Future<void> _estimate() async {
    final String name = widget.nameController.text.trim();
    if (name.isEmpty) {
      GoldSnackBar.show(context, '请先填写卡牌名称再自动估值');
      return;
    }
    setState(() => _loading = true);
    try {
      final MarketQuote? quote = await ref
          .read(marketPriceServiceProvider)
          .fetchQuote(name, widget.numberController.text.trim(),
              category: widget.category);
      if (!mounted) return;
      if (quote == null) {
        GoldSnackBar.show(context, '暂未获取到行情，请手动填写估值');
        return;
      }
      widget.marketController.text = quote.priceCny.toStringAsFixed(2);
      widget.onHistoryFetched(quote.historyJson);
      HapticFeedback.lightImpact();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _label(context),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: widget.marketController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: context.gold.textWhite, fontSize: 14),
                    decoration: _dec(context).copyWith(
                      hintText: '0.0 (选填，默认 0)',
                      hintStyle: TextStyle(
                          color: context.gold.textInactive, fontSize: 13),
                    ),
                    validator: (String? v) {
                      if (v != null &&
                          v.trim().isNotEmpty &&
                          double.tryParse(v) == null) {
                        return '请输入数字';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                _autoBtn(context),
              ],
            ),
          ],
        ),
      );

  Widget _label(BuildContext context) => Text('当前估值 (¥)',
      style: TextStyle(color: context.gold.textMuted, fontSize: 12));

  InputDecoration _dec(BuildContext context) => InputDecoration(
        filled: true,
        fillColor: context.gold.surfaceDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: AppColors.goldPrimary.withValues(alpha: 0.2), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.goldPrimary, width: 0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: AppColors.goldPrimary.withValues(alpha: 0.2), width: 0.5),
        ),
      );

  Widget _autoBtn(BuildContext context) => SizedBox(
        height: 44,
        child: ElevatedButton.icon(
          onPressed: _loading ? null : _estimate,
          icon: _loading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: context.gold.bgPure))
              : const Icon(Icons.bolt, size: 16),
          label: Text(_loading ? '估值中' : '自动估值',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.goldPrimary,
            foregroundColor: context.gold.bgPure,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
      );
}
