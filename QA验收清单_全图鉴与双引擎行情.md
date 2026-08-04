# 🧪 QA 严格自我验收清单 —— 全图鉴 & 国内外成交价双引擎系统

> 模块：`lib/features/card_catalog`（全品类图鉴）、`lib/features/market_price`（国内外成交价）
> 规范依据：`RULES.md`（大厂黑金 / 架构拆分 ≤250 行 / 0 Error·Warning·Info / 全页联动 / 空状态不塌陷）

## ①【大厂风格】视觉极简、细节丰富
- ✅ 纯黑/深灰底（`context.gold.bgDark`）+ 香槟金微量点缀（`AppColors.goldPrimary` 仅用于选中态、边框、均价高亮），无大面积填充、无廉价 Emoji。
- ✅ 8dp 网格：所有 Padding/Margin 严格 8/12/16 倍数。
- ✅ 微交互：分类 Tab 选中态金色过渡、成交 Tab 分段按钮、空/加载/错误三态均有优雅黑金矢量提示（无布局塌陷）。
- ✅ 图标全部采用 Flutter 原生 Lightweight 矢量（`Icons.auto_awesome_mosaic_outlined` / `Icons.show_chart_outlined` / `Icons.storefront_outlined` 等），无默认 Emoji。

## ②【架构拆分】新增文件 & 行数（≤250）
| 文件 | 行数 | 说明 |
|---|---|---|
| card_catalog/domain/models/catalog_item.dart | ~110 | 统一图鉴模型（toJson/fromJson + Null Guard） |
| card_catalog/domain/enums/catalog_category.dart | ~25 | 品类枚举（独立于收藏库 CardCategory） |
| card_catalog/data/config/catalog_config.dart | ~18 | 运行配置 |
| card_catalog/domain/repositories/i_catalog_adapter.dart | ~22 | 适配器接口 |
| card_catalog/data/adapters/tcg_catalog_adapter.dart | ~124 | TCG（宝可梦/游戏王/万智牌） |
| card_catalog/data/adapters/sports_catalog_adapter.dart | ~88 | 球星卡（NBA/足球） |
| card_catalog/domain/services/catalog_service.dart | ~22 | 双适配器路由 |
| card_catalog/presentation/providers/catalog_providers.dart | ~36 | 检索/分类/关键词 Provider |
| card_catalog/presentation/widgets/catalog_card_tile.dart | ~95 | 网格单元 |
| card_catalog/presentation/widgets/catalog_detail_sheet.dart | ~167 | 详情浮层 + 一键加入收藏 |
| card_catalog/presentation/pages/catalog_center_page.dart | ~182 | 全图鉴中心 |
| market_price/domain/models/price_comp_item.dart | ~40 | 成交记录模型 |
| market_price/data/config/market_config.dart | ~12 | 运行配置 |
| market_price/domain/repositories/i_price_adapter.dart | ~16 | 价格适配器接口 |
| market_price/data/adapters/domestic_price_adapter.dart | ~54 | 国内（集换社/闲鱼） |
| market_price/data/adapters/foreign_price_adapter.dart | ~55 | 国外（eBay/130point/TCGplayer） |
| market_price/domain/services/currency_service.dart | ~30 | USD→CNY 汇率换算 |
| market_price/domain/services/price_service.dart | ~28 | 双引擎聚合 |
| market_price/presentation/providers/price_providers.dart | ~46 | 行情 Provider |
| market_price/presentation/widgets/price_trend_chart_card.dart | ~118 | fl_chart 走势图 |
| market_price/presentation/widgets/price_sales_list.dart | ~96 | 成交明细行（独立拆分以控行数） |
| market_price/presentation/widgets/market_price_widget.dart | ~184 | 国内外 Tab + 列表 + 跳转 |
| market_price/presentation/pages/market_price_page.dart | ~48 | 行情全屏页 |

> 全部 ≤250 行；**未触碰既有 Isar 模型 / CRUD / Supabase 备份服务**（红线达成）。

## ③【全页联动】搜索 / 分类真正联动
- ✅ 图鉴：顶部分类 Tab（宝可梦/游戏王/万智牌/球星卡）经 `selectedCatalogCategoryProvider` 驱动；搜索框经 `catalogSearchQueryProvider` 实时过滤卡名/卡号/球员/系列；结果由 `catalogResultsProvider((category, query))` 双键联动。
- ✅ 行情：国内外 Tab（`selectedMarketTabProvider`）+ 30/90 天区间（`selectedPriceRangeProvider`）驱动 `priceSalesProvider((cardName, cardNo))`，走势图与明细列表同源刷新。
- ✅ 一键加入收藏：经既有 `cardRepositoryProvider.saveCard` 写入本地库，与收藏页真实联动。

## ④【静态检查】`flutter analyze`
- ✅ **No issues found! (0 Error / 0 Warning / 0 Info)**（已用 `dart fix --apply` 清除 prefer_const / unused_import）。

## ⚠️ 重要透明披露：示例数据策略
- 本环境**未提供任何外部 API Key / 网络凭证**，真实数据源（PokémonTCG.io / Scryfall / YGOProDeck / 集换社 / eBay / 130point / TCGplayer）无法实拉。
- 采用与 RULES「拒绝假数据当真数据」一致的策略：默认 `useSampleData = true`，经**与真实路径完全相同的适配器接口 / Provider 管线下发**结构化示例样本，且 UI 全程展示「示例数据」角标，**绝不伪装为真实行情**。
- 真实接入：将 `catalog_config.dart` / `market_config.dart` 的 `useSampleData` 置为 `false` 并为各适配器配置对应 Key / 抓取服务（端点已在各适配器注释中标注），真实请求路径即生效（无 Key / 网络异常时返回空列表并呈现空状态）。
- 改动范围：仅在 `pubspec.yaml` 追加 `url_launcher: ^6.3.0`（成交原文跳转），未改任何既有依赖版本。
