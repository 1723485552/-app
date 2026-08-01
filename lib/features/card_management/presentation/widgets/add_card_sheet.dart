import 'dart:ui';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// 加号快捷弹层的操作类型枚举，用于解耦「点击」与「业务响应」。
///
/// 弹层只负责把用户意图以枚举回传，由调用方（主壳）在弹层彻底关闭、
/// 上下文完全安全后再路由到对应业务弹窗，规避嵌套 [BuildContext] 销毁竞态。
enum QuickActionType { ocr, addCard, addWishlist }

/// 黑金高奢「悬浮加号」径向菜单：深色全屏遮罩 + 命中区域点击关闭 +
/// 底部金色「×」关闭按钮 + 上方拱形错落的 3 个金色图标选项。
///
/// 点击选项仅做两件事：震动 + 以 [QuickActionType] 回传并关闭；业务路由
/// 交由主壳处理。蒙层任意点击或 × 关闭时回传 null。
Future<QuickActionType?> showAddCardSheet(BuildContext context) {
  return showModalBottomSheet<QuickActionType>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext ctx) => const _AddRadialMenu(),
  );
}

/// 菜单中单个径向选项的静态描述。
class _RadialOptionData {
  const _RadialOptionData(this.icon, this.label, this.action);

  final IconData icon;
  final String label;
  final QuickActionType action;
}

class _AddRadialMenu extends StatelessWidget {
  const _AddRadialMenu();

  @override
  Widget build(BuildContext context) {
    final double bottomPad = MediaQuery.of(context).padding.bottom;
    // 顺序：左=扫码识卡，中=手动录入，右=添加心愿单。
    final List<_RadialOptionData> options = <_RadialOptionData>[
      const _RadialOptionData(
          Icons.qr_code_2_outlined, '扫码识卡', QuickActionType.ocr),
      const _RadialOptionData(
          Icons.edit_outlined, '手动录入', QuickActionType.addCard),
      const _RadialOptionData(Icons.auto_awesome_outlined, '添加心愿单',
          QuickActionType.addWishlist),
    ];

    // 以底部 X 关闭按钮为锚点，3 圆球在其上方呈扇形弧线排列。
    // 中间正上方 120dp，左右沿 45° 弧线分布（±90, -75）。
    const double anchor = 32.0; // X 按钮下边距基准（与下方 Positioned 对齐）。
    const double midUp = 120.0;
    const double sideDx = 90.0;
    const double sideDy = 75.0;

    return Material(
      color: Colors.transparent,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0), // 12px 柔和高斯模糊。
          child: Container(
            color: Colors.black.withValues(alpha: 0.70), // 70% 深度暗黑半透明遮罩。
            child: Stack(
              children: <Widget>[
                // 全屏半透明遮罩：点击任意空白处关闭（回传 null）。
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox.expand(),
                  ),
                ),
                // 左侧圆球（左上方 45° 弧线）。
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: anchor + bottomPad + sideDy,
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(-sideDx, 0),
                      child: _RadialOption(data: options[0]),
                    ),
                  ),
                ),
                // 右侧圆球（右上方 45° 弧线）。
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: anchor + bottomPad + sideDy,
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(sideDx, 0),
                      child: _RadialOption(data: options[2]),
                    ),
                  ),
                ),
                // 中间圆球（正上方 120dp）。
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: anchor + bottomPad + midUp,
                  child: Center(child: _RadialOption(data: options[1])),
                ),
                // 底部金色「×」关闭按钮（回传 null）；自身 onTap 拦截，不触发遮罩关闭。
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: anchor + bottomPad,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldPrimary,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: AppColors.goldGlow,
                                blurRadius: 18,
                                spreadRadius: 1)
                          ],
                        ),
                        child: Icon(Icons.close_rounded,
                            color: context.gold.bgDark, size: 28),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 径向菜单中的单个图标选项（金色圆 + 矢量图标 + 下方文案）。
class _RadialOption extends StatelessWidget {
  const _RadialOption({required this.data});

  final _RadialOptionData data;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop(data.action);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.gold.surfaceDark,
                border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.5),
                    width: 0.5),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                      color: AppColors.goldGlow,
                      blurRadius: 14,
                      spreadRadius: -4)
                ],
              ),
              child: Icon(data.icon, color: AppColors.goldPrimary, size: 24),
            ),
            const SizedBox(height: 10),
            Text(data.label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    shadows: <Shadow>[
                      Shadow(blurRadius: 4, color: Colors.black)
                    ])),
          ],
        ),
      );
}
