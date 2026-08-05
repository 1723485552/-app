import 'dart:async';

import 'package:flutter/foundation.dart';

/// 后台静默任务护栏 —— 云端链路「绝不打扰用户」的统一入口。
///
/// ## 为什么需要它
///
/// 所有云端动作（增量同步 / 众包上报 / 自动备份）都以「本地先落盘、云端后补偿」的
/// 方式挂在写入链路之后。过去这些调用直接用 `unawaited(...)` 抛向后台，但
/// **`unawaited` 只是告诉分析器「我不打算 await」，它并不捕获异常**：
///
/// - 一旦 Future 内部抛出（平台通道失败、SharedPreferences 初始化异常、磁盘满、
///   Supabase SDK 内部错误），异常会逃逸成 *unhandled async error*；
/// - 逃逸后由当前 Zone / [FlutterError.onError] 接管 —— debug 构建下弹红屏，
///   release 下污染崩溃上报（Crashlytics 会记为一次崩溃），
///   直接违背「静默众包、失败降级、绝不打扰用户」的产品与合规约定。
///
/// ## 保证
///
/// [runSilently] 在 `unawaited` 之外再包一层 try/catch，向调用方承诺：
/// 1. **绝不阻塞** —— 立即返回，调用方不会因云端 IO 卡住 UI 线程；
/// 2. **绝不抛出** —— 任何异常都在此终结，不逃逸到 Zone；
/// 3. **绝不弹窗** —— 失败只写 debug 日志，用户端无任何可感知反馈；
/// 4. **本地为准** —— 云端失败不回滚、不影响本地数据资产，等待下次补偿同步。
///
/// ## 用法
///
/// ```dart
/// runSilently(() => _sync.pushCard(row), tag: 'CardSync');
/// ```
///
/// 泛型 [T] 让返回 `Future<bool>`（如同步服务）与 `Future<void>`（如备份服务）
/// 的任务都能直接传入，无需在调用点包一层 `async {}`。
void runSilently<T>(Future<T> Function() task, {required String tag}) {
  unawaited(_guard<T>(task, tag));
}

/// 实际执行体：吞掉一切异常，仅保留可观测的调试日志。
///
/// 这里刻意捕获 `Object` 而非 `Exception` —— 平台通道抛出的 `Error`
/// （如 `MissingPluginException` 之外的 `StateError`）同样不得逃逸。
Future<void> _guard<T>(Future<T> Function() task, String tag) async {
  try {
    await task();
  } catch (e, st) {
    // 静默降级：不抛异常、不弹窗，但保留完整错误与堆栈，便于真机调试定位底层阻断原因。
    debugPrint('[$tag] 后台任务失败（已静默降级，本地数据不受影响）: $e\n$st');
  }
}
