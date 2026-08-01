import 'dart:io';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../data/models/card_item.dart';
import '../../domain/enums/currency_unit.dart';
import 'card_cover_image.dart';
import '../helpers/card_meta.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/gold_snack_bar.dart';
import '../../../../core/widgets/gold_stat_tile.dart';

/// 黑金晒卡海报生成与分享（原生平台）。
///
/// 以 [RepaintBoundary] 包裹 9:16 高奢黑金海报，渲染为 PNG 字节流后保存并调起
/// 系统原生分享面板。复用 [cardImageProvider] / [cardGradingLabel] / [formatMoney]。
Future<void> showCardSharePoster(
  BuildContext context,
  CardItem card,
  CurrencyUnit currency,
) {
  final GlobalKey boundaryKey = GlobalKey();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.gold.scrim,
    builder: (BuildContext ctx) => Container(
      decoration: BoxDecoration(
        color: context.gold.bgNav,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(top: BorderSide(color: AppColors.goldBorder, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
              child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.goldGlow,
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          CardSharePoster(boundaryKey: boundaryKey, card: card, currency: currency),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _exportPoster(ctx, boundaryKey, card, currency),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: context.gold.bgPure,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('保存并分享',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _exportPoster(
  BuildContext context,
  GlobalKey key,
  CardItem card,
  CurrencyUnit currency,
) async {
  try {
    final RenderRepaintBoundary? boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;
    final Uint8List png = bytes.buffer.asUint8List();
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = '${dir.path}/card_poster_${card.id}.png';
    await File(path).writeAsBytes(png, flush: true);
    final XFile xfile = XFile.fromData(
      png,
      mimeType: 'image/png',
      name: 'card_poster_${card.id}.png',
    );
    if (!context.mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        text: '我的黑金藏品 · ${card.cardName}',
        files: <XFile>[xfile],
      ),
    );
    } catch (e) {
    if (context.mounted) {
      GoldSnackBar.show(context, '海报导出失败：$e');
    }
  }
}

/// 9:16 黑金晒卡海报视图。
class CardSharePoster extends StatelessWidget {
  const CardSharePoster({
    super.key,
    required this.boundaryKey,
    required this.card,
    required this.currency,
  });
  final GlobalKey boundaryKey;
  final CardItem card;
  final CurrencyUnit currency;

  @override
  Widget build(BuildContext context) {
    final double pct = card.profitPercentage;
    final bool up = pct >= 0;
    final bool graded = card.gradeScore != null;
    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: 360,
        height: 640,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF1A1A1A), Color(0xFF0E0E0E)],
          ),
          border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: 0.4), width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('CARD COLLECTOR',
                    style: TextStyle(
                        color: AppColors.goldPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5)),
                Icon(cardCategoryIcon(card.category),
                    color: AppColors.goldPrimary, size: 22),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CardCoverImage(imageUrl: card.imageUrl),
              ),
            ),
            const SizedBox(height: 16),
            if (graded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldGlow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${cardGradingLabel(card.grading)} ${card.gradeScore!.toInt()}',
                    style: const TextStyle(
                        color: AppColors.goldPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            const SizedBox(height: 10),
            Text(card.cardName,
                style: TextStyle(
                    color: context.gold.textWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
            Text('卡号 ${card.cardNumber}',
                style: TextStyle(color: context.gold.textMuted, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                _stat('买入', CurrencyFormatter.formatCny(card.buyPrice, currency)),
                _stat('估值', CurrencyFormatter.formatCny(card.marketPrice, currency)),
                _stat('盈亏', '${up ? '+' : ''}${pct.toStringAsFixed(1)}%',
                    color: up ? AppColors.trendUp : AppColors.trendDown),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: context.gold.surfaceDark.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.5), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const BrandLogo(size: 28, bordered: false),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('CARD COLLECTOR',
                            style: TextStyle(
                                color: AppColors.goldPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2)),
                        Text('卡牌资产 · ${DateTime.now().year}',
                            style: TextStyle(
                                color: context.gold.textMuted, fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, {Color? color}) => Expanded(
        child: GoldStatTile(
            label: label, value: value, valueColor: color, valueSize: 15),
      );
}
