import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/catalog_category.dart';
import '../../domain/models/catalog_item.dart';
import '../../domain/models/catalog_page.dart';
import 'catalog_providers.dart';

/// 图鉴分页检索状态（累积列表 + 翻页游标 + 加载/错误态）。
class CatalogSearchState {
  const CatalogSearchState({
    this.items = const <CatalogItem>[],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.error,
    this.category = CatalogCategory.tcgPokemon,
    this.query = '',
  });
  final List<CatalogItem> items;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final CatalogCategory category;
  final String query;

  CatalogSearchState copyWith({
    List<CatalogItem>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    String? error,
    CatalogCategory? category,
    String? query,
  }) =>
      CatalogSearchState(
        items: items ?? this.items,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        category: category ?? this.category,
        query: query ?? this.query,
      );
}

/// 图鉴检索 Notifier：管理分页累积与滚动触底加载更多。
class CatalogSearchNotifier
    extends AutoDisposeAsyncNotifier<CatalogSearchState> {
  @override
  Future<CatalogSearchState> build() async => const CatalogSearchState();

  /// 重新检索（切换分类 / 关键词防抖后触发），重置分页游标。
  Future<void> search(String query, CatalogCategory category) async {
    state = const AsyncLoading();
    try {
      final CatalogPage page = await ref
          .read(catalogServiceProvider)
          .searchPage(query, category, 1);
      state = AsyncData(CatalogSearchState(
        items: page.items,
        page: 1,
        hasMore: page.hasMore,
        category: category,
        query: query,
      ));
    } catch (e) {
      state = AsyncData(const CatalogSearchState()
          .copyWith(error: e.toString(), isLoading: false));
    }
  }

  /// 触底加载下一页（并发 / 越界由内部状态守卫）。
  Future<void> loadMore() async {
    final CatalogSearchState? cur = state.value;
    if (cur == null || cur.isLoading || !cur.hasMore) return;
    state = AsyncData(cur.copyWith(isLoading: true));
    try {
      final CatalogPage next = await ref
          .read(catalogServiceProvider)
          .searchPage(cur.query, cur.category, cur.page + 1);
      state = AsyncData(cur.copyWith(
        items: <CatalogItem>[...cur.items, ...next.items],
        page: cur.page + 1,
        hasMore: next.hasMore,
        isLoading: false,
      ));
    } catch (e) {
      state = AsyncData(cur.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

/// 图鉴检索（分页）Provider。
final AutoDisposeAsyncNotifierProvider<CatalogSearchNotifier, CatalogSearchState>
    catalogSearchProvider =
    AutoDisposeAsyncNotifierProvider<CatalogSearchNotifier, CatalogSearchState>(
  CatalogSearchNotifier.new,
);
