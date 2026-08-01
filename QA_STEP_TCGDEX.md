# QA 严格自我验收清单 · TCGdex 宝可梦卡牌查询接入

> 任务：在 Flutter 项目中接入 TCGdex 宝可梦卡牌 API（数据模型 / 网络服务 / 搜索 UI）。
> 规范依据：`RULES.md` 四大核心工程与设计规则（大厂视觉 / 防偷懒架构 / 静态零容忍 / 强制 Self-QA）。

---

## 1. 【大厂风格】视觉极简、细节丰富

| 验收项 | 落地情况 |
|---|---|
| 黑金主题 token | 全程使用 `context.gold`（bgDark / surfaceDark / textWhite / textMuted / textInactive）+ `AppColors.goldPrimary` / `goldBorder`，零硬编码色值 |
| 0.5px 香槟金微边框 | 卡片瓦片、搜索框 `enabledBorder`/`focusedBorder` 均用 `AppColors.goldBorder`（0.5px） |
| 8dp 网格 | 所有 Padding/Margin 为 8/16/24 倍数（16/8/16、8/8、12 等）；卡片间距 `mainAxisSpacing:16`/`crossAxisSpacing:16` |
| 微交互 | 搜索框聚焦态金色描边切换；结果网格用 `AnimatedSwitcher`（200ms 淡入）平滑过渡；菜单跳转带 `HapticFeedback.lightImpact()` 触觉反馈 |
| 拒绝廉价 Emoji / 默认图标 | 全程使用轻量矢量图标（`Icons.search_outlined` / `Icons.style_outlined` / `Icons.cloud_off_outlined` / `Icons.inventory_2_outlined`），无任何 Emoji |
| 图片高清拼接 | `TcgdexCard.highImage` 自动拼接 `/high.png`（TCGdex 真实图床规则） |

---

## 2. 【架构拆分】新增文件与行数（≤250）

| 文件 | 行数 | 职责 |
|---|---|---|
| `lib/models/tcgdex_card.dart` | 57 | 领域模型 `TcgdexCard`（id/localId/name/image/rarity + `highImage` getter + `fromJson`） |
| `lib/services/tcgdex_service.dart` | 96 | 网络服务 `TcgdexService`（`baseUrl`、10s 超时、`getCardDetail` / `searchCards`，统一 `TcgdexException`） |
| `lib/screens/tcgdex_search_provider.dart` | 67 | Riverpod `StateNotifier` 四态（`Idle/Loading/Loaded/Error`）+ `tcgdexSearchProvider` |
| `lib/screens/tcgdex_card_tile.dart` | 82 | 列表项黑金瓦片（复用 `CardCoverImage`，断网/无图自动降级卡背） |
| `lib/screens/card_search_screen.dart` | 206 | 搜索页（搜索框 + 三态主体 + 2 列网格） |
| `lib/features/card_management/presentation/widgets/profile_menu_list.dart` | 229（+1 入口） | 「我的」页新增 **TCGdex 卡牌查询** 菜单入口 |

- 全部分层清晰：`models`（数据）→ `services`（网络）→ `screens`（UI + Provider），符合 Clean Architecture 与 RULES 第 2 条「拒绝单文件堆砌」。
- **none** 文件超过 250 行。

---

## 3. 【全页联动】搜索真正响应

- 搜索框 `onSubmitted` → `tcgdexSearchProvider.notifier.search(q)` 真实发起网络请求（服务端 `?name=` 模糊匹配，经 `Uri.https` 自动编码）。
- 空查询不发起请求，直接回到 `Idle` 引导态。
- 结果通过 Riverpod `state` 全页响应，UI 三态（`loading` / `error` / `empty` / `loaded`）真实联动，无静态硬编码假列表。
- 重试按钮重发最近一次查询（`_lastQuery`）。

---

## 4. 【静态检查】`dart analyze` 预期

- ⚠️ **沙箱环境无 Flutter 工具链**，无法在本地执行 `dart analyze`；以下为人工静态核查结论，需用户在开发机执行 `flutter analyze` 终验。
- 已核查项（应为 0 Error / 0 Warning / 0 Info）：
  - 无未使用 import（import 列表与引用一致）。
  - 无 `unnecessary_const`（全部 `const` 为构造器优化用，无冗余顶层 const 变量）。
  - `switch` 表达式改用解构 pattern（`TcgdexLoaded(:final cards)` / `TcgdexError(:final message)`），类型安全、无提升告警。
  - `sealed class TcgdexSearchState` 四态被 `switch` 完整覆盖（exhaustive，无缺失分支告警）。
  - 括号/大括号/方括号平衡校验通过（脚本扫描均为 0）。
  - 无弃用 API；`http` 已在 `pubspec.yaml` 依赖中，无需新增依赖。

---

## 5. 真机验证路径（用户侧）

```bash
cd /c/card_management
flutter run -d V2458A
```

进入 App → 「我的」→ **TCGdex 卡牌查询** → 输入 `Pikachu` / `Charizard` 回车，应看到 2 列黑金卡牌网格（高清卡图）。设备网络已在上一轮排查中验证可直连 `api.tcgdex.net`（Google 被墙属正常）。

---

## 6. 已知边界（诚实披露）

- `getCardDetail(String id)` 已实现并经 provider `fetchDetail` 暴露，但本次搜索页卡片项点击暂为占位（`onTap: () {}`）；如需详情大图页可后续追加 `CardDetailScreen`。
- 列表摘要部分条目 `rarity` 缺失，UI 已做非空判断降级（不显示稀有度行）。
- TCGdex 无免费密钥限制，`INTERNET` 权限已就位，无需 `--dart-define`。

---

## 7. 价格解析与展示（追加任务）

- **模型** `TcgdexCard` 新增 `tcgplayerUsd`（USD，取自 `pricing.tcgplayer.{holofoil|normal}.marketPrice`）与 `cardmarketEur`（EUR，取自 `pricing.cardmarket.avg`），并由 `priceLabel` getter 统一输出 `$12.50` / `€10.00`，皆无则 null。
- **关键事实**：TCGdex 列表搜索 API（`/cards?name=`）摘要**不含 `pricing`**，仅详情 `cards/{id}` 返回完整价格。故在 `searchCards` 中**并发补全前 12 张详情**填充价格（性能护栏 `priceFetchLimit=12`），超出部分保持「暂无报价」。
- **UI** `tcgdex_card_tile.dart` 底部新增 `_priceRow`：有价显示金色粗体高亮标签，无价显示灰色「暂无报价」，符合 8dp 网格与黑金 token。
- 行数：`tcgdex_card.dart` 116 / `tcgdex_service.dart` 121 / `tcgdex_card_tile.dart` 99，均 ≤250。
- 沙箱无 Flutter 工具链，静态检查需用户在开发机 `flutter analyze` 终验。
