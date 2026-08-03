import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_management/features/market_price/presentation/pages/market_price_page.dart';

import '../../../../core/widgets/gold_snack_bar.dart';
import '../../data/models/card_item.dart';
import '../../domain/enums/currency_unit.dart';
import '../../domain/repositories/card_repository.dart';
import '../providers/card_providers.dart';
import '../pages/centering_measurement_page.dart';
import 'card_detail_bars.dart';
import 'card_detail_drag_dismiss.dart';
import 'card_detail_info_sheet.dart';
import 'card_share_poster.dart';
import 'zoomable_card_image.dart';

/// 全屏沉浸式卡片看图：100% 对标手机原生相册。
///
/// - 纯黑全屏、图片按比例居中；左右滑动 [PageView] 切换上/下一张；
/// - 双击放大/还原 + 双指捏合缩放（[ZoomableCardImage]）；
/// - 下拉图片缩小并退出预览（[DragDismissStack]）；单击屏幕任意位置淡入/淡出控制栏；
/// - 底部仅一排极窄 Icon 工具条（分享/居中度/行情/信息/编辑/删除），默认隐藏，
///   无任何文本面板遮挡卡片；点击「信息」才从底部拉出财务与居中度明细卡片。
Future<void> showCardDetailModal(
  BuildContext context,
  List<CardItem> cards,
  int initialIndex, {
  required CurrencyUnit currency,
  VoidCallback? onEdit,
}) {
  HapticFeedback.lightImpact();
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    pageBuilder: (BuildContext ctx, _, __) => CardDetailModal(
      cards: cards,
      initialIndex: initialIndex,
      currency: currency,
      onEdit: onEdit,
    ),
    transitionBuilder: (_, Animation<double> a, __, Widget child) =>
        FadeTransition(opacity: a, child: child),
  );
}

class CardDetailModal extends ConsumerStatefulWidget {
  const CardDetailModal({
    super.key,
    required this.cards,
    required this.initialIndex,
    required this.currency,
    this.onEdit,
  });
  final List<CardItem> cards;
  final int initialIndex;
  final CurrencyUnit currency;
  final VoidCallback? onEdit;

  @override
  ConsumerState<CardDetailModal> createState() => _CardDetailModalState();
}

class _CardDetailModalState extends ConsumerState<CardDetailModal> {
  late int _page = widget.initialIndex;
  bool _showControls = false;
  bool _zoomed = false;

  CardItem get _card => widget.cards[_page];

  void _close() => Navigator.of(context).pop();

  void _toggleControls() {
    HapticFeedback.lightImpact();
    setState(() => _showControls = !_showControls);
  }

  void _edit() {
    Navigator.of(context).pop();
    widget.onEdit?.call();
  }

  Future<void> _delete() async {
    final CardItem temp = _card;
    final ProviderContainer container = ProviderScope.containerOf(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    await container.read(cardRepositoryProvider).deleteCard(temp.id);
    container.invalidate(allCardsProvider);
    if (!mounted) return;
    GoldSnackBar.showOn(messenger, '卡牌已删除',
        actionLabel: '撤销',
        duration: const Duration(seconds: 3), onAction: () async {
      await container.read(cardRepositoryProvider).saveCard(temp);
      container.invalidate(allCardsProvider);
    });
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final double topPad = MediaQuery.of(context).padding.top;
    final double botPad = MediaQuery.of(context).padding.bottom;
    return DragDismissStack(
      locked: _zoomed,
      onTap: _toggleControls,
      onDismiss: _close,
      onDragStart: () => setState(() => _showControls = false),
      child: Stack(
        children: <Widget>[
          PageView.builder(
            itemCount: widget.cards.length,
            onPageChanged: (int i) => setState(() {
              _page = i;
              _zoomed = false;
              _showControls = false;
            }),
            itemBuilder: (BuildContext ctx, int i) => ZoomableCardImage(
              key: ValueKey<int>(i),
              imageUrl: widget.cards[i].imageUrl,
              onScaleChanged: (bool z) => setState(() => _zoomed = z),
              size: Size(sw, sh),
            ),
          ),
          Positioned(
            top: topPad + 8,
            left: 12,
            right: 12,
            child: _fade(
              visible: _showControls,
              child: buildDetailTopBar(
                name: _card.cardName,
                count: '${_page + 1} / ${widget.cards.length}',
                onBack: _close,
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: botPad + 14,
            child: _fade(
              visible: _showControls,
              child: buildDetailBottomBar(
                onShare: () =>
                    showCardSharePoster(context, _card, widget.currency),
                onCentering: _openCentering,
                onMarket: _openMarket,
                onInfo: _showInfoSheet,
                onEdit: _edit,
                onDelete: _delete,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fade({required bool visible, required Widget child}) =>
      AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        child: IgnorePointer(ignoring: !visible, child: child),
      );

  void _openCentering() => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CenteringMeasurementPage(card: _card),
        ),
      );

  void _openMarket() => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MarketPricePage(card: _card),
        ),
      );

  void _showInfoSheet() => showCardDetailInfoSheet(
        context,
        _card,
        widget.currency,
        _openCentering,
      );
}
