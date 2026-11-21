import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../util/styles.dart';
import '../../cart/controllers/cart_controller.dart';

class CustomCurvedNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavBarItem> items;
  final int cartCount; // 👈 NEW

  const CustomCurvedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.cartCount = 0, // 👈 default
  });

  /// A floating pill as the web app's bottom bar (.bottom-nav): detached
  /// from the screen edges, the active tab in a grey capsule, green.
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    const muted = Color(0xFF6B6B70);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, 12 + bottom),
      child: Container(
        height: 66,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 30, offset: const Offset(0, 10)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = currentIndex == index;
            final color = isSelected ? primaryColor : muted;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEFEFF0) : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildIcon(item.iconPath, color, 22),
                          // Cart count (the cart is the second tab).
                          if (index == 1 && cartCount > 0)
                            Positioned(
                              top: -7, right: -9,
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xFFB8901F),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: GetBuilder<CartController>(builder: (cartController) {
                                  return Text(
                                    cartController.cartList.length.toString(),
                                    style: robotoBold.copyWith(color: Colors.white, fontSize: 9),
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: color,
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// 🔹 SVG / IMAGE AUTO
  Widget _buildIcon(String path, Color color, double size) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        height: size,
        width: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    } else {
      return Image.asset(
        path,
        height: size,
        width: size,
        color: color,
      );
    }
  }
}

class NavBarItem {
  final String iconPath;
  final String label;
  final double iconSize;

  NavBarItem({
    required this.iconPath,
    required this.label,
    this.iconSize = 24,
  });
}
