# OCR 拍照识卡 · QA 严格自我验收清单

> 任务：实现真实设备端 OCR 拍照识卡 + 本地照片入库闭环
> 状态：**已部署并验证** —— `flutter pub get` / `dart analyze 0/0/0` / `flutter build apk --debug`（构建绿）/ `adb install` 装到真机 `10AG1D28SB00A6Q`（V2458A, Android 16）/ App 启动无崩溃、ML Kit 原生库与 OCR 模型已内置。
> 交互功能（实拍识卡、入网格）需你在真机手动点选确认，详见文末「自动化验证结论」与「需你手动验收项」。

## 一、静态检查与硬规（⚙️ 必须 0/0/0）
- [ ] `flutter pub get` 成功（需联网拉取 `image_picker` / `google_mlkit_text_recognition` 及 Maven 原生制品）
- [ ] `dart analyze` 输出 **No issues found!**（0 error / 0 warning / 0 info）
- [ ] 手写文件均 ≤ 250 行：
  - `scan_add_card_dialog.dart` = 168 行 ✅
  - `manual_add_card_sheet.dart` = 183 行 ✅
  - `card_ocr_service.dart` = 140 行 ✅
  - `card_image.dart` / `_native` / `_web` 均极短 ✅
- [ ] 复用 `AppColors` / `CardItem` / `cardGradingLabel` 等既有 token，无硬编码颜色、无重复组件
- [ ] 8dp 栅格、无 emoji（AI 高亮用 `Icons.auto_awesome` + 文字，规避字面 emoji）

## 二、双模式黑金识别器（🎯2）
- [ ] 弹窗顶部 Segment 切换「拍照 OCR」/「条码扫码」可点且高亮态为香槟金
- [ ] `showGeneralDialog` 已带 `barrierLabel`（规避运行时 assertion 崩溃，真机已验证过的坑）
- [ ] 拍照 OCR 模式：黑金四角框 + 金线扫描动画；点击「拍照识卡」调相机、「从相册选择」调相册
- [ ] 条码扫码模式：保留激光扫描动画 + 「模拟扫描识别」回填（历史行为，无新增条码库）
- [ ] 识别完成显示 ✓ 与「识别成功：PSA 10 初版喷火龙」摘要文案
- [ ] 关闭扫描窗 → 延迟 280ms → 拉起手动录入（规避 Root Navigator pop→show 竞态）

## 三、设备端 OCR 与智能提取（🎯1）
- [ ] `image_picker` 取图后落盘 `getApplicationDocumentsDirectory()/cards/`（持久化封面）
- [ ] `google_mlkit_text_recognition` 设备端识别，识别中显示 `CircularProgressIndicator`
- [ ] 正则提取：评级机构 PSA / BGS / CGC / SGC；分数 10、9.5、GEM MT 等；卡号 `#xxx`；卡名（Title Case 启发式）；分类按关键词推断
- [ ] 识别异常（如 ML Kit 模型未下载）被 `try/catch` 兜底，不崩溃，仅留照片无字段
- [ ] 用户取消选择 → 停留识别页、不误触发回填

## 四、照片入库闭环（🎯3）
- [ ] 识别照片路径写入 `ManualAddPrefill.imagePath` → 保存时赋值 `CardItem.imageUrl`
- [ ] 网格 `card_tile` 与大图 `card_detail_lightbox` 经 `cardImageProvider` 渲染本地 `FileImage`，封面为实拍卡图
- [ ] `errorBuilder` 兜底保留（路径失效时回退金边图标占位）
- [ ] 被回填字段显示香槟金「AI 识别」小标签；标题区显示「AI 识别已自动填充」金 pill
- [ ] 确认入库 → `CardLocalDatasource().saveCard` → `ref.invalidate(allCardsProvider)` 全站刷新

## 五、权限与平台（🎯1 / 部署）
- [ ] `AndroidManifest.xml` 已加 `CAMERA` / `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE(maxSdk=32)`
- [ ] 真机（V2458A, Android 16）`flutter run` 安装成功、无运行时 assertion
- [ ] 相机/相册权限弹窗正常、首次使用不闪退

## 六、已知限制 / 待确认
- ⚠️ **ML Kit 模型**：设备端文本识别模型首次使用会从 Google CDN 自动下载，需联网一次；长期离线环境将退化为「仅拍照无字段提取」。如需纯离线，可改为预置模型（`RemoteModelManager` 下载后置 `AndroidManifest` 元数据）。
- ⚠️ **条码模式**：当前为模拟回填（未引入 `mobile_scanner` 等真实扫码库）。如需真扫码，此轮网络受限未加，可后续补充。
- ⚠️ **Web 构建**：OCR 依赖（`image_picker`/`google_mlkit_text_recognition`）非 Web 友好；`card_image` 已做条件导出保护 web 编译，但 OCR 弹窗整体未做 Web 适配（本任务目标为真机 Android）。

## 七、本轮自动化验证结论（机器已验证 ✅）

| 检查项 | 结果 | 证据 |
|---|---|---|
| `flutter pub get` | ✅ 成功 | `google_mlkit_text_recognition 0.13.1` + `image_picker 1.2.3` 已加入，Changed 18 dependencies，RC=0 |
| `dart analyze` 0/0/0 | ✅ 通过 | 输出 `No issues found!`（RC=0），已修 2 error + 7 info |
| `flutter build apk --debug` | ✅ 构建绿 | `√ Built build/app/outputs/flutter-apk/app-debug.apk`（RC=0，仅 JDK 源/目标 8 弃用警告，无害） |
| ML Kit 原生库打包 | ✅ 已内置 | APK 含 `lib/arm64-v8a/libmlkit_google_ocr_pipeline.so` 等三架构 + `assets/mlkit-google-ocr-models/*`（模型随包，弱网友好） |
| image_picker 配置 | ✅ 已内置 | `res/xml/flutter_image_picker_file_paths.xml` + `play-services-mlkit-text-recognition*.properties` 均在 APK 内 |
| `adb install -r` 到真机 | ✅ 成功 | 设备 `10AG1D28SB00A6Q`（V2458A, Android 16）`Performing Streamed Install / Success` |
| App 启动无崩溃 | ✅ 无 FATAL | logcat 无 `AndroidRuntime`/`FATAL`/原生库缺失；进程正常 JIT/GC，仅其它系统进程无关的多播 ENETUNREACH |
| 文件行数硬规 ≤250 | ✅ 合规 | scan 弹窗 168 / 手动表单 ~183 / OCR 服务 140（均在修订后重新统计） |

## 八、需你手动验收项（真机点选，命令行无法模拟相机/相册 UI）

请在真机上依次验收，对应上面第二～五节：

1. 进入「添加卡牌」→ 点「扫码识别录入」：弹窗顶部 Segment 可切「拍照 OCR / 条码扫码」，选中态为香槟金。
2. 切到「拍照 OCR」→ 点「拍照识卡」：弹出系统相机，拍一张评级卡（含 PSA/BGS/CGC 字样与分数）；或点「从相册选择」选一张卡图。
3. 观察黑金四角框 + 金线扫描动画 → 识别中转圈 → ✓「识别成功：PSA 10 初版喷火龙」类摘要。
4. 自动跳转手动录入：被识别字段带香槟金「AI 识别」小标签，标题区显示「AI 识别已自动填充」金 pill；卡图预览为实拍照片。
5. 点确认入库 → 返回主页网格，新卡封面为**本地实拍照片**（非网络占位），点开大图预览同为该本地图。
6. 「条码扫码」模式点「模拟扫描识别」→ 同样回填并入库（历史模拟行为）。
7. 首次使用相机/相册权限弹窗正常，不闪退。

> 若第 2~5 步识别不到字段：多为卡面文字不清或 ML Kit 模型仍在下载（首启联网一次）。可重试或选更清晰的卡图；照片仍会作为封面入库。
