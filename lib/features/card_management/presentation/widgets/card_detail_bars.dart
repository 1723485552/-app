import 'package:flutter/material.dart';

/// 顶部浮动栏：左侧返回箭头 + 卡片名称 + 数量序号（如 "1 / 12"）。
Widget buildDetailTopBar({
  required String name,
  required String count,
  required VoidCallback onBack,
}) =>
    Row(
      children: <Widget>[
        _roundBtn(Icons.arrow_back, onBack),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(count,
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
      ],
    );

Widget _roundBtn(IconData icon, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
            color: Colors.black45, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );

/// 底部极窄 Icon 工具条（半透明，无大黑框，约 50px）。
Widget buildDetailBottomBar({
  required VoidCallback onShare,
  required VoidCallback onCentering,
  required VoidCallback onMarket,
  required VoidCallback onInfo,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) =>
    Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _barIcon(Icons.share_outlined, onShare),
          _barIcon(Icons.center_focus_strong_outlined, onCentering),
          _barIcon(Icons.show_chart_outlined, onMarket),
          _barIcon(Icons.info_outline_rounded, onInfo),
          _barIcon(Icons.edit_outlined, onEdit),
          _barIcon(Icons.delete_outline_rounded, onDelete),
        ],
      ),
    );

Widget _barIcon(IconData icon, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Icon(icon, color: Colors.white, size: 23),
      ),
    );
