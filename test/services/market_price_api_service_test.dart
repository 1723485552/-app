import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:card_management/features/card_management/domain/services/market_price_api_service.dart';

/// 根据 URL 返回模拟 Scrydex 响应的 MockClient。
/// - 搜索接口 `/cards?q=`：返回含一条带价格的卡（验证直查回退链路）。
/// - 历史接口 `/price_history`：返回两条真实历史价。
/// - [status] 非 200 时整站返回该状态码（模拟网络 / 服务端异常）。
MockClient _mockClient({int status = 200}) => MockClient(
      (http.Request request) async {
        final String url = request.url.toString();
        if (status != 200) {
          return http.Response('', status, request: request);
        }
        if (url.contains('/price_history')) {
          return http.Response(
            jsonEncode(<Map<String, dynamic>>[
              <String, dynamic>{'price': 100.0},
              <String, dynamic>{'price': 110.0},
            ]),
            200,
            request: request,
          );
        }
        if (url.contains('/cards?q=')) {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'data': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'TEST123',
                  'prices': <Map<String, dynamic>>[
                    <String, dynamic>{'market': 10.0},
                  ],
                },
              ],
            }),
            200,
            request: request,
          );
        }
        // 直查接口兜底返回空 data，迫使回退到按名搜索。
        return http.Response(
          jsonEncode(<String, dynamic>{'data': <dynamic>[]}),
          200,
          request: request,
        );
      },
    );

void main() {
  group('Scrydex API 优雅降级', () {
    test('无密钥时 fetchQuote 优雅返回 null（不抛、不伪造）', () async {
      // 未注入 apiKey/teamId → 取默认编译期常量（测试环境默认空）→ 直接降级。
      final MarketPriceApiService svc =
          MarketPriceApiService(client: _mockClient());
      final MarketQuote? quote = await svc.fetchQuote('Pikachu', '001');
      expect(quote, isNull);
    });

    test('注入密钥且接口正常：返回折算后的 CNY 价与真实历史', () async {
      final MarketPriceApiService svc = MarketPriceApiService(
        client: _mockClient(),
        apiKey: 'k',
        teamId: 't',
      );
      // cardNo 空 → _deriveId 返回 '' → 跳过直查，走按名搜索回退。
      final MarketQuote? quote = await svc.fetchQuote('Pikachu', '');
      expect(quote, isNotNull);
      // priceUsd=10.0 * usdToCnyRate(7.2) = 72.0
      expect(quote!.priceCny, 72.0);
      // 历史 [100,110] * 7.2 = [720,792]，长度>=2 → 写入 historyJson
      final List<dynamic> hist = jsonDecode(quote.historyJson) as List<dynamic>;
      expect(hist, <dynamic>[720.0, 792.0]);
    });

    test('服务端 500：fetchQuote 捕获异常返回 null', () async {
      final MarketPriceApiService svc = MarketPriceApiService(
        client: _mockClient(status: 500),
        apiKey: 'k',
        teamId: 't',
      );
      final MarketQuote? quote = await svc.fetchQuote('Pikachu', '');
      expect(quote, isNull);
    });

    test('响应结构非法（data 非数组）：解析失败返回 null', () async {
      final MockClient bad = MockClient(
        (http.Request request) async => http.Response(
          jsonEncode(<String, dynamic>{'data': 'not-a-list'}),
          200,
          request: request,
        ),
      );
      final MarketPriceApiService svc = MarketPriceApiService(
        client: bad,
        apiKey: 'k',
        teamId: 't',
      );
      final MarketQuote? quote = await svc.fetchQuote('Pikachu', '');
      expect(quote, isNull);
    });

    test('fetchLatestPrice 无数据时回落为 0.0（不抛）', () async {
      final MarketPriceApiService svc = MarketPriceApiService(
        client: _mockClient(status: 500),
        apiKey: 'k',
        teamId: 't',
      );
      final double price = await svc.fetchLatestPrice('Pikachu', '');
      expect(price, 0.0);
    });
  });
}
