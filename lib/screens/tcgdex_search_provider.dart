import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tcgdex_card.dart';
import '../services/tcgdex_service.dart';

/// TCGdex 搜索状态：未查询 / 加载中 / 成功 / 异常 四态。
sealed class TcgdexSearchState {
  const TcgdexSearchState();
}

class TcgdexIdle extends TcgdexSearchState {
  const TcgdexIdle();
}

class TcgdexLoading extends TcgdexSearchState {
  const TcgdexLoading();
}

class TcgdexLoaded extends TcgdexSearchState {
  const TcgdexLoaded(this.cards);
  final List<TcgdexCard> cards;
}

class TcgdexError extends TcgdexSearchState {
  const TcgdexError(this.message);
  final String message;
}

/// TCGdex 搜索控制器：真实联动搜索框输入与网络服务。
class TcgdexSearchNotifier extends StateNotifier<TcgdexSearchState> {
  TcgdexSearchNotifier(this._service) : super(const TcgdexIdle());

  final TcgdexService _service;

  /// 执行搜索；空查询重置为 Idle（不发起请求）。
  Future<void> search(String query) async {
    final String q = query.trim();
    if (q.isEmpty) {
      state = const TcgdexIdle();
      return;
    }
    state = const TcgdexLoading();
    try {
      final List<TcgdexCard> cards = await _service.searchCards(q);
      state = TcgdexLoaded(cards);
    } on TcgdexException catch (e) {
      state = TcgdexError(e.message);
    } catch (_) {
      state = const TcgdexError('未知错误，请稍后重试');
    }
  }

  /// 获取并展示单卡详情（预留：供卡片项点击跳转详情页）。
  Future<TcgdexCard?> fetchDetail(String id) async {
    try {
      return await _service.getCardDetail(id);
    } on TcgdexException {
      return null;
    }
  }
}

/// 全局 TCGdex 搜索 Provider。
final StateNotifierProvider<TcgdexSearchNotifier, TcgdexSearchState>
    tcgdexSearchProvider =
    StateNotifierProvider<TcgdexSearchNotifier, TcgdexSearchState>(
        (ref) => TcgdexSearchNotifier(TcgdexService()));
