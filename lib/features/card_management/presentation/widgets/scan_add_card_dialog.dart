import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/services/card_ocr_service.dart';
import '../../domain/enums/card_category.dart';
import '../../domain/enums/grading_company.dart';
import '../../../../core/widgets/hd_image_actions.dart';
import '../../../../core/widgets/hd_image_viewer.dart';
import '../helpers/card_image.dart';
import '../helpers/card_meta.dart';
import 'manual_add_card_sheet.dart';

/// 弹出黑金沉浸式识别弹窗：双模式（拍照 OCR / 条码扫码）。
Future<void> showScanAddCardDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: context.gold.scrim,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => _ScanDialog(rootContext: context),
    transitionBuilder: (_, Animation<double> a, __, Widget child) =>
        FadeTransition(opacity: a, child: child),
  );
}

class _ScanDialog extends StatefulWidget {
  const _ScanDialog({required this.rootContext});
  final BuildContext rootContext;
  @override
  State<_ScanDialog> createState() => _ScanDialogState();
}

class _ScanDialogState extends State<_ScanDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
        ..repeat(reverse: true);
  int _mode = 0; // 0 = 拍照 OCR，1 = 条码扫码
  bool _busy = false;
  bool _done = false;
  OcrResult? _ocr;

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _startOcr(ImageSource source) async {
    if (_busy || _done) return;
    setState(() => _busy = true);
    final OcrResult? res = await CardOcrService().captureAndRecognize(source);
    if (!mounted) return;
    if (res == null) {
      setState(() => _busy = false);
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _busy = false;
      _done = true;
      _ocr = res;
    });
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _transition(res.prefill);
    });
  }

  void _startBarcode() {
    if (_done) return;
    setState(() => _done = true);
    HapticFeedback.lightImpact();
    const ManualAddPrefill prefill = ManualAddPrefill(
        cardName: '初版喷火龙', cardNumber: '#004', grading: GradingCompany.psa, gradeScore: 10, category: CardCategory.pokemon);
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _transition(prefill);
    });
  }

  Future<void> _transition(ManualAddPrefill prefill) async {
    // 先关闭扫描窗，退场动画后再拉起手动录入，规避 Root Navigator 上 pop→show 竞态。
    Navigator.of(context).pop();
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (widget.rootContext.mounted) showManualAddCardSheet(widget.rootContext, prefill: prefill);
  }

  Widget _corner({double top = 0, double left = 0, double right = 0, double bottom = 0}) {
    const BorderSide s = BorderSide(color: AppColors.goldPrimary, width: 1.5);
    return Positioned(top: top, left: left, right: right, bottom: bottom, child: Container(width: 24, height: 24, decoration: BoxDecoration(border: Border(top: top == 0 ? s : BorderSide.none, left: left == 0 ? s : BorderSide.none, right: right == 0 ? s : BorderSide.none, bottom: bottom == 0 ? s : BorderSide.none))));
  }

  Widget _toggleItem(String label, int idx) => Expanded(
        child: GestureDetector(
          onTap: () {
            if (_mode != idx && !_busy && !_done) setState(() => _mode = idx);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: _mode == idx ? AppColors.goldPrimary : Colors.transparent),
            child: Center(child: Text(label, style: TextStyle(color: _mode == idx ? context.gold.bgPure : context.gold.textMuted, fontSize: 13, fontWeight: FontWeight.w600))),
          ),
        ),
      );

  Widget _toggle() => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: context.gold.bgPure.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.goldBorder, width: 0.5)),
        child: Row(children: <Widget>[_toggleItem('拍照 OCR', 0), _toggleItem('条码扫码', 1)]),
      );

  @override
  Widget build(BuildContext context) {
    const double size = 240;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          _toggle(),
          Stack(children: <Widget>[
            Container(width: size, height: size, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.2), width: 0.5), color: context.gold.bgPure.withValues(alpha: 0.4))),
            _corner(top: 0, left: 0), _corner(top: 0, right: 0), _corner(bottom: 0, left: 0), _corner(bottom: 0, right: 0),
            if (_ocr != null && !_done)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () => showHdImage(
                          context,
                          _ocr!.imagePath,
                          actions: <HdImageAction>[
                            hdShareAction(context, _ocr!.imagePath),
                            hdSaveAction(context, _ocr!.imagePath),
                          ],
                        ),
                    child: Image(
                        image: cardImageProvider(_ocr!.imagePath),
                        fit: BoxFit.cover),
                  ),
                ),
              ),
            if (_busy || (!_done && _mode == 1))
              AnimatedBuilder(animation: _anim, builder: (_, __) => Positioned(top: _anim.value * size, left: 10, right: 10, child: Container(height: 2, decoration: const BoxDecoration(color: AppColors.goldPrimary, boxShadow: <BoxShadow>[BoxShadow(color: AppColors.goldGlow, blurRadius: 12, spreadRadius: 1)])))),
            if (_busy) const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary, strokeWidth: 2)),
            if (_done) const Center(child: Icon(Icons.check_circle_outline_rounded, color: AppColors.goldPrimary, size: 48)),
          ]),
          const SizedBox(height: 16),
          _caption(),
          const SizedBox(height: 16),
          _action(),
        ]),
      ),
    );
  }

  Widget _caption() {
    if (_busy) return Text('AI 正在识别卡面信息…', style: TextStyle(color: context.gold.textWhite, fontSize: 13));
    if (_done) {
      final ManualAddPrefill p = _ocr?.prefill ?? const ManualAddPrefill(cardName: '初版喷火龙', grading: GradingCompany.psa, gradeScore: 10);
      final String name = p.cardName ?? '未知卡牌';
      final String grade = p.grading != null
          ? '${cardGradingLabel(p.grading!)}${p.gradeScore == null ? '' : (p.gradeScore! % 1 == 0 ? ' ${p.gradeScore!.toInt()}' : ' ${p.gradeScore!}')}'
          : '';
      return Text('识别成功：$grade $name', style: TextStyle(color: context.gold.textWhite, fontSize: 13));
    }
    return Text(_mode == 0 ? '拍照或选图，AI 自动识别卡面' : '将二维码 / 条形码置于框内', style: TextStyle(color: context.gold.textWhite, fontSize: 13));
  }

  Widget _action() {
    if (_done) return const SizedBox.shrink();
    if (_mode == 0) {
      return Row(children: <Widget>[
        Expanded(child: _goldBtn('拍照识卡', () => _startOcr(ImageSource.camera))),
        const SizedBox(width: 12),
        Expanded(child: _goldBtn('从相册选择', () => _startOcr(ImageSource.gallery))),
      ]);
    }
    return SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _startBarcode, style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.5), width: 0.5), foregroundColor: AppColors.goldPrimary, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('模拟扫描识别', style: TextStyle(fontSize: 14))));
  }

  Widget _goldBtn(String label, VoidCallback onTap) => SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary, foregroundColor: context.gold.bgPure, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))));
}
