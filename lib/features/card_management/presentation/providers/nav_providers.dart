import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 底部导航栏选中索引（响应式状态，遵循 RULES.md Riverpod 硬规）。
///
/// 抽离为独立 Provider 文件，供 [MainScreen] 与首页各组件共享，
/// 避免 widget ↔ page 之间的循环依赖。
/// 索引对应：0=首页 / 1=攒卡 / 2=账单 / 3=我的。
final StateProvider<int> navIndexProvider = StateProvider<int>((ref) => 0);
