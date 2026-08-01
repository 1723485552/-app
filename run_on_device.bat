@echo off
REM 真机运行助手：在项目根目录双击或终端执行即可。
REM 前提：手机已开 USB 调试、USB 连电脑并已授权、USB 模式设为"传输文件(MTP)"；本机 Flutter 版本须为 3.22–3.27。
cd /d %~dp0

echo === [1/3] flutter pub get ===
flutter pub get
if errorlevel 1 (
  echo pub get 失败，请检查 Flutter 版本(3.22-3.27)与网络。
  pause
  exit /b 1
)

echo === [2/3] flutter devices（确认手机已列出且非 unauthorized）===
flutter devices

echo === [3/3] flutter run -d android（强制跑在已连接的 Android 手机，避免误开 Web/Edge）===
flutter run -d android
pause
