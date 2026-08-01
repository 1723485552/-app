# 🚨 卡牌资产 App（Card Collector）大厂级强制开发规范

在开始任何代码编写或修改前，必须无条件遵循以下四大核心工程与设计规则。任何违反规范的代码将直接被判定为不合格并重跑。

---

## 💎 1. 全程贯穿“简洁而不简单”的大厂设计语言 (Sophisticated Simplicity)
* **视觉极其干练（简洁）**：
  * **去除冗余视觉噪点**：严禁使用多余的彩色渐变块、粗重边框或夸张的阴影。
  * **克制且高级的色彩配置**：纯黑/深灰背景 (`0xFF1A1A1A`)，搭配香槟金/高奢金 (`0xFFD4AF37`) 作为微量点缀色（金色仅用于高亮、选中态或 0.5px 极细微边框，禁止大面积填充）。
* **细节极具质感（不简单）**：
  * **精准的 8dp 网格布局**：所有控件 Padding 与 Margin 严格遵循 8/16/24 的倍数，保持极致的秩序感。
  * **细腻的微交互 (Micro-interactions)**：按钮点击必须有轻微的状态反馈，展开/收起组件必须使用平滑过渡（如 `AnimatedSize` 或 `AnimatedSwitcher`），严禁生硬跳变。
* **绝对去 AI 化（Anti-AI Aesthetic）**：
  * **严禁使用默认 Emoji**（如 🚀、🔥、🎉、🤖 等）充当页面核心图标或 Tab 矢量。
  * **严禁使用粗笨平庸的默认图标**（如普通的 `Icons.home`、`Icons.category` 等）。
  * 必须统一使用 Flutter 原生 Lightweight 矢量图标（如 `Icons.grid_view_rounded`、`Icons.style_outlined`、`Icons.show_chart_rounded` 等）。

---

## 🛑 2. 代码架构与防偷懒禁令 (Anti-Lazy Architecture)
* **严格拒绝单文件代码堆砌**：
  * 严格遵循 Clean Architecture 拆分（`pages` / `widgets` / `providers`）。
  * **单个文件行数上限为 250 行**，超过必须强制抽离为独立 Widget 组件。
* **拒绝假逻辑与静态硬编码**：
  * 所有列表、网格、统计 Banner 必须绑定真实的 Riverpod Provider/State。
  * 搜索和分类筛选必须真正联动全页数据源。
* **边界情况与空状态防塌陷**：
  * 任何列表/网格必须优雅处理 `loading`（加载中）、`error`（异常）及 `empty`（空数据）三种状态。
  * 空状态必须有极简、干净的黑金矢量提示，不得出现布局塌陷。

---

## ⚙️ 3. 大厂静态工程约束 (Engineering Standards)
* **静态分析零容忍**：每次提交前必须通过 `dart analyze` 静态检查，保持 **0 Error / 0 Warning / 0 Info**。
* **性能与构造优化**：
  * 全量启用 `const` 构造，避免不必要的 Widget 重绘。
  * 禁用已弃用 (Deprecated) 的 Flutter API。

---

## 📋 4. 强制交付与 Self-QA 自查机制
* 每次完成任务后，必须附带一份 **《QA 严格自我验收清单》**，逐条对齐并说明：
  1. 【大厂风格】：界面是否做到视觉极简、细节丰富（8dp网格、微交互、无廉价 Emoji）。
  2. 【架构拆分】：新增/修改了哪些文件，单文件行数是否控制在 250 行以内。
  3. 【全页联动】：搜索/分类是否全页响应。
  4. 【静态检查】：`dart analyze` 结果是否为 0 Issues。



# 🚨 卡牌资产 App（Card Collector）大厂级强制开发规范

---

## 🔁 0. 绝对上下文感知硬规 (Always Read Context First)
* **强制重读项目上下文**：
  * 在进行任何代码编写、新增功能或修改重构前，**智能体必须首先重新扫描并读取全盘项目代码结构（含 lib/ 下所有文件）**。
  * 严禁凭记忆或猜测直接生成代码！必须确保新增的组件、Provider 和 Helper **绝不与现有代码重复**，且必须无缝复用既有的 `AppColors`、`CardItem` 和数据源。

---

## 🎨 1. 首页去单调化与大厂资产质感 (Rich & Dynamic Dashboard)
* **杜绝单调与干瘪感**：
  * 首页不仅要包含资产统计，还必须具备**高频动态与高价值展示区**。
  * **必须增加【神卡/稀有卡高奢展示 Card Showcase】**：以 3D/微阴影卡片形式展示最具价值的镇馆之宝或最新收录的卡牌。
  * **必须增加【市场行情微走势 / 快速高频入口 Quick Actions】**：提供如“快速扫码/拍卡录入”、“高频盈亏速览”、“今日关注神卡”等微型动态 Widget，大幅丰富页面的视觉与信息层级。
  * **严禁滥用默认 Emoji**，全量继续使用 0.5px 金边、黑金 Theme Token 和 Outlined 矢量图标。

# 🚨 卡牌资产 App（Card Collector）大厂级强制开发规范

---

## 📸 6. 攒卡网格紧凑化与大厂沉浸式大图预览 (Compact Grid & Fullscreen Viewer)
* **网格尺寸紧凑化 (Compact Card Tiles)**：
  * 攒卡页面卡片网格 (`CardGrid`) 必须缩小默认显示尺寸，保持高信息密度（如单行 3-4 列紧凑卡片，或微型高奢贴纸框），突出卡片缩略图、评级标签与核心价格，去除冗余大面积留白。
* **微信式点击全屏/大图沉浸式预览 (Fullscreen Card Lightbox)**：
  * 点击任意卡片时，禁止直接展开繁琐的弹窗，**必须触发类似微信聊天记录图片的全屏/沉浸式大图预览组件 (`CardDetailLightbox`)**。
  * **预览体验要求**：
    * **沉浸黑金背景**：背景带高纯度深灰/纯黑遮罩（`0xEE121212`）与平滑淡入动画（`FadeTransition` / `Hero` 动画）。
    * **高精大卡展示**：中央展示大图，四周带 **0.5px 香槟金微发光边框**，并可放大查看卡牌精细纹理。
    * **底栏资产浮层**：大图下方悬浮展示卡牌全名、PSA/BGS 评级勋章、买入价与当前估值。
    * **手势支持**：支持点击空白处或向下下滑平滑关闭，点击时带 `HapticFeedback.lightImpact()` 触觉反馈。

# 🚨 卡牌资产 App（Card Collector）大厂级强制开发规范

---

## 🌗 7. 全局三态主题与户外强光适配 (System/Dark/Light Gold Theme)
* **全局 ThemeMode 真实响应**：
  * 主题设置必须通过 Riverpod `themeModeProvider` 真实绑定到根组件 `MaterialApp` 的 `themeMode` 属性（支持 `ThemeMode.system` 跟随系统、`ThemeMode.dark` 暗黑黑金、`ThemeMode.light` 明亮香槟金）。
* **明亮香槟金模式 (Light Gold Mode) 视觉规范**：
  * **户外强光高对比度**：白天/亮色模式下，背景采用极致纯白/微灰高质感底色（`0xFFF8F9FA`），卡片采用纯白 (`0xFFFFFFFF`) + 0.5px 香槟金微边框 (`0xFFD4AF37`)。
  * **文字与图标强对比**：主要文字采用深炭灰/纯黑 (`0xFF1A1A1A`)，确保强光下文字清晰易读，保留香槟金作为微量高亮点缀。