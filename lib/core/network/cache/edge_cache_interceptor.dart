import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'edge_cache_interceptor.g.dart';

@HiveType(typeId: 10)
class CacheEntry extends HiveObject {
  @HiveField(0)
  @override
  final String key;

  @HiveField(1)
  final String jsonBody;

  @HiveField(2)
  final DateTime cachedAt;

  @HiveField(3)
  final String? eTag;

  @HiveField(4)
  final String? lastModified;

  @HiveField(5)
  final int maxAgeSeconds;

  CacheEntry({
    required this.key,
    required this.jsonBody,
    required this.cachedAt,
    this.eTag,
    this.lastModified,
    this.maxAgeSeconds = 86400,
  });

  bool get isExpired =>
      DateTime.now().difference(cachedAt).inSeconds > maxAgeSeconds;

  Map<String, dynamic> toJson() => {
        'key': key,
        'jsonBody': jsonBody,
        'cachedAt': cachedAt.toIso8601String(),
        'eTag': eTag,
        'lastModified': lastModified,
        'maxAgeSeconds': maxAgeSeconds,
      };
}

class EdgeCacheInterceptor extends Interceptor {
  static const String cacheBoxName = 'api_edge_cache_box';
  static const int defaultMaxAgeSeconds = 86400;
  late final Box<CacheEntry> _cacheBox;

  EdgeCacheInterceptor() {
    _cacheBox = Hive.box<CacheEntry>(cacheBoxName);
  }

  String _cacheKey(RequestOptions options) {
    final List<String> queryPairs = options.queryParameters.entries
        .where((entry) => entry.value != null)
        .map((entry) =>
            '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent('${entry.value}')}')
        .toList()
      ..sort();

    return '${options.baseUrl}${options.path}${queryPairs.isEmpty ? '' : '?${queryPairs.join('&')}'}';
  }

  bool _shouldCache(RequestOptions options) {
    return options.method.toUpperCase() == 'GET' &&
        options.extra['disable_cache'] != true;
  }

  bool _enableOfflineFallback(RequestOptions options) {
    return options.extra['offline_first'] == true ||
        options.extra['use_cache_on_error'] == true;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_shouldCache(options)) {
      handler.next(options);
      return;
    }

    final String cacheKey = _cacheKey(options);
    final CacheEntry? entry = _cacheBox.get(cacheKey);

    if (entry != null) {
      if (entry.eTag != null) {
        options.headers['If-None-Match'] = entry.eTag;
      }
      if (entry.lastModified != null && options.headers['If-Modified-Since'] == null) {
        options.headers['If-Modified-Since'] = entry.lastModified;
      }

      if (!entry.isExpired && _enableOfflineFallback(options)) {
        return handler.resolve(Response(
          requestOptions: options,
          data: jsonDecode(entry.jsonBody),
          statusCode: 200,
          extra: {'is_from_cache': true, 'is_offline_fallback': true},
        ));
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final RequestOptions options = response.requestOptions;
    final String cacheKey = _cacheKey(options);

    if (_shouldCache(options) && response.statusCode == 200) {
      try {
        final String body = jsonEncode(response.data);
        final String? eTag = response.headers.value('etag');
        final String? lastModified = response.headers.value('last-modified');

        _cacheBox.put(
          cacheKey,
          CacheEntry(
            key: cacheKey,
            jsonBody: body,
            cachedAt: DateTime.now(),
            eTag: eTag,
            lastModified: lastModified,
            maxAgeSeconds: options.extra['cache_max_age'] as int? ?? defaultMaxAgeSeconds,
          ),
        );
      } catch (_) {
        // 忽略无法缓存的响应体。
      }
    } else if (response.statusCode == 304) {
      final CacheEntry? entry = _cacheBox.get(cacheKey);
      if (entry != null) {
        return handler.resolve(Response(
          requestOptions: options,
          data: jsonDecode(entry.jsonBody),
          statusCode: 200,
          extra: {
            'is_from_cache': true,
            'is_not_modified': true,
            'is_offline_fallback': false,
          },
        ));
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      final String cacheKey = _cacheKey(err.requestOptions);
      final CacheEntry? entry = _cacheBox.get(cacheKey);
      if (entry != null && _enableOfflineFallback(err.requestOptions)) {
        return handler.resolve(Response(
          requestOptions: err.requestOptions,
          data: jsonDecode(entry.jsonBody),
          statusCode: 200,
          extra: {
            'is_fallback_offline': true,
            'fallback_source': 'cache_entry',
          },
        ));
      }
    }
    handler.next(err);
  }
}
