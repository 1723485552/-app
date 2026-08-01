import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/card_item.dart';
import '../../domain/enums/currency_unit.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/card_providers.dart';
import '../providers/profile_providers.dart';
import 'ledger_txn_row.dart';

/// 账单明细页：财务看板（累计买入投入 / 已变现浮盈 / 当前藏品总估值）
/// + 交易流水（按买入时间倒序）。数据全部源自真实 [allCardsProvider]，
/// 不引入任何硬编码或模拟数值。
class LedgerView extends ConsumerWidget {
  const LedgerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CardItem>> asyncCards = ref.watch(allCardsProvider);
    final CurrencyUnit currency = ref.watch(profileCurrencyProvider);
    return Scaffold(
      backgroundColor: context.gold.bgDark,
      appBar: AppBar(
        title: const Text('账单明细'),
        centerTitle: false,
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.receipt_long_outlined,
                color: AppColors.goldPrimary, size: 22),
          ),
        ],
      ),
      body: asyncCards.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary)),
        error: (_, __) => const _CenterHint(text: '账单数据加载失败'),
        data: (List<CardItem> cards) {
          final List<CardItem> held =
              cards.where((CardItem c) => c.isCollected).toList();
          final double invested =
              held.fold<double>(0, (double s, CardItem c) => s + c.buyPrice);
          final double valuation =
              held.fold<double>(0, (double s, CardItem c) => s + c.marketPrice);
          final double realized = valuation - invested;
          final List<CardItem> txns = List<CardItem>.from(held)
            ..sort((CardItem a, CardItem b) => b.buyDate.compareTo(a.buyDate));
          return CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _Board(
                  invested: invested,
                  realized: realized,
                  valuation: valuation,
                  currency: currency,
                ),
              ),
              const SliverToBoxAdapter(child: _SectionTitle(text: '交易流水')),
              if (txns.isEmpty)
                const SliverToBoxAdapter(child: _CenterHint(text: '暂无交易记录')),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, int i) => LedgerTxnRow(card: txns[i], currency: currency),
                  childCount: txns.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

/// 财务看板：三张黑金卡片（0.5px 香槟金微发光边框）。
class _Board extends StatelessWidget {
  const _Board({
    required this.invested,
    required this.realized,
    required this.valuation,
    required this.currency,
  });
  final double invested;
  final double realized;
  final double valuation;
  final CurrencyUnit currency;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _StatCard(
                label: '累计买入投入',
                value: CurrencyFormatter.formatCny(invested, currency),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: '已变现金额',
                value: CurrencyFormatter.formatCny(realized, currency),
                caption: '账面浮盈',
                valueColor: realized >= 0 ? AppColors.goldPrimary : AppColors.trendDown,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: '当前藏品总估值',
                value: CurrencyFormatter.formatCny(valuation, currency),
              ),
            ),
          ],
        ),
      );
}

/// 单张财务统计卡。
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.caption,
    this.valueColor,
  });
  final String label;
  final String value;
  final String? caption;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.gold.surfaceDark,
          border: Border.all(color: AppColors.goldBorder, width: 0.5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: AppColors.goldGlow, blurRadius: 8, spreadRadius: -4),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.gold.textMuted, fontSize: 11)),
            const SizedBox(height: 8),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor ?? AppColors.goldPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                )),
            if (caption != null) ...<Widget>[
              const SizedBox(height: 4),
              Text(caption!,
                  style: TextStyle(color: context.gold.textInactive, fontSize: 10)),
            ],
          ],
        ),
      );
}

/// 区块标题。
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(text,
            style: TextStyle(
              color: context.gold.textWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            )),
      );
}

/// 空 / 异常态极简黑金提示（避免布局塌陷）。
class _CenterHint extends StatelessWidget {
  const _CenterHint({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.receipt_long_outlined,
                size: 40, color: context.gold.textInactive),
            const SizedBox(height: 12),
            Text(text,
                style: TextStyle(color: context.gold.textMuted, fontSize: 13)),
          ],
        ),
      );
}
