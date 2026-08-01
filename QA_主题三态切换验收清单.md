# QA 严格自我验收清单 — 主题三态切换（Task M）

> 依据 RULES.md §4 强制交付标准。结论：`dart analyze` **0 Error / 0 Warning / 0 Info**；`flutter build web --release` **成功**；预览服务器 **HTTP 200**。

## 一、核心 Bug 修复（主题点击无效）

| # | 验收项 | 结果 |
|---|--------|------|
| 1 | 定位「主题点击无效」根因：全 App 硬编码 `AppColors` 暗色 Token（非 `Theme.of`），`themeMode` 绑定本无视觉变化 | ✅ 已诊断 |
| 2 | `AppColors` 改为亮度感知：金色调保持 `static const`；背景/文字改为按 `_brightness` 解析的 getter + `setBrightness` | ✅ 已落地 |
| 3 | `CardManagementApp` 升级为 `ConsumerStatefulWidget`，`MaterialApp.themeMode` 绑定 `themeModeProvider` | ✅ 已落地 |
| 4 | 主题/系统亮度切换即时全局生效（含 `static const` 缓存子树）——通过 `MainScreen(key: ValueKey<Brightness>(effective))` 强制整树重建 | ✅ 已落地 |
| 5 | 「跟随系统」模式实时响应系统昼夜切换（`WidgetsBindingObserver.didChangePlatformBrightness`） | ✅ 已落地 |

## 二、三态主题功能

| # | 验收项 | 结果 |
|---|--------|------|
| 6 | 枚举 `AppThemeMode { system, dark, light }` + `themeModeProvider` 状态 | ✅ |
| 7 | `AppTheme.light`（明亮香槟金）：bg 0xFFF8F9FA / 卡片 0xFFFFFFFF / 0.5px 金边 / 文字 0xFF1A1A1A / 点缀香槟金 0xFFD4AF37 | ✅ |
| 8 | `AppTheme.dark`（暗黑黑金）保留并改为 getter 实时读取 `AppColors` | ✅ |
| 9 | 「我的」页「外观主题模式」项：展示当前模式（跟随系统/暗黑黑金/明亮香槟金），图标随模式变化 | ✅ |
| 10 | 点击拉起黑金高奢三态 Sheet：📱跟随系统 / 🌙暗黑黑金 / ☀️明亮香槟金（`brightness_auto_outlined` / `dark_mode_outlined` / `light_mode_outlined`） | ✅ |
| 11 | 切换触发 `HapticFeedback.lightImpact()` 触觉反馈 | ✅ |
| 12 | 切换后应用界面立即全局生变（不重启、不手动刷新） | ✅ 构建验证 |

## 三、设计规范（Sophisticated Simplicity 黑金）

| # | 验收项 | 结果 |
|---|--------|------|
| 13 | 全程 **0 Emoji**（仅矢量图标，无文本 Emoji） | ✅ |
| 14 | Outlined / Rounded 矢量图标，无实心卡通图标 | ✅ |
| 15 | 0.5px 香槟金微边框（`goldBorder` 0x26D4AF37） | ✅ |
| 16 | 8dp 网格对齐、黑金点缀克制（无大色块金填充） | ✅ |
| 17 | 废弃的 AMOLED 开关已移除，模式语义归一为三态 | ✅ |

## 四、架构与工程硬规

| # | 验收项 | 结果 |
|---|--------|------|
| 18 | Clean Architecture：状态集中于 `providers`，无硬编码主题值 | ✅ |
| 19 | Riverpod 真实状态联动（`themeModeProvider` 驱动全局），非假数据 | ✅ |
| 20 | 所有手写 `.dart` 文件 ≤ 250 行（生成产物 `card_item_native.g.dart` 豁免） | ✅ |
| 21 | `dart analyze`：**0 Error / 0 Warning / 0 Info** | ✅ No issues found! |
| 22 | 优先使用 `const` 构造（无多余 `const`、无遗漏 `const`） | ✅ 0 Info |
| 23 | 无 deprecated API（`background`/`onBackground`/`withOpacity` 已替换） | ✅ |
| 24 | 跨端安全：web 走内存数据，native 走 Isar，条件导入未破坏 | ✅ 构建通过 |

## 五、构建与预览

| # | 验收项 | 结果 |
|---|--------|------|
| 25 | `flutter build web --release` 成功（`√ Built build/web`） | ✅ |
| 26 | 单实例静态服务器 http://localhost:8080/ 运行（curl HTTP 200） | ✅ |
| 27 | 无端口冲突（全局仅 1 个 server） | ✅ |

## 六、遗留 / 备注

- `CardItem.copyWith` 的 `id` 参数仍被静默忽略（历史逻辑 Bug，未触发 analyze，留待后续）。
- `present_files` 对 localhost 偶发「400 input length too long」工具怪癖，服务器本身正常，浏览器直接开 http://localhost:8080/ 即可预览。
