import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/gold_snack_bar.dart';
import '../../../../core/widgets/gold_stat_tile.dart';
import '../../data/models/card_item.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/enums/currency_unit.dart';
import 'card_cover_image.dart';
import 'price_trend_chart.dart';
import '../helpers/card_meta.dart';
import '../providers/card_providers.dart';
import 'card_share_poster.dart';
// 微信式全屏沉浸式大图预览：Hero 淡入 + 单击任意区域关闭 + 按住拖拽平移 + 弹性回弹/顺势飞出。
class CardDetailLightbox extends ConsumerStatefulWidget {
  const CardDetailLightbox(
      {super.key,
      required this.card,
      required this.currency,
      required this.heroTag,
      this.onEdit});
  final CardItem card;
  final CurrencyUnit currency;
  final String heroTag;

  /// 编辑回调：由列表侧持有存活的 [BuildContext]，规避大图预览 pop 后的上下文失效。
  final VoidCallback? onEdit;
  @override
  ConsumerState<CardDetailLightbox> createState() => _CardDetailLightboxState();
}
class _CardDetailLightboxState extends ConsumerState<CardDetailLightbox>
    with TickerProviderStateMixin {
  Offset _offset = Offset.zero;
  late final AnimationController _anim;
  late Animation<Offset> _a;
  void _close() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }
  void _edit() {
    Navigator.of(context).pop();
    widget.onEdit?.call();
  }

  /// 安全删除：先乐观移除数据，再在 root ScaffoldMessenger 上弹出「撤销」SnackBar。
  ///
  /// 关键修复：删除后列表项（[CardTile]）会从网格卸载、其 [BuildContext] 随之失效，
  /// 故不能依赖列表侧 context 弹 SnackBar（会抛「deactivated widget」导致撤销无反应）。
  /// 此处捕获应用级 [ProviderContainer] 与当前存活 context，撤销的数据写回与
  /// [allCardsProvider] 刷新走应用级容器，确保点击「撤销」后 UI 真正回滚。
  Future<void> _delete() async {
    final CardItem temp = widget.card;
    // 删除前捕获应用级容器与存活的 messenger / navigator：删除后列表项卸载、
    // 其 context 失效，故全程不跨 await 使用 context，规避「撤销无反应」。
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
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this);
    _a = _anim.drive(Tween<Offset>(begin: Offset.zero, end: Offset.zero));
    _anim.addListener(() => setState(() => _offset = _a.value));
  }
  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }
  void _run(Offset target, Curve curve, int ms, {bool close = false}) {
    _a = _anim.drive(Tween<Offset>(begin: _offset, end: target));
    _anim.duration = Duration(milliseconds: ms);
    _anim.forward(from: 0).then((_) {
      if (close && mounted) _close();
    });
  }
  void _onPanEnd() {
    if (_offset.distance > 80) {
      _run(_offset * 2.4, Curves.easeIn, 220, close: true);
    } else {
      _run(Offset.zero, Curves.elasticOut, 200);
    }
  }
  @override
  Widget build(BuildContext context) {
    final CardItem card = widget.card;
    final double pct = card.profitPercentage;
    final bool up = pct >= 0;
    final double top = MediaQuery.of(context).padding.top;
    final double bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: context.gold.scrim,
      body: GestureDetector(
        onTap: _close,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: top + 12,
              right: 16,
              child: GestureDetector(
                onTap: _close,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: context.gold.bgPure.withValues(alpha: 0.6),
                      shape: BoxShape.circle),
                  child: Icon(Icons.close_outlined,
                      color: context.gold.textWhite, size: 22),
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
                onPanUpdate: (d) => setState(() => _offset += d.delta),
                onPanEnd: (_) => _onPanEnd(),
                child: Transform.translate(
                    offset: _offset, child: _stage(card, widget.heroTag)),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: bottom + 20,
              child: _infoBar(card, widget.currency, up, pct, _delete),
            ),
          ],
        ),
      ),
    );
  }
  Widget _stage(CardItem card, String heroTag) {
    final double w = MediaQuery.of(context).size.width * 0.82;
    return Hero(
      tag: heroTag,
      child: Container(
        width: w,
        height: w * 1.4,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: 0.4), width: 0.5),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: AppColors.goldGlow, blurRadius: 30, spreadRadius: -10)
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: CardCoverImage(imageUrl: card.imageUrl),
        ),
      ),
    );
  }
  Widget _infoBar(CardItem card, CurrencyUnit currency, bool up, double pct,
      VoidCallback onDelete) {
    final bool graded = card.gradeScore != null;
    final List<Widget> titleRow = <Widget>[
      Expanded(
          child: Text(card.cardName,
              style: TextStyle(
                  color: context.gold.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis)),
      if (graded)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: const BoxDecoration(
              color: AppColors.goldGlow,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Text('${cardGradingLabel(card.grading)} ${card.gradeScore!.toInt()}',
              style: const TextStyle(color: AppColors.goldPrimary, fontSize: 11)),
        ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () => showCardSharePoster(context, card, widget.currency),
        child: Icon(Icons.share_outlined,
            color: context.gold.textMuted, size: 18),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: _edit,
        child: Icon(Icons.edit_outlined,
            color: context.gold.textMuted, size: 18),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: onDelete,
        child: Icon(Icons.delete_outline_rounded,
            color: context.gold.textMuted, size: 18),
      ),
    ];
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: context.gold.bgPure.withValues(alpha: 0.82),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: AppColors.goldBorder, width: 0.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: titleRow),
            const SizedBox(height: 4),
            Text('卡号 ${card.cardNumber}',
                style: TextStyle(
                    color: context.gold.textMuted, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                _stat('买入成本', CurrencyFormatter.formatCny(card.buyPrice, currency)),
                _stat('当前估值', CurrencyFormatter.formatCny(card.marketPrice, currency)),
                _stat('盈亏率', '${up ? '+' : ''}${pct.toStringAsFixed(1)}%',
                    valueColor: up ? AppColors.trendUp : AppColors.trendDown),
              ],
            ),
            const SizedBox(height: 14),
            PriceTrendCard(priceHistoryJson: card.priceHistoryJson),
          ],
        ),
      ),
    );
  }
  Widget _stat(String label, String value, {Color? valueColor}) => Expanded(
        child: GoldStatTile(label: label, value: value, valueColor: valueColor),
      );
}
