import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import 'package:card_management/core/theme/app_colors.dart';
import 'package:card_management/features/market_price/data/config/market_config.dart';
import '../../domain/models/price_comp_item.dart';
import '../providers/price_providers.dart';
import 'price_sales_list.dart';
import 'price_trend_chart_card.dart';

/// 卡片详情页：国内外成交价行情组件。
///
/// 顶部 Tab 切换【国内成交 / 国外成交】，配 30/90 天走势图与成交明细列表；
/// 列表项点击可跳转原文 / 原链接（[PriceCompItem.sourceUrl] 非空时）。
class MarketPriceWidget extends ConsumerWidget {
  const MarketPriceWidget({
    super.key,
    required this.cardName,
    required this.cardNo,
  });
  final String cardName;
  final String cardNo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool domestic = ref.watch(selectedMarketTabProvider);
    final int range = ref.watch(selectedPriceRangeProvider);
    final AsyncValue<List<PriceCompItem>> asyncSales =
        ref.watch(priceSalesProvider((cardName, cardNo)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _segment(context, ref, domestic),
        const SizedBox(height: 12),
        _rangeToggle(context, ref, range),
        const SizedBox(height: 16),
        asyncSales.when(
          loading: () => const Center(
              child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.goldPrimary))),
          error: (_, __) => _state(context, '行情加载失败', Icons.cloud_off_outlined),
          data: (List<PriceCompItem> sales) {
            final DateTime cutoff =
                DateTime.now().subtract(Duration(days: range));
            final List<PriceCompItem> inRange = sales
                .where((PriceCompItem s) =>
                    s.isDomestic == domestic && s.soldDate.isAfter(cutoff))
                .toList()
              ..sort((a, b) => a.soldDate.compareTo(b.soldDate));
            final List<double> series =
                inRange.map((PriceCompItem s) => s.priceInRmb).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PriceTrendChartCard(prices: series),
                const SizedBox(height: 18),
                if (useSampleData) _sampleBadge(context),
                const SizedBox(height: 8),
                _listHeader(context, inRange.length),
                const SizedBox(height: 8),
                if (inRange.isEmpty)
                  _state(context, '该区间暂无成交', Icons.receipt_long_outlined)
                else
                  ...inRange.map((PriceCompItem s) => PriceSaleRow(item: s)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _segment(BuildContext context, WidgetRef ref, bool domestic) => Row(
        children: <Widget>[
          _segBtn(context, '国内成交', domestic, true, ref),
          const SizedBox(width: 8),
          _segBtn(context, '国外成交', domestic, false, ref),
        ],
      );

  Widget _segBtn(BuildContext context, String label, bool current, bool value,
          WidgetRef ref) =>
      Expanded(
        child: GestureDetector(
          onTap: () =>
              ref.read(selectedMarketTabProvider.notifier).state = value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: current == value
                  ? AppColors.goldPrimary
                  : context.gold.bgPure,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.goldBorder, width: 0.5),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: current == value
                      ? context.gold.bgDark
                      : context.gold.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _rangeToggle(BuildContext context, WidgetRef ref, int range) => Row(
        children: <Widget>[
          _rangeChip(context, '近 30 天', 30, range, ref),
          const SizedBox(width: 8),
          _rangeChip(context, '近 90 天', 90, range, ref),
        ],
      );

  Widget _rangeChip(BuildContext context, String label, int value, int current,
          WidgetRef ref) =>
      GestureDetector(
        onTap: () =>
            ref.read(selectedPriceRangeProvider.notifier).state = value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: current == value ? AppColors.goldGlow : context.gold.bgPure,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.goldBorder, width: 0.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: current == value
                  ? AppColors.goldPrimary
                  : context.gold.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

  Widget _listHeader(BuildContext context, int count) => Row(
        children: <Widget>[
          Text('成交明细',
              style: TextStyle(
                  color: context.gold.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('$count 条',
              style: TextStyle(color: context.gold.textMuted, fontSize: 12)),
        ],
      );

  Widget _state(BuildContext context, String text, IconData icon) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: <Widget>[
              Icon(icon, size: 40, color: context.gold.textInactive),
              const SizedBox(height: 10),
              Text(text,
                  style: TextStyle(color: context.gold.textMuted, fontSize: 13)),
            ],
          ),
        ),
      );

  Widget _sampleBadge(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.goldGlow,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text('示例数据',
            style: TextStyle(color: AppColors.goldPrimary, fontSize: 10)),
      );
}
