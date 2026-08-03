import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import 'package:card_management/core/theme/app_colors.dart';
import '../../domain/enums/catalog_category.dart';
import '../../domain/models/catalog_item.dart';
import '../providers/catalog_providers.dart';
import '../providers/catalog_search_notifier.dart';
import '../widgets/catalog_card_tile.dart';
import '../widgets/catalog_detail_sheet.dart';

/// 全图鉴中心：分类 Tab + 防抖搜索 + 网格 + 触底无限加载 + 详情浮层。
class CatalogCenterPage extends ConsumerStatefulWidget {
  const CatalogCenterPage({super.key});

  /// 四个分类 Tab（单一球星卡 Tab 涵盖 NBA / 足球等子品类）。
  static const List<CatalogCategory> _tabs = <CatalogCategory>[
    CatalogCategory.tcgPokemon,
    CatalogCategory.tcgYugioh,
    CatalogCategory.tcgMtg,
    CatalogCategory.sportsNba,
  ];

  @override
  ConsumerState<CatalogCenterPage> createState() => _CatalogCenterPageState();
}

class _CatalogCenterPageState extends ConsumerState<CatalogCenterPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: CatalogCenterPage._tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      ref.read(selectedCatalogCategoryProvider.notifier).state =
          CatalogCenterPage._tabs[_tabController.index];
    });
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _search(ref.read(selectedCatalogCategoryProvider),
          ref.read(catalogSearchQueryProvider));
    });
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      ref.read(catalogSearchProvider.notifier).loadMore();
    }
  }

  void _search(CatalogCategory category, String query) {
    ref.read(catalogSearchProvider.notifier).search(query, category);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CatalogCategory category =
        ref.watch(selectedCatalogCategoryProvider);
    final String query = ref.watch(catalogSearchQueryProvider);

    // 分类切换：立即重新检索。
    ref.listen(selectedCatalogCategoryProvider, (prev, next) {
      if (prev?.key != next.key) _search(next, query);
    });
    // 关键词变化：防抖 400ms 后检索（避免每次按键都打网络）。
    ref.listen(catalogSearchQueryProvider, (prev, next) {
      if (prev == next) return;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400),
          () => _search(category, next));
    });

    final AsyncValue<CatalogSearchState> state =
        ref.watch(catalogSearchProvider);

    return Scaffold(
      backgroundColor: context.gold.bgDark,
      appBar: AppBar(
        backgroundColor: context.gold.bgDark,
        elevation: 0,
        title: Text('全图鉴中心',
            style: TextStyle(
                color: context.gold.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.goldPrimary,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppColors.goldPrimary,
          unselectedLabelColor: context.gold.textInactive,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: CatalogCenterPage._tabs
              .map((CatalogCategory c) => Tab(text: c.label))
              .toList(),
        ),
      ),
      body: Column(
        children: <Widget>[
          _searchBar(context),
          Expanded(
            child: state.when(
              loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.goldPrimary)),
              error: (_, __) =>
                  _state(context, '加载失败，请检查网络', Icons.cloud_off_outlined),
              data: (CatalogSearchState s) {
                if (s.items.isEmpty && !s.isLoading) {
                  return _state(
                    context,
                    s.category.isSports
                        ? '球星卡数据源未配置（需 TCDB API Key）'
                        : '暂无匹配图鉴，换个关键词试试',
                    Icons.auto_awesome_mosaic_outlined,
                  );
                }
                return GridView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: s.items.length + (s.isLoading ? 1 : 0),
                  itemBuilder: (_, int i) {
                    if (i >= s.items.length) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.goldPrimary));
                    }
                    return CatalogCardTile(
                      item: s.items[i],
                      onTap: () => _openDetail(s.items[i]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (String v) =>
              ref.read(catalogSearchQueryProvider.notifier).state = v,
          style: TextStyle(color: context.gold.textWhite, fontSize: 14),
          decoration: InputDecoration(
            hintText: '搜索卡名 / 卡号 / 球员 / 系列',
            hintStyle: TextStyle(color: context.gold.textInactive, fontSize: 13),
            prefixIcon: Icon(Icons.search_outlined,
                size: 18, color: context.gold.textMuted),
            filled: true,
            fillColor: context.gold.bgPure,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.goldBorder, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.goldBorder, width: 0.5),
            ),
          ),
        ),
      );

  void _openDetail(CatalogItem item) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => CatalogDetailSheet(item: item),
      );

  Widget _state(BuildContext context, String text, IconData icon) => Center(
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
