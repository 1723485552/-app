# 第一步回归 Runbook：Isar build_runner 代码生成与模型对齐

> 用途：在**开发机**（非沙箱）干净重生成 `card_item_native.g.dart`，退役手工补丁，并验证模型/数据库联动。
> 沙箱限制：本环境无 Flutter/Dart/Isar-FFI 工具链，无法执行以下任何命令；本 Runbook 由智能体预检 + 落盘模型改造后交付，需用户在本机执行。

---

## 0. 前置条件

- **Flutter 版本必须锁定 3.22 – 3.27**（代码用 `Color.withValues()` 需 ≥3.22；Isar 3.1.0 与最新 3.44/Dart 3.12 不兼容 `build_runner`）。
- Dart SDK（随 Flutter 自带）、可访问 pub 源（已配置 `PUB_HOSTED_URL` 国内镜像）。
- 若尚未设置 git 身份，先执行一次提交快照（见步骤 1）。

---

## 1. 先 git 快照当前手工补丁状态（关键）

```bash
cd C:\card_management
git add -A
git status            # 确认 card_item_native.g.dart 等已被追踪
git commit -m "chore: snapshot hand-patched .g.dart before build_runner regression"
```

> 目的：回归后可用 `git diff lib/features/card_management/data/models/card_item_native.g.dart` 校验「生成器产物 == 预期的 @ignore schema（id 13/14 字段移除、下游顺移）」。注意：**本步预期 schema 会变化**（见步骤 4），diff 应确认变化符合预期，而非「零变化」。

---

## 2. 拉取依赖

```bash
flutter pub get
```

---

## 3. 干净重生成 Isar 适配器

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- `--delete-conflicting-outputs` 会自动覆盖旧 `card_item_native.g.dart`（即「清理旧的 .g.dart」），无需手动删除。
- `@ignore` 是 Isar 3.1 合法注解，代码生成本身会顺利；若控制台报 analyzer 错误，先 `flutter analyze` 排查是否由本步模型改造引入（理论上不应有）。

---

## 4. 校验生成结果（核心验收）

```bash
git diff lib/features/card_management/data/models/card_item_native.g.dart
```

人工比对要点（**与手工补丁不同，这是预期内的破坏性变更**）：

| 检查项 | 期望 |
|---|---|
| 字段 `profit` / `profitPercentage` | **被移除**——不再出现在 schema 中（本就以 `@ignore` 声明，属纯派生 getter，不持久化） |
| `priceHistoryJson` | schema id 仍为 `12` |
| `targetPrice` / `volume` / `wishlistPriority` | id 顺移为 `13` / `14` / `15`（原 15/16/17，因 13/14 移除后上移） |
| 其他字段 | 集合与回归前逐一对应，无意外增删 |

> ⚠️ **这是 schema 破坏性变更**：原手工补丁把 `profit`/`profitPercentage` 当存储字段（id 13/14），但 `deserialize` 从未读取——属预先存在的 schema bug。`@ignore` 重生成后这俩字段从 schema 彻底移除，旧设备库直接打开会读到错位字节/抛 schema 异常。旧 13/14 字节本就是孤儿数据（从未反序列化），**清空本地库不丢任何真实业务数据**。
> 若 diff 出现「预期之外的字段增删或类型变化」→ 立即 `git checkout` 还原 `.g.dart` 并回报。正确情况下 schema 移除 13/14 + 下游顺移，且工程仍可编译。

---

## 5. 静态检查（RULES.md 硬约束）

```bash
flutter analyze     # 目标：No issues found!（0 Error / 0 Warning / 0 Info）
flutter test        # 现有 widget_test 冒烟通过（测试体系补齐见方案 1）
```

- 若 `flutter analyze` 报 `profit`/`profitPercentage` 相关问题，通常是 `@ignore` 导入或注解位置问题（`isar.dart` 已在 `card_item_native.dart` L1 导入），回到步骤 2 排查。
- 沙箱无法代跑，请将 `No issues found!` 贴回以正式坐实 0/0/0。

---

## 6. 运行期数据库联动验证（真机/模拟器）

1. **全新安装**：录入一张卡（手动估值或「自动估值」）→ 退出重进，确认 `priceHistoryJson` 持久化无误、走势图读取正常。全新安装无 schema 冲突。
2. **⚠️ 既有库升级**：回归前 APK 已写入数据的设备，**覆盖安装回归后 APK 会因 schema 变化（13/14 字段移除）导致旧库打开异常**。正确做法：升级时走「卸载重装」清空旧 Isar 库（或 app 既有清库兜底）；因 13/14 为孤儿数据，清库不丢真实业务数据。

---

## 附录：为何不在沙箱删除 .g.dart

- 沙箱无 Flutter，删除后无法重生成 → 工程将不可编译。
- 当前 `card_item_native.g.dart` 为手工补丁，但**工程此刻可正常编译**（含 13/14 字段）；开发机执行步骤 3 后会由工具产出以 `@ignore` 为准的干净版本覆盖之——新产物 schema 与旧补丁不同（移除 13/14），属预期内的修正，手工补丁自然退役。
