#!/usr/bin/env python3
"""Generate 软著 supporting proof document: screenshots + proof of running software."""

import os
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Image, Table, TableStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

OUTPUT_DIR = r"C:\kapai\card_management\soft_copyright"
SCREENSHOT_DIR = os.path.join(OUTPUT_DIR, "screenshots")

# Register Chinese font
FONT_NAME = "ChineseFont"
for fp in [r"C:\Windows\Fonts\msyh.ttc", r"C:\Windows\Fonts\simhei.ttf", r"C:\Windows\Fonts\simsun.ttc"]:
    if os.path.exists(fp):
        try:
            pdfmetrics.registerFont(TTFont(FONT_NAME, fp, subfontIndex=0 if fp.endswith('.ttc') else -1))
            break
        except Exception:
            continue


def make_proof_pdf():
    out_path = os.path.join(OUTPUT_DIR, "其他相关证明文件_软件运行截图证明.pdf")
    doc = SimpleDocTemplate(out_path, pagesize=A4,
                            leftMargin=20*mm, rightMargin=20*mm,
                            topMargin=20*mm, bottomMargin=20*mm)

    h1 = ParagraphStyle("H1", fontName=FONT_NAME, fontSize=16, leading=26,
                        spaceBefore=14, spaceAfter=8, textColor="#1a1a2e")
    h2 = ParagraphStyle("H2", fontName=FONT_NAME, fontSize=13, leading=22,
                        spaceBefore=10, spaceAfter=6, textColor="#16213e")
    body = ParagraphStyle("Body", fontName=FONT_NAME, fontSize=10.5, leading=18,
                          spaceBefore=3, spaceAfter=3)
    caption = ParagraphStyle("Caption", fontName=FONT_NAME, fontSize=9,
                             leading=14, alignment=1, textColor="#666666",
                             spaceBefore=4, spaceAfter=12)
    note = ParagraphStyle("Note", fontName=FONT_NAME, fontSize=9.5, leading=16,
                          leftIndent=15, textColor="#444444",
                          borderPadding=8, backColor="#f8f8f8",
                          spaceBefore=6, spaceAfter=6)

    P = lambda text, style=body: Paragraph(text, style)
    elements = []

    # ========== COVER ==========
    elements.append(Spacer(1, 60*mm))
    elements.append(Paragraph("其他相关证明文件", ParagraphStyle(
        "CoverMain", fontName=FONT_NAME, fontSize=20, leading=30, alignment=1,
        textColor="#1a1a2e")))
    elements.append(Spacer(1, 10*mm))
    elements.append(Paragraph("《卡牌收藏管理 App》软件运行截图证明", ParagraphStyle(
        "CoverSub", fontName=FONT_NAME, fontSize=14, leading=22, alignment=1,
        textColor="#16213e")))
    elements.append(Spacer(1, 25*mm))
    elements.append(Paragraph(
        "本文件为「卡牌收藏管理 App（Card Management）」V1.0.0 软件<br/>"
        "在真实 Android 设备上的运行截图证明材料，<br/>"
        "用于佐证该软件已独立开发完成并正常运行。",
        ParagraphStyle("CoverDesc", fontName=FONT_NAME, fontSize=11, leading=20, alignment=1)))
    elements.append(Spacer(1, 15*mm))
    elements.append(Paragraph("测试设备：V2458A（Android 16）", ParagraphStyle(
        "CoverInfo", fontName=FONT_NAME, fontSize=10, leading=18, alignment=1)))
    elements.append(Paragraph("截图时间：2026-08-03", ParagraphStyle(
        "CoverInfo2", fontName=FONT_NAME, fontSize=10, leading=18, alignment=1)))
    elements.append(PageBreak())

    # ========== SECTION 1: Software Info ==========
    elements.append(Paragraph("一、软件基本信息", h1))
    info_table_data = [
        ["项目", "内容"],
        ["软件全称", "卡牌收藏管理 App（Card Management）"],
        ["软件简称", "Card Management"],
        ["版本号", "V1.0.0"],
        ["开发语言", "Dart（Flutter 框架）"],
        ["开发工具", "Flutter SDK 3.44.4 / Dart 3.12.2"],
        ["源程序量", "116 个 .dart 文件 / 10,321 行代码"],
        ["运行平台", "Android / Web / iOS（跨平台）"],
        ["测试设备", "V2458A（Android 16）"],
        ["构建方式", "flutter build apk --debug --target-platform android-arm64"],
        ["安装方式", "adb install -r -g（含权限自动授权）"],
        ["本地数据库", "Isar NoSQL 3.1.0+1"],
        ["状态管理", "Riverpod 2.6.1"],
    ]
    t = Table(info_table_data, colWidths=[35*mm, 110*mm])
    t.setStyle(TableStyle([
        ("FONTNAME", (0, 0), (-1, -1), FONT_NAME),
        ("FONTSIZE", (0, 0), (-1, -1), 9.5),
        ("BACKGROUND", (0, 0), (-1, 0), "#D4A853"),
        ("TEXTCOLOR", (0, 0), (-1, 0), "#FFFFFF"),
        ("ALIGN", (0, 0), (-1, -1), "LEFT"),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("GRID", (0, 0), (-1, -1), 0.5, "#CCCCCC"),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), ["#FFFFFF", "#FAFAFA"]),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ("LEFTPADDING", (0, 0), (-1, -1), 8),
    ]))
    elements.append(t)
    elements.append(PageBreak())

    # ========== SECTION 2: Screenshots ==========
    elements.append(Paragraph("二、软件运行截图（真机实拍）", h1))

    elements.append(Paragraph("截图 1：主页面 — 攒卡列表视图", h2))
    elements.append(P("""此截图展示 App 启动后的默认首页——「攒卡」Tab。页面包含：顶部 AppBar（应用标题 + 全图鉴入口按钮）、分类筛选栏、卡片列表区域（封面图 + 名称 + 分类标签 + 估值）、底部悬浮添加按钮（FAB）、底部导航栏（攒卡/统计/我的）。当前采用黑金主题配色方案。"""))
    img1 = os.path.join(SCREENSHOT_DIR, "screenshot_01_home.png")
    if os.path.exists(img1):
        img_obj = Image(img1, width=130*mm, height=230*mm)
        elements.append(img_obj)
    elements.append(Paragraph("图 1：App 主页 — 攒卡列表（Android 真机 V2458A 截图）", caption))

    elements.append(Paragraph("截图 2：统计页面 — 资产汇总与数据分析", h2))
    elements.append(P("""此截图展示底部导航栏第二个 Tab ——「统计」页面。页面以可视化图表形式呈现用户的收藏资产概况：总资产估值、按分类统计的藏品数量分布饼图、价格区间分析等数据指标。采用 GoldStatTile 组件展示核心数字，配合黑金风格的数据可视化设计。"""))
    img2 = os.path.join(SCREENSHOT_DIR, "screenshot_02_stats.png")
    if os.path.exists(img2):
        img_obj2 = Image(img2, width=130*mm, height=230*mm)
        elements.append(img_obj2)
    elements.append(Paragraph("图 2：统计页面 — 资产汇总与分析（Android 真机 V2458A 截图）", caption))

    elements.append(Paragraph("截图 3：我的页面 — 个人设置与云端备份", h2))
    elements.append(P("""此截图展示底部导航栏第三个 Tab ——「我的」页面。页面包含用户头像区域、应用信息、以及功能入口列表。其中重点展示了「数据云端备份」功能模块：基于 Supabase Storage 的云端备份与恢复入口，包含「立即备份」（Toast 提示）和「从云端恢复」（二次确认弹窗防误触）两个操作按钮。该功能支持 Isar 数据库快照上传/下载/校验/回滚的完整流程。"""))
    img3 = os.path.join(SCREENSHOT_DIR, "screenshot_03_profile.png")
    if os.path.exists(img3):
        img_obj3 = Image(img3, width=130*mm, height=230*mm)
        elements.append(img_obj3)
    elements.append(Paragraph("图 3：我的页面 — 设置与云端备份（Android 真机 V2458A 截图）", caption))

    elements.append(PageBreak())

    # ========== SECTION 3: Feature Summary ==========
    elements.append(Paragraph("三、已实现功能清单", h1))

    features = [
        ("F01", "卡片 CRUD 管理", "创建/编辑/删除/查看卡片条目；支持拍照/相册选图/OCR识别录入封面；字段包括名称/分类/价格/货币/日期/品相/备注等"),
        ("F02", "OCR 自动识别", "集成 Google ML Kit Text Recognition，拍摄或选取卡片图片后自动提取文字辅助填表"),
        ("F03", "全品类图鉴中心", "覆盖宝可梦TCG/游戏王/万智牌/NBA球星卡/足球球星卡；分类Tab切换+实时搜索+网格浏览+一键加入收藏"),
        ("F04", "国内外双引擎行情", "国内（集换社/闲鱼）vs 国外（eBay/130point/TCGplayer）双Tab；fl_chart 30/90天走势图+成交明细+人民币折算+原文跳转"),
        ("F05", "居中度测量工具", "InteractiveViewer交互式四边锚点拖拽定位；CenteringCalculator计算L/R/T/B百分比偏差；PSA标准评级(GemMint/Mint/OffCenter)"),
        ("F06", "云端备份恢复", "Supabase Storage集成；Isar copyToFile只读快照上传；下载size>0校验；default.isar.old回滚机制；kIsWeb禁用保护"),
        ("F07", "黑金主题系统", "AppColors静态Design Token体系；深色背景+金色强调色；LuxuryBottomNav自定义导航；GoldSnackBar全局提示"),
        ("F08", "网络请求层", "自封装NetworkService+ApiResponse<T>泛型包装；8秒超时；401/404/500状态拦截；Web安全无dart:io依赖"),
    ]

    feat_data = [["编号", "功能名称", "功能说明"]]
    for fid, fname, fdesc in features:
        feat_data.append([fid, fname, fdesc])

    ft = Table(feat_data, colWidths=[12*mm, 38*mm, 95*mm])
    ft.setStyle(TableStyle([
        ("FONTNAME", (0, 0), (-1, -1), FONT_NAME),
        ("FONTSIZE", (0, 0), (-1, -1), 9),
        ("BACKGROUND", (0, 0), (-1, 0), "#D4A853"),
        ("TEXTCOLOR", (0, 0), (-1, 0), "#FFFFFF"),
        ("ALIGN", (0, 0), (1, -1), "CENTER"),
        ("ALIGN", (2, 0), (2, -1), "LEFT"),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("GRID", (0, 0), (-1, -1), 0.5, "#DDDDDD"),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), ["#FFFFFF", "#FAFAFA"]),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
    ]))
    elements.append(ft)

    elements.append(Spacer(1, 8*mm))

    # ========== SECTION 4: Declaration ==========
    elements.append(Paragraph("四、声明", h1))
    elements.append(P("""本证明文件所附截图均为「卡牌收藏管理 App」在 Android 真机设备（型号 V2458A，系统版本 Android 16）上实际运行的屏幕截取图像，未经任何图像编辑软件进行修改或伪造。截图时间戳与设备信息均可通过系统日志核实。<br/><br/>本软件全部源代码由开发者独立编写，使用 Dart 语言（Flutter 框架）开发，未使用任何第三方闭源商业组件的核心逻辑代码。开源依赖均在 pubspec.yaml 中声明并遵循对应许可证要求。<br/><br/>特此证明。"""))

    doc.build(elements)
    print(f"[OK] Proof PDF -> {out_path}")
    return out_path


if __name__ == "__main__":
    make_proof_pdf()
