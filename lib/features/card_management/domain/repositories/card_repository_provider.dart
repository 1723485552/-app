import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card_repository.dart';
import 'card_repository_impl_drift.dart';

/// 全局卡牌仓库 Provider（按平台注入原生 / Web 实现）。
///
/// 通过条件导入解析具体实现 [CardRepositoryImpl]，避免条件导出在库内不可见的问题。
///
/// 原生平台自 v2 起改为 **SQLite(Drift) 本地优先 + Supabase 后台增量同步** 实现
/// （[card_repository_impl_drift]）；旧的纯 Isar 实现
/// （`card_repository_impl_native.dart`）保留在仓库中作为回滚备份，未被引用。
/// Web 平台仍走内存实现，行为不变。
final Provider<CardRepository> cardRepositoryProvider =
    Provider<CardRepository>((ref) => CardRepositoryImpl());
