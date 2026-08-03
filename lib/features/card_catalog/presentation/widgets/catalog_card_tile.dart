import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import 'package:card_management/core/theme/app_colors.dart';
import '../../domain/models/catalog_item.dart';
import 'catalog_image.dart';

/// 图鉴网格单元（黑金极简卡片，复用既有 [CardCoverImage] 实现 Web 安全降级）。
class CatalogCardTile extends StatelessWidget {
  const CatalogCardTile({
    super.key,
    required this.item,
    required this.onTap,
  });
  final CatalogItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: context.gold.bgPure,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(color: AppColors.goldBorder, width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: CatalogImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  enableHdPreview: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.name,
                      style: TextStyle(
                        color: context.gold.textWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        _chip(context, item.rarity),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.cardSet,
                            style: TextStyle(
                              color: context.gold.textMuted,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _chip(BuildContext context, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: const BoxDecoration(
          color: AppColors.goldGlow,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.goldPrimary, fontSize: 9),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
}
