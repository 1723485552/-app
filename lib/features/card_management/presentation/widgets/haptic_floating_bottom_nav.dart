import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticFloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isSheetOpen;
  final List<BottomNavItemData> items;

  const HapticFloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isSheetOpen = false,
    required this.items,
  });

  void _handleTap(int index) {
    if (index == currentIndex) return;
    HapticFeedback.selectionClick();
    onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final double translateY = isSheetOpen ? 1.2 : 0.0;
    final double opacity = isSheetOpen ? 0.0 : 1.0;

    return AnimatedSlide(
      offset: Offset(0, translateY),
      duration: const Duration(milliseconds: 320),
      curve: isSheetOpen ? Curves.easeInBack : Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 250),
        child: IgnorePointer(
          ignoring: isSheetOpen,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF141416).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(items.length, (index) {
                          final isSelected = index == currentIndex;
                          final item = items[index];
                          return _NavItemTile(
                            item: item,
                            isSelected: isSelected,
                            onTap: () => _handleTap(index),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavItemTile extends StatelessWidget {
  final BottomNavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFFFD700);
    final unselectedColor = Colors.white.withValues(alpha: 0.45);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? goldColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: goldColor.withValues(alpha: 0.4), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? goldColor : unselectedColor,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: const TextStyle(
                  color: goldColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
