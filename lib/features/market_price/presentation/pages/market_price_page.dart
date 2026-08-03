import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import 'package:card_management/core/theme/app_colors.dart';
import 'package:card_management/features/card_management/data/models/card_item.dart';
import 'package:card_management/features/market_price/data/config/market_config.dart';
import '../widgets/market_price_widget.dart';

/// 国内外成交价行情页（从卡片详情页进入的全屏载体）。
class MarketPricePage extends ConsumerWidget {
  const MarketPricePage({super.key, required this.card});
  final CardItem card;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        backgroundColor: context.gold.bgDark,
        appBar: AppBar(
          backgroundColor: context.gold.bgDark,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_outlined,
                color: context.gold.textWhite, size: 22),
          ),
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(card.cardName,
                    style: TextStyle(
                        color: context.gold.textWhite,
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              if (useSampleData) _sampleBadge(context),
            ],
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: MarketPriceWidget(
            cardName: card.cardName,
            cardNo: card.cardNumber,
          ),
        ),
      );

  Widget _sampleBadge(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.goldGlow,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text('示例数据',
            style: TextStyle(color: AppColors.goldPrimary, fontSize: 10)),
      );
}
