import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// 图鉴数据层专用 Web 安全 HTTP 工具。
///
/// 统一封装超时与异常归一：连接 / 超时 / 解析异常一律返回 `null`，
/// 由调用方降级为「空列表 + 空状态」，绝不向上抛异常导致黑屏。
/// 仅依赖 `http`，无 `dart:io` 引用，Web 端可正常编译运行。

/// GET 并返回 JSON 对象；失败返回 `null`。
Future<Map<String, dynamic>?> catalogGetJson(
  String url, {
  Map<String, String>? headers,
  Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    final Uri uri = Uri.parse(url);
    final http.Response res =
        await http.get(uri, headers: headers).timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) return null;
    final dynamic body = jsonDecode(res.body);
    return body is Map<String, dynamic> ? body : null;
  } on TimeoutException {
    return null;
  } catch (_) {
    return null;
  }
}

/// GET 并返回 JSON 数组；失败返回 `null`。
Future<List<dynamic>?> catalogGetList(
  String url, {
  Map<String, String>? headers,
  Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    final Uri uri = Uri.parse(url);
    final http.Response res =
        await http.get(uri, headers: headers).timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) return null;
    final dynamic body = jsonDecode(res.body);
    return body is List<dynamic> ? body : null;
  } on TimeoutException {
    return null;
  } catch (_) {
    return null;
  }
}
