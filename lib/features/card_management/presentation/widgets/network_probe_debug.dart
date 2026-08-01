import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:card_management/core/theme/gold_theme_extension.dart';

/// 临时调试组件：App 层网络连通性探测（无需 Scrydex 密钥）。
///
/// 直接用 App 依赖的 `http` 库访问两个公开地址，显示状态码与耗时，
/// 用于确认「应用自身能否出网」。验证完毕后可整体删除本文件及其引用。
class NetworkProbeDebug extends StatefulWidget {
  const NetworkProbeDebug({super.key});

  @override
  State<NetworkProbeDebug> createState() => _NetworkProbeDebugState();
}

class _NetworkProbeDebugState extends State<NetworkProbeDebug> {
  static const Duration _timeout = Duration(seconds: 8);
  static const List<(String, String)> _targets = <(String, String)>[
    ('Scrydex API', 'https://api.scrydex.com/'),
    ('Google', 'https://www.google.com/'),
  ];

  final Map<String, String> _results = <String, String>{};
  bool _testing = false;

  Future<void> _runProbe() async {
    if (_testing) return;
    setState(() {
      _testing = true;
      _results.clear();
    });
    for (final (String name, String url) in _targets) {
      final Stopwatch sw = Stopwatch()..start();
      try {
        final http.Response res =
            await http.get(Uri.parse(url)).timeout(_timeout);
        sw.stop();
        final String mark =
            res.statusCode >= 200 && res.statusCode <= 399 ? '✅' : '⚠️';
        _results[name] = '$mark HTTP ${res.statusCode} · ${sw.elapsedMilliseconds}ms';
      } on TimeoutException {
        _results[name] = '⏱️ 超时（${_timeout.inSeconds}s）';
      } catch (e) {
        _results[name] = '❌ 连接失败：$e';
      }
      if (!mounted) return;
      setState(() {});
    }
    if (!mounted) return;
    setState(() => _testing = false);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = TextStyle(
      color: context.gold.textWhite,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
    final TextStyle bodyStyle = TextStyle(
      color: context.gold.textMuted,
      fontSize: 13,
    );
    return Card(
      color: context.gold.surfaceDark,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.wifi_find, color: context.gold.goldPrimary, size: 18),
                const SizedBox(width: 8),
                Text('调试 · 网络探测（可删）', style: titleStyle),
              ],
            ),
            const SizedBox(height: 4),
            Text('验证 App 自身能否出网，不依赖 Scrydex 密钥', style: bodyStyle),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _testing ? null : _runProbe,
              icon: _testing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.network_check, size: 16),
              label: Text(_testing ? '探测中…' : '开始探测'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.gold.goldPrimary,
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            ..._targets.map((t) {
              final String name = t.$1;
              final String url = t.$2;
              final String? r = _results[name];
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: Text('$name\n$url', style: bodyStyle)),
                    const SizedBox(width: 8),
                    Text(r ?? '—', style: bodyStyle),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
