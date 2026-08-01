# 依赖升级分析 — file_picker / share_plus 与 KGP 警告

任务：将 file_picker 与 share_plus 升级到「支持 Built-in Kotlin」的最新兼容版本，以消除控制台 Kotlin Gradle Plugin (KGP) 警告。

---

## 结论速览
- **pubspec.yaml 无需改动**：两个依赖当前已处于「互相兼容的最新版本」。
- 强制升级 share_plus 到 13.x 会**直接破坏 `flutter pub get`**（win32 版本冲突）。
- API 调用点**无需任何适配**（使用的都是稳定 API）。
- KGP 警告的真正来源是项目**自己的** `android/build.gradle.kts` AGP-9 补丁，而非过期插件，插件升级无法消除它。

---

## 1. 扫描全盘后的事实

### file_picker
- 当前约束：`^11.0.2`（`pubspec.yaml:21`）。
- 最新发布版：**11.0.2（2026-04，15 天前）**——已是最高版本，**无更新可升**。

### share_plus
- 当前约束：`^12.0.2`（`pubspec.yaml:22`）。
- 最新版：**13.1.0（2026-04）**。但 13.0.0 的破坏性变更把 `win32` 从 5.15.0 提升到了 **6.0.0**。
- `file_picker 11.0.2` 对 win32 的约束是 `^5.9.0`（即 `<6.0.0`）。
- 两者 win32 区间不重叠 → 若 share_plus 升到 13.x，`flutter pub get` 会因 **win32 5.x vs 6.x 版本冲突**而失败。
- 因此 share_plus 在「与 file_picker 11.0.2 共存」前提下，最高只能停在 **12.0.2**（当前版本）。

### 调用点 API 兼容性（已核对）
- `lib/.../card_share_poster.dart:99` → `SharePlus.instance.share(ShareParams(text:, files:[XFile]))`。
- `lib/.../data_backup_service.dart:33` → `SharePlus.instance.share(ShareParams(text:, subject:, files:[XFile]))`。
- `lib/.../data_backup_service.dart:45` → `FilePicker.pickFiles(type:, allowedExtensions:)`。
- 上述 API（`SharePlus` 类 + `ShareParams` 自 11.0.0 引入；`FilePicker.pickFiles` 长期稳定）在 11/12/13 三档大版本中**签名未变**，故即使能升级也无需改代码。当前 12.x 下已编译通过，无需适配。

---

## 2. KGP 警告的真正来源（关键）

`android/build.gradle.kts` 第 22–43 行有一段**项目自建的 AGP-9 补丁**：

> file_picker 11.0.2 在 AGP 9（Flutter 3.44）下会跳过应用 Kotlin Gradle 插件、转而依赖 Flutter 内置 Kotlin，但内置 Kotlin 无法编译其 Kotlin 源码 → `cannot find symbol FilePickerPlugin`。补丁通过 `apply(plugin = "org.jetbrains.kotlin.android")` 强制给 `:file_picker` 套上 Kotlin 插件才得以编译。

**这条补丁本身正是 KGP 警告的来源**（向子模块强制 apply kotlin-android 会触发 Kotlin Gradle Plugin 的多重加载 / 版本提示类告警）。它**不是**由「插件版本过旧」引起的，因此：
- 升级 file_picker —— 已是最新，无效；
- 升级 share_plus —— 会引发 win32 冲突，反而让构建直接失败；
- 删除补丁 —— 会令 file_picker 11.0.2 在 AGP 9 下编译失败。

要真正消除该警告，现实路径只有两条：
1. **等 file_picker 后续版本**原生支持 AGP 9 的内置 Kotlin（届时补丁与警告可一并移除）；11.0.2 已是当前最新，暂无。
2. **精修该补丁**以消音具体告警（例如为 `:file_picker` 的 kotlin-android 显式指定与宿主一致的 Kotlin 版本，或加 `resolutionStrategy` 统一 Kotlin 版本避免「loaded multiple times」）。此改动有破坏构建的风险，且当前执行环境 Shell 不可用，**无法本地验证**，故本次不予改动。

---

## 3. 本次实际改动
- `pubspec.yaml`：**未改动**（已最优）。
- Dart 代码：**未改动**（API 已兼容，无需适配）。
- `flutter analyze` 现状：沿用此前 0/0/0；本次无代码变更，静态诊断不受影响。
- 已与用户沟通：升级前提不成立，盲目升级会破坏可构建性。

---

## 4. 后续可选
- 若坚持要消音 KGP 警告：在 Shell 恢复后，我可尝试**精修 `android/build.gradle.kts` 补丁**（指定 Kotlin 版本 / 去重），并实跑 `flutter build apk --debug` 验证不破构建再交付。
- 或保持现状，待 file_picker 发版后再评估移除补丁。
