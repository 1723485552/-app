import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:card_management/core/theme/app_colors.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';
import 'package:card_management/core/widgets/gold_snack_bar.dart';
import 'package:card_management/features/card_management/data/models/card_item.dart';
import 'package:card_management/features/card_management/domain/enums/card_category.dart';
import 'package:card_management/features/card_management/domain/repositories/card_repository.dart';
import 'package:card_management/features/card_catalog/domain/models/catalog_item.dart';

/// 全网图鉴探索页：基于 Supabase `master_catalogs` 做实时搜索与一键入盒。
class MasterCatalogView extends ConsumerStatefulWidget {
  const MasterCatalogView({super.key});

  @override
  ConsumerState<MasterCatalogView> createState() => _MasterCatalogViewState();
}

class _MasterCatalogViewState extends ConsumerState<MasterCatalogView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<CatalogItem> _items = <CatalogItem>[];
  bool _loading = false;
  bool _hasMore = true;
  String _query = '';
  int _page = 0;
  Timer? _debounce;

  static const int _pageSize = 18;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _refresh();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _refresh(force: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_loading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _refresh({bool force = false}) async {
    if (!force && _loading) return;
    setState(() {
      _loading = true;
      _page = 0;
      _hasMore = true;
      _items.clear();
      _query = _searchController.text.trim();
    });
    await _fetchPage(reset: true);
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    await _fetchPage(reset: false);
  }

  Future<void> _fetchPage({required bool reset}) async {
    try {
      final SupabaseClient client = Supabase.instance.client;
      final String q = _query;
      final int from = reset ? 0 : _page * _pageSize;
      final int to = from + _pageSize - 1;

      dynamic query = client
          .from('master_catalogs')
          .select('id, name, category, set_name, card_number, image_url, rarity, status')
          .order('updated_at', ascending: false)
          .range(from, to);

      if (q.isNotEmpty) {
        final String like = '%$q%';
        query = query.or('name.ilike.$like,card_number.ilike.$like,set_name.ilike.$like');
      }

      final List<dynamic> rows = await query;
      final List<CatalogItem> next = rows.map<CatalogItem>((dynamic row) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(row as Map);
        return CatalogItem(
          id: (map['id'] ?? '').toString(),
          name: (map['name'] ?? '').toString(),
          category: (map['category'] ?? '').toString(),
          cardSet: (map['set_name'] ?? '').toString(),
          cardNumber: (map['card_number'] ?? '').toString(),
          imageUrl: (map['image_url'] ?? '').toString(),
          rarity: (map['rarity'] ?? '').toString(),
          releaseYear: 0,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        if (reset) {
          _items
            ..clear()
            ..addAll(next);
        } else {
          _items.addAll(next);
        }
        _hasMore = next.length >= _pageSize;
        _page += 1;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      debugPrint('[MasterCatalogView] search failed: $e');
    }
  }

  Future<void> _addToCollection(CatalogItem item) async {
    final CardItem card = _toCardItem(item);
    await ref.read(cardRepositoryProvider).saveCard(card);
    if (!mounted) return;
    GoldSnackBar.show(context, '已加入我的卡盒：${item.name}');
  }

  CardItem _toCardItem(CatalogItem item) {
    CardCategory cat;
    final String category = item.category.toLowerCase();
    switch (category) {
      case 'tcg_pokemon':
      case 'pokemon':
        cat = CardCategory.pokemon;
      case 'tcg_yugioh':
      case 'yugioh':
        cat = CardCategory.yugioh;
      case 'sports_nba':
      case 'sports_soccer':
      case 'sports':
        cat = CardCategory.sportsOther;
      case 'tcg_mtg':
      case 'mtg':
        cat = CardCategory.all;
      default:
        cat = CardCategory.all;
    }
    return CardItem(
      cardName: item.name.isEmpty ? '未命名卡牌' : item.name,
      cardNumber: item.cardNumber.isEmpty ? '—' : item.cardNumber,
      imageUrl: item.imageUrl,
      category: cat,
      buyPrice: 0,
      marketPrice: 0,
      buyDate: DateTime.now(),
      isCollected: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gold.bgDark,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: context.gold.textWhite, fontSize: 14),
              decoration: InputDecoration(
                hintText: '搜索卡名 / 卡号 / 系列',
                hintStyle: TextStyle(color: context.gold.textInactive, fontSize: 13),
                prefixIcon: Icon(Icons.search_outlined, size: 18, color: context.gold.textMuted),
                filled: true,
                fillColor: context.gold.bgPure,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.goldBorder, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.goldBorder, width: 0.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading && _items.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.goldPrimary),
                  )
                : _items.isEmpty
                    ? _emptyState(context)
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _items.length + (_loading ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index >= _items.length) {
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.goldPrimary),
                            );
                          }
                          final CatalogItem item = _items[index];
                          return _CatalogTile(
                            item: item,
                            onAdd: () => _addToCollection(item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.auto_awesome_mosaic_outlined,
                size: 44, color: context.gold.textInactive),
            const SizedBox(height: 12),
            Text('暂无匹配图鉴', style: TextStyle(color: context.gold.textMuted, fontSize: 14)),
          ],
        ),
      );
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({required this.item, required this.onAdd});
  final CatalogItem item;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = item.imageUrl;
    return GestureDetector(
      onTap: () => _openDetailSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: context.gold.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.goldBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: imageUrl.isEmpty
                    ? Container(
                        color: context.gold.bgPure,
                        alignment: Alignment.center,
                        child: Icon(Icons.style_outlined,
                            color: AppColors.goldPrimary.withValues(alpha: 0.8), size: 34),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: context.gold.bgPure,
                          alignment: Alignment.center,
                          child: Icon(Icons.broken_image_outlined,
                              color: AppColors.goldPrimary.withValues(alpha: 0.8), size: 28),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name.isEmpty ? '未命名卡牌' : item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.gold.textWhite, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.cardSet.isEmpty ? '未知系列' : item.cardSet} · ${item.cardNumber.isEmpty ? '—' : item.cardNumber}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.gold.textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('入盒'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.goldPrimary,
                        foregroundColor: context.gold.bgDark,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetailSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: context.gold.bgDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: AppColors.goldBorder, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.goldGlow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 110,
                    height: 154,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.imageUrl.isEmpty
                          ? Container(
                              color: context.gold.bgPure,
                              alignment: Alignment.center,
                              child: Icon(Icons.style_outlined,
                                  color: AppColors.goldPrimary.withValues(alpha: 0.8), size: 32),
                            )
                          : Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              width: 110,
                              height: 154,
                              errorBuilder: (_, __, ___) => Container(
                                color: context.gold.bgPure,
                                alignment: Alignment.center,
                                child: Icon(Icons.broken_image_outlined,
                                    color: AppColors.goldPrimary.withValues(alpha: 0.8), size: 28),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.name.isEmpty ? '未命名卡牌' : item.name,
                          style: TextStyle(color: context.gold.textWhite, fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${item.cardSet.isEmpty ? '未知系列' : item.cardSet} · ${item.cardNumber.isEmpty ? '—' : item.cardNumber}',
                          style: TextStyle(color: context.gold.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.rarity.isEmpty ? '稀有度未知' : item.rarity,
                          style: const TextStyle(
                            color: AppColors.goldPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    onAdd();
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('存入我的卡盒'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: context.gold.bgDark,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
