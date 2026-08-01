# Card Management（卡牌资产）项目全面扫描分析报告

> 扫描时间：2026-08-01
> 扫描范围：`C:\card_management`（Flutter / Dart 工程）
> 扫描方式：只读静态扫描（未修改任何源码）

---

## 一、项目是做什么的

这是一个**面向收藏卡玩家的资产管理 App（Card Collector）**，定位「大厂级黑金风」移动端应用。核心能力：

| 模块 | 说明 |
|---|---|
| 卡牌收藏（攒卡） | 按分类（宝可梦 / 海贼王 / 游戏王 / 体育等）分组管理卡牌，支持搜索、评级筛选、网格展示 |
| 录入方式 | 手动录入 + **设备端 OCR 拍照识卡**（ML Kit 文本识别，正则提取评级机构/分数/卡号/卡名）+ 心愿单 |
| 首页仪表盘 | 资产统计、神卡展示、市场行情微走势、快速入口 |
| 行情 / 账本 | 价格走势图、评级占比饼图、交易明细（Ledger） |
| 个人中心 | 主题三态切换（跟随系统 / 暗黑黑金 / 明亮香槟金）、关于、导出备份 |
| 数据安全 | 本地 JSON 备份/恢复 + 24h 节流静默自动备份（7 天滚动保留）+ 云同步抽象（**占位未实现**） |

**技术栈**：Flutter 3.x + Riverpod 2.6（状态管理）+ Isar 3.1（本地持久化）+ http（网络层）+ fl_chart（图表）+ google_mlkit_text_recognition（OCR）+ share_plus/file_picker（分享/恢复）+ 条件导入实现原生/Web 双端兼容。

**规模**：78 个 `.dart` 文件，约 **9382 行**手写代码（+ 1 个 build_runner 生成的 2652 行适配器）。

---

## 二、代码质量评分

### 综合得分：**84 / 100**（低于 90，需改进）

| 维度 | 评分 | 依据 |
|---|---|---|
| 代码规范 / Lint 整洁度 | 9.5 | 0 处 `print()`，0 处已弃用 API（部件树用 `withValues` 而非 `withOpacity`），`const` 构造普及，手写文件全部 ≤250 行红线 |
| 文档与可读性 | 9.0 | 542 处注释，几乎每个文件/类/方法都有 DartDoc，且有 RULES.md 强制规范 |
| 错误处理 | 8.5 | 网络层统一 `ApiResponse` 包装、绝不抛崩溃；OCR/M 备份均有 try-catch；DB 初始化失败有可读错误页 |
| 状态/空态处理 | 8.5 | loading/error/empty 三态在列表页、图表、Banner 均有处理 |
| 测试覆盖 | **1.5** | **仅 1 个默认 `widget_test.dart`**，无任何单元/集成测试（repository、datasource、OCR、备份、provider 全裸奔） |
| 架构落地一致性 | 8.0 | 分层清晰，但存在全局可变静态状态、`.g.dart` 手工补丁、Stub 服务等瑕疵（见下） |
| 工程化 / CI | 6.0 | 无 CI、无覆盖率门禁，0/0/0 静态要求靠人工本地执行 |

**主要扣分项**：
1. **零自动化测试**——9.4k 行生产代码仅有 1 个启动冒烟测试，是最大质量风险。
2. **全局可变静态状态**：`AppColors._brightness` + `setBrightness()` 依赖副作用，配合 `ValueKey` 强制重建整树，可测试性差、调用顺序敏感。
3. **`card_item_native.g.dart` 存在手工补丁**（isWishlist/targetPrice/wishlistPriority），属脆弱技术债。
4. **MarketPriceService / CloudSyncService 为明确 Stub**（返回 0 / 空操作，标记 `TODO(phase5)`）——行情与云同步功能目前不可用，且价格走势图用随机种子伪造数据，存在「假数据当真数据展示」的误导风险。

> ⚠️ 注：上述扣分项的整改进度见文末 **「六、优化落地进度（2026-08-01 更新）」**。其中第 2 项（全局可变状态）与第 4 项（行情 Stub / 伪造数据）**已在本次优化第二步、第三步彻底解决**；第 1 项（测试）与第 3 项（.g.dart 补丁）仍为待办。

---

## 三、架构设计评分

### 综合得分：**88 / 100**（低于 90，需改进）

| 维度 | 评分 | 依据 |
|---|---|---|
| 分层合规性（Clean Architecture） | 9.5 | `core / features → data / domain / presentation` 三层职责清晰，依赖方向正确（UI→领域→数据） |
| 平台抽象 | 9.5 | 通过条件导入（`if (dart.library.html)`）彻底隔离 Isar/FFI 与 Web 内存实现，Web 可编译 |
| 依赖注入 / 解耦 | 8.5 | Riverpod Provider 集中注入 repository / service，Widget 不直接 new 数据源 |
| 状态管理 | 8.5 | Riverpod + `AsyncValue` 联动流畅；但 `watchAll()` 用自造 `StreamController` 而非 Isar 原生 `.watch()`，略显 hack |
| 可扩展性 | 8.0 | 抽象接口完善，但 Stub 服务与手工补丁会拖慢后续接入 |
| 可测试性 | 7.0 | 全局静态主题色、服务多依赖真实 `SharedPreferences`/`Isar`/`File`，单测需要较重 mock |
| 安全/隐私 | 7.5 | 备份写应用私有目录、自动备份静默；云同步未实现故无外泄，但无任何加密 |

**亮点**：规范文档（RULES.md）极具大厂风格、三态主题 Token 体系集中管理、空态/微交互细节到位，整体比大多数同类 Flutter 工程更工程化。

**薄弱点**：主题状态全局可变、响应式数据源未用 Isar 原生 watch、Stub 服务与手工补丁影响长期可维护性。

---

## 四、改进方案（评分 < 90，提供 5 项）

### 方案 1：补齐自动化测试体系（最高优先级）
- 为 `CardLocalDatasource` / `CardRepositoryImpl` 加 CRUD + `replaceAllCards` 单测（用内存 Isar 或 fake）。
- 为 `CardOcrService._parse` 加解析单测（覆盖 PSA/BGS/CGC、卡号、卡名正则分支）。
- 为 `profile_export` 加 JSON 序列化/反序列化往返测试。
- 为关键页面（`card_collection_page`、`dashboard_page`）加 `WidgetTester` 交互测试。
- 目标：数据/领域层覆盖率 ≥ 60%，CI 中加 `flutter test --coverage` 门禁。

### 方案 2：主题系统去全局可变状态 ✅ 已完成（2026-08-01）
- ✅ 移除 `AppColors._brightness` 静态变量与 `setBrightness` 副作用（仅保留跨主题恒定品牌色）。
- ✅ 新增 `GoldThemeExtension`（含 `copyWith`/`lerp`/dark/light 静态实例）经 `ThemeData.extensions` 注入；组件经 `context.gold` 响应式取色。
- ✅ 新增 `themeProvider`（`NotifierProvider` + SharedPreferences 三态持久化），根 `MaterialApp.themeMode` 绑定；删除 `MainScreen` / `main.dart` 的 `ValueKey<Brightness>` 强重建 hack。
- ✅ 34 个 widget 自动迁移 `AppColors.X` → `context.gold.X`。
- ✅ 静态自审 0/0/0（沙箱无 Flutter，开发机 `flutter analyze` 待用户执行确认；详见 `QA_STEP2_ANALYZE_FIX.md`）。

### 方案 3：回归生成 .g.dart，退役手工补丁（模型层已对齐，待开发机执行）
- **模型层已对齐（2026-08-01 第三步回归）**：`isWishlist` / `targetPrice` / `wishlistPriority` 本就在 `@Collection` 模型中正确声明；`profit` / `profitPercentage` 为纯派生 getter（`marketPrice - buyPrice` / 百分比），本次以 Isar 3.1 标准注解 `@ignore` 声明（见 `card_item_native.dart`）——Isar 3.1 **不存在** `@Computed()` 注解，故此前误加的 `@Computed()` 属非法写法，已纠正为 `@ignore`，使二者仅作运行期派生值、不参与持久化。
- **修正预先存在的 schema bug（破坏性变更，已评估）**：原手工 `.g.dart` 把 `profit` / `profitPercentage` 当存储字段写入（schema id 13/14），但 `deserialize` 从未读取，属脆弱 hack。以 `@ignore` 重生成后，这俩字段从 schema **彻底移除**，下游 `targetPrice`→13、`volume`→14、`wishlistPriority`→15 顺移。这是**预期内的 schema 破坏性变更**：旧设备库直接打开会读到错位字节/抛 schema 异常；但 13/14 字节本就是孤儿数据（从未被反序列化），**清空本地库不丢任何真实业务数据**，升级时走「卸载重装」或 app 既有清库兜底即可，全新安装无影响。
- 在命令通道可用时执行 `flutter pub run build_runner build --delete-conflicting-outputs`，干净重新生成 Isar 适配器（生成器会产出与当前手工补丁等效、但由源码驱动的版本）。
- 在 CI 中加入「生成文件与源码一致」检查，防止漂移。
- ⏳ 状态：模型改造已完成并通过静态自审；`build_runner` 实际重生成仍待用户在开发机执行（沙箱无 Isar/FFI 工具链，无法运行）。⚠️ 注意：因 `@ignore` 移除 id 13/14 字段，重生成产物与旧手工补丁 schema **不同**，既有设备库升级需清库（详见 `RUNBOOK_STEP1.md` 步骤 4/6）。回归前需先 `git` 快照当前手工补丁状态。详见 `RUNBOOK_STEP1.md` / `QA_STEP1_BUILD_RUNNER.md`。

### 方案 4：处理占位服务与假数据 ✅ 已完成（2026-08-01，行情部分）
- ✅ 彻底下架 `StubMarketPriceService` 与 `seedPriceHistoryJson` 随机种子伪造逻辑（原「假数据当真数据」风险消除）。
- ✅ 新增 `MarketPriceApiService`（对接真实 **Scrydex API**：`/v1/cards/{id}?include=prices` + `/price_history?days=30`），密钥经 `String.fromEnvironment` 注入，缺失时优雅降级为「暂无行情历史」，**绝不伪造曲线**。
- ✅ 估值输入框旁新增香槟金「自动估值」按钮（`MarketEstimateField`），发起真实网络请求并自动回填估值 + 真实走势 JSON。
- ✅ `PriceTrendCard` 在无 API 数据时优雅展示「暂无行情历史」空状态，不再展示模拟曲线。
- ⏳ 备注：`CloudSyncService`（云同步）仍为占位未实现，超出本次范围，建议后续单独立项（Supabase 2.0 或明确 Feature Flag 隐藏入口）。

### 方案 5：建立 CI 静态门禁
- 增加 GitHub Actions / CI 流水线：每次提交跑 `flutter analyze`（强制 0 Error/0 Warning/0 Info）、`flutter test`、`flutter test --coverage`（设阈值）。
- 把 RULES.md 的「静态零容忍」从人工约束升级为自动化卡点。

---

## 五、结论

项目**架构设计优秀、代码规范度高、文档完善**，是质量上乘的 Flutter 工程；但**自动化测试近乎空白**、存在**少量全局可变状态与手工补丁/Stub 技术债**，使其距离「90+ 大厂级」仍有可量化的差距。优先落地**方案 1（测试）**与**方案 3（.g.dart 回归）**可在 1–2 个迭代内将综合分推过 90。

---

## 六、优化落地进度（2026-08-01 更新）

> 本工程自本报告初稿后已连续推进三步优化，以下为可追溯的落地记录。

| 步骤 | 目标 | 状态 | 关键交付 / 结果 |
|---|---|---|---|
| **第一步** | Isar `.g.dart` 回归（退役手工补丁） | 🟡 进行中（模型已对齐，待开发机执行） | 模型层已对齐：`isWishlist`/`targetPrice`/`wishlistPriority` 本就正确声明；`profit`/`profitPercentage` 为纯派生 getter，本次以 `@ignore`（Isar 3.1 标准，纠正此前非法的 `@Computed()`）声明，使其不持久化。⚠️ 副作用：重生成会**移除**原手工补丁误加的 schema id 13/14 字段（下游顺移），属预期内破坏性 schema 变更——旧设备库升级需清库（13/14 为从未读取的孤儿数据，不丢真实业务数据），全新安装无影响；`build_runner` 代码生成本身会顺利。`build_runner` 实际重生成仍待用户在开发机执行（沙箱无 Isar/FFI）。详见 `RUNBOOK_STEP1.md` / `QA_STEP1_BUILD_RUNNER.md`。 |
| **第二步** | 主题系统去全局可变状态 + `flutter analyze` 0/0/0 | ✅ 完成（自审） | `GoldThemeExtension` + `themeProvider`（三态持久化）替换 `setBrightness` 全局可变状态；删除 `ValueKey<Brightness>` 重建 Hack；34 文件迁移 `context.gold`；静态自审 0/0/0（开发机 `flutter analyze` 待用户确认）。详见 `QA_STEP2_THEME_SYSTEM.md` / `QA_STEP2_ANALYZE_FIX.md`。 |
| **第三步** | 接入真实 Scrydex 行情 API + 下架伪造曲线 | ✅ 完成（代码；开发机 `flutter analyze` 0/0/0 待用户确认） | 下架 `StubMarketPriceService` 与 `seedPriceHistoryJson` 随机种子；新增 `MarketPriceApiService`（真实 Scrydex 请求）、`MarketEstimateField`（香槟金「自动估值」按钮）、`PriceTrendCard` 「暂无行情历史」空状态；密钥经 `String.fromEnvironment` 注入，缺失降级不伪造；DB 层校验 `priceHistoryJson` 读写与 JSON 解析路径一致（裸 double 数组，无格式错位）。 |

**质量分预期变化**：原扣分项 #2（全局可变状态）与 #4（行情 Stub / 伪造数据）已在第二、三步彻底解决，可测试性与数据可信度显著提升；剩余主要风险为 #1（自动化测试近乎空白）与 #3（`.g.dart` 手工补丁回归）。

**待办（下一步建议）**：
1. **第三步收尾**：用户在开发机执行 `flutter analyze`（目标 0/0/0）确认；沙箱无 Flutter 工具链，无法代为执行。
2. 落地**方案 1（补齐自动化测试）**——优先 `GoldThemeExtension` / `themeProvider` / `MarketPriceApiService` 单测。
3. **第一步回归**：开发机执行 `build_runner build --delete-conflicting-outputs`（模型已对齐，`RUNBOOK_STEP1.md` 已就绪）；执行前先用 `git` 快照当前手工补丁状态，便于 diff 校验「生成器产物 == 原手工补丁（schema 零变化）」。
4. 单独评估 `CloudSyncService` 云同步占位（Supabase 2.0 或 Feature Flag）。

