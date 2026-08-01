import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/enums/grading_company.dart';
import '../providers/collection_providers.dart';

/// 搜卡与评级筛选栏。
///
/// 搜索框（gold underline / focus 态）与 PSA / BGS / CGC 评级快捷筛选，
/// 均通过 Riverpod 实时联动 [filteredCollectionProvider]，搜索/筛选即刻反映到全页列表。
class CardSearchFilterBar extends ConsumerWidget {
  const CardSearchFilterBar({super.key});

  static const List<GradingCompany?> _options = <GradingCompany?>[
    null,
    GradingCompany.psa,
    GradingCompany.bgs,
    GradingCompany.cgc,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GradingCompany? grading = ref.watch(cardGradingFilterProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: <Widget>[
          TextField(
            onChanged: (String v) =>
                ref.read(cardSearchQueryProvider.notifier).state = v,
            style: TextStyle(color: context.gold.textWhite, fontSize: 14),
            decoration: InputDecoration(
              hintText: '搜索卡牌名称',
              hintStyle:
                  TextStyle(color: context.gold.textMuted, fontSize: 14),
              prefixIcon: Icon(Icons.search_outlined,
                  color: context.gold.textMuted, size: 20),
              filled: true,
              fillColor: context.gold.surfaceDark,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.goldBorder, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.goldBorder, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.goldPrimary, width: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _options
                  .map((GradingCompany? g) => _gradeChip(context, ref, g, grading))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradeChip(
      BuildContext context, WidgetRef ref, GradingCompany? g, GradingCompany? current) {
    final bool active = g == current;
    final String label = g == null ? '全部' : _gradeLabel(g);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(cardGradingFilterProvider.notifier).state = g;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.goldGlow : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? AppColors.goldPrimary : AppColors.goldBorder,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.goldPrimary : context.gold.textMuted,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  String _gradeLabel(GradingCompany g) {
    switch (g) {
      case GradingCompany.psa:
        return 'PSA';
      case GradingCompany.bgs:
        return 'BGS';
      case GradingCompany.cgc:
        return 'CGC';
      case GradingCompany.raw:
        return '裸卡';
    }
  }
}
