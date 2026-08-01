import 'dart:io';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_optimizer.dart';
import '../helpers/card_image.dart';

/// 黑金封面图选择区块（手动录入 / 心愿单共用）。
///
/// 顶部虚线感黑金描边区块，点击调起相册选图，经 [ImageOptimizer] 压缩后
/// 通过 [onPicked] 回传本地路径；[initialPath] 非空时（编辑模式）默认展示已有封面，
/// 支持点击重新替换。空安全：压缩异常时回退原图路径，绝不崩溃。
class CardCoverPicker extends StatefulWidget {
  const CardCoverPicker({super.key, this.initialPath, required this.onPicked});
  final String? initialPath;
  final ValueChanged<String> onPicked;
  @override
  State<CardCoverPicker> createState() => _CardCoverPickerState();
}

class _CardCoverPickerState extends State<CardCoverPicker> {
  String? _path;

  @override
  void initState() {
    super.initState();
    _path = widget.initialPath;
  }

  Future<void> _pick() async {
    // 先弹出「拍摄 / 相册」双选底栏，再按所选来源取图（相机权限由 image_picker 自动请求）。
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: context.gold.scrim,
      builder: (BuildContext ctx) => const _CoverSourceSheet(),
    );
    if (source == null) return; // 用户取消
    final XFile? f = await ImagePicker().pickImage(source: source);
    if (f == null) return;
    String path = f.path;
    try {
      path = (await ImageOptimizer.compressImage(File(f.path))).path;
    } catch (_) {
      path = f.path; // 压缩异常回退原图，绝不崩溃
    }
    if (!mounted) return;
    setState(() => _path = path);
    widget.onPicked(path);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: _pick,
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.gold.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: 0.25), width: 0.5),
          ),
          child: _path == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.add_a_photo_outlined,
                        color: AppColors.goldPrimary, size: 26),
                    const SizedBox(height: 6),
                    Text('点击上传卡片封面（选填）',
                        style: TextStyle(
                            color: context.gold.textMuted, fontSize: 12)),
                  ],
                )
              : Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image(
                        image: cardImageProvider(_path!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 120,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.add_a_photo_outlined,
                            color: AppColors.goldPrimary),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.gold.bgPure.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.refresh_outlined,
                            size: 16, color: AppColors.goldPrimary),
                      ),
                    ),
                  ],
                ),
        ),
      );
}

/// 封面来源双选底栏：拍摄照片 / 从相册选择（黑金矢量图标，禁用 Emoji）。
class _CoverSourceSheet extends StatelessWidget {
  const _CoverSourceSheet();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.gold.bgNav,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: const Border(top: BorderSide(color: AppColors.goldBorder, width: 0.5)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.goldGlow, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 12),
            Text('选择封面来源',
                style: TextStyle(
                    color: context.gold.textWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _sourceItem(context, Icons.camera_alt_outlined, '拍摄照片', ImageSource.camera),
            const SizedBox(height: 10),
            _sourceItem(context, Icons.photo_library_outlined, '从相册选择', ImageSource.gallery),
          ],
        ),
      );

  Widget _sourceItem(BuildContext context, IconData icon, String label, ImageSource source) =>
      GestureDetector(
        onTap: () => Navigator.of(context).pop(source),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: context.gold.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: 0.2), width: 0.5),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, color: AppColors.goldPrimary, size: 22),
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(color: context.gold.textWhite, fontSize: 14)),
              const Spacer(),
              Icon(Icons.chevron_right_outlined,
                  color: context.gold.textMuted, size: 18),
            ],
          ),
        ),
      );
}
