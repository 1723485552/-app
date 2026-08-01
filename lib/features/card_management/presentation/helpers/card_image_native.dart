import 'dart:io';

import 'package:flutter/material.dart';

/// 卡面封面图片源解析（原生端：支持拍照识卡落盘的本地文件路径）。
///
/// 本地路径（以 `/`、`file://` 或 `content://` 开头）返回 [FileImage]；
/// 远程地址（如历史占位图）返回 [NetworkImage]。集中处理避免网格 / 大图重复分支。
ImageProvider cardImageProvider(String url) {
  if (url.startsWith('file://')) {
    return FileImage(File(url.replaceFirst('file://', '')));
  }
  if (url.startsWith('/') || url.startsWith('content://')) {
    return FileImage(File(url));
  }
  return NetworkImage(url);
}
