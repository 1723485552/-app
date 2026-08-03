import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../models/tcgdex_card.dart';
import 'tcgdex_card_tile.dart';
import 'tcgdex_search_provider.dart';

/// TCGdex 宝可梦卡牌搜索页（黑金大厂风格）。
///
/// 顶部搜索框实时联动 [tcgdexSearchProvider]；主体三态渲染：
/// 加载中（环形进度）、异常（矢量提示 + 重试）、空结果（干净提示）；
/// 成功结果为 2 列紧凑卡牌网格。全部遵循 8dp 网格与黑金 token。
class CardSearchScreen extends ConsumerStatefulWidget {
  const CardSearchScreen({super.key});

  @override
  ConsumerState<CardSearchScreen> createState() => _CardSearchScreenState();
}

class _CardSearchScreenState extends ConsumerState<CardSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _lastQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final String q = value.trim();
    _lastQuery = q;
    ref.read(tcgdexSearchProvider.notifier).search(q);
  }

  void _retry() {
    if (_lastQuery.isNotEmpty) _submit(_lastQuery);
  }

  @override
  Widget build(BuildContext context) {
    final TcgdexSearchState state = ref.watch(tcgdexSearchProvider);
    return Scaffold(
      backgroundColor: context.gold.bgDark,
      appBar: AppBar(
        backgroundColor: context.gold.bgDark,
        elevation: 0,
        centerTitle: false,
        title: Text('TCGdex 卡牌查询',
            style: TextStyle(
                color: context.gold.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: <Widget>[
          _SearchBar(controller: _controller, onSubmit: _submit),
          Expanded(child: _Body(state: state, onRetry: _retry)),
        ],
      ),
    );
  }
}

/// 黑金搜索框：0.5px 金边 + 轻量矢量图标 + 提交回车即时检索。
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSubmit});
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmit,
        style: TextStyle(color: context.gold.textWhite, fontSize: 14),
        cursorColor: AppColors.goldPrimary,
        decoration: InputDecoration(
          hintText: '搜索卡牌名称，如 Pikachu / Charizard',
          hintStyle: TextStyle(color: context.gold.textInactive, fontSize: 14),
          prefixIcon: Icon(Icons.search_outlined,
              color: context.gold.textMuted, size: 20),
          filled: true,
          fillColor: context.gold.surfaceDark,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.goldBorder, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.goldBorder, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.goldPrimary, width: 0.5),
          ),
        ),
      ),
    );
  }
}

/// 主体三态渲染。
class _Body extends StatelessWidget {
  const _Body({required this.state, required this.onRetry});
  final TcgdexSearchState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      TcgdexIdle() => const _Hint(icon: Icons.search_outlined, text: '输入关键字开始搜索 TCGdex 卡牌'),
      TcgdexLoading() => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrimary),
        ),
      TcgdexError(:final message) => _ErrorState(message: message, onRetry: onRetry),
      TcgdexLoaded(:final cards) => _buildGrid(context, cards),
    };
  }

  Widget _buildGrid(BuildContext context, List<TcgdexCard> cards) {
    if (cards.isEmpty) {
      return const _Hint(icon: Icons.inventory_2_outlined, text: '未找到相关卡牌，换个关键字试试');
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: GridView.builder(
        key: ValueKey<int>(cards.length),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemCount: cards.length,
        itemBuilder: (BuildContext ctx, int i) => TcgdexCardTile(
          card: cards[i],
          onTap: () {},
        ),
      ),
    );
  }
}

/// 空态 / 引导态：黑金矢量提示，无 emoji。
class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48, color: context.gold.textInactive),
            const SizedBox(height: 12),
            Text(text,
                style: TextStyle(color: context.gold.textMuted, fontSize: 14)),
          ],
        ),
      );
}

/// 异常态：矢量提示 + 重试。
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.cloud_off_outlined,
                  size: 48, color: context.gold.textInactive),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.gold.textMuted, fontSize: 14)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.goldPrimary, width: 0.5),
                  foregroundColor: AppColors.goldPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
}
