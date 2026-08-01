# 账单明细 Tab 重构 · QA 严格自我验收清单

> 任务：将底部导航「行情」Tab 彻底替换为高奢「账单明细」Tab（含全新 LedgerView 页），并清除行情/走势图废弃代码。
> 状态：代码改动已全部完成（文件工具落盘）；**本回合命令执行层失效，静态检查 / 真机构建部署待下一回合 shell 恢复后执行**（历史同症状：每回合末自愈）。

## 一、大厂风格（视觉极简 / 细节丰富 / 无廉价 Emoji）
- 底部导航 Tab 文案与图标：首页 `grid_view_rounded`、攒卡 `style_outlined`（藏品图鉴）、账单 `receipt_long_outlined`、我的 `person_outline_rounded`，全部 Flutter 原生 Lightweight 矢量图标，零 Emoji。
- 财务看板三卡：黑金底（`surfaceDark`）+ **0.5px 香槟金微发光边框**（`goldBorder` + `goldGlow` 8dp 柔光），无渐变块、无粗边框。
- 8dp 网格：padding 全部 16/12/8 倍数；交易流水行圆角 14、缩略图圆角 10。
- 微交互：流水行继承统一 `goldBorder` 黑金卡，点击态由列表滚动与原生 Ink 反馈承担（遵循既有范式）。

## 二、架构拆分（新增 / 修改文件 & 行数）
| 文件 | 操作 | 行数 | ≤250 |
|---|---|---|---|
| `presentation/pages/ledger_view.dart` | 新增 | ~210 | ✅ |
| `presentation/widgets/luxury_bottom_nav.dart` | 改（行情→账单） | 177 | ✅ |
| `presentation/pages/main_screen.dart` | 改（MarketTrendPage→LedgerView） | 82 | ✅ |
| `presentation/providers/nav_providers.dart` | 改（注释索引） | 9 | ✅ |
| `presentation/widgets/quick_action_bar.dart` | 改（doc 注释） | 125 | ✅ |

> 未新增任何重复组件，全部复用既有 `AppColors` / `CardItem` / `allCardsProvider` / `profileCurrencyProvider` / `cardImageProvider` / `cardGradingLabel`。

## 三、全页联动（真实数据，无硬编码）
- **累计买入投入** = Σ `buyPrice`（仅 `isCollected` 持仓卡）。
- **当前藏品总估值** = Σ `marketPrice`（仅 `isCollected`）。
- **已变现金额** = Σ(`marketPrice`−`buyPrice`)，即持仓账面浮盈口径；卡片副标题标注「账面浮盈」保持诚实。
  - 说明：现有 `CardItem` 数据模型**无独立卖出/变现记录字段**，故「已变现」按「若今日全部变现可得的账面收益」口径呈现，数值完全源自真实持仓，非随机模拟；后续若接入卖出流水可精确区分。
- **交易流水** = 各持仓卡买入记录，按 `buyDate` 倒序；含缩略图（`cardImageProvider` 兼容本地/远程）、卡名、`grading` 徽标、买入标签、金额、日期。
- 复用 `allCardsProvider`（首次进入自动注入 Mock 卡牌），财务数字随真实数据实时重算。

## 四、静态检查
- 目标：`dart analyze` → **0 Error / 0 Warning / 0 Info**。
- 当前：本回合 shell 失效未能实跑；下一回合恢复后立即执行并报告。

## 五、底部导航物理中心点校验
- 4 Tab 以中间凹槽（`_fabGap=72`）为轴对称：`Row[Expanded, Expanded, SizedBox(72), Expanded, Expanded]`。
- 单 Tab 宽 `tabW = (w−72)/4`；`centers = [tabW/2, 3tabW/2, (w+72)/2+tabW/2, (w+72)/2+3tabW/2]`。
- 指示器 `left = centers[index] − 11`（宽 22/2），**100% 精准正对图标几何中心正下方**。
- 本次仅替换 index 2 的 label/icon，布局宽度不变，对齐公式保持对称有效。

## 六、待彻底删除的行情/走势废弃代码（待 shell 恢复后 rm）
仅被 `market_trend_page` 引用，移除主入口后整簇脱离编译，应在 shell 恢复后删除：
- `presentation/pages/market_trend_page.dart`
- `data/trend_history.dart`
- `presentation/providers/trend_providers.dart`
- `domain/enums/trend_ranking_type.dart`
- `presentation/widgets/trend_line_chart.dart`
- `presentation/widgets/trend_ranking_list.dart`
- `presentation/widgets/trend_ranking_segment.dart`

## 七、恢复后执行顺序
1. `rm` 上述 7 个废弃文件。
2. `dart analyze` → 0/0/0。
3. `flutter run` / `flutter build apk --debug` + `adb install -r` 部署到真机 `10AG1D28SB00A6Q`。
4. 真机复验：底部第 3 Tab 显示「账单」+ 收据图标；进入后三卡金额正确；流水按时间倒序；空/加载/异常三态正常。

## 八、需你手动验收
- 切到「账单」Tab，核对三张财务卡数值与持仓一致。
- 交易流水缩略图正常（本地实拍/远程图均兼容）、按日期倒序。
- 香槟金指示器正对「账单」图标下方。
