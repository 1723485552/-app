import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/tcgdex_card.dart';

/// TCGdex 宝可梦卡牌 API 网络服务。
///
/// 基址固定为 `https://api.tcgdex.net/v2/en/`，提供单卡详情与关键字搜索。
/// 任意网络 / 解析异常均抛出带可读中文的 [TcgdexException]，由上游 UI
/// 统一捕获并展示黑金矢量异常态，绝不静默吞错或伪造数据。
class TcgdexService {
  TcgdexService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// TCGdex v2 英文基址。
  static const String baseUrl = 'https://api.tcgdex.net/v2/en';

  static const Duration _timeout = Duration(seconds: 10);

  /// 获取单张卡片完整详情。
  ///
  /// [id] 为全局卡牌 ID（如 `swsh1-1`）。成功返回 [TcgdexCard]，失败抛
  /// [TcgdexException]。
  Future<TcgdexCard> getCardDetail(String id) async {
    final Uri uri = Uri.parse('$baseUrl/cards/$id');
    return _get<TcgdexCard>(
      uri,
      (dynamic json) => TcgdexCard.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 按名称关键字搜索卡牌列表（服务端模糊匹配）。
  ///
  /// [query] 为空或纯空白时直接返回空列表，避免无效请求；
  /// 查询词经 [Uri.https] 自动编码（支持含空格卡名，如 `Charizard V`）。
  ///
  /// 列表摘要不含价格，故取回后**并发补全前 [priceFetchLimit] 张详情**
  /// 以填充 `pricing`（其余条目保持「暂无报价」），避免数百次详情请求拖垮性能。
  /// 单张详情失败不影响整体结果（降级为无价格条目）。成功返回 [TcgdexCard] 数组。
  Future<List<TcgdexCard>> searchCards(String query) async {
    final String q = query.trim();
    if (q.isEmpty) return const <TcgdexCard>[];
    final Uri uri = Uri.https('api.tcgdex.net', '/v2/en/cards',
        <String, String>{'name': q});
    final List<dynamic> list = await _getList(uri);
    final List<TcgdexCard> summaries = list
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> json) => TcgdexCard.fromSummaryJson(json))
        .toList();

    if (summaries.isEmpty) return summaries;
    final int limit = summaries.length <= priceFetchLimit
        ? summaries.length
        : priceFetchLimit;
    final List<TcgdexCard> detailed = await Future.wait(
      summaries.sublist(0, limit).map<Future<TcgdexCard>>((TcgdexCard c) async {
        try {
          return await getCardDetail(c.id);
        } catch (_) {
          return c; // 详情失败降级为无价格摘要
        }
      }),
    );
    return <TcgdexCard>[
      ...detailed,
      ...summaries.sublist(limit),
    ];
  }

  /// 搜索时并发补全价格的最大卡片数（性能护栏）。
  static const int priceFetchLimit = 12;

  Future<T> _get<T>(
    Uri uri,
    T Function(dynamic) parser,
  ) async {
    try {
      final http.Response res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode != 200 || res.body.isEmpty) {
        throw TcgdexException('服务器响应异常：${res.statusCode}');
      }
      return parser(jsonDecode(res.body));
    } on TimeoutException {
      throw TcgdexException('请求超时，请稍后重试');
    } on TcgdexException {
      rethrow;
    } catch (e) {
      throw TcgdexException('网络连接失败，请检查网络设置');
    }
  }

  Future<List<dynamic>> _getList(Uri uri) async {
    try {
      final http.Response res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode != 200 || res.body.isEmpty) {
        throw TcgdexException('服务器响应异常：${res.statusCode}');
      }
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is List<dynamic>) return decoded;
      throw TcgdexException('数据格式异常');
    } on TimeoutException {
      throw TcgdexException('请求超时，请稍后重试');
    } on TcgdexException {
      rethrow;
    } catch (e) {
      throw TcgdexException('网络连接失败，请检查网络设置');
    }
  }
}

/// TCGdex 业务异常：统一携带可读中文提示，供 UI 直接展示。
class TcgdexException implements Exception {
  const TcgdexException(this.message);
  final String message;
  @override
  String toString() => message;
}
