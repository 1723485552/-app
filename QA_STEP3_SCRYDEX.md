# QA 严格自我验收清单 —— 第三步：接入真实 Scrydex 行情 API & 下架伪造曲线

> 依据 RULES.md §4：「每次完成任务后，必须附带一份 《QA 严格自我验收清单》」。
> 本清单覆盖第三步（2026-08-01）的全部改动：下架伪造行情数据、接通真实 Scrydex API、估值回填与图表空状态。

---

## 一、需求覆盖核对（逐条对应用户指令）

| # | 用户指令要求 | 落地情况 | 状态 |
|---|-------------|---------|------|
| 1 | 彻底下架 `MarketPriceService` 及 `Stub` / 随机种子伪造数据 | 原 Stub + `seedPriceHistoryJson` + `Random` 全部移除；`market_price_service.dart` 仅保留纯契约（`MarketPriceService` 抽象类 + `MarketQuote`），无实现、无种子 | ✅ |
| 2 | 将 `MarketPriceApiService` 与真实 Scrydex API 联动 | 新增 `market_price_api_service.dart` 实现 `MarketPriceService`，请求 Scrydex `/{game}/v1/cards/{id}` 与 `/price_history` | ✅ |
| 3 | 估值框旁「⚡ 自动估值」香槟金按钮发起真实请求并自动回填 | `MarketEstimateField` 香槟金按钮 `Icons.bolt`（矢量，遵守 RULES.md 反 emoji 规则）→ `_estimate()` 调 `fetchQuote` → 回填空 `marketController` | ✅ |
| 4 | 图表优先展示真实行情，无数据则优雅「暂无行情历史」空状态，**严禁伪造随机曲线** | `PriceTrendCard` 历史为空走 `Icons.show_chart_outlined` + 「暂无行情历史」空态；全程无 `Random` 干扰决策 | ✅ |
| 5 | 单文件行数严格 ≤ 250 行 | 见第三节自检，最大 243 行 | ✅ |
| 6 | 静态检查维持 0 Error / 0 Warning / 0 Info | 见第四节自检（沙箱无 Flutter，需在开发机最终确认） | ⏳ 待开发机 |

---

## 二、功能正确性验收

### 2.1 配置层 (`lib/core/config/scrydex_config.dart`, 18 行)
- [x] `scrydexBaseUrl = 'https://api.scrydex.com'` 正确。
- [x] `scrydexApiKey` / `scrydexTeamId` 用 `String.fromEnvironment(..., defaultValue: '')` 编译期注入，未设置时为空串 → 优雅降级。
- [x] `usdToCnyRate` 默认 7.2，附 `TODO(step3)` 标注后续接实时汇率。

### 2.2 契约层 (`lib/features/.../domain/services/market_price_service.dart`, 25 行)
- [x] `MarketQuote` 仅含 `priceCny` / `historyJson`，全 `const` 构造。
- [x] `MarketPriceService` 抽象类两个方法签名稳定：`fetchLatestPrice`、`fetchQuote(..., {CardCategory? category})`。
- [x] 仅 import `CardCategory` 枚举，不反向 import API 实现 → 无循环依赖。
- [x] 头部注释明确声明已替换原 Stub / 随机种子伪造逻辑。

### 2.3 实现层 (`lib/features/.../domain/services/market_price_api_service.dart`, 155 行)
- [x] `implements MarketPriceService`，`marketPriceServiceProvider = Provider((ref) => MarketPriceApiService())` 在此定义并 `export` 契约文件。
- [x] `_gameFor`：`onePiece` → `'onepiece'`，其余（pokemon 等）→ `'pokemon'`。
- [x] `_deriveId`：对 `cardNo` 做清洗得到 Scrydex card id。
- [x] `_resolveCard`：先 `GET /{game}/v1/cards/{id}?include=prices`，失败回退 name 搜索 `?q=name:&pageSize=1&include=prices`。
- [x] `_extractPriceUsd`：从 `prices[].market` 取 USD 市价。
- [x] `_fetchHistory`：`GET /{game}/v1/cards/{id}/price_history?days=30`，兼容 `price`/`market`/`value`/`close` 字段。
- [x] **永不抛异常**：任何失败路径返回 `null`；密钥缺失 → 直接 `return null`（优雅降级，不伪造）。
- [x] USD → CNY 经 `usdToCnyRate` 换算。
- [x] 仅在 `scrydexApiKey` / `scrydexTeamId` 非空时才附加 `X-Api-Key` / `X-Team-ID` 两个 Header。

### 2.4 估值输入组件 (`lib/features/.../presentation/widgets/market_estimate_field.dart`, 148 行)
- [x] `MarketEstimateField extends ConsumerStatefulWidget`，持有 `marketController` / `nameController` / `numberController` / `category` / `onHistoryFetched`。
- [x] 香槟金按钮用矢量 `Icons.bolt`，未用 emoji。
- [x] `onPressed → _estimate()`：`ref.read(marketPriceServiceProvider).fetchQuote(name, number, category:)`。
- [x] 返回 `null` → `GoldSnackBar` 提示「暂未获取到行情，请手动填写估值」，绝不伪造数值。
- [x] 成功 → `marketController.text = quote.priceCny.toStringAsFixed(2)` 并回调 `onHistoryFetched(quote.historyJson)`。

### 2.5 录入页接入 (`lib/features/.../presentation/widgets/manual_add_card_sheet.dart`, 243 行)
- [x] 移除 `market_price_service` 旧 import，改引 `market_estimate_field`。
- [x] 新增状态 `String _priceHistoryJson = ''`；编辑态 init 置为 `c.priceHistoryJson`。
- [x] 原 `_field('当前估值 (¥)', _market, ...)` 替换为 `MarketEstimateField(... onHistoryFetched: (h) => setState(() => _priceHistoryJson = h))`。
- [x] `_submit` 新卡写入 `priceHistoryJson: _priceHistoryJson`（原为 `seedPriceHistoryJson(market)` 伪造）。

### 2.6 走势图 (`lib/features/.../presentation/widgets/price_trend_chart.dart`, 146 行)
- [x] 历史为空 → 优雅空态（矢量图标 + 「暂无行情历史」），不绘制任何曲线。
- [x] 历史非空 → 真实数据 `reduce(math.min/math.max)` 计算轴域（已 `import 'dart:math' as math`，无 analyze 断点）。
- [x] 全程无 `Random` 干扰决策。

---

## 三、单文件行数自检（RULES.md ≤250 硬约束）

| 文件 | 行数 | ≤250 |
|------|------|------|
| `lib/core/config/scrydex_config.dart` | 18 | ✅ |
| `lib/features/.../domain/services/market_price_service.dart` | 25 | ✅ |
| `lib/features/.../domain/services/market_price_api_service.dart` | 155 | ✅ |
| `lib/features/.../presentation/widgets/market_estimate_field.dart` | 148 | ✅ |
| `lib/features/.../presentation/widgets/manual_add_card_sheet.dart` | 243 | ✅ |
| `lib/features/.../presentation/widgets/price_trend_chart.dart` | 146 | ✅ |

> 最大 243 行（manual_add_card_sheet），全部达标。

---

## 四、静态检查自检（沙箱无 Flutter，逐项静态核对）

| 检查项 | 方法 | 结果 |
|--------|------|------|
| 无伪造数据残留 | grep `StubMarketPriceService\|seedPriceHistoryJson\|Random\|Fake\|伪造` | 仅存于 doc 注释，0 处真实引用 |
| 无循环依赖 | grep import 关系 | `api_service → market_price_service`（单向）+ re-export，0 反向 |
| `context.gold` 取色 | grep widget 文件 import | market_estimate_field / price_trend_chart 均 import `context.gold` 来源 |
| 密钥优雅降级 | 读 `scrydex_config.dart` | `String.fromEnvironment` 空默认 + api 层空串判空 `return null` |
| 反 emoji 规则 | 查按钮图标 | 估值按钮用 `Icons.bolt` 矢量图标，未用 emoji 字形 |
| `dart:math` 引用 | grep | price_trend_chart 已 import，避免 `math.min/max` 未定义 |

> ⏳ **最终 0/0/0 须用户在开发机执行 `flutter analyze` 确认**（沙箱无 Flutter/Dart 工具链，已如实说明，未伪造结果）。

---

## 五、集成风险与边界

- **Scrydex 为付费 API（无免费额度）**：密钥经 `String.fromEnvironment` 编译期注入，缺失时应用自动走「手动填写估值 + 暂无行情历史」降级路径，不报错、不伪造。
- **网络异常**：所有请求失败统一 `return null`，UI 仅提示，不崩溃。
- **分类映射**：当前仅 `onePiece`→onepiece、其余→pokemon；若后续接入其他游戏需在 `_gameFor` 扩展。
- **汇率**：`usdToCnyRate` 为静态 7.2，已标 TODO，建议接入实时汇率服务（属后续优化，不在本步范围）。
- **CloudSyncService** 云端同步 Stub 不在本步范围，仍待评估（见 CODE_ANALYSIS_REPORT.md 进度表）。

---

## 六、待开发机闭环（用户侧）

1. `flutter pub get` → `flutter analyze`（目标 0 Error / 0 Warning / 0 Info）并贴回 `No issues found!`。
2. `flutter test` 冒烟（当前仅 1 个默认 widget_test，方案 1 测试补齐仍 pending）。
3. 提供 `git user.name` / `user.email` 以完成首次提交（钉死当前手工补丁状态）。

---

_本清单由 Agent 在沙箱内静态核对生成；涉及 Flutter 编译器的 0/0/0 结论须以开发机 `flutter analyze` 实跑为准。_
