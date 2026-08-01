import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card_repository.dart';
import 'card_repository_impl_native.dart' if (dart.library.html) 'card_repository_impl_web.dart';

/// 全局卡牌仓库 Provider（按平台注入原生 / Web 实现）。
///
/// 通过条件导入解析具体实现 [CardRepositoryImpl]，避免条件导出在库内不可见的问题。
final Provider<CardRepository> cardRepositoryProvider =
    Provider<CardRepository>((ref) => CardRepositoryImpl());
