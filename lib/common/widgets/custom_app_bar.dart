import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/common/widgets/cart_widget.dart';
import 'package:sixam_mart/common/widgets/veg_filter_widget.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Page header as in the Noor web app (.page-header): green gradient, white
/// back arrow and title on the left, white icons.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool backButton;
  final Function? onBackPressed;
  final bool showCart;
  final Function(String value)? onVegFilterTap;
  final String? type;
  final String? leadingIcon;
  final Widget? menuWidget;
  const CustomAppBar({super.key, required this.title, this.backButton = true, this.onBackPressed, this.showCart = false, this.leadingIcon, this.onVegFilterTap, this.type, this.menuWidget});

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return const WebMenuBar();
    final canGoBack = backButton || Navigator.canPop(context);
    return AppBar(
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
      centerTitle: false,
      titleSpacing: canGoBack ? 0 : 16,
      automaticallyImplyLeading: false,
      leading: canGoBack ? IconButton(
        icon: leadingIcon != null ? Image.asset(leadingIcon!, height: 22, width: 22, color: Colors.white) : const Icon(Icons.arrow_back_rounded),
        color: Colors.white,
        onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context),
      ) : null,
      backgroundColor: NoorTheme.green,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: const DecoratedBox(decoration: BoxDecoration(gradient: NoorTheme.headerGradient)),
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      actions: showCart || onVegFilterTap != null ? [
        showCart ? IconButton(
          onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
          icon: const CartWidget(color: Colors.white, size: 25),
        ) : const SizedBox(),

        onVegFilterTap != null ? VegFilterWidget(
          type: type,
          onSelected: onVegFilterTap,
          fromAppBar: true,
        ) : const SizedBox(),

      ] : [menuWidget ?? const SizedBox()],
    );
  }

  @override
  Size get preferredSize => Size(Get.width, GetPlatform.isDesktop ? 100 : 60);
}
