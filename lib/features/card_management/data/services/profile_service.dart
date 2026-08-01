/// 个人中心数据服务条件导出。
///
/// 原生平台使用文件系统实现（[profile_service_native]，依赖 path_provider / dart:io）；
/// Web 平台改用浏览器下载 / 文件选择实现（[profile_service_web]，依赖 dart:html），
/// 保证 Web 构建可编译且预览中功能可真实触发。
library;

export 'profile_service_native.dart'
    if (dart.library.html) 'profile_service_web.dart';
