import 'package:flutter/material.dart';

/// 卡面封面图片源解析（Web 端：仅远程地址，避免 dart:io 编译期报错）。
ImageProvider cardImageProvider(String url) => NetworkImage(url);
