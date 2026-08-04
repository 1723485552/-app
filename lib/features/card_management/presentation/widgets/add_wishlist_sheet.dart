import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/repositories/card_repository.dart';
import '../../data/models/card_item.dart';
import '../../domain/enums/card_category.dart';
import '../helpers/card_meta.dart';
import 'card_cover_picker.dart';

// 黑金高奢「心愿单录入」底部抽屉（轻量版：卡名 / 系列 / 目标价 / 星级 / 示例图）。
Future<void> showAddWishlistSheet(BuildContext context) =>
    showModalBottomSheet<void>(context: context, useRootNavigator: true, isScrollControlled: true, backgroundColor: Colors.transparent, barrierColor: context.gold.scrim, builder: (BuildContext c) => const WishlistAddForm());

class WishlistAddForm extends ConsumerStatefulWidget {
  const WishlistAddForm({super.key});
  @override
  ConsumerState<WishlistAddForm> createState() => _WishlistAddFormState();
}

class _WishlistAddFormState extends ConsumerState<WishlistAddForm> {
  final GlobalKey<FormState> _k = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _target = TextEditingController();
  CardCategory _cat = CardCategory.pokemon;
  int _prio = 3;
  String? _img;
  bool _saving = false, _saved = false;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_k.currentState!.validate()) return;
    setState(() => _saving = true);
    final double? tp = double.tryParse(_target.text);
    await ref.read(cardRepositoryProvider).saveCard(CardItem(
      cardName: _name.text.trim(),
      cardNumber: '—',
      imageUrl: _img ??
          'https://example.com/${Uri.encodeComponent(_name.text.trim())}.jpg',
      category: _cat,
      buyPrice: 0.0,
      marketPrice: tp ?? 0.0,
      buyDate: DateTime.now(),
      isCollected: false,
      isWishlist: true,
      targetPrice: tp,
      wishlistPriority: _prio,
      volume: 0.0,
    ));
    HapticFeedback.mediumImpact();
    setState(() => _saved = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) Navigator.of(context).pop();
  }

  InputDecoration _dec() => InputDecoration(
        filled: true,
        fillColor: context.gold.surfaceDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: AppColors.goldPrimary.withValues(alpha: 0.2), width: 0.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.goldPrimary, width: 0.5)),
      );

  Widget _field(String label, TextEditingController c,
          {bool num = false, bool req = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text(label, style: TextStyle(color: context.gold.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          TextFormField(
            controller: c,
            keyboardType: num
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            style: TextStyle(color: context.gold.textWhite, fontSize: 14),
            decoration: _dec().copyWith(hintText: '选填', hintStyle: TextStyle(color: context.gold.textInactive, fontSize: 13)),
            validator: (String? v) {
              if (req && (v == null || v.trim().isEmpty)) return '必填';
              if (num && v != null && v.trim().isNotEmpty && double.tryParse(v) == null) return '请输入数字';
              return null;
            },
          ),
        ]),
      );

  Widget _series() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('所属系列', style: TextStyle(color: context.gold.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: CardCategory.values
                .where((CardCategory c) => c != CardCategory.all)
                .map((CardCategory c) => GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _cat = c);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: _cat == c ? AppColors.goldGlow : context.gold.surfaceDark, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.2), width: 0.5)),
                        child: Text(cardCategoryLabel(c), style: TextStyle(color: _cat == c ? AppColors.goldPrimary : context.gold.textMuted, fontSize: 12, fontWeight: _cat == c ? FontWeight.w600 : FontWeight.normal)),
                      ),
                    ))
                .toList(),
          ),
        ]),
      );

  Widget _stars() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('心愿星级', style: TextStyle(color: context.gold.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          Row(children: <Widget>[for (int i = 1; i <= 5; i++) GestureDetector(onTap: () { HapticFeedback.lightImpact(); setState(() => _prio = i); }, child: Padding(padding: const EdgeInsets.only(right: 4), child: Icon(i <= _prio ? Icons.star_rounded : Icons.star_outline_rounded, size: 28, color: i <= _prio ? AppColors.goldPrimary : context.gold.textInactive)))]),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final double kb = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: kb),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - kb - 24),
        decoration: BoxDecoration(color: context.gold.bgNav, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), border: const Border(top: BorderSide(color: AppColors.goldBorder, width: 0.5))),
        child: _saved
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.check_rounded, color: AppColors.goldPrimary, size: 56),
                    const SizedBox(height: 16),
                    Text('已加入心愿单！',
                        style: TextStyle(
                            color: context.gold.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Form(
                  key: _k,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.goldGlow, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 12),
                    Text('添加心愿单', style: TextStyle(color: context.gold.textWhite, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('记录心仪的卡牌与心理价位', style: TextStyle(color: context.gold.textMuted, fontSize: 12)),
                    const SizedBox(height: 16),
                    _field('卡名 / 潮玩名', _name, req: true),
                    _series(),
                    _field('目标买入价 (¥)', _target, num: true),
                    _stars(),
                    CardCoverPicker(
                        initialPath: _img,
                        onPicked: (String p) => setState(() => _img = p)),
                    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saving ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary, foregroundColor: context.gold.bgPure, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: _saving ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: context.gold.bgPure)) : const Text('加入心愿单', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)))),
                  ]),
                ),
              ),
      ),
    );
  }
}
