# 📋 QA 严格自我验收清单 · 第二步收尾（精准修复 14 处 flutter analyze 诊断）

> 任务来源：根据 `flutter analyze` 抛出的 14 处问题日志，逐项精准修补，目标 0 Error / 0 Warning / 0 Info。
> 复盘口径对齐 RULES.md §4 四大维度。本沙箱无 Flutter 工具链，以下为**静态自审**结果；最终 0/0/0 须由用户在开发机执行 `flutter analyze` 确认（见末尾 Runbook 指引）。

---

## ✅ 1. 【大厂风格】视觉与代码风格一致性
- 重构仅修正「取色来源」与「编译期错误」，**未触碰任何视觉参数**（8dp 网格、0.5px 金边、Outlined 矢量图标、微交互均保持黑金高奢调性）。
- 主题响应式取色统一收敛至 `context.gold`（ThemeExtension），与第二步整体设计语言一致；BGS 饼图色改为随主题切换（`context.gold.chartBgs`），强化三态一致性。
- 无新增默认 Emoji、无粗笨图标，符合 §1 反 AI 化约束。

## ✅ 2. 【架构拆分】本次新增/修改文件与行数
共修改 **9 个文件**，全部 `≤ 250` 行（脚本逐文件核验，附行数）：

| 文件 | 行数 | 本次改动 |
|---|---:|---|
| `lib/main.dart` | 90 | 修正 `theme_provider` 导入路径 → `core/theme/theme_provider.dart` |
| `lib/core/theme/app_theme.dart` | 79 | `extensions` 列表字面量补 `const`（L26/L60） |
| `lib/core/widgets/gold_stat_tile.dart` | 49 | 删除未使用的 `app_colors.dart` 导入 |
| `lib/features/.../pages/profile_page.dart` | 42 | 删除未使用的 `app_colors.dart` 导入 |
| `lib/core/widgets/gold_snack_bar.dart` | 57 | `_build` 补 `BuildContext context` 参数，自 `messenger.context` 透传 |
| `lib/features/.../pages/card_collection_page.dart` | 93 | `_emptyState` 补 `BuildContext context` 参数并透传 |
| `lib/features/.../widgets/card_search_filter_bar.dart` | 123 | `_gradeChip` 补 `BuildContext context` 参数并透传 |
| `lib/features/.../widgets/collection_tab_bar.dart` | 89 | `_tabButton` 补 `BuildContext context` 参数并透传 |
| `lib/features/.../widgets/grade_pie_chart.dart` | 248 | 模块级 `_gradingColor` map → `_gradingColors(BuildContext)` 函数，调用点透传 `context` |

## ✅ 3. 【全页联动】主题/数据响应式
- 5 处 `context.gold` 取色从「无作用域的静态方法/模块变量」改为经 `BuildContext` 解析，主题切换仍由 `MaterialApp.themeMode` 驱动、全页即时联动（含 SnackBar、攒卡页空态、搜索筛选 Chip、Tab 分段、饼图配色）。
- 无假逻辑/硬编码，未破坏既有 Riverpod 绑定。

## ✅ 4. 【静态检查】逐项命中 14 处诊断并修复
定位与修复明细（按用户四类指令归类）：

**🎯 1. 路径与变量定义（1 处）**
- `main.dart:10` 导入 URI 由 `features/card_management/presentation/providers/theme_provider.dart` 修正为 `core/theme/theme_provider.dart`（与第二步实际文件位置一致），`themeProvider` 正常解析。

**🎯 2. undefined_identifier 'context'（5 文件 / 多命中）**
- `gold_snack_bar.dart`：`_build` 静态方法无 `context` → 新增参数，由 `showOn` 经 `messenger.context` 传入。
- `card_collection_page.dart`：`_emptyState` 实例方法无 `context` → 新增参数，由 `build` 调用处传入。
- `card_search_filter_bar.dart`：`_gradeChip` 无 `context` → 新增参数并透传。
- `collection_tab_bar.dart`：`_tabButton` 无 `context` → 新增参数并透传。
- `grade_pie_chart.dart`：模块级 map `_gradingColor` 含 `context.gold` → 重构为 `_gradingColors(BuildContext)` 函数，两处调用点（`L188/L219`）补 `context`。

**🎯 3. 清理 Unused Imports & 补全 Const（4 处）**
- 删除 `gold_stat_tile.dart` 未使用的 `app_colors.dart` 导入。
- 删除 `profile_page.dart` 未使用的 `app_colors.dart` 导入。
- `app_theme.dart` L26/L60 `extensions` 列表字面量补 `const`（消除 prefer_const 告警）。

**⚙️ 4. 静态检查复核（脚本自动全盘扫描）**
- 全盘 79 个手写 `.dart` 文件：**0 个 > 250 行**（grade_pie_chart 经压缩由 252 → 248，回归达标）。
- 残留 `AppColors` 亮度 getter（`bgPrimary/bgPure/bgNav/surfaceDark/textPrimary/textSecondary/textInactive/lightboxScrim/chartBgs`）：**0 处**。
- 残留旧名 `_gradingColor`：**0 处**（已统一为 `_gradingColors`）。
- `context.gold` 出现在「无 BuildContext 参数的 static 方法」内：**0 处**（5 处已全部补参/改为函数）。
- 临时自审脚本 `audit_step2_fixes.py` 已清理，不污染工程。

---

## 🚦 待用户在开发机终验
1. 重开终端（Flutter 3.22–3.27）→ `cd C:\card_management`
2. `flutter pub get`
3. `flutter analyze` → 期望 `No issues found!`（0/0/0）
4. 将输出贴回对话，第二步即**正式收口**。

> 注：本清单记录的是「静态自审通过」；`flutter analyze` 真机结果以用户执行输出为准，未伪造。
