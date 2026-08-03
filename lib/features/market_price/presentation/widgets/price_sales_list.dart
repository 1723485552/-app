import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/price_comp_item.dart';

/// 平台图标映射（集换社 / 闲鱼 / eBay / 130point / TCGplayer）。
IconData pricePlatformIcon(String name) {
  if (name.contains('集换')) return Icons.storefront_outlined;
  if (name.contains('闲鱼')) return Icons.forum_outlined;
  if (name.contains('eBay')) return Icons.shopping_cart_outlined;
  if (name.contains('130')) return Icons.bar_chart_outlined;
  if (name.contains('TCG')) return Icons.style_outlined;
  return Icons.public_outlined;
}

String _symbol(String currency) => currency.toUpperCase() == 'USD' ? '\$' : '¥';

/// 跳转成交原文 / 原链接（不可达时静默忽略）。
Future<void> launchPriceSource(String url) async {
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {
    // 链接不可达不影响行情浏览。
  }
}

/// 单条成交记录行：平台图标 / 品相 / 成交时间 / 原价 + 人民币折算 / 跳转原文。
class PriceSaleRow extends StatelessWidget {
  const PriceSaleRow({super.key, required this.item});
  final PriceCompItem item;

  @override
  Widget build(BuildContext context) {
    final PriceCompItem s = item;
    return InkWell(
      onTap: s.sourceUrl == null ? null : () => launchPriceSource(s.sourceUrl!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.gold.bgPure,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.goldBorder, width: 0.5),
        ),
        child: Row(
          children: <Widget>[
            Icon(pricePlatformIcon(s.platformName),
                size: 20, color: AppColors.goldPrimary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(s.platformName,
                      style: TextStyle(
                          color: context.gold.textWhite, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(_date(s.soldDate),
                      style: TextStyle(
                          color: context.gold.textMuted, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text('${_symbol(s.currency)}${s.price.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: context.gold.textWhite, fontSize: 13)),
                const SizedBox(height: 2),
                Text('¥${s.priceInRmb.round()}',
                    style: const TextStyle(
                        color: AppColors.goldPrimary, fontSize: 11)),
              ],
            ),
            const SizedBox(width: 8),
            _gradeChip(context, s.conditionGrade),
          ],
        ),
      ),
    );
  }

  Widget _gradeChip(BuildContext context, String grade) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.goldGlow,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(grade,
            style:
                const TextStyle(color: AppColors.goldPrimary, fontSize: 9)),
      );
}

String _date(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
