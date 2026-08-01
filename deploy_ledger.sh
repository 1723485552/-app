#!/usr/bin/env bash
# 心愿单功能 + 账单明细 Tab：干净代码生成 + 清理废弃簇 + 静态检查 + 真机部署
# 说明：
#  - 本流程通过「build_runner 重生成」让 card_item_native.g.dart 彻底退役手工补丁，
#    由生成器标准化托管；并随后「uninstall 全新安装」避免 Isar schema 变更冲突。
#  - 若仅需静态检查/部署、无需重生成，可注释掉第 1 步（BUILD_RUNNER）。
set -e
cd /c/kapai/card_management || exit 1

echo "== 0) 干净代码生成（让 Isar .g.dart 退役手工补丁，由生成器标准化托管） =="
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
echo "== 0) .g.dart 已重新生成，手工补丁已退役 =="

echo "== 1) 删除行情/走势废弃簇（7 个文件） =="
rm -f \
  lib/features/card_management/presentation/pages/market_trend_page.dart \
  lib/features/card_management/data/trend_history.dart \
  lib/features/card_management/presentation/providers/trend_providers.dart \
  lib/features/card_management/domain/enums/trend_ranking_type.dart \
  lib/features/card_management/presentation/widgets/trend_line_chart.dart \
  lib/features/card_management/presentation/widgets/trend_ranking_list.dart \
  lib/features/card_management/presentation/widgets/trend_ranking_segment.dart

echo "== 2) dart analyze（目标 0/0/0） =="
flutter analyze

echo "== 3) 构建 debug APK =="
flutter build apk --debug

echo "== 4) 清理安装并启动真机（Isar schema 已变更，必须全新安装避免 schema 冲突） =="
ADB="/c/Users/17234/AppData/Local/Android/Sdk/platform-tools/adb.exe"
"$ADB" uninstall com.example.card_management || true
"$ADB" install build/app/outputs/flutter-apk/app-debug.apk
"$ADB" shell am start -n com.example.card_management/.MainActivity
echo "DONE ✅ 请在真机复验【心愿单】录入与【账单明细】Tab"
