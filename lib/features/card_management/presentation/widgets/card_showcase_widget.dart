import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/gold_stat_tile.dart';
import '../../data/models/card_item.dart';
import '../../domain/enums/currency_unit.dart';
import '../providers/card_providers.dart';
import '../providers/profile_providers.dart';
import 'card_cover_image.dart';
import 'card_detail_modal.dart';
import 'manual_add_card_sheet.dart';

/// 首页「黑金展柜」：横向展示估值 Top-3 卡牌，香槟金辉光边框。
///
/// 仅当已收集卡牌 >= 3 时渲染；点击卡片以 Hero 联动打开大图预览。
/// 展柜使用独立 Hero tag（[showcase_img_] 以避开与网格 [card_img_] 的重复 tag 冲突）。
class CardShowcaseWidget extends ConsumerWidget {
  const CardShowcaseWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CardItem>> asyncCards =
        ref.watch(allCardsProvider) ?? const AsyncLoading();
    return asyncCards.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (List<CardItem> cards) {
        final List<CardItem> collected = cards
            .where((CardItem c) => c.isCollected && !c.isWishlist)
            .toList();
        if (collected.length < 3) return const SizedBox.shrink();
        collected.sort((CardItem a, CardItem b) =>
            b.marketPrice.compareTo(a.marketPrice));
        final List<CardItem> top = collected.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.diamond_outlined,
                      color: AppColors.goldPrimary, size: 16),
                  const SizedBox(width: 6),
                  Text('黑金展柜 · 估值 TOP3',
                      style: TextStyle(
                          color: context.gold.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: top.length,
                itemBuilder: (BuildContext ctx, int i) =>
                    _ShowcaseCard(cards: top, index: i),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ShowcaseCard extends ConsumerWidget {
  const _ShowcaseCard({required this.cards, required this.index});
  final List<CardItem> cards;
  final int index;
  CardItem get card => cards[index];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String heroTag = 'showcase_img_${card.id}';
    final CurrencyUnit currency = ref.watch(profileCurrencyProvider);
    return GestureDetector(
      onTap: () => showCardDetailModal(
        context,
        cards,
        index,
        currency: currency,
        onEdit: () => showManualAddCardSheet(context, initialCard: card),
      ),
      child: Container(
        width: 132,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.gold.bgPure,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: 0.45), width: 0.8),
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: AppColors.goldGlow, blurRadius: 18, spreadRadius: -6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CardCoverImage(
                  imageUrl: card.imageUrl,
                  width: 112,
                  height: 96,
                  cacheSize: 240,
                  enableHdPreview: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(card.cardName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: context.gold.textWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            GoldStatTile(
              label: '估值',
              value: CurrencyFormatter.formatCny(card.marketPrice, currency),
              valueSize: 13,
            ),
          ],
        ),
      ),
    );
  }
}
