# QA 严格自我验收清单 —— 第一步回归：Isar build_runner 与模型对齐

> 对应任务：重新生成 `card_item_native.g.dart`、退役手工补丁、确保 `priceHistoryJson` 与新价格历史结构在 Isar 中读写顺畅、维持 0/0/0。
> 适用范围：本步为**后端/代码生成/数据库层**改造，无 UI 变更；凡 UI 相关条目标注「N/A」。
> 执行环境：沙箱无 Flutter/Dart/Isar-FFI，代码生成与 `flutter analyze` 实际执行需在**开发机**完成（见 `RUNBOOK_STEP1.md`）。

---

## 1. 【大厂风格】—— N/A（无界面改动）

- 本步未新增/修改任何页面、Widget 或图标，反 Emoji / 8dp 网格 / 微交互等视觉规则无新增违反点。
- `card_item_native.dart` 仅补充 DartDoc 注释，风格与既有黑金文档体系一致。

---

## 2. 【架构拆分】—— 改动文件清单与行数

| 文件 | 类型 | 行数 | 说明 |
|---|---|---|---|
| `lib/.../data/models/card_item_native.dart` | 手写（已改） | **140**（≤250 ✅） | 对 `profit` / `profitPercentage` 加 `@ignore` + DartDoc，明确为纯运行期派生 getter，无逻辑改动 |
| `lib/.../data/models/card_item_native.g.dart` | **自动生成**（豁免 250 行） | 2652（工具产出） | 由开发机 `build_runner` 重生成，覆盖手工补丁 |
| `lib/.../data/models/card_item_web.dart` | 手写（未改） | 96 | Web 纯 Dart 模型，无 Isar，无需 `@ignore` |
| `RUNBOOK_STEP1.md` | 文档（新增） | — | 开发机回归步骤 |
| `QA_STEP1_BUILD_RUNNER.md` | 文档（新增） | — | 本清单 |

- 手写改动文件 **仅 1 个**，且 140 行远小于 250 红线；生成文件依规豁免。✅

---

## 3. 【全页联动】—— N/A（无搜索/分类/页面联动改动）

- 校验 `priceHistoryJson` 数据链路在 DB 层闭环（见第 5 节），不影响现有页面联动逻辑。

---

## 4. 【静态检查】—— 0/0/0 与编译正确性

| 检查项 | 状态 | 说明 |
|---|---|---|
| 手写文件 ≤250 行 | ✅ | `card_item_native.dart` = 140 行 |
| `import 'package:isar/isar.dart'` 已存在 | ✅ | `@ignore` 为本文件顶部已导入的 `isar.dart` 标准注解（L1 已导入） |
| 无新增 deprecated API | ✅ | 仅注解，无 API 调用 |
| `dart analyze` 0/0/0 | ⏳ 开发机执行 | 沙箱无 Flutter；请在本机跑 `flutter analyze` 并贴回 `No issues found!` |
| `flutter test` 冒烟 | ⏳ 开发机执行 | 现有 `widget_test` 通过即可 |
| 循环依赖 / 重复声明 | ✅ | `@ignore` 为注解，不引入新依赖 |

---

## 5. 模型与数据库联动校验（本步核心）

| 检查项 | 结论 | 证据 |
|---|---|---|
| `priceHistoryJson` 持久化声明 | ✅ | `card_item_native.dart` L64 `final String priceHistoryJson`，Isar 自动持久化（非 `@ignore`）；`.g.dart` 已含 id 12 映射 + serialize/deserialize |
| 真实历史 JSON 格式与解析一致 | ✅ | `MarketPriceApiService._fetchHistory` 将每点压平为裸 `double`，`fetchQuote` 存 `jsonEncode([...double])`；`parsePriceHistory` 解析 `List<num>` → 裸 double 数组，**无格式错位** |
| 空/非法 JSON 不崩溃 | ✅ | `parsePriceHistory` 空串直返 `[]`；`try/catch` 兜底返回 `[]` → 图表走「暂无行情历史」空态 |
| `profit` / `profitPercentage` 改为 `@ignore` 后语义 | ✅ 纯派生 getter | 二者为 `marketPrice - buyPrice` / 百分比，**无存储字段支撑**；以 `@ignore` 声明后仅作 Dart 运行期派生值，**不参与 Isar 持久化**（Isar 3.1 无 `@Computed()` 注解，这是唯一正确的标准写法） |
| **⚠️ 既有本地库 schema 变更（重要）** | ⚠️ **破坏性变更** | 原手工补丁把 `profit`/`profitPercentage` 当存储字段写入 schema（id 13/14），但 `deserialize` 从未读取——属**预先存在的 schema bug**。以 `@ignore` 重生成后，这俩字段从 schema 中**彻底移除**，下游字段 id 顺移：`targetPrice` 15→13、`volume` 16→14、`wishlistPriority` 17→15。**重生成产物与旧 .g.dart 布局不同**，旧设备库直接打开会读到错位字节/抛 schema 异常 |
| 升级兼容处理 | ✅ 方案已定 | 该 13/14 字节本就是**孤儿数据**（从未被反序列化读取），清空本地库**不丢任何真实数据**；升级时走「卸载重装」或 app 既有清库兜底即可（见 `RUNBOOK_STEP1.md` 步骤 6）；全新安装无此问题 |
| `profit`/`profitPercentage` 既有调用不受影响 | ✅ | 5 处 widget 仅作**显示 getter** 读取；`@ignore` 后 getter 仍存在、值仍由 `marketPrice`/`buyPrice` 实时派生，调用面零改动 |
| 生成文件不被误删导致不可编译 | ✅ | 沙箱未删除 `.g.dart`（无工具无法重生成）；开发机用 `build_runner --delete-conflicting-outputs` 原位覆盖（见 Runbook 步骤 3） |

---

## 6. 集成风险与边界

- **唯一剩余执行风险**：开发机 `build_runner` 实际运行（依赖 Flutter 3.22–3.27 + 网络 pub 源）。`@ignore` 是 Isar 3.1 合法注解，`build_runner` 代码生成本身会顺利；**真正的注意点是运行期既有库升级需清库**（见第 5 节 ⚠️ 项）。
- **回滚预案**：若 `git diff` 显示 `.g.dart` 出现非预期的字段增删/类型异常，立即 `git checkout` 还原并回报；本步模型改造本身不影响编译（现成 `.g.dart` 仍含 13/14 字段，可正常编译）。
- **既有库升级**：因 schema 布局发生变化（13/14 字段移除），覆盖安装**不应**期望旧库直接打开；依赖「卸载重装」清库兜底，全新安装无影响。

---

## 7. 自审结论

- ✅ 模型层已对齐，`profit`/`profitPercentage` 以 `@ignore` 明确为纯派生 getter（Isar 3.1 唯一正确写法），手工补丁退役路径已打通。
- ✅ 静态自审：手写改动 1 文件、140 行、无新增告警源。
- ⚠️ **运行期注意**：重生成会让 schema 移除 id 13/14（修正预存在的 schema bug），既有设备库升级需清库（不丢真实数据）。
- ⏳ `flutter analyze` / `flutter test` 0/0/0 与 `build_runner` 实际重生成 **待开发机执行并贴回结果**。
