import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/gold_stat_tile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/card_item.dart';
import '../../domain/enums/card_category.dart';
import '../providers/card_providers.dart';

/// 资产大盘 Banner。
///
/// 监听 [categoryFilteredCardsProvider]，切换分类时以 300ms 平滑过渡重算
/// 总资产 / 总成本 / 总盈亏，并优雅处理 loading / error / empty 三态。
class AssetBanner extends ConsumerWidget {
  const AssetBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CardItem>> asyncCards =
        ref.watch(categoryFilteredCardsProvider);
    final CardCategory category = ref.watch(selectedCategoryProvider);
    return asyncCards.when(
      loading: () => const _BannerState(text: '加载中…'),
      error: (_, __) => const _BannerState(text: '数据加载失败'),
      data: (List<CardItem> cards) {
        if (cards.isEmpty) {
          return const _BannerState(text: '该分类暂无卡牌');
        }
        final double totalMarket =
            cards.fold<double>(0, (double s, CardItem c) => s + c.marketPrice);
        final double totalCost =
            cards.fold<double>(0, (double s, CardItem c) => s + c.buyPrice);
        final double profit = totalMarket - totalCost;
        final double profitPct =
            totalCost > 0 ? (profit / totalCost) * 100 : 0.0;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _BannerContent(
            key: ValueKey<CardCategory>(category),
            totalMarket: totalMarket,
            totalCost: totalCost,
            profit: profit,
            profitPct: profitPct,
            count: cards.length,
          ),
        );
      },
    );
  }
}

/// loading / error / empty 的极简黑金占位。
class _BannerState extends StatelessWidget {
  const _BannerState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.gold.surfaceDark,
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(color: context.gold.textMuted, fontSize: 13),
      ),
    );
  }
}

/// 资产大盘具体内容（标题 + 总资产 + 成本/盈亏）。
class _BannerContent extends StatelessWidget {
  const _BannerContent({
    super.key,
    required this.totalMarket,
    required this.totalCost,
    required this.profit,
    required this.profitPct,
    required this.count,
  });

  final double totalMarket;
  final double totalCost;
  final double profit;
  final double profitPct;
  final int count;

  @override
  Widget build(BuildContext context) {
    final Color profitColor =
        profit >= 0 ? AppColors.goldPrimary : const Color(0xFFCF6679);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.gold.surfaceDark,
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const BrandLogo(size: 36),
              const SizedBox(width: 8),
              Text(
                '资产大盘',
                style: TextStyle(
                  color: context.gold.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.goldGlow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count 张',
                  style: const TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(totalMarket),
            style: const TextStyle(
              color: AppColors.goldPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              GoldStatTile(label: '总成本', value: CurrencyFormatter.format(totalCost)),
              const SizedBox(width: 24),
              GoldStatTile(
                label: '总盈亏',
                value: '${profit >= 0 ? '+' : ''}${CurrencyFormatter.format(profit)}',
                valueColor: profitColor,
              ),
              const SizedBox(width: 24),
              GoldStatTile(
                label: '收益率',
                value: '${profit >= 0 ? '+' : ''}${profitPct.toStringAsFixed(1)}%',
                valueColor: profitColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
