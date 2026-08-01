/// 卡牌数据模型的条件导出。
///
/// 原生平台使用 Isar 持久化模型（[card_item_native]）；
/// Web 平台 Isar 3.x 不再支持 `dart:ffi`，改用纯 Dart 内存模型（[card_item_web]），
/// 从而把 Isar / FFI 代码彻底排除在 Web 构建之外。
library;

export 'card_item_native.dart' if (dart.library.html) 'card_item_web.dart';
