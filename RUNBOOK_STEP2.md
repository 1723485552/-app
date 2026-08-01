# 🚀 优化第二步 · 开发机验收 Runbook（flutter analyze + flutter test）

> 本沙箱（WorkBuddy）**无 Flutter/Dart 工具链**，静态重构与静态自审已完成，但 `flutter analyze` / `flutter test` 必须在你的**开发机**执行。
> 请在本机**重开一个终端**（确保第 1 步配置的环境变量已加载，Flutter 版本须为 **3.22–3.27**，以兼容 Isar 3.1.0）后，依次执行下列命令。

---

## 0. 前置确认（一次性）
```bash
# 确认 Flutter 版本在 3.22 ~ 3.27 之间（Isar 3.1.0 兼容窗口）
flutter --version

# 若提示 command not found：确认已按之前的配置写入用户级环境变量
#   PATH 含 C:\flutter\bin
#   PUB_HOSTED_URL=https://pub.flutter-io.cn
#   FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
# 重开终端后仍未生效：请在“系统属性 → 环境变量”核对，或在本会话 source 一下。
```

## 1. 拉取依赖
```bash
cd C:\card_management
flutter pub get
```
> 本次新增依赖：`shared_preferences`（已写入 pubspec.yaml，Runbook 已校验存在）。
> 若 `flutter pub get` 报网络问题，确认镜像环境变量已生效（flutter-io.cn）。

## 2. 生成代码（如本机之前未跑过 build_runner）
```bash
# 仅当本地还未生成 card_item_native.g.dart 等产物时执行；
# 若已有且你接受“优化第一步”所述 profit/profitPercentage 删列变更（需清库重建），可跑：
flutter pub run build_runner build --delete-conflicting-outputs
```
> ⚠️ 关于 `.g.dart` 回归风险（优化第一步已记录）：干净重生成会移除原手工补丁把 `profit` / `profitPercentage` 当存储字段写入的 schema（id 13/14），属于破坏性删列 schema 变更，已有本地库需清库重建（main.dart 已有“卸载重装”兜底）。如你只想先验收第二步主题重构，可暂跳过此步。

## 3. 静态分析（RULES.md §3 硬指标：0 Error / 0 Warning / 0 Info）
```bash
flutter analyze
```
**期望输出（目标）：**
```
Analyzing card_management...
No issues found!   (or: 0 issues)
```
把该输出**原样粘贴回对话**，作为第二步 0/0/0 的验收证据。
若出现 issue，按提示逐条修复后重跑，直至 `No issues found!`。

## 4. 单元测试（RULES.md 大厂工程标准）
```bash
flutter test
```
> 注意：当前项目**几乎无自动化测试**（仅 1 个默认 `widget_test`，且大概率因依赖/初始化在纯 test 环境报错）。
> 第二步本身未改动测试，但建议借机补齐：
> - `test/core/theme/gold_theme_extension_test.dart`：校验 `copyWith` / `lerp(t=0与t=1)` / `dark` / `light` 字段值。
> - `test/core/theme/theme_provider_test.dart`：用 `SharedPreferences.setMockInitialValues` 验证三态持久化与恢复。
> 若 `flutter test` 因无测试或默认测试崩溃而失败，属预期，需在第三步测试补齐专项中处理（下一步计划）。

## 5. 真机 / 模拟器冒烟（可选但推荐）
```bash
flutter run
```
- 进入「个人中心 → 外观主题模式」，分别点「跟随系统 / 暗黑黑金 / 明亮香槟金」；
- 确认全页背景、文字、卡片表面色**平滑过渡**（lerp），无整页闪白重建；
- 杀进程重启，确认主题选择被持久化恢复；
- 系统切到深色模式（若处于“跟随系统”）应自动响应。

---

## ✅ 验收通过判据
1. `flutter analyze` → `No issues found!`（0/0/0）；
2. `flutter run` 三态切换全页生效且重启保留；
3. 将 `flutter analyze` 输出贴回对话，第二步即视为**正式收口**。

> 待你贴回 `flutter analyze` 结果后，我将：
> - 把第二步结论写进 `CODE_ANALYSIS_REPORT.md` 的改进进度；
> - 衔接「优化第三步：测试补齐」与「优化第一步：Isar .g.dart 回归」收尾（需你提供 git user.name / user.email 做首个快照提交）。
