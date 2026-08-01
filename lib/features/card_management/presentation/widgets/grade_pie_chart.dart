import 'package:fl_chart/fl_chart.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/card_item.dart';
import '../../domain/enums/card_category.dart';
import '../../domain/enums/grading_company.dart';
import '../providers/card_providers.dart';

/// 评级公司 → 饼图黑金高奢配色（PSA 香槟金 / BGS 曜石黑 / CGC 钛银蓝 / 裸卡高灰），BGS 取主题响应式 [GoldThemeExtension.chartBgs]。
Map<GradingCompany, Color> _gradingColors(BuildContext context) => <GradingCompany, Color>{
  GradingCompany.raw: AppColors.chartRaw, GradingCompany.psa: AppColors.goldPrimary,
  GradingCompany.bgs: context.gold.chartBgs, GradingCompany.cgc: AppColors.chartCgc,
};

const Map<GradingCompany, String> _gradingLabel = <GradingCompany, String>{
  GradingCompany.raw: '裸卡',
  GradingCompany.psa: 'PSA',
  GradingCompany.bgs: 'BGS',
  GradingCompany.cgc: 'CGC',
};

/// 黑金高奢半径常量：未选中 32dp，选中平滑放大至 42dp（突出 +10dp）。
const double _kBaseRadius = 32;
const double _kSelectedRadius = 42;
const double _kCenterSpace = 26;

/// 百分比徽标：跨主题恒定的暗色半透明底 + 白字，选中时字号放大加粗。
Widget _buildBadge(String text, bool selected) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.chartBadgeBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: TextStyle(
              color: AppColors.chartBadgeText,
              fontSize: selected ? 15 : 12,
              fontWeight: FontWeight.bold)),
    );

/// 评级占比饼图（GradePieChart）。
///
/// 监听 [categoryFilteredCardsProvider]，按评级公司聚合占比；
/// 切换分类时以 400ms 重播平滑动画（通过 key 驱动 remount）。
class GradePieChart extends ConsumerWidget {
  const GradePieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CardItem>> asyncCards =
        ref.watch(categoryFilteredCardsProvider);
    final CardCategory category = ref.watch(selectedCategoryProvider);
    return asyncCards.when(
      loading: () => const _ChartState(text: '加载中…'),
      error: (_, __) => const _ChartState(text: '数据加载失败'),
      data: (List<CardItem> cards) {
        if (cards.isEmpty) return const _ChartState(text: '该分类暂无卡牌');
        final Map<GradingCompany, int> counts = <GradingCompany, int>{};
        for (final CardItem c in cards) {
          counts[c.grading] = (counts[c.grading] ?? 0) + 1;
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _PieContent(
            key: ValueKey<CardCategory>(category),
            counts: counts,
            total: cards.length,
          ),
        );
      },
    );
  }
}

/// loading / error / empty 的极简黑金占位。
class _ChartState extends StatelessWidget {
  const _ChartState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.gold.surfaceDark,
          border: Border.all(color: AppColors.goldBorder, width: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text,
            style: TextStyle(color: context.gold.textMuted, fontSize: 13)),
      );
}

/// 饼图 + 图例（响应式：饼图尺寸随可用宽度自适应，永不超过容器）。
///
/// 维护 [touchedIndex] 实现点击扇区平滑放大交互。
class _PieContent extends StatefulWidget {
  const _PieContent({
    super.key,
    required this.counts,
    required this.total,
  });

  final Map<GradingCompany, int> counts;
  final int total;

  @override
  State<_PieContent> createState() => _PieContentState();
}

class _PieContentState extends State<_PieContent> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<GradingCompany, int>> entries =
        widget.counts.entries.toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.gold.surfaceDark,
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double full = constraints.maxWidth;
          // 为右侧图例预留最小宽度，避免窄屏下文字挤压 / 溢出。
          const double legendMin = 120.0;
          // pieSize 自适应封顶，下限保证容纳选中 42dp 半径。
          final double pieSize = (full - 16 - legendMin).clamp(120.0, 150.0);

          // fl_chart 0.68：外半径 = centerSpaceRadius + section.radius（绝对像素）。
          // 反推半径预算，确保整体直径 ≤ 容器，杜绝爆框；常规屏宽下选中态稳定 42dp。
          final double maxOuter = pieSize / 2 - 4;
          final double centerSpace = _kCenterSpace.clamp(0.0, maxOuter - 2);
          final double selectedR =
              _kSelectedRadius.clamp(0.0, maxOuter - centerSpace);
          final double baseR = _kBaseRadius.clamp(0.0, selectedR);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('评级占比',
                  style: TextStyle(
                      color: context.gold.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: pieSize,
                    height: pieSize,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: centerSpace,
                        startDegreeOffset: -90,
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, PieTouchResponse? resp) {
                            if (event is FlTapUpEvent) {
                              final int idx = resp
                                      ?.touchedSection?.touchedSectionIndex ??
                                  -1;
                              if (idx != _touchedIndex) {
                                HapticFeedback.lightImpact();
                                setState(() => _touchedIndex = idx);
                              }
                            }
                          },
                        ),
                        sections: entries.asMap().entries.map(
                          (MapEntry<int, MapEntry<GradingCompany, int>> me) {
                            final bool selected = _touchedIndex == me.key;
                            final MapEntry<GradingCompany, int> e = me.value;
                            return PieChartSectionData(
                              value: e.value.toDouble(),
                              title: '',
                              showTitle: false,
                              color: _gradingColors(context)[e.key]!,
                              radius: selected ? selectedR : baseR,
                              borderSide: const BorderSide(
                                  color: AppColors.goldGlow, width: 0.5),
                              badgeWidget: _buildBadge(
                                '${(e.value / widget.total * 100).round()}%',
                                selected,
                              ),
                              badgePositionPercentageOffset: 0.5,
                            );
                          },
                        ).toList(),
                      ),
                      swapAnimationDuration:
                          const Duration(milliseconds: 600),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entries
                          .map(
                            (MapEntry<GradingCompany, int> e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _gradingColors(context)[e.key],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_gradingLabel[e.key]!,
                                      style: TextStyle(
                                          color: context.gold.textWhite,
                                          fontSize: 12)),
                                  const Spacer(),
                                  Text('${e.value}张 · ${(e.value / widget.total * 100).round()}%',
                                      style: TextStyle(
                                          color: context.gold.textMuted,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
