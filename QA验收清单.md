# QA 严格自我验收清单 — 架构级全量升级

> 项目: `C:\kapai\card_management\` | Flutter 3.44.4 / Dart 3.12.2 / Isar 3.1.0+1 / Riverpod 2.6.1
> 验收时间: 2026-07-30

---

## 一、全局硬规则

| # | 规则 | 状态 | 证据 |
|---|------|------|------|
| 1 | 单文件 ≤250 行 (生成代码除外) | ✅ 通过 | 最大手写文件 card_detail_lightbox.dart = 232 行; 仅 Isar 生成 `*.g.dart` 超 250 (2652行, 不受约束) |
| 2 | `flutter analyze` = 0 Error / 0 Warning / 0 Info | ✅ 通过 | `No issues found! (ran in 15.0s)` |
| 3 | 保持 Isar 数据结构不破坏 | ✅ 通过 | build_runner 重新生成 schema, `.g.dart` 含 32 处 priceHistoryJson 引用 |
| 4 | 新增字段加默认值 + Null Guard | ✅ 通过 | `priceHistoryJson` 默认 `''`, 解析时 try-catch 返回空列表 |

## 二、四条强制修改规则

| # | 规则 | 状态 | 证据 |
|---|------|------|------|
| 1 | 新增/修改字段添加默认值和空安全保护 | ✅ | `priceHistoryJson = ''` (native+web); `parsePriceHistory` 空串/非法返回 `[]` |
| 2 | 修改数据结构后清理缓存冷启动 | ✅ | `flutter pub run build_runner build --delete-conflicting-outputs` + `flutter pub get` |
| 3 | 检查所有使用该模型的地方已适配 | ✅ | profile_export.dart 备份 JSON 增/读 priceHistoryJson; 编辑器创建分支播种历史; lightbox 渲染走势 |
| 4 | 每次修改完运行 flutter analyze 并修复至 0 | ✅ | 每阶段末均验证 0/0/0, 最终再次确认 |

---

## 三、阶段一: 工程架构解耦与公共 UI 提取

| 交付物 | 行数 | 规格上限 | 状态 |
|--------|------|----------|------|
| `core/utils/currency_formatter.dart` | 41 | ≤100 | ✅ CurrencyFormatter.format + formatCny + 千分位 + 货币符号切换 |
| `core/widgets/gold_stat_tile.dart` | 50 | ≤120 | ✅ 统一指标卡 (黑金边框) |
| `core/widgets/empty_state_placeholder.dart` | 80 | ≤100 | ✅ 统一空态占位 + 操作按钮 |
| `core/widgets/gold_snack_bar.dart` | 40 | ≤90 | ✅ GoldSnackBar.show + 撤销按钮 |
| `domain/repositories/card_repository.dart` | 29 | — | ✅ 抽象接口 (CRUD/查询/watch stream) |
| `card_repository_provider.dart` | 10 | — | ✅ 条件导入 + cardRepositoryProvider |
| `card_repository_impl_native.dart` | 46 | — | ✅ Isar 实现 (StreamController 替代 watch) |
| `card_repository_impl_web.dart` | 47 | — | ✅ 内存实现 (StreamController 广播) |

- ✅ 消除 4 处重复 UI 代码 (asset_banner / card_detail_lightbox / card_share_poster / card_tile 的指标卡)
- ✅ 统一货币工具 (合并 `_formatYuan` + `money_format.dart`)
- ✅ 删除 `presentation/helpers/money_format.dart`
- ✅ 所有 UI 不再直接 new datasource, 经 cardRepositoryProvider 注入

## 四、阶段二: 卡牌编辑与安全撤销机制

| 交付物 | 行数 | 状态 |
|--------|------|------|
| `manual_add_card_sheet.dart` (编辑模式) | 228 | ✅ 可选 initialCard 预填 + updateCard |
| `card_detail_lightbox.dart` (编辑按钮+安全删除) | 232 | ✅ 编辑按钮重开预填表单; 删除=临时存储+3s撤销 |
| `card_tile.dart` (回调接线) | 205 | ✅ onEdit/onDeleted 用列表层存活 context |

- ✅ 编辑: lightbox 编辑按钮 → 重开预填 sheet → updateCard → 刷新
- ✅ 安全撤销: 删除 → GoldSnackBar("卡牌已删除", actionLabel:"撤销") → 3s 未撤销则真删
- ✅ 撤销路由经回调到 card_tile (lightbox pop 后 context 失效)

## 五、阶段三: 行情接口抽象与价格走势图

| 交付物 | 行数 | 规格上限 | 状态 |
|--------|------|----------|------|
| `domain/services/market_price_service.dart` | 46 | — | ✅ MarketPriceService 抽象 + buildSeedHistory stub |
| `presentation/widgets/price_trend_chart.dart` | 131 | ≤180 | ✅ CustomPainter 黑金折线图 + PriceTrendCard 封装 |
| `card_item_native.dart` (新增字段) | — | — | ✅ priceHistoryJson 默认 '' + copyWith |
| `card_item_web.dart` (新增字段) | — | — | ✅ priceHistoryJson 默认 '' + copyWith |
| `card_item_native.g.dart` (重新生成) | 2652 | 生成代码 | ✅ 含 32 处 priceHistoryJson |

- ✅ 行情接口抽象 (fetchLatestPrice stub, 预留接入)
- ✅ 价格走势图嵌入 lightbox (近30日, 涨跌色 + 百分比)
- ✅ 新建卡牌自动播种历史数据 (buildSeedHistory)

## 六、阶段四: 首页"黑金展柜"与 Hero 动效

| 交付物 | 行数 | 规格上限 | 状态 |
|--------|------|----------|------|
| `card_showcase_widget.dart` | 157 | ≤200 | ✅ 横向 Top-3 展柜 + 香槟金发光边框 |
| `dashboard_page.dart` (接入) | 99 | — | ✅ AssetBanner 下方插入 CardShowcaseWidget |

- ✅ 展柜用 GoldStatTile + 香槟金 glow border
- ✅ Hero tag 统一: card_tile + lightbox 均用 `card_img_${card.id}`
- ✅ 展柜用独立 tag `showcase_img_` 避免与网格冲突

## 七、阶段五: 静默本地自动备份与云端接口预留

| 交付物 | 行数 | 规格上限 | 状态 |
|--------|------|----------|------|
| `backup/services/auto_backup_service.dart` | 94 | ≤160 | ✅ 24h 静默备份 + 7天滚动 |
| `backup/services/cloud_sync_service.dart` | 34 | ≤120 | ✅ 抽象 syncToCloud/restoreFromCloud 预留 |
| `main.dart` (触发) | 106 | — | ✅ initState unawaited 触发 maybeRun |
| `pubspec.yaml` | — | — | ✅ 新增 shared_preferences ^2.3.2 |

- ✅ 备份到 app 私有目录, 保留最近 7 天, 超期自动清理
- ✅ 云端接口抽象预留 Supabase 2.0
- ✅ 首次启动不备份 (等待 24h), 后台静默执行

---

## 八、最终验证

```
$ flutter analyze
Analyzing card_management...
No issues found! (ran in 15.0s)
```

- ✅ 0 Error / 0 Warning / 0 Info
- ✅ 所有 13 个新增文件存在且 ≤250 行
- ✅ 所有修改文件 ≤250 行
- ✅ Isar schema 已重新生成 (priceHistoryJson 已入 schema)
- ✅ 旧 money_format.dart 已删除
- ✅ shared_preferences 依赖已添加

---

## 验收结论

**全部 5 阶段交付完成,QA 验收通过。**
