import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_response.dart';

/// 轻量级核心 HTTP 网络服务。
///
/// 统一处理：默认 8s 超时、Header 自动注入
///（Content-Type + 可选 Bearer Token）、状态码拦截
///（2xx 成功 / 401 未授权 / 4xx·5xx 异常）与断网·超时兜底。
/// 所有失败均以 [ApiResponse.failure] 返回，绝不向上抛异常导致崩溃。
///
/// 跨平台：连接层异常 Web 端为 [http.ClientException]，原生端为
/// SocketException（属 dart:io，此处不直接 import 以免破坏 Web 构建），
/// 二者均归一为「网络连接失败」。
class NetworkService {
  NetworkService({this.baseUrl = '', this.authToken});

  /// 接口基址（预留，构造时或运行时注入）。
  final String baseUrl;

  /// 鉴权 Token（预留，登录 / 刷新后可更新）。
  String? authToken;

  static const Duration _defaultTimeout = Duration(seconds: 8);

  Map<String, String> _buildHeaders() {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  /// 通用 GET 请求，返回统一包装 [ApiResponse]。
  Future<ApiResponse<T>> get<T>(String path, {Duration? timeout}) async {
    try {
      final Uri uri = Uri.parse('$baseUrl$path');
      final http.Response response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(timeout ?? _defaultTimeout);
      return _handleResponse<T>(response);
    } on TimeoutException {
      return ApiResponse<T>.failure('请求超时，请稍后重试');
    } catch (e) {
      return _wrapError<T>(e);
    }
  }

  /// 通用 POST 请求，[body] 会被 [jsonEncode] 为 JSON 字符串。
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Duration? timeout,
  }) async {
    try {
      final Uri uri = Uri.parse('$baseUrl$path');
      final http.Response response = await http
          .post(
            uri,
            headers: _buildHeaders(),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(timeout ?? _defaultTimeout);
      return _handleResponse<T>(response);
    } on TimeoutException {
      return ApiResponse<T>.failure('请求超时，请稍后重试');
    } catch (e) {
      return _wrapError<T>(e);
    }
  }

  ApiResponse<T> _handleResponse<T>(http.Response response) {
    final int code = response.statusCode;
    if (code >= 200 && code <= 299) {
      final dynamic decoded =
          response.body.isEmpty ? null : jsonDecode(response.body);
      return ApiResponse<T>.success(decoded as T?, statusCode: code);
    }
    if (code == 401) {
      return ApiResponse<T>.failure('登录已过期或权限不足 (401)', statusCode: code);
    }
    return ApiResponse<T>.failure('服务器响应异常: $code', statusCode: code);
  }

  ApiResponse<T> _wrapError<T>(Object e) {
    // 连接层异常：Web 抛 ClientException；原生抛 SocketException（dart:io）。
    final bool isNetworkError =
        e is http.ClientException || e.toString().startsWith('SocketException');
    if (isNetworkError) {
      return ApiResponse<T>.failure('网络连接失败，请检查网络设置');
    }
    return ApiResponse<T>.failure('请求发生未知错误: $e');
  }
}
