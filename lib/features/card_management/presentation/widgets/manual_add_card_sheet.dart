import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/repositories/card_repository.dart';
import '../../data/models/card_item.dart';
import '../../domain/enums/card_category.dart';
import '../../domain/enums/grading_company.dart';
import '../widgets/market_estimate_field.dart';
import '../helpers/card_meta.dart';
import 'card_cover_picker.dart';
// 扫码 / OCR 识别后回填到手动表单的预填数据。
class ManualAddPrefill {
  const ManualAddPrefill({this.cardName, this.cardNumber, this.grading, this.gradeScore, this.category, this.imagePath});
  final String? cardName;
  final String? cardNumber;
  final GradingCompany? grading;
  final double? gradeScore;
  final CardCategory? category;
  final String? imagePath; // OCR 拍照落盘的本地封面路径
}
// 平滑拉起黑金高奢「手动录入卡牌」表单 Sheet（底部抽屉式）。
///
/// [initialCard] 非空时为「编辑模式」：用其字段回填表单，提交时走
/// [CardRepository.updateCard] 覆盖写入（保留原 id / 收藏状态 / 买入日期等）。
Future<void> showManualAddCardSheet(BuildContext context,
        {ManualAddPrefill? prefill, CardItem? initialCard}) =>
    showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: context.gold.scrim,
        builder: (BuildContext ctx) =>
            ManualAddForm(prefill: prefill, initialCard: initialCard));
class ManualAddForm extends ConsumerStatefulWidget {
  const ManualAddForm({super.key, this.prefill, this.initialCard});
  final ManualAddPrefill? prefill;
  final CardItem? initialCard;
  @override
  ConsumerState<ManualAddForm> createState() => _ManualAddFormState();
}
class _ManualAddFormState extends ConsumerState<ManualAddForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _score = TextEditingController();
  final TextEditingController _buy = TextEditingController();
  final TextEditingController _market = TextEditingController();
  CardCategory _category = CardCategory.pokemon;
  GradingCompany _grading = GradingCompany.raw;
  bool _saving = false;
  bool _saved = false;
  String? _imagePath;
  String _priceHistoryJson = '';
  final Set<String> _aiFields = <String>{};
  @override
  void initState() {
    super.initState();
    // 编辑模式：用既有卡牌字段回填（优先级高于 OCR 预填）。
    final CardItem? c = widget.initialCard;
    if (c != null) {
      _name.text = c.cardName;
      _number.text = c.cardNumber;
      _category = c.category == CardCategory.all ? CardCategory.pokemon : c.category;
      _grading = c.grading;
      if (c.gradeScore != null) _score.text = c.gradeScore!.toString();
      _buy.text = c.buyPrice.toString();
      _market.text = c.marketPrice.toString();
      _imagePath = c.imageUrl;
      _priceHistoryJson = c.priceHistoryJson;
      return;
    }
    final ManualAddPrefill? p = widget.prefill;
    if (p != null) {
      if (p.cardName != null) {
        _name.text = p.cardName!;
        _aiFields.add('卡牌名称');
      }
      if (p.cardNumber != null) {
        _number.text = p.cardNumber!;
        _aiFields.add('卡牌编号');
      }
      if (p.gradeScore != null) {
        _score.text = p.gradeScore!.toString();
        _aiFields.add('评级分数');
      }
      if (p.grading != null) {
        _grading = p.grading!;
        if (p.grading != GradingCompany.raw) _aiFields.add('评级机构');
      }
      if (p.category != null) {
        _category = p.category!;
        _aiFields.add('所属分类');
      }
      _imagePath = p.imagePath;
    }
  }
  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _score.dispose();
    _buy.dispose();
    _market.dispose();
    super.dispose();
  }
  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final CardItem card;
    if (widget.initialCard != null) {
      // 编辑模式：保留原 id / 收藏状态 / 买入日期 / 心愿单字段，仅覆盖可编辑项。
      card = widget.initialCard!.copyWith(
        id: widget.initialCard!.id, // 显式继承原 ID，杜绝重复新增
        cardName: _name.text.trim(),
        cardNumber: _number.text.trim().isEmpty ? '—' : _number.text.trim(),
        imageUrl: _imagePath ?? widget.initialCard!.imageUrl,
        grading: _grading,
        category: _category,
        gradeScore:
            _grading == GradingCompany.raw ? null : double.tryParse(_score.text),
        buyPrice: double.tryParse(_buy.text) ?? 0.0,
        marketPrice: double.tryParse(_market.text) ?? 0.0,
      );
      await ref.read(cardRepositoryProvider).updateCard(card);
    } else {
      final double market = double.tryParse(_market.text) ?? 0.0;
      card = CardItem(
        cardName: _name.text.trim(),
        cardNumber: _number.text.trim().isEmpty ? '—' : _number.text.trim(),
        imageUrl: _imagePath ??
            'https://example.com/${Uri.encodeComponent(_name.text.trim())}.jpg',
        grading: _grading,
        category: _category,
        gradeScore:
            _grading == GradingCompany.raw ? null : double.tryParse(_score.text),
        buyPrice: double.tryParse(_buy.text) ?? 0.0,
        marketPrice: market,
        priceHistoryJson: _priceHistoryJson,
        buyDate: DateTime.now(),
        isCollected: true,
        volume: 0.0,
      );
      await ref.read(cardRepositoryProvider).saveCard(card);
    }
    HapticFeedback.mediumImpact();
    setState(() => _saved = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) Navigator.of(context).pop();
  }
  InputDecoration _dec() => InputDecoration(filled: true, fillColor: context.gold.surfaceDark, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.2), width: 0.5)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.goldPrimary, width: 0.5)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.2), width: 0.5)));
  Widget _label(String t) => Row(
        children: <Widget>[
          Text(t, style: TextStyle(color: context.gold.textMuted, fontSize: 12)),
          if (_aiFields.contains(t)) ...<Widget>[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.goldGlow,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.auto_awesome, size: 10, color: AppColors.goldPrimary),
                  SizedBox(width: 2),
                  Text('AI 识别',
                      style: TextStyle(
                          color: AppColors.goldPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      );
  Widget _field(String label, TextEditingController ctrl, {String hint = '', bool numeric = false, bool required = false}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[_label(label), const SizedBox(height: 6), TextFormField(controller: ctrl, keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, style: TextStyle(color: context.gold.textWhite, fontSize: 14), decoration: _dec().copyWith(hintText: hint, hintStyle: TextStyle(color: context.gold.textInactive, fontSize: 13)), validator: (String? v) {if (required && (v == null || v.trim().isEmpty)) return '必填'; if (numeric && v != null && v.trim().isNotEmpty && double.tryParse(v) == null) return '请输入数字'; return null;})]));
  Widget _dropdown<T>(String label, T value, List<T> items, String Function(T) labelOf, ValueChanged<T?> onChanged) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[_label(label), const SizedBox(height: 6), DropdownButtonFormField<T>(initialValue: value, items: items.map((T v) => DropdownMenuItem<T>(value: v, child: Text(labelOf(v), style: TextStyle(color: context.gold.textWhite, fontSize: 14)))).toList(), onChanged: onChanged, dropdownColor: context.gold.bgPure, style: TextStyle(color: context.gold.textWhite, fontSize: 14), decoration: _dec())]));
  @override
  Widget build(BuildContext context) {
    final double kb = MediaQuery.of(context).viewInsets.bottom;
    return Padding(padding: EdgeInsets.only(bottom: kb), child: Container(constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - kb - 24), decoration: BoxDecoration(color: context.gold.bgNav, borderRadius: const BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)), border: const Border(top: BorderSide(color: AppColors.goldBorder, width: 0.5))), child: _saved ? _success() : SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.goldGlow, borderRadius: BorderRadius.circular(2)))),
      const SizedBox(height: 12),
      Text(widget.initialCard != null ? '编辑卡牌' : '手动录入卡牌', style: TextStyle(color: context.gold.textWhite, fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(widget.initialCard != null ? '修改藏品信息并保存' : '填写藏品信息并入库', style: TextStyle(color: context.gold.textMuted, fontSize: 12)),
      if (_aiFields.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.goldGlow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.auto_awesome, size: 12, color: AppColors.goldPrimary),
              SizedBox(width: 4),
              Text('AI 识别已自动填充',
                  style: TextStyle(
                      color: AppColors.goldPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      const SizedBox(height: 16),
      CardCoverPicker(
          initialPath: _imagePath,
          onPicked: (String p) => setState(() => _imagePath = p)),
      const SizedBox(height: 16),
      _field('卡牌名称', _name, hint: '如 初版喷火龙', required: true),
      _field('卡牌编号', _number, hint: '如 #004 / BS1'),
      _dropdown<CardCategory>('所属分类', _category, CardCategory.values.where((CardCategory c) => c != CardCategory.all).toList(), cardCategoryLabel, (CardCategory? v) => setState(() => _category = v!)),
      _dropdown<GradingCompany>('评级机构', _grading, GradingCompany.values, cardGradingLabel, (GradingCompany? v) => setState(() => _grading = v!)),
      if (_grading != GradingCompany.raw) _field('评级分数', _score, hint: '如 10 / 9.5', numeric: true),
      _field('买入成本 (¥)', _buy, hint: '0', numeric: true, required: true),
      MarketEstimateField(
        marketController: _market,
        nameController: _name,
        numberController: _number,
        category: _category,
        onHistoryFetched: (String h) => setState(() => _priceHistoryJson = h),
      ),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saving ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary, foregroundColor: context.gold.bgPure, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: _saving ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: context.gold.bgPure)) : const Text('确认入库', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)))),
    ],
          ),
        ),
      ),
    ),
  );
  }
  Widget _success() => Padding(padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24), child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.goldGlow, border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.5), width: 0.5)), child: const Icon(Icons.check_rounded, color: AppColors.goldPrimary, size: 32)), const SizedBox(height: 16), Text(widget.initialCard != null ? '卡牌已更新！' : '卡牌入库成功！', style: TextStyle(color: context.gold.textWhite, fontSize: 16, fontWeight: FontWeight.w600))]));
}
