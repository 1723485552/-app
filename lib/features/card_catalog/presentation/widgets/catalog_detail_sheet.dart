import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:card_management/core/widgets/gold_snack_bar.dart';

import 'package:card_management/core/theme/app_colors.dart';
import 'package:card_management/features/card_management/data/models/card_item.dart';
import 'package:card_management/features/card_management/domain/enums/card_category.dart';
import 'package:card_management/features/card_management/domain/repositories/card_repository.dart';
import '../../domain/models/catalog_item.dart';
import '../widgets/catalog_image.dart';

/// 图鉴详情底部浮层：高清大图 + 属性参数 + 一键加入收藏。
class CatalogDetailSheet extends ConsumerWidget {
  const CatalogDetailSheet({super.key, required this.item});
  final CatalogItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: context.gold.bgDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _grabber(context),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 110,
                height: 154,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: CatalogImage(imageUrl: item.imageUrl, fit: BoxFit.cover, enableHdPreview: true),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.name,
                        style: TextStyle(
                            color: context.gold.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    _meta(context, '系列', item.cardSet),
                    _meta(context, '卡号', item.cardNumber),
                    _meta(context, '稀有度', item.rarity),
                    _meta(context, '年份', item.releaseYear.toString()),
                  ],
                ),
              ),
            ],
          ),
          if (item.extraFields.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            ...item.extraFields.entries
                .map((e) => _meta(context, e.key, e.value.toString())),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _addToCollection(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('一键加入我的收藏'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: context.gold.bgDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCollection(BuildContext context, WidgetRef ref) async {
    final CardItem card = _toCardItem(item);
    await ref.read(cardRepositoryProvider).saveCard(card);
    if (!context.mounted) return;
    GoldSnackBar.show(context, '已加入收藏：${item.name}');
    Navigator.of(context).pop();
  }

  Widget _meta(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: <Widget>[
            Text('$label  ',
                style:
                    TextStyle(color: context.gold.textMuted, fontSize: 12)),
            Expanded(
              child: Text(value,
                  style: TextStyle(color: context.gold.textWhite, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );

  Widget _grabber(BuildContext context) => Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: context.gold.textInactive,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  /// 图鉴条目 → 收藏库 [CardItem]（仅做字段对齐，不写入行情/估值）。
  CardItem _toCardItem(CatalogItem item) {
    CardCategory cat;
    switch (item.category) {
      case 'tcg_pokemon':
        cat = CardCategory.pokemon;
      case 'tcg_yugioh':
        cat = CardCategory.yugioh;
      case 'sports_nba':
      case 'sports_soccer':
        cat = CardCategory.sportsOther;
      default:
        cat = CardCategory.all;
    }
    return CardItem(
      cardName: item.name,
      cardNumber: item.cardNumber,
      imageUrl: item.imageUrl,
      category: cat,
      buyPrice: 0,
      marketPrice: 0,
      buyDate: DateTime.now(),
      isCollected: true,
    );
  }
}
