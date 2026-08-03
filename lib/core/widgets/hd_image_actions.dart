import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:card_management/core/widgets/gold_snack_bar.dart';
import 'package:card_management/core/widgets/hd_image_viewer.dart';

/// 全屏预览通用功能按钮工厂。
///
/// 这些按钮不依赖具体业务上下文，可挂接在任意 [HdImageViewer] 上：
/// - [hdShareAction]：分享图片（网络图 HTTP 拉取 / 本地图文件读取，经系统分享面板）；
/// - [hdSaveAction]：保存图片到应用文档目录并提示路径。
/// 需要卡片上下文的高级按钮（居中度测量 / 编辑 / 删除）由调用方自行组装。

Future<Uint8List> _loadBytes(String url) async {
  if (url.startsWith('http')) {
    final http.Response res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) throw Exception('图片获取失败 (${res.statusCode})');
    return res.bodyBytes;
  }
  if (kIsWeb) throw UnsupportedError('Web 端暂不支持本地图片');
  return XFile(url).readAsBytes();
}

/// 分享按钮：拉起系统原生分享面板发送当前图片。
HdImageAction hdShareAction(BuildContext context, String url) => HdImageAction(
      icon: Icons.share_outlined,
      label: '分享',
      onTap: () => _shareImage(context, url),
    );

Future<void> _shareImage(BuildContext context, String url) async {
  try {
    final Uint8List bytes = await _loadBytes(url);
    final XFile file =
        XFile.fromData(bytes, mimeType: 'image/jpeg', name: 'card_image.jpg');
    if (!context.mounted) return;
    await SharePlus.instance.share(ShareParams(files: <XFile>[file]));
  } catch (e) {
    if (context.mounted) GoldSnackBar.show(context, '分享失败：$e');
  }
}

/// 保存按钮：将图片写入应用文档目录，并 Toast 提示保存路径。
HdImageAction hdSaveAction(BuildContext context, String url) => HdImageAction(
      icon: Icons.save_alt_outlined,
      label: '保存',
      onTap: () => _saveImage(context, url),
    );

Future<void> _saveImage(BuildContext context, String url) async {
  try {
    final Uint8List bytes = await _loadBytes(url);
    final Directory dir = await getApplicationDocumentsDirectory();
    final String name = 'card_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    if (context.mounted) GoldSnackBar.show(context, '已保存：${file.path}');
  } catch (e) {
    if (context.mounted) GoldSnackBar.show(context, '保存失败：$e');
  }
}
