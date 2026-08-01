# 《QA 严格自我验收清单》— 细节缺陷专项修复（4 项）

> 派工单：修复撤销无响应 / 界面溢出 / 图片上传 / 估值选填
> 交付时间：2026-07-30　静态诊断：`flutter analyze` = **0 Error / 0 Warning / 0 Info**

---

## 1. 【大厂风格】视觉与交互
- ✅ 封面图选择区块沿用黑金 0.5px 金边 + 深灰底，**未使用任何 Emoji**（采用 `Icons.add_a_photo_outlined` / `Icons.refresh_outlined` 矢量图标）。
- ✅ 8dp 网格对齐、微交互（点击震动、淡入）保持不变，未引入廉价视觉噪点。
- ✅ 撤销 SnackBar 为黑金浮层 + 香槟金「撤销」动作按钮（3 秒反悔窗口）。

## 2. 【架构拆分】新增/修改文件与行数（均 ≤250）
| 文件 | 行数 | 改动 |
|------|------|------|
| `presentation/widgets/card_cover_picker.dart`（新增） | 101 | 共用封面图选择 + 压缩组件 |
| `presentation/widgets/card_detail_lightbox.dart` | 244 | 删除/撤销逻辑内聚 + 安全 context |
| `presentation/widgets/manual_add_card_sheet.dart` | 233 | 接入封面选择 + 估值选填 + 溢出修复 |
| `presentation/widgets/add_wishlist_sheet.dart` | 186 | 替换内联 picker + 溢出修复 |
| `presentation/widgets/card_tile.dart` | 196 | 移除冗余 onDeleted 回调 |
| `presentation/widgets/card_showcase_widget.dart` | 146 | 移除冗余 onDeleted 回调 |
| `core/widgets/gold_snack_bar.dart` | 56 | 新增 `showOn(ScaffoldMessengerState)` 重载 |

## 3. 【全页联动 / 问题根因与修复】

### 🎯 1. 撤销按钮点击无反应（已根治）
- **真因**：原实现把撤销 SnackBar 挂在 `card_tile` 的 `BuildContext` 上；删除后该卡片格从网格卸载、其 context 随之失效 → `ScaffoldMessenger.of(失效context)` 抛异常 → SnackBar 无法弹出 / 点了没反应。
- **修复**：删除编排收敛进 `card_detail_lightbox._delete`，删除前捕获**应用级** `ProviderScope.containerOf(context)` + `ScaffoldMessengerState` + `NavigatorState`（全程不跨 `await` 使用 context，规避 `use_build_context_synchronously`）；撤销的数据写回（`saveCard`）与 `allCardsProvider` 刷新均走应用级容器 → UI 必定回滚。
- **连带清理**：移除 `card_tile` / `card_showcase_widget` 中重复的 `onDeleted` 回调（展柜也存在同一隐患）。

### 🎯 2. RenderFlex OVERFLOWED BY 60PX（已根治）
- **根因**：表单 Sheet 的 `maxHeight: size.height * 0.92` 未扣除键盘高度 `viewInsets.bottom`，键盘弹起时总高超出屏幕 → 黄色溢出条。
- **修复**：`manual_add_card_sheet` 与 `add_wishlist_sheet` 的 `maxHeight` 改为 `size.height - kb - 24`，并保留底部 `viewInsets.bottom` Padding，内容仍可 `SingleChildScrollView` 滚动。

### 🎯 3. 封面图片上传（已补齐）
- 新增可复用 `CardCoverPicker`：黑金虚线感区块 → `ImagePicker().pickImage(gallery)` → `ImageOptimizer.compressImage()`（≤1080px / ≤300KB）压缩后回传本地路径；**压缩异常自动回退原图**（Null Guard，绝不崩溃）。
- `manual_add_card_sheet`：编辑模式自动加载 `initialCard.imageUrl` 作预览，可点击替换。
- `add_wishlist_sheet`：替换原有未压缩的内联 picker，统一压缩逻辑，消除重复代码。

### 🎯 4. 当前估值改为选填（默认 0）
- 移除「当前估值」的 `required` 非空校验；占位符由 `0` 改为 `0.0 (选填，默认 0)`；解析 `double.tryParse(...) ?? 0.0`（既有）。

## 4. 【静态检查】
- ✅ `flutter analyze`：**No issues found!**（0 Error / 0 Warning / 0 Info）
- ✅ 全局 `prefer_const_constructors`、`use_build_context_synchronously` 等 lint 全部清零。

## 5. 【真机交付】
- ✅ 设备 V2458A（Android 16）：`flutter clean` → `flutter build apk --debug` → `flutter install --debug` 全量冷构建重装（APK 时间戳 2026-07-30 18:44）。
- ✅ 新功能字符串（点击上传卡片封面 / 近 30 日价格走势 / 黑金展柜 / 卡牌已删除 / 撤销 / CardCoverPicker）在 `kernel_blob.bin` 全部命中；启动 logcat 无 FATAL / 崩溃。
- ⚠️ 备注：Flutter **debug** APK 的应用代码位于 `assets/flutter_assets/kernel_blob.bin`（非 `libapp.so`），验收字符串须扫该文件。

## 6. 【新增硬规则落实验证】
1. 默认值 + Null Guard：封面压缩异常回退、估值 `?? 0.0`、空 `priceHistoryJson` 有保护。
2. 清缓存冷启动：本次 `flutter clean` + 全量重编 + 重装（虽未改数据模型，仍按冷构建交付）。
3. 全量字段适配：未改数据模型，仅 UI 层改动，无模型适配遗漏。
4. 每次修改后 `flutter analyze` 至 0/0/0：已执行并清零。
