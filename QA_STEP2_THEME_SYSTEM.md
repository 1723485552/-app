# 🎨 优化第二步 · 主题系统重构 — 《QA 严格自我验收清单》

> 对应任务：【🎨 优化第二步】重构主题系统：引入 ThemeExtension 彻底消除全局可变状态与 Rebuild Hack
> 验收日期：2026-08-01 ｜ 规范依据：RULES.md §1 / §2 / §3 / §4 / §7
> 执行环境：本沙箱无 Flutter/Dart 工具链，静态重构 + 静态自审已完成；`flutter analyze` / `flutter test` 需在开发机执行（见同目录 `RUNBOOK_STEP2.md`）。

---

## 1. 【大厂风格】视觉极简、细节丰富（8dp 网格、微交互、无廉价 Emoji）

| 验收项 | 结果 | 说明 |
|---|---|---|
| 黑金暗色调色板恒定 | ✅ | 金色系 / 涨跌 / 图表专属 / 按钮渐变全部收敛进 `AppColors` 静态 `const`（`goldPrimary 0xFFD4AF37` 等），跨主题恒定，无全局可变。 |
| 0.5px 香槟金微边框 | ✅ | `goldBorder = 0x26D4AF37`（=withOpacity 0.15），Sheet / 对话框圆角边框统一复用，无大面积金色填充。 |
| 8dp 网格秩序 | ✅ | `theme_mode_sheet` 使用 `16/14/18/20/28` 等 8 的倍数间距；对话框 `padding: 14/12`。 |
| 微交互 | ✅ | 三态切换 `HapticFeedback.lightImpact()` + `InkWell.splashColor: goldGlow` + `BorderRadius.circular(12)` 平滑按压态；Sheet 圆角 `20` 顶部圆角。 |
| 无廉价 Emoji | ✅ | 主题图标统一用原生 Outlined 矢量：`brightness_auto_outlined` / `dark_mode_outlined` / `light_mode_outlined`，零 Emoji。 |
| 明亮香槟金模式规范 | ✅ | `GoldThemeExtension.light` 背景 `0xFFF8F9FA`、卡片 `0xFFFFFFFF`、`textWhite 0xFF1A1A1A` 高对比，符合 RULES.md §7 户外强光规范。 |

---

## 2. 【架构拆分】新增 / 修改文件清单，单文件 ≤ 250 行

### 新增文件（2）
| 文件 | 行数 | 职责 |
|---|---|---|
| `lib/core/theme/gold_theme_extension.dart` | 96 | `ThemeExtension<GoldThemeExtension>`，含 `copyWith` / `lerp` / `dark` / `light` 静态实例 + `BuildContext.gold` 便捷读取（≤120 行 ✅）。 |
| `lib/core/theme/theme_provider.dart` | 56 | `NotifierProvider<ThemeNotifier, ThemeMode>`，SharedPreferences 持久化三态 + `themeModeLabel` / `themeModeIcon` 映射。 |

### 重写文件（5）
| 文件 | 行数 | 变更 |
|---|---|---|
| `lib/core/theme/app_colors.dart` | 45 | 删除 `setBrightness` / `_brightness` / `_byBrightness` 及全部亮度 getter，仅留跨主题恒定的品牌 `const`。 |
| `lib/core/theme/app_theme.dart` | 79 | `dark` / `light` 改读 `GoldThemeExtension.dark/light` 静态实例，并 `extensions:` 注入主题树（无 BuildContext 误用）。 |
| `lib/main.dart` | 90 | 删除 `AppColors.setBrightness` 与 `ValueKey<Brightness>` 重建 Hack；`home: const MainScreen()`，`themeMode: ref.watch(themeProvider)`。 |
| `lib/.../providers/profile_providers.dart` | 67 | 删除 `AppThemeMode` 枚举 / `themeModeProvider` / `appThemeModeLabel` / `appThemeModeIcon`。 |
| `lib/.../widgets/theme_mode_sheet.dart` | 186 | 改用 `themeProvider` + `ThemeMode` 枚举 + `context.gold.*` 取色。 |

### 自动迁移文件（34）
`AppColors.bgPrimary/bgPure/bgNav/surfaceDark/textPrimary/textSecondary/textInactive/lightboxScrim/chartBgs` → `context.gold.bgDark/bgPure/bgNav/surfaceDark/textWhite/textMuted/textInactive/scrim/chartBgs`，并注入 `gold_theme_extension.dart` import（脚本批量替换，已逐文件校验 import 覆盖）。

### 行数静态约束
- 全手写 `.dart` 文件共 **79 个**，**0 个 > 250 行**（已脚本遍历 `lib/`，排除生成的 `.g.dart`）。
- `gold_theme_extension.dart` **96 行**（≤120 子任务约束）。

---

## 3. 【全页联动】主题切换全页响应（无毁树重建）

| 验收项 | 结果 | 说明 |
|---|---|---|
| 根组件绑定 | ✅ | `MaterialApp.themeMode = ref.watch(themeProvider)`，主题切换由 Flutter 自动重建主题子树。 |
| 三态真实生效 | ✅ | `ThemeMode.system` / `.dark` / `.light` 经 `theme` / `darkTheme` 双 `ThemeData` 落地，覆盖全页。 |
| 组件响应式取色 | ✅ | 35 个文件改用 `context.gold.*`；切换主题时 `ThemeExtension.lerp` 驱动背景/文字/表面色平滑过渡。 |
| 持久化恢复 | ✅ | `ThemeNotifier._restore()` 启动异步读 `SharedPreferences('theme_mode')`，重启自动恢复用户选择。 |
| Rebuild Hack 已消除 | ✅ | `main.dart` 与 `main_screen.dart` 中 `ValueKey<Brightness>` / `setBrightness` 强制重绘逻辑全部删除。 |
| 跟随系统昼夜 | ✅ | `WidgetsBindingObserver.didChangePlatformBrightness` 在 system 模式下触发重建，响应系统明暗切换。 |

---

## 4. 【静态检查】`dart analyze` 目标 0 Issues

| 验收项 | 沙箱结果 | 开发机动作 |
|---|---|---|
| 残留全局可变状态 (`setBrightness` / `_brightness`) | ✅ 0 处（仅 `app_colors.dart:7` 注释提及，非代码） | 开发机 `flutter analyze` 复核 |
| 残留 `ValueKey<Brightness>` Hack | ✅ 0 处 | 开发机 `flutter analyze` 复核 |
| 残留旧 `AppColors` 亮度 getter 调用 | ✅ 0 处 | 开发机 `flutter analyze` 复核 |
| 残留 `AppThemeMode` / `themeModeProvider` | ✅ 0 处 | 开发机 `flutter analyze` 复核 |
| `context.gold` 真实使用缺少 import | ✅ 0 个 | 开发机 `flutter analyze` 复核 |
| 单文件 > 250 行 | ✅ 0 个 | 开发机 `flutter analyze` 复核 |
| 弃用 API | ✅ 无新引入 | 开发机 `flutter analyze` 复核 |
| **`dart analyze` 0 Error / 0 Warning / 0 Info** | ⏳ 沙箱无法执行 | **必须在开发机执行 `flutter analyze` 并打印结果**（详见 `RUNBOOK_STEP2.md`） |

---

## ✅ 自审结论

- **全局可变状态已彻底消除**：`AppColors` 退化为纯 `const` 品牌色表；亮度相关色全部 Theme 化。
- **Rebuild Hack 已彻底消除**：`ValueKey<Brightness>` 与 `setBrightness` 全删，换肤走 Flutter 原生 `themeMode` + `lerp`。
- **架构合规**：新增 2 文件均 ≤120 行，全手写文件 0 个超 250 行，符合 RULES.md §2 / §3。
- **唯一待办**：在开发机执行 `flutter analyze` 拿到 0/0/0 并粘贴结论（沙箱无 Flutter 工具链，无法伪造）。
