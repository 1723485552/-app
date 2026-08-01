import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/enums/currency_unit.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/profile_providers.dart';

/// 个人中心黑金高奢 Header。
///
/// 展现 VVIP 头像框、收藏家昵称、资产总称号（按估值分档）、
/// 资产估值（随货币单位实时联动）与收藏生涯三大核心指标微卡片。
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ProfileStats> stats = ref.watch(profileStatsProvider);
    final CurrencyUnit unit = ref.watch(profileCurrencyProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.gold.bgDark,
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          const _VipAvatar(),
          const SizedBox(height: 16),
          Text(
            '墨金藏家',
            style: TextStyle(
              color: context.gold.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          stats.when(
            loading: () => const SizedBox(
              height: 44,
              child: CircularProgressIndicator(
                color: AppColors.goldPrimary,
                strokeWidth: 2,
              ),
            ),
            error: (_, __) => Text(
              '数据加载失败',
              style: TextStyle(color: context.gold.textMuted, fontSize: 13),
            ),
            data: (ProfileStats s) => Column(
              children: <Widget>[
                Text(
                  s.title,
                  style: const TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '资产估值 ${CurrencyFormatter.formatCny(s.totalAssetValue, unit)}',
                  style: TextStyle(
                    color: context.gold.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _Metric(label: '入坑天数', value: '${s.daysSinceFirst}'),
                    ),
                    Expanded(
                      child: _Metric(label: '收藏卡牌', value: '${s.collectedCount}'),
                    ),
                    Expanded(
                      child: _Metric(
                        label: '最高收益',
                        value: '${s.maxReturnPct >= 0 ? '+' : ''}'
                            '${s.maxReturnPct.toStringAsFixed(1)}%',
                        valueColor: s.maxReturnPct >= 0
                            ? AppColors.trendUp
                            : AppColors.trendDown,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// VVIP 头像框：香槟金圆环 + 微光晕 + 角标 VVIP 标识。
class _VipAvatar extends StatelessWidget {
  const _VipAvatar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.goldPrimary, width: 1.5),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: AppColors.goldGlow,
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.gold.surfaceDark,
              border: Border.all(color: AppColors.goldBorder, width: 0.5),
            ),
            child: const Icon(
              Icons.diamond_outlined,
              size: 36,
              color: AppColors.goldPrimary,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.gold.bgDark, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.verified_user_outlined,
                    size: 12, color: context.gold.bgDark),
                const SizedBox(width: 3),
                Text(
                  'VVIP',
                  style: TextStyle(
                    color: context.gold.bgDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Header 内的单个指标微卡片。
class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? context.gold.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: context.gold.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}
