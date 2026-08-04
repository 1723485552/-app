#!/usr/bin/env python3
"""Generate 软著登记 materials: source code PDF + design doc PDF."""

import os
import glob
import textwrap
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Preformatted
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

PROJECT = r"C:\kapai\card_management"
OUTPUT_DIR = r"C:\kapai\card_management\soft_copyright"
os.makedirs(OUTPUT_DIR, exist_ok=True)

LINES_PER_PAGE = 50  # ~50 lines per page for source code

# --- Try to register a Chinese-capable font ---
FONT_PATHS = [
    r"C:\Windows\Fonts\msyh.ttc",      # Microsoft YaHei
    r"C:\Windows\Fonts\simhei.ttf",     # SimHei
    r"C:\Windows\Fonts\simsun.ttc",     # SimSun
]
FONT_NAME = "ChineseFont"
for fp in FONT_PATHS:
    if os.path.exists(fp):
        try:
            pdfmetrics.registerFont(TTFont(FONT_NAME, fp, subfontIndex=0 if fp.endswith('.ttc') else -1))
            break
        except Exception:
            continue


def collect_dart_sources():
    """Collect all non-generated .dart files with their content."""
    files = []
    for root, dirs, fnames in os.walk(os.path.join(PROJECT, "lib")):
        dirs[:] = [d for d in dirs if d not in ("build", ".dart_tool")]
        for f in sorted(fnames):
            if f.endswith(".dart") and not f.endswith(".g.dart") and not f.endswith(".freezed.dart"):
                path = os.path.join(root, f)
                try:
                    with open(path, "r", encoding="utf-8") as fh:
                        content = fh.read()
                    rel = os.path.relpath(path, PROJECT)
                    files.append((rel, content))
                except Exception:
                    pass
    return files


def make_source_pdf():
    """Generate 程序鉴别材料: first 30 pages + last 30 pages of source code."""
    sources = collect_dart_sources()
    all_lines = []
    for rel, content in sources:
        all_lines.append(f"// ===== {rel} =====")
        all_lines.extend(content.splitlines())
        all_lines.append("")  # blank line between files

    total_lines = len(all_lines)
    page_count_30 = 30 * LINES_PER_PAGE  # 1500 lines

    front_lines = all_lines[:page_count_30]
    back_lines = all_lines[-page_count_30:] if total_lines > page_count_30 else []

    out_path = os.path.join(OUTPUT_DIR, "程序鉴别材料_源代码前后各30页.pdf")
    doc = SimpleDocTemplate(out_path, pagesize=A4,
                            leftMargin=15*mm, rightMargin=15*mm,
                            topMargin=15*mm, bottomMargin=15*mm)

    styles = getSampleStyleSheet()
    code_style = ParagraphStyle(
        "Code",
        fontName="Courier",
        fontSize=7.5,
        leading=9.5,
        wordWrap="CJK",
    )
    title_style = ParagraphStyle(
        "TitleCN",
        fontName=FONT_NAME,
        fontSize=14,
        leading=20,
        alignment=1,  # center
        spaceAfter=10,
    )

    elements = []

    # Title page
    elements.append(Spacer(1, 80*mm))
    elements.append(Paragraph("程序鉴别材料", title_style))
    elements.append(Paragraph("（源代码前30页连续页 + 后30页连续页）", ParagraphStyle(
        "SubTitle", fontName=FONT_NAME, fontSize=10, leading=16, alignment=1)))
    elements.append(Spacer(1, 20*mm))
    elements.append(Paragraph(f"软件名称：卡牌收藏管理 App (Card Management)", ParagraphStyle(
        "Info", fontName=FONT_NAME, fontSize=10, leading=16, alignment=1)))
    elements.append(Paragraph(f"编程语言：Dart / Flutter", ParagraphStyle(
        "Info2", fontName=FONT_NAME, fontSize=10, leading=16, alignment=1)))
    elements.append(Paragraph(f"源程序总行数：{total_lines} 行（不含生成代码）", ParagraphStyle(
        "Info3", fontName=FONT_NAME, fontSize=10, leading=16, alignment=1)))
    elements.append(PageBreak())

    # First 30 pages
    elements.append(Paragraph("━━━ 第一部分：源代码前 30 页（第 1～1500 行） ━━━", ParagraphStyle(
        "PartTitle", fontName=FONT_NAME, fontSize=11, leading=18, spaceAfter=8)))
    elements.append(Spacer(1, 3*mm))

    for i, line in enumerate(front_lines, 1):
        # Escape XML special chars
        safe = line.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        # Truncate very long lines
        if len(safe) > 110:
            safe = safe[:107] + "..."
        numbered = f"{i:5d}  {safe}"
        elements.append(Paragraph(numbered, code_style))

    elements.append(PageBreak())

    # Last 30 pages
    start_back = total_lines - page_count_30 + 1
    elements.append(Paragraph(
        f"━━━ 第二部分：源代码后 30 页（第 {start_back}～{total_lines} 行） ━━━",
        ParagraphStyle("PartTitle2", fontName=FONT_NAME, fontSize=11, leading=18, spaceAfter=8)))
    elements.append(Spacer(1, 3*mm))

    for i, line in enumerate(back_lines, start=start_back):
        safe = line.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        if len(safe) > 110:
            safe = safe[:107] + "..."
        numbered = f"{i:5d}  {safe}"
        elements.append(Paragraph(numbered, code_style))

    doc.build(elements)
    print(f"[OK] Source code PDF -> {out_path}")
    return out_path


def make_design_doc_pdf():
    """Generate 文档鉴别材料: design document (设计说明书) 前30页+后30页."""
    out_path = os.path.join(OUTPUT_DIR, "文档鉴别材料_设计说明书前后各30页.pdf")
    doc = SimpleDocTemplate(out_path, pagesize=A4,
                            leftMargin=20*mm, rightMargin=20*mm,
                            topMargin=20*mm, bottomMargin=20*mm)

    styles = getSampleStyleSheet()

    h1 = ParagraphStyle("H1", fontName=FONT_NAME, fontSize=16, leading=26,
                        spaceBefore=16, spaceAfter=8, textColor="#1a1a2e")
    h2 = ParagraphStyle("H2", fontName=FONT_NAME, fontSize=13, leading=22,
                        spaceBefore=12, spaceAfter=6, textColor="#16213e")
    h3 = ParagraphStyle("H3", fontName=FONT_NAME, fontSize=11, leading=18,
                        spaceBefore=8, spaceAfter=4, textColor="#0f3460")
    body = ParagraphStyle("Body", fontName=FONT_NAME, fontSize=10, leading=18,
                          spaceBefore=3, spaceAfter=3, firstLineIndent=20)
    body_no_indent = ParagraphStyle("BodyNI", fontName=FONT_NAME, fontSize=10,
                                    leading=18, spaceBefore=2, spaceAfter=2)
    code_inline = ParagraphStyle("CodeInline", fontName="Courier", fontSize=8.5,
                                 leading=13, leftIndent=15, backColor="#f5f5f5",
                                 spaceBefore=4, spaceAfter=4)
    bullet = ParagraphStyle("Bullet", fontName=FONT_NAME, fontSize=10, leading=17,
                            leftIndent=20, bulletIndent=8)

    P = lambda text, style=body: Paragraph(text, style)

    elements = []

    # ========== COVER PAGE ==========
    elements.append(Spacer(1, 70*mm))
    elements.append(Paragraph("文档鉴别材料", ParagraphStyle(
        "CoverMain", fontName=FONT_NAME, fontSize=22, leading=32, alignment=1,
        textColor="#1a1a2e")))
    elements.append(Spacer(1, 10*mm))
    elements.append(Paragraph("《卡牌收藏管理 App 设计说明书》", ParagraphStyle(
        "CoverSub", fontName=FONT_NAME, fontSize=16, leading=24, alignment=1,
        textColor="#16213e")))
    elements.append(Spacer(1, 25*mm))
    cover_info = [
        "软件全称：卡牌收藏管理 App（Card Management）",
        "软件简称：Card Management",
        "版本号：V1.0.0",
        "开发语言：Dart（Flutter 框架）",
        "运行平台：Android / Web / iOS（跨平台）",
        "开发工具：Flutter SDK 3.44.4 / Dart 3.12.2",
    ]
    for info in cover_info:
        elements.append(Paragraph(info, ParagraphStyle(
            "CoverInfo", fontName=FONT_NAME, fontSize=11, leading=20, alignment=1)))
    elements.append(PageBreak())

    # ========== TABLE OF CONTENTS ==========
    elements.append(Paragraph("目  录", h1))
    elements.append(Spacer(1, 6*mm))
    toc_items = [
        "一、软件概述 .......................................... 3",
        "二、需求分析 .......................................... 4",
        "三、总体设计 .......................................... 6",
        "四、数据模型设计 ....................................... 9",
        "五、功能模块详细设计 ................................. 12",
        "　5.1 卡片管理模块 ................................... 12",
        "　5.2 图鉴中心模块 ................................... 15",
        "　5.3 市场行情模块 ................................... 18",
        "　5.4 云端备份模块 ................................... 21",
        "　5.5 居中度测量工具 ................................. 23",
        "六、界面设计规范 ..................................... 25",
        "七、接口设计 ......................................... 27",
        "八、测试与验收 ....................................... 29",
        "九、附录：文件结构图 ................................. 31",
    ]
    for item in toc_items:
        elements.append(Paragraph(item, body_no_indent))
    elements.append(PageBreak())

    # ========== CHAPTER 1 ==========
    elements.append(Paragraph("一、软件概述", h1))

    elements.append(Paragraph("1.1 项目背景", h2))
    elements.append(P("""随着集卡文化（Trading Card Game / 体育球星卡）的蓬勃发展，收藏者需要一款专业化的数字管理工具来记录、整理和追踪自己的藏品。目前市场上的通用型笔记或表格应用无法满足卡牌收藏领域的特殊需求——如品相评级（PSA/BGS）、居中度测量、多平台成交价对比、图鉴对照等。本项目旨在填补这一空白。"""))

    elements.append(Paragraph("1.2 软件目标", h2))
    elements.append(P("""本软件「卡牌收藏管理 App」是一款面向卡牌收藏爱好者的跨平台移动应用，核心目标包括："""))
    goals = [
        "提供完整的卡片 CRUD 管理（增删改查），支持拍照/选图录入封面；",
        "建立全品类图鉴数据库，覆盖 TCG（宝可梦/游戏王/万智牌）与体育球星卡（NBA/足球）；",
        "集成国内外双引擎市场行情系统，自动折算人民币价格并展示走势图表；",
        "提供交互式居中度测量工具，辅助品相评估；",
        "支持云端备份与恢复，保障数据安全。",
    ]
    for g in goals:
        elements.append(Paragraph(f"• {g}", bullet))

    elements.append(Paragraph("1.3 运行环境", h2))
    env_items = [
        "操作系统：Android 6.0+ / iOS 14.0+ / Web 浏览器（Chrome/Firefox/Safari）",
        "运行时依赖：Isar 本地数据库（原生）/ 内存存储（Web）、Riverpod 状态管理框架",
        "网络要求：在线功能（图鉴查询、行情获取、云端备份）需互联网连接；离线模式下本地功能正常可用",
        "硬件要求：Android 设备需摄像头权限（用于 OCR 识别与拍照）；建议 RAM ≥ 2GB",
    ]
    for e in env_items:
        elements.append(Paragraph(f"• {e}", bullet))

    elements.append(Paragraph("1.4 技术栈概览", h2))
    tech_table = """
    <b>技术层</b>　　　<b>选用方案</b>　　　　　　<b>版本</b><br/>
    UI 框架　　　　Flutter（跨平台）　　　3.44.4<br/>
    编程语言　　　 Dart　　　　　　　　　 3.12.2<br/>
    本地数据库 　　Isar NoSQL　　　　　　 3.1.0+1<br/>
    状态管理　　　 Riverpod　　　　　　　 2.6.1<br/>
    网络请求　　　 http + 自封装 NetworkService<br/>
    图表库　　　　fl_chart　　　　　　　 0.68.0<br/>
    云端服务　　　 Supabase（备份恢复）　 2.16.0<br/>
    图片识别　　　 Google ML Kit Text Recognition<br/>
    文件选择　　　 file_picker　　　　　 11.0.2<br/>
    URL 跳转　　　 url_launcher　　　　　 6.3.0<br/>
    """
    elements.append(Paragraph(tech_table, code_inline))

    # ========== CHAPTER 2 ==========
    elements.append(Paragraph("二、需求分析", h1))

    elements.append(Paragraph("2.1 功能性需求", h2))

    elements.append(Paragraph("【F01】卡片基础管理", h3))
    elements.append(P("""用户应能够创建、编辑、删除卡片条目。每张卡片包含以下信息字段：名称、分类（TCG 各子类/体育卡各子类）、购买价格、出售价格、估值、货币单位（CNY/USD/EUR 等）、购买日期、品相评级（PSA/BGS/裸卡等）、备注、封面图片。支持按分类筛选、关键词搜索、排序。"""))

    elements.append(Paragraph("【F02】OCR 自动识别", h3))
    elements.append(P("""用户可通过相机拍摄或从相册选取卡片图片，系统调用 Google ML Kit 文字识别引擎自动提取文字内容，辅助填充卡片名称、编号等信息，减少手动输入工作量。"""))

    elements.append(Paragraph("【F03】全品类图鉴中心", h3))
    elements.append(P("""提供标准化的卡牌图鉴浏览功能，覆盖以下品类：宝可梦 TCG（Pokémon Trading Card Game）、游戏王 Yu-Gi-Oh!、万智牌 Magic: The Gathering、NBA 球星卡、足球球星卡。用户可按分类 Tab 切换浏览，支持按卡名/卡号/球员名/系列名实时搜索。点击图鉴卡片查看高清大图及属性详情，并可一键将图鉴条目加入个人收藏库。"""))

    elements.append(Paragraph("【F04】国内外双引擎行情", h3))
    elements.append(P("""在卡片详情页面展示该卡的市场成交行情。分为国内平台（集换社、闲鱼）和国外平台（eBay、130point、TCGplayer）两个 Tab。展示近 30 天 / 90 天的价格走势曲线图（基于 fl_chart），以及成交明细列表（含平台图标、品相等级、成交时间、原始币种价格、自动折算后的人民币价格）。支持点击跳转到原始成交链接。"""))

    elements.append(Paragraph("【F05】居中度测量工具", h3))
    elements.append(P("""提供交互式卡片图像居中度测量功能。用户上传或选择卡片正面照片后，在 InteractiveViewer 中通过拖动四边锚点标记卡边位置，系统实时计算左/右/上/下四边的居中百分比偏差，并根据 PSA 标准给出评级（Gem Mint / Mint / Off-Center）。测量结果格式化保存至卡片记录。"""))

    elements.append(Paragraph("【F06】云端备份与恢复", h3))
    elements.append(P("""基于 Supabase Storage 实现数据的云端备份与恢复功能。备份时生成 Isar 数据库只读快照文件并加密上传至用户专属存储桶；恢复时下载校验完整性后替换本地数据库，失败时自动回滚至旧版本。当前版本因无登录体系，采用 'local-user' 兜底标识，后续可对接真实用户认证系统。"""))

    elements.append(Paragraph("2.2 非功能性需求", h2))
    nfr = [
        "<b>性能</b>：首页加载时间 ≤ 1 秒；搜索响应 ≤ 300ms；列表滚动帧率 ≥ 55fps",
        "<b>兼容性</b>：支持 Android 6.0+ 和现代 Web 浏览器；适配不同屏幕尺寸（手机/平板）",
        "<b>安全性</b>：敏感操作（如云端恢复）需二次确认；API Key 通过 dart-define 注入而非硬编码",
        "<b>可维护性</b>：单文件不超过 250 行代码；flutter analyze 零 Error/零 Warning；遵循分层架构",
        "<b>离线能力</b>：核心 CRUD 功能完全离线可用；图鉴/行情等在线功能优雅降级为空状态提示",
    ]
    for n in nfr:
        elements.append(Paragraph(f"• {n}", bullet))

    # ========== CHAPTER 3 ==========
    elements.append(Paragraph("三、总体设计", h1))

    elements.append(Paragraph("3.1 架构模式", h2))
    elements.append(P("""本软件采用经典的**分层架构（Layered Architecture）**结合 **Clean Architecture** 思想进行组织。整体架构自上而下分为四个层次："""))

    arch_layers = """
    <b>┌─────────────────────────────────────────┐</b><br/>
    <b>│  Presentation Layer（表现层）           │</b><br/>
    <b>│  Pages / Widgets / Providers(Riverpod) │</b><br/>
    <b>├─────────────────────────────────────────┤</b><br/>
    <b>│  Domain Layer（领域层）                 │</b><br/>
    <b>│  Services / Repositories(抽象接口)     │</b><br/>
    <b>│  Enums / Utils / Calculators            │</b><br/>
    <b>├─────────────────────────────────────────┤</b><br/>
    <b>│  Data Layer（数据层）                   │</b><br/>
    <b>│  Models / Datasources / Adapters       │</b><br/>
    <b>├─────────────────────────────────────────┤</b><br/>
    <b>│  Core Layer（基础设施层）               │</b><br/>
    <b>│  Theme / Network / Widgets / Utils      │</b><br/>
    <b>└─────────────────────────────────────────┘</b>
    """
    elements.append(Paragraph(arch_layers, code_inline))

    elements.append(Paragraph("3.2 目录结构", h2))
    dir_struct = """
    lib/<br/>
    ├── main.dart                          // 应用入口<br/>
    ├── core/                             // 基础设施层<br/>
    │   ├── theme/                        // 黑金主题系统(AppColors)<br/>
    │   ├── network/                      // 网络请求层(ApiResponse/NetworkService)<br/>
    │   ├── utils/                        // 工具类(CurrencyFormatter)<br/>
    │   └── widgets/                      // 通用UI组件(GoldSnackBar/GoldStatTile)<br/>
    ├── features/card_management/         // 主业务域：卡片管理<br/>
    │   ├── data/models/                  // Isar数据模型(CardItem)<br/>
    │   ├── domain/repositories/          // 仓库抽象接口+Provider<br/>
    │   ├── domain/services/              // 行情服务等<br/>
    │   ├── domain/enums/                 // 枚举(分类/货币)<br/>
    │   ├── presentation/pages/           // 页面(主页/详情/设置)<br/>
    │   ├── presentation/widgets/         // 业务组件(大图/封面/导航)<br/>
    │   └── presentation/providers/       // Riverpod状态管理<br/>
    ├── features/card_catalog/            // 图鉴中心模块<br/>
    │   ├── domain/models/                // CatalogItem统一模型<br/>
    │   ├── domain/enums/                 // CatalogCategory枚举<br/>
    │   ├── domain/repositories/          // ICatalogAdapter接口<br/>
    │   ├── domain/services/              // CatalogService路由<br/>
    │   ├── data/adapters/                // TCG/Sports适配器<br/>
    │   └── presentation/                 // UI(中心页/卡片/详情浮层)<br/>
    ├── features/market_price/            // 市场行情模块<br/>
    │   ├── domain/models/                // PriceCompItem成交记录<br/>
    │   ├── domain/repositories/          // IPriceAdapter接口<br/>
    │   ├── domain/services/              // CurrencyService/PriceService<br/>
    │   ├── data/adapters/                // Domestic/Foreign适配器<br/>
    │   └── presentation/                 // UI(行情Widget/走势图/明细)<br/>
    └── services/                         // 全局服务<br/>
        └── cloud_sync_service.dart       // Supabase云端备份恢复<br/>
    """
    elements.append(Paragraph(dir_struct, code_inline))

    elements.append(Paragraph("3.3 状态管理方案", h2))
    elements.append(P("""采用 **Riverpod 2.6.1** 作为全局状态管理方案。选择理由如下："""))
    riverpod_reasons = [
        "编译时安全：Provider 的依赖关系在编译期确定，避免运行时 Context 丢失异常",
        "可测试性：不依赖 BuildContext，可在纯 Dart 环境中进行单元测试",
        "自动销毁：当 Provider 不再被监听时自动释放资源，防止内存泄漏",
        "与 Isar 配合良好：Repository Provider 可安全持有 Isar 实例引用",
    ]
    for r in riverpod_reasons:
        elements.append(Paragraph(f"• {r}", bullet))

    elements.append(Paragraph("3.4 数据流示意", h2))
    elements.append(P("""用户操作 → UI Widget 触发 Riverpod Provider → 调用 Domain Service / Repository 抽象接口 → Data 层 Datasource 执行具体逻辑（Isar 写入 / HTTP 请求 / 适配器转换）→ 结果经 Provider 向上传播 → UI 自动重建渲染。对于 Isar 数据变更通知，由于 Isar 无内置 Watch API，采用 StreamController.broadcast() 模式：每次写操作完成后调用 _emit() 通知监听者刷新。"""))

    # ========== CHAPTER 4 ==========
    elements.append(Paragraph("四、数据模型设计", h1))

    elements.append(Paragraph("4.1 核心实体：CardItem（卡片条目）", h2))
    carditem_fields = """
    <b>字段名</b>　　　<b>类型</b>　　　　<b>说明</b><br/>
    id　　　　　　 Id　　　　　　Isar自增主键<br/>
    name　　　　　 String　　　　卡片名称（必填，默认空串）<br/>
    category　　　 CardCategory 枚举　分类（tcg_pokemon/yugioh/mtg/sports_nba/soccer/other）<br/>
    purchasePrice double?　　　 购买价格<br/>
    sellPrice　　 double?　　　 出售价格<br/>
    estimatedValue double?　　 估值<br/>
    currencyUnit　 CurrencyUnit 枚举　货币单位（CNY/USD/EUR等）<br/>
    purchaseDate DateTime?　　购买日期<br/>
    conditionGrade String?　　 品相评级（PSA 10 / BGS 9.5 / Raw等）<br/>
    notes　　　　 String?　　　 备注<br/>
    coverImagePath String?　　 封面图片路径<br/>
    centeringResult String?　　居中度测量结果（格式化字符串）<br/>
    createdAt　　 DateTime　　 创建时间（自动）<br/>
    updatedAt　　 DateTime　　 更新时间（自动）<br/>
    """
    elements.append(Paragraph(carditem_fields, code_inline))

    elements.append(Paragraph("4.2 图鉴实体：CatalogItem", h2))
    catalog_fields = """
    <b>字段名</b>　　　<b>类型</b>　　　　　　<b>说明</b><br/>
    id　　　　　　 String　　　　　　唯一标识<br/>
    name　　　　　 String　　　　　　卡牌/球员名称<br/>
    category　　　 CatalogCategory　 图鉴分类<br/>
    set_　　　　　 String?　　　　　 所属系列<br/>
    cardNumber　　String?　　　　　 卡号<br/>
    imageUrl　　　 String?　　　　　 高清图片URL<br/>
    rarity　　　　 String?　　　　　 稀有度<br/>
    releaseYear　 int?　　　　　　　发行年份<br/>
    extraFields　 Map&lt;String,dynamic&gt;?　扩展属性（球员/球队/编数等）<br/>
    """
    elements.append(Paragraph(catalog_fields, code_inline))

    elements.append(Paragraph("4.3 行情实体：PriceCompItem", h2))
    price_fields = """
    <b>字段名</b>　　　<b>类型</b>　　　<b>说明</b><br/>
    id　　　　　　 String　　　唯一标识<br/>
    platformName　 String　　　平台名称（集换社/闲鱼/eBay/130point/TCGplayer）<br/>
    isDomestic　　bool　　　　是否国内平台<br/>
    price　　　　 double　　　成交价格<br/>
    currency　　　 String　　　币种（CNY/USD）<br/>
    priceInRmb　　double　　　折算后人民币价格<br/>
    conditionGrade String　　 品相等级<br/>
    soldDate　　　DateTime　　成交时间<br/>
    sourceUrl　　 String?　　 原始链接<br/>
    """
    elements.append(Paragraph(price_fields, code_inline))

    elements.append(Paragraph("4.4 存储策略", h2))
    elements.append(P("""<b>CardItem</b> 使用 Isar NoSQL 数据库持久化，通过 @Collection 注解自动生成适配器代码（build_runner）。支持原生（Android/iOS）和 Web 双端：原生端使用 Isar native 引擎，Web 端因浏览器限制降级为内存 Map 存储，通过条件导出（conditional export）实现平台无关的 Repository 接口。<br/><br/><b>CatalogItem</b> 和 <b>PriceCompItem</b> 为纯 Dart 运行时模型，不参与 Isar 持久化，数据来自外部 API 或示例样本，由 Riverpod Provider 在内存中管理生命周期。"""))

    # ========== CHAPTER 5 ==========
    elements.append(Paragraph("五、功能模块详细设计", h1))

    elements.append(Paragraph("5.1 卡片管理模块", h2))
    elements.append(Paragraph("5.1.1 主页面（MainScreen）", h3))
    elements.append(P("""主屏幕采用底部标签栏导航（LuxuryBottomNav），包含三个 Tab：「攒卡」（卡片列表/网格视图切换）、「统计」（资产汇总/分类饼图）、「我的」（设置/备份）。顶部 AppBar 展示应用标题和「全图鉴」快捷入口按钮。使用 IndexedStack 保持各 Tab 状态不被销毁。"""))

    elements.append(Paragraph("5.1.2 卡片列表（CardCollectionPage）", h3))
    elements.append(P("""支持列表/网格双视图切换。列表视图每行显示封面缩略图、名称、分类 Chip、估值金额；网格视图以卡片形式排列。顶部提供分类筛选下拉框和搜索框（实时过滤）。空状态时显示 EmptyStatePlaceholder 占位组件。长按卡片弹出操作菜单（编辑/删除）。底部悬浮添加按钮（FAB）触发新建流程。"""))

    elements.append(Paragraph("5.1.3 卡片详情（CardDetailLightbox）", h3))
    elements.append(P("""点击卡片进入全屏详情浮层（Lightbox 模式），展示：封面大图（支持手势缩放）、基本信息栏（名称/分类/价格/品相/日期/备注）、操作按钮组（编辑/删除/居中度测量/成交行情）。底部可滑动查看完整备注内容。关闭动画采用渐隐+缩放组合效果。"""))

    elements.append(Paragraph("5.1.4 新建/编辑表单", h3))
    elements.append(P("""表单字段包括：名称（TextField 必填）、分类（DropdownButtonFormField）、购买/出售/估值（TextField 数字键盘）、货币单位（SegmentedButton）、日期（DatePicker）、品相评级（TextField + 常用选项快捷 Chip）、备注（多行 TextField）、封面图片（相机拍照/相册选择/OCR 识别三路入口）。所有字段变更实时预览，保存前做非空校验。"""))

    elements.append(Paragraph("5.2 图鉴中心模块", h2))
    elements.append(Paragraph("5.2.1 图鉴中心页（CatalogCenterPage）", h3))
    elements.append(P("""顶部分类 Tab 栏横向滚动，包含：全部、宝可梦、游戏王、万智牌、NBA、足球。每个 Tab 对应一个 CatalogCategory 枚举值。搜索框位于 Tab 栏下方，支持模糊匹配卡名/卡号/球员/系列名。主体区域为 GridView（2 列布局），每个图鉴项使用 CatalogCardTile 组件渲染：圆角封面图 + 名称 + 分类标签 + 稀有度。<br/><br/>页面维护三种状态：<b>loading</b>（骨架屏 shimmer 效果）、<b>error</b>（错误提示 + 重试按钮）、<b>empty</b>（空状态插图 + 引导文字）。数据由 catalogServiceProvider 通过 CatalogService 从对应 Adapter 获取。"""))

    elements.append(Paragraph("5.2.2 图鉴详情浮层（CatalogDetailSheet）", h3))
    elements.append(P("""点击图鉴卡片从底部滑出详情面板（DraggableScrollableSheet），展示：高清大图（NetworkImage 加载，带渐入动画）、属性参数列表（系列/卡号/稀有度/发行年份/扩展字段）、底部固定操作栏「一键加入我的收藏」。点击收藏按钮时，将 CatalogItem 映射转换为 CardItem 对象（填充名称、封面 URL、分类），调用 cardRepositoryProvider 写入本地 Isar 数据库，成功后 GoldSnackBar 提示并关闭浮层。"""))

    elements.append(Paragraph("5.2.3 适配器设计（ICatalogAdapter）", h3))
    elements.append(P("""ICatalogAdapter 定义统一搜索接口 search(category, query)。两个实现类：<br/>• <b>TcgCatalogAdapter</b>：处理 TCG 类别（宝可梦/游戏王/万智牌），预留 PokémonTCG.io、Scryfall、YGOProDeck 等真实 API 端点。<br/>• <b>SportsCatalogAdapter</b>：处理体育球星卡类别（NBA/足球），预留 Panini、Topps、TCDB 等数据源。<br/>CatalogService 根据 category.isSports 标志路由到对应适配器。当前因无外部 API 凭证，useSampleData=true 时返回结构化示例数据（UI 标注「示例数据」角标）。"""))

    elements.append(Paragraph("5.3 市场行情模块", h2))
    elements.append(Paragraph("5.3.1 行情 Widget（MarketPriceWidget）", h3))
    elements.append(P("""嵌入卡片详情页的行情组件。顶部为 SegmentedButton 切换「国内成交」与「国外成交」两个 Tab。<br/><br/><b>国内 Tab</b>：展示 DomesticPriceAdapter 返回的数据（集换社/闲鱼平台成交记录）。<br/><b>国外 Tab</b>：展示 ForeignPriceAdapter 返回的数据（eBay/130point/TCGplayer 成交记录），价格经 CurrencyService 自动折算为人民币。<br/><br/>每个 Tab 内部上方为 PriceTrendChartCard（fl_chart LineChart，支持 30天/90天 切换），下方为 PriceSalesList 成交明细列表（平台图标 + 品相 + 时间 + 原价 + CNY 折算价 + 点击跳转原文）。"""))

    elements.append(Paragraph("5.3.2 价格趋势图（PriceTrendChartCard）", h3))
    elements.append(P("""基于 fl_chart 0.68.0 的 LineChart 实现。X 轴为日期标签，Y 轴为价格刻度。数据点之间平滑曲线连接（curves: Curves.easeInOut）。悬停/触摸显示 Tooltip（日期 + 价格）。支持 30 天 / 90 天 时间范围切换。配色沿用黑金主题：线条 goldPrimary 色，网格线半透明金色，背景深色。无数据时显示空状态占位。"""))

    elements.append(Paragraph("5.3.3 汇率服务（CurrencyService）", h3))
    elements.append(P("""CurrencyService 提供 USD → CNY 汇率换算能力。设计为可缓存模式：优先使用缓存汇率（有效期 24 小时），过期后从远程汇率 API 获取最新汇率。折算公式：priceInRmb = price × exchangeRate。当前版本因无汇率 API Key，使用固定参考汇率（USD/CNY ≈ 7.25），生产环境应接入实时汇率源。"""))

    elements.append(Paragraph("5.4 云端备份模块", h2))
    elements.append(Paragraph("5.4.1 CloudSyncService 设计", h3))
    elements.append(P("""CloudSyncService 是备份恢复的核心服务类，两个公开方法：<br/><br/><b>uploadBackup()</b> 流程：<br/>1. ensureSupabaseInitialized() — 检查/初始化 Supabase 客户端（重复调用自动跳过）；<br/>2. Isar.getInstance().copyToFile(tempPath) — 生成数据库只读快照；<br/>3. Supabase.instance.client.storage.from('user-backups').upload() — 上传至用户路径；<br/>4. finally 块清理临时文件。<br/><br/><b>restoreBackup()</b> 流程：<br/>1. storage.download() — 下载备份文件；<br/>2. 校验文件大小 > 0；<br/>3. 将现有 default.isar 重命名为 default.isar.old（回滚备份）；<br/>4. 写入下载文件为新的 default.isar；<br/>5. 验证新库可打开，失败则恢复 .old 文件。<br/><br/>kIsWeb 平台直接抛出不支持异常（Web 端 copyToFile 不可用）。"""))

    elements.append(Paragraph("5.4.2 用户界面集成", h3))
    elements.append(P("""在 ProfilePage（「我的」页面）末尾追加「数据云端备份」卡片区域。包含两个操作按钮：<br/>• 「立即备份」→ 调用 uploadBackup() → 成功后 GoldSnackBar Toast 提示「备份已完成」；<br/>• 「从云端恢复」→ 弹出 AlertDialog 二次确认（警告⚠️将覆盖本地数据）→ 用户确认后执行 restoreBackup()。<br/><br/>凭证注入方式：通过 flutter build/run 的 --dart-define 参数传入 SUPABASE_URL 和 SUPABASE_ANON_KEY，运行时通过 StringFromEnvironment 读取，缺失时抛 CloudBackupConfigException。"""))

    elements.append(Paragraph("5.5 居中度测量工具", h2))
    elements.append(Paragraph("5.5.1 测量页面（CenteringMeasurementPage）", h3))
    elements.append(P("""交互式居中度测量工具页面。核心布局为 Stack + InteractiveViewer（支持捏合缩放平移卡片图片）。图片上叠加 CustomPainter 绘制的外框、内框和四条辅助引导线。四边各有一个圆形拖拽锚点（EdgeHandle），用户拖动锚点定位卡边位置。<br/><br/>技术要点：<br/>• 使用 Listener + GestureDetector 监听拖拽事件，拖拽期间禁用 InteractiveViewer 的 pan 手势（避免冲突）；<br/>• LayoutBuilder 获取实际像素尺寸，将归一化坐标（0.0~1.0）转换为屏幕像素坐标；<br/>• 四个锚点的归一化坐标实时传给 CenteringCalculator 计算居中百分比。"""))

    elements.append(Paragraph("5.5.2 计算引擎（CenteringCalculator）", h3))
    elements.append(P("""纯数学计算模块，输入四边距（left, right, top, bottom，均为 0~100 的百分比值），输出 CenteringEvaluation 对象：<br/>• leftPct / rightPct：水平方向左右占比（理想值均接近 50%）<br/>• topPct / bottomPct：垂直方向上下占比<br/>• grade：居中评级（Gem Mint / Mint / Off-Center）<br/><br/>评级规则：取水平/垂直偏离度较大轴的 deviation 值 —— deviation ≤ 5% → Gem Mint（绿色，对应 PSA 10 标准）；5% < deviation ≤ 10% → Mint（黄色，PSA 9）；deviation > 10% → Off-Center（红色）。formatCentering() 方法输出格式化字符串如「L/R: 52/48 | T/B: 51/49」。"""))

    elements.append(Paragraph("5.5.3 结果面板与保存", h3))
    elements.append(P("""底部固定 CenteringResultPanel 面板，展示：四边百分比数值、居中评级 Chip（颜色随等级变化）、保存按钮。点击保存调用 ref.read(cardRepositoryProvider).updateCard() 将 formatCentering() 结果写入 CardItem.centeringResult 字段，持久化到 Isar 数据库。保存成功后 GoldSnackBar 提示并返回上一级页面，详情页信息栏即时显示测量结果。"""))

    # ========== CHAPTER 6 ==========
    elements.append(Paragraph("六、界面设计规范", h1))

    elements.append(Paragraph("6.1 设计语言：黑金主题系统", h2))
    elements.append(P("""本软件采用统一的「黑金奢华」视觉风格，所有颜色值定义在 AppColors 静态类中作为 Design Token："""))

    color_tokens = """
    <b>Token 名称</b>　　　<b>色值</b>　　　　<b>用途</b><br/>
    background　　　#121212　　　 页面/卡片背景（深黑）<br/>
    surface　　　　 #1E1E1E　　　 浮层/弹窗表面<br/>
    goldPrimary　　 #D4A853　　　 主金色（按钮/高亮/强调）<br/>
    goldBorder　　　#B8942F　　　 边框/分割线<br/>
    goldLight　　　 #F0D78C　　　 浅金（次要文字/禁用态）<br/>
    textWhite　　　 #FFFFFF　　　 主要文字<br/>
    textMuted　　　 #9E9E9E　　　 次要/提示文字<br/>
    successGreen　 #4CAF50　　　 成功/正向状态<br/>
    warningAmber　 #FFC107　　　 警告/中间态<br/>
    errorRed　　　 #F44336　　　 错误/危险/负向<br/>
    """
    elements.append(Paragraph(color_tokens, code_inline))

    elements.append(Paragraph("6.2 间距与排版", h2))
    spacing_rules = [
        "基础网格单元：8dp，所有间距为 8 的倍数（8/16/24/32dp）",
        "卡片圆角：12dp（小卡片）/ 16dp（大卡片/弹窗）",
        "内边距（Padding）：页面水平 16dp，卡片内部 16dp",
        "字体层级：标题 18sp(w600)/正文 14sp/辅助文字 12sp",
        "图标尺寸：导航栏 24dp / 行内操作 18dp / 大图标 48dp",
    ]
    for s in spacing_rules:
        elements.append(Paragraph(f"• {s}", bullet))

    elements.append(Paragraph("6.3 组件规范", h2))
    elements.append(P("""<b>LuxuryBottomNav</b>：自定义底部导航栏，选中态金色图标+文字渐变动画，未选中态灰色。使用 CustomPaint 绘制顶部弧形指示器。<br/><br/><b>GoldSnackBar</b>：全局 SnackBar 主题，深色背景+金色左边框+金色确认图标，3秒自动消失。<br/><br/><b>GoldStatTile</b>：统计数字卡片，大号金色数字+浅色标签文字，用于「统计」Tab 的资产汇总展示。<br/><br/><b>EmptyStatePlaceholder</b>：空状态占位组件，居中插图（Lottie/Icon）+ 标题+描述文字+操作按钮。"""))

    # ========== CHAPTER 7 ==========
    elements.append(Paragraph("七、接口设计", h1))

    elements.append(Paragraph("7.1 网络层架构", h2))
    elements.append(P("""自封装 NetworkService 基于 http 包实现，统一处理所有 HTTP 通信："""))
    net_features = [
        "baseUrl + authToken 可配置注入",
        "全局 8 秒超时（TimeoutException 捕获）",
        "状态码拦截：200-299 成功；401 未授权 / 404 未找到 / 500 服务器错误 分别映射为 failure 响应",
        "Web 安全：捕获 http.ClientException 及 SocketException 字符串匹配（避免 dart:io 导入破坏 Web 构建）",
        "泛型 ApiResponse<T> 包装：isSuccess / data / errorMessage / statusCode 四要素",
    ]
    for n in net_features:
        elements.append(Paragraph(f"• {n}", bullet))

    elements.append(Paragraph("7.2 外部 API 预留端点", h2))
    api_endpoints = """
    <b>数据源</b>　　　　<b>用途</b>　　　　　　<b>预留端点</b><br/>
    PokémonTCG.io　 宝可梦图鉴　　　 https://api.pokemontcg.io/v2/cards<br/>
    Scryfall　　　　万智牌图鉴　　　 https://api.scryfall.com/cards<br/>
    YGOProDeck　　 游戏王图鉴　　　 https://ygoprodeck.com/api/v7/cardinfo.php<br/>
    集换社 API　　 国内TCG行情　　 https://www.jiehuanshe.com/api<br/>
    eBay Finding　 国外成交记录　　 svcs.ebay.com/services/search/FindingService/v1<br/>
    130point　　　 国外球星卡行情 https://www.130point.com/api<br/>
    TCGplayer　　　国外TCG行情　　https://api.tcgplayer.com/catalog<br/>
    Supabase Stg　 云端备份存储　　用户自行部署实例<br/>
    汇率API　　　　USD/CNY换算　　开放汇率API / 央行数据<br/>
    """
    elements.append(Paragraph(api_endpoints, code_inline))

    elements.append(Paragraph("7.3 适配器接口定义", h2))
    adapter_iface = """
    <b>// ICatalogAdapter — 图鉴适配器接口</b><br/>
    Future&lt;List&lt;CatalogItem&gt;&gt; search(CatalogCategory category, String query);<br/><br/>
    <b>// IPriceAdapter — 价格适配器接口</b><br/>
    Future&lt;List&lt;PriceCompItem&gt;&gt; fetchPrices(String keyword, {String? condition});<br/>
    """
    elements.append(Paragraph(adapter_iface, code_inline))

    # ========== CHAPTER 8 ==========
    elements.append(Paragraph("八、测试与验收", h1))

    elements.append(Paragraph("8.1 静态分析", h2))
    elements.append(P("""项目配置 analysis_options.yaml 启用 package:flutter_lints/flutter.yaml 严格规则集。每次代码变更后必须执行 `flutter analyze` 并确保输出为：<br/><b>No issues found! (0 errors, 0 warnings, 0 infos)</b><br/><br/>不允许任何级别的问题进入代码库。常见自动修复项（prefer_const_constructors / unused_import / prefer_const_declarations）通过 `dart fix --apply` 一键处理。"""))

    elements.append(Paragraph("8.2 单文件行数限制", h2))
    elements.append(P(""" RULES.md 强制规定：单个 .dart 源文件不得超过 **250 行**（自动生成的 *.g.dart 适配器文件除外）。超出时必须拆分：提取子组件/子方法到独立文件、抽取公共逻辑到 utils/、使用 mixin/trait 组合行为。此约束保证代码可读性和可审查性。"""))

    elements.append(Paragraph("8.3 真机验证", h2))
    elements.append(P("""每次功能迭代后在真机（V2458A, Android 16）上进行完整验证：构建命令 `flutter build apk --debug --target-platform android-arm64`，安装命令 `adb install -r -g`（-g 自动授权新增权限），启动前 `am force-stop` 确保冷启动。验证清单包括：CRUD 全流程、图鉴搜索切换、行情 Tab 与图表渲染、居中度测量拖拽与保存、备份恢复 UI 触达（需凭证时验证 graceful degradation）。"""))

    elements.append(Paragraph("8.4 数据模型变更流程", h2))
    elements.append(P("""修改 Isar @Collection 模型后必须执行以下步骤：<br/>1. 新增字段加默认值 + Null Guard（防御旧数据迁移）；<br/>2. `flutter pub run build_runner build --delete-conflicting-outputs` 重新生成适配器；<br/>3. `flutter pub get` 同步依赖；<br/>4. 冷启动 App（真机上重装或清除数据）触发 Isar 自动 Schema 迁移；<br/>5. flutter analyze 确认 0/0/0。<br/><br/>跳过任一步骤可能导致运行时崩溃或数据丢失。"""))

    # ========== CHAPTER 9 ==========
    elements.append(Paragraph("九、附录：文件结构图", h1))

    elements.append(Paragraph("9.1 完整源文件清单", h2))
    # Get actual file list
    sources = collect_dart_sources()
    elements.append(P(f"共计 {len(sources)} 个 Dart 源文件（不含生成代码）："))
    file_list_lines = []
    for rel, _ in sources:
        file_list_lines.append(f"  • {rel}")
    elements.append(Paragraph("<br/>".join(file_list_lines), body_no_indent))

    elements.append(Paragraph("9.2 依赖声明（pubspec.yaml 核心依赖）", h2))
    deps_text = """
    flutter:<br/>
      sdk: flutter<br/>
    flutter_riverpod: ^2.6.1　　　　// 状态管理<br/>
    isar: ^3.1.0+1　　　　　　　　 // 本地NoSQL数据库<br/>
    isar_flutter_libs: ^3.1.0+1　　// Isar原生引擎<br/>
    provider: ^6.1.2　　　　　　　 // Riverpod兼容层<br/>
    http: ^1.2.0　　　　　　　　　 // 网络请求<br/>
    fl_chart: ^0.68.0　　　　　　　 // 价格走势图表<br/>
    image_picker: ^1.1.2　　　　　 // 相册/相机选图<br/>
    file_picker: ^11.0.2　　　　　 // 文件选择器<br/>
    google_mlkit_text_recognition: ^0.13.1　// OCR文字识别<br/>
    share_plus: ^12.0.2　　　　　　// 分享功能<br/>
    shared_preferences: ^2.3.2　　 // 轻量键值存储<br/>
    supabase_flutter: ^2.5.0　　　 // 云端备份服务<br/>
    url_launcher: ^6.3.0　　　　　 // 外链跳转<br/>
    """
    elements.append(Paragraph(deps_text, code_inline))

    elements.append(Paragraph("9.3 版本历史", h2))
    version_history = """
    <b>V1.0.0</b>（2026-08-03）初始版本发布<br/>
    　• 卡片 CRUD 管理 + OCR 识别<br/>
    　• 黑金主题系统 + 底部导航<br/>
    　• 统计页（资产汇总/分类饼图）<br/>
    　• 全品类图鉴中心（TCG + 体育球星卡）<br/>
    　• 国内外双引擎市场行情（fl_chart 走势图）<br/>
    　• 居中度交互式测量工具<br/>
    　• Supabase 云端备份与恢复<br/>
    　• 网络请求层封装（ApiResponse + NetworkService）<br/>
    """
    elements.append(Paragraph(version_history, body_no_indent))

    # ========== BUILD PDF ==========
    doc.build(elements)
    print(f"[OK] Design doc PDF -> {out_path}")
    return out_path


if __name__ == "__main__":
    src = make_source_pdf()
    doc = make_design_doc_pdf()
    print("\nDone! Both PDFs generated in:", OUTPUT_DIR)
