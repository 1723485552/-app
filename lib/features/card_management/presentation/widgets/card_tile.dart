import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/gold_snack_bar.dart';
import '../../data/models/card_item.dart';
import '../../domain/enums/currency_unit.dart';
import '../../domain/repositories/card_repository.dart';
import 'card_cover_image.dart';
import '../helpers/card_meta.dart';
import '../providers/profile_providers.dart';
import '../providers/card_providers.dart';
import 'card_detail_modal.dart';
import 'manual_add_card_sheet.dart';

/// 紧凑型单张卡牌瓦片（攒卡网格 3 列微型贴纸框）。
///
/// 仅保留：缩略图（Hero 联动大图）+ 微型评级勋章（如 PSA 10）+ 单行卡名 + 简短价格；
/// 点击卡片任意位置统一打开沉浸式详情浮层 [CardDetailModal]，带 Haptic 触觉反馈。
class CardTile extends ConsumerWidget {
  const CardTile({super.key, required this.cards, required this.index});

  final List<CardItem> cards;
  final int index;
  CardItem get card => cards[index];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CurrencyUnit currency = ref.watch(profileCurrencyProvider);
    final bool graded = card.gradeScore != null;
    final double pct = card.profitPercentage;
    final bool up = pct >= 0;
    final String heroTag = 'card_img_${card.id}';
    return GestureDetector(
      onTap: () => showCardDetailModal(
        context,
        cards,
        index,
        currency: currency,
        onEdit: () => showManualAddCardSheet(context, initialCard: card),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.gold.bgDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.goldBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child: CardCoverImage(
                      imageUrl: card.imageUrl,
                      width: double.infinity,
                      height: 78,
                      cacheSize: 300,
                      enableHdPreview: true,
                    ),
                  ),
                ),
                if (card.isWishlist)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.goldGlow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4), width: 0.5),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                        const Icon(Icons.star_rounded, size: 10, color: AppColors.goldPrimary),
                        const SizedBox(width: 2),
                        Text('${card.wishlistPriority}', style: const TextStyle(color: AppColors.goldPrimary, fontSize: 10)),
                      ]),
                    ),
                  )
                else if (graded)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.goldGlow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4), width: 0.5),
                      ),
                      child: Text('${cardGradingLabel(card.grading)} ${card.gradeScore!.toInt()}', style: const TextStyle(color: AppColors.goldPrimary, fontSize: 10)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(card.cardName,
                      style: TextStyle(
                          color: context.gold.textWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (card.isWishlist)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('目标 ${CurrencyFormatter.formatCny(card.targetPrice ?? 0, currency)}',
            style: const TextStyle(
                color: AppColors.goldPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _convert(ref, context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppColors.goldPrimary
                                      .withValues(alpha: 0.5),
                                  width: 0.5),
                              foregroundColor: AppColors.goldPrimary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('一键拔草',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(CurrencyFormatter.formatCny(card.marketPrice, currency),
                            style: TextStyle(
                                color: context.gold.textWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        Text('${up ? '+' : ''}${pct.toStringAsFixed(0)}%',
                            style: TextStyle(
                                color: up
                                    ? AppColors.trendUp
                                    : AppColors.trendDown,
                                fontSize: 11)),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _convert(WidgetRef ref, BuildContext context) async {
    HapticFeedback.lightImpact();
    final CardItem updated = card.copyWith(
      isCollected: true,
      isWishlist: false,
      buyPrice: card.targetPrice ?? card.buyPrice,
      marketPrice: card.targetPrice ?? card.marketPrice,
      buyDate: DateTime.now(),
    );
    await ref.read(cardRepositoryProvider).saveCard(updated);
    ref.invalidate(allCardsProvider);
    if (context.mounted) {
      GoldSnackBar.show(context, '已拔草，转入已收集');
    }
  }
}
