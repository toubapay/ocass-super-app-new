import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:sixam_mart/util/dimensions.dart';

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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [

                  /// 🔹 TOP INDICATOR
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.transparent,
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 5),
                        ),
                      ]
                          : [],
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// 🔹 ICON + BADGE
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildIcon(
                        item.iconPath,
                        isSelected
                            ? primaryColor
                            : Colors.grey.shade700,
                        item.iconSize,
                      ),

                      /// 🔴 CART COUNT BADGE (ONLY index == 1)
                      if (index == 1 && cartCount > 0)
                        Positioned(
                          top: -10, right: -5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                            child: GetBuilder<CartController>(builder: (cartController) {
                              return Text(
                                cartController.cartList.length.toString(),
                                style: robotoMedium.copyWith(color: Colors.white, fontSize: 8),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// 🔹 LABEL
                  Text(
                    item.label,
                    style: TextStyle(
                      color:
                      isSelected ? primaryColor : Colors.grey.shade700,
                      fontSize: Dimensions.fontSizeSmall,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          );
        }),
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
