/// 卡牌本地数据源条件导出。
///
/// 原生平台使用 Isar 实现（[card_local_datasource_native]）；
/// Web 平台 Isar 3.x 不再支持 `dart:ffi`，改用纯 Dart 内存实现
/// （[card_local_datasource_web]），保证 Web 构建可编译。
library;

export 'card_local_datasource_native.dart'
    if (dart.library.html) 'card_local_datasource_web.dart';
