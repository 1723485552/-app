import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/scrydex_config.dart';
import '../../domain/enums/card_category.dart';
import 'market_price_service.dart';

export 'market_price_service.dart';

/// 真实行情服务：对接 Scrydex API，替换原 Stub / 随机种子伪造实现。
///
/// 任意网络 / 解析异常均以 `null` 优雅返回（绝不抛崩溃），由上游 UI 展示
/// 「暂无行情历史」空状态，规避伪造曲线误导决策。
///
/// 请求链路：解析卡牌 id（直查 → 按名搜索回退）→ 取最新市场价 →
/// 拉取近 30 日真实价格历史；全部经 [scrydexBaseUrl] 统一基址与双 Header 鉴权。
class MarketPriceApiService implements MarketPriceService {
  MarketPriceApiService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 8);

  Map<String, String> get _headers => <String, String>{
        'Content-Type': 'application/json',
        if (scrydexApiKey.isNotEmpty) 'X-Api-Key': scrydexApiKey,
        if (scrydexTeamId.isNotEmpty) 'X-Team-ID': scrydexTeamId,
      };

  @override
  Future<double> fetchLatestPrice(String cardName, String cardNo) async {
    final MarketQuote? quote = await fetchQuote(cardName, cardNo);
    return quote?.priceCny ?? 0.0;
  }

  @override
  Future<MarketQuote?> fetchQuote(String cardName, String cardNo,
      {CardCategory? category}) async {
    // 无密钥则优雅降级，避免伪造数据。
    if (scrydexApiKey.isEmpty || scrydexTeamId.isEmpty) return null;
    final String game = _gameFor(category);
    final String id = _deriveId(cardNo);
    try {
      final ({String id, double priceUsd})? card =
          await _resolveCard(game, id, cardName);
      if (card == null) return null;
      final List<double> history = await _fetchHistory(game, card.id);
      final List<double> historyCny =
          history.map((double e) => e * usdToCnyRate).toList();
      return MarketQuote(
        priceCny: card.priceUsd * usdToCnyRate,
        historyJson: historyCny.length >= 2 ? jsonEncode(historyCny) : '',
      );
    } catch (_) {
      return null;
    }
  }

  String _gameFor(CardCategory? c) {
    switch (c) {
      case CardCategory.onePiece:
        return 'onepiece';
      case CardCategory.pokemon:
      case CardCategory.yugioh:
      case CardCategory.sportsOther:
      case CardCategory.all:
      case null:
        return 'pokemon';
    }
  }

  /// 提取字母数字并大写，尽力匹配 Scrydex 卡牌 id（如 `#004 / BS1` → `BS1004`）。
  String _deriveId(String cardNo) {
    final String cleaned = cardNo.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return cleaned.isEmpty ? '' : cleaned.toUpperCase();
  }

  Future<dynamic> _get(String url) async {
    try {
      final http.Response res =
          await _client.get(Uri.parse(url), headers: _headers).timeout(_timeout);
      if (res.statusCode != 200 || res.body.isEmpty) return null;
      return jsonDecode(res.body);
    } catch (_) {
      return null;
    }
  }

  /// 直查卡牌；命中且含价格则直接返回，否则按卡名搜索回退取首条。
  Future<({String id, double priceUsd})?> _resolveCard(
      String game, String id, String name) async {
    if (id.isNotEmpty) {
      final dynamic res = await _get('$scrydexBaseUrl/$game/v1/cards/$id?include=prices');
      if (res != null) {
        final String? cid = _extractId(res);
        final double? price = _extractPriceUsd(res);
        if (cid != null && price != null) return (id: cid, priceUsd: price);
      }
    }
    final String q = Uri.encodeComponent('name:$name');
    final dynamic res =
        await _get('$scrydexBaseUrl/$game/v1/cards?q=$q&pageSize=1&include=prices');
    if (res == null) return null;
    final List<dynamic>? list =
        res is Map ? res['data'] as List<dynamic>? : res as List<dynamic>?;
    if (list == null || list.isEmpty) return null;
    final dynamic first = list.first;
    final String? cid = first is Map ? first['id'] as String? : null;
    if (cid == null) return null;
    return (id: cid, priceUsd: _extractPriceUsd(first) ?? 0.0);
  }

  String? _extractId(dynamic data) {
    final dynamic card =
        data is Map && data['data'] is Map ? data['data'] : data;
    return card is Map ? card['id'] as String? : null;
  }

  double? _extractPriceUsd(dynamic data) {
    final dynamic card =
        data is Map && data['data'] is Map ? data['data'] : data;
    final List<dynamic>? prices =
        card is Map ? card['prices'] as List<dynamic>? : null;
    if (prices == null || prices.isEmpty) return null;
    for (final dynamic p in prices) {
      if (p is Map && p['market'] is num) return (p['market'] as num).toDouble();
    }
    return null;
  }

  Future<List<double>> _fetchHistory(String game, String cardId) async {
    final dynamic res = await _get(
        '$scrydexBaseUrl/$game/v1/cards/$cardId/price_history?days=30');
    if (res == null) return const <double>[];
    final List<dynamic>? points =
        res is Map ? res['data'] as List<dynamic>? : res as List<dynamic>?;
    if (points == null) return const <double>[];
    final List<double> out = <double>[];
    for (final dynamic pt in points) {
      if (pt is! Map) continue;
      final num? v = pt['price'] as num? ??
          pt['market'] as num? ??
          pt['value'] as num? ??
          pt['close'] as num?;
      if (v != null) out.add(v.toDouble());
    }
    return out;
  }
}

/// 行情服务 Provider：注入真实 Scrydex 实现（原 Stub 已下架）。
final Provider<MarketPriceService> marketPriceServiceProvider =
    Provider<MarketPriceService>((ref) => MarketPriceApiService());
