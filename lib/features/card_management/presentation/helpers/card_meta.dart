import 'package:flutter/material.dart';

import '../../domain/enums/card_category.dart';
import '../../domain/enums/grading_company.dart';

/// 卡牌分类展示元数据集中映射（图标 + 中文文案）。
///
/// 作为单一数据源，避免首页导航、攒卡分组、行情榜单等各 Widget 重复硬编码
/// 分类的图标与文案，符合 RULES.md「拒绝单文件代码堆砌 / 防重复」的硬规。
IconData cardCategoryIcon(CardCategory category) {
  switch (category) {
    case CardCategory.all:
      return Icons.auto_awesome_mosaic_outlined;
    case CardCategory.pokemon:
      return Icons.catching_pokemon_outlined;
    case CardCategory.onePiece:
      return Icons.sailing_outlined;
    case CardCategory.yugioh:
      return Icons.extension_outlined;
    case CardCategory.sportsOther:
      return Icons.sports_basketball_outlined;
  }
}

/// 分类中文文案。
String cardCategoryLabel(CardCategory category) {
  switch (category) {
    case CardCategory.all:
      return '全部';
    case CardCategory.pokemon:
      return '宝可梦';
    case CardCategory.onePiece:
      return '航海王';
    case CardCategory.yugioh:
      return '游戏王';
    case CardCategory.sportsOther:
      return '体育·其他';
  }
}

/// 评级公司中文标签（单一数据源，供饼图图例、神卡勋章等复用）。
///
/// 与 [CardItem.grading] 的持久化枚举保持一致，新增评级公司时仅在此扩展。
String cardGradingLabel(GradingCompany grading) {
  switch (grading) {
    case GradingCompany.raw:
      return '裸卡';
    case GradingCompany.psa:
      return 'PSA';
    case GradingCompany.bgs:
      return 'BGS';
    case GradingCompany.cgc:
      return 'CGC';
  }
}
