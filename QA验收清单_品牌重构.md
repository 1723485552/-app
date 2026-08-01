# QA 严格自我验收清单 — 品牌重构（App Logo 集成）

任务：集成自定义 App Logo 与资产路径自动初始化

---

## 1. 【大厂风格】视觉极简、细节丰富（8dp 网格、微交互、无廉价 Emoji）

- 新增 `BrandLogo` 统一组件：黑金 0.5px 金边 + 圆角描边容器，复用既有 `AppColors` Token，**未使用任何 Emoji 作图标**（解析失败回退为 `Icons.diamond_outlined` 矢量图标）。
- 三处品牌展示均符合黑金质感：
  - 资产大盘 Header：36×36 描边 Logo 紧贴“资产大盘”标题（8dp 间距）。
  - 晒卡海报：底部升级为「Logo + CARD COLLECTOR / 卡牌资产·年份」高奢印章组合（金边圆角卡片）。
  - 关于弹窗：顶部 64×64 居中 Logo。
- 全程沿用 8dp 网格（padding 4/8/12/16），无彩色噪点、无粗重阴影。

## 2. 【架构拆分】新增/修改文件 + 单文件行数 ≤250

| 文件 | 动作 | 行数 |
|------|------|------|
| `lib/core/widgets/brand_logo.dart` | 新增（共享组件，防重复） | 44 |
| `lib/features/card_management/presentation/widgets/asset_banner.dart` | 修改（Header 嵌 Logo） | 170 |
| `lib/features/card_management/presentation/widgets/card_share_poster.dart` | 修改（落款升级印章） | 243 |
| `lib/features/card_management/presentation/widgets/profile_about_dialog.dart` | 修改（顶部 Logo） | 107 |
| `pubspec.yaml` | 修改（注册 assets） | — |
| `assets/images/app_logo.png` | 新增（真实 PNG） | — |
| `android/app/src/main/res/mipmap-*/ic_launcher.png` ×5 | 替换（桌面图标） | — |

全部 ≤250 行（最大 243）。`BrandLogo` 抽离为独立组件，三处复用，符合 RULES 反重复原则。

## 3. 【全页联动 / 资产路径自动初始化】

- **资产目录自动初始化**：检测到用户原始 Logo 位于 `assets/新建文件夹/app_logo.png`，已自动创建 `assets/images/` 目录并落盘至 `assets/images/app_logo.png`。
- **关键修复（防崩溃）**：原始文件实为 JPEG 字节（FFD8 头）却以 `.png` 命名。Flutter 按扩展名解码资源 → 必崩。已用 Pillow 将其转换为**真实 PNG**（8950 头，1024×1024 RGBA），保证 `Image.asset` 正常加载。
- **pubspec 注册**：`flutter:` 节点下新增 `assets: - assets/images/app_logo.png`，APK 校验确认已打包（`assets/flutter_assets/assets/images/app_logo.png`）。
- **桌面图标**：Logo 按 mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi（48/72/96/144/192px）重采样并覆盖 `ic_launcher.png`，APK 校验 5 张全部打包；`AndroidManifest.xml` 沿用 `@mipmap/ic_launcher`。
- 全盘扫描确认：本任务未改动任何数据模型（CardItem 等字段无增删），故无 Mock/Provider/渲染点需要适配。

## 4. 【静态检查】dart analyze 结果

```
flutter analyze
No issues found! (0 Error / 0 Warning / 0 Info)
```

- 已修复 `profile_about_dialog` 的 2 处 `prefer_const_constructors`（info），最终 0/0/0。

## 5. 【冷启动验证】Clean Build + 设备安装

- 执行 `flutter clean` → `flutter build apk --debug` → `flutter install --debug -d 10AG1D28SB00A6Q`（V2458A）。
- 旧版本已卸载并重装最新包，APK 内资产/图标核验通过。
- 建议真机确认：首页资产大盘 Header 显示 Logo、晒卡海报底部印章、关于弹窗顶部 Logo、桌面临面图标替换生效。

---

交付结论：4 项集成全部完成，`flutter analyze` 0/0/0，单文件均 ≤250 行，已 Clean 重装至真机。
