import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/styles.dart';

class CartCountView extends StatelessWidget {
  final Item item;
  final Widget? child;
  final int? index;
  final bool isSmall;
  const CartCountView(
      {super.key,
      required this.item,
      this.child,
      this.index = -1,
      this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(item.id!);
      int cartIndex = cartController.isExistInCart(
          item.id, cartController.cartVariant(item.id!), false, null);

      // Sizes based on isSmall flag
      double badgeHeight = isSmall ? 22 : 32;
      double iconSize = isSmall ? 12 : 18;
      double fontSize = isSmall ? 9 : 12;
      double borderRadius = isSmall ? 5 : 8;

      // Blinkit style - when item is in cart, show quantity controls
      if (cartQty != 0 && cartIndex != -1) {
        return Container(
          height: badgeHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Theme.of(context).primaryColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Minus button
              InkWell(
                onTap: cartController.isLoading
                    ? null
                    : () {
                        if (cartController.cartList[cartIndex].quantity! > 1) {
                          cartController.setDirectlyAddToCartIndex(index);
                          cartController.setQuantity(
                              false,
                              cartIndex,
                              cartController.cartList[cartIndex].stock,
                              cartController
                                  .cartList[cartIndex].item!.quantityLimit);
                        } else {
                          cartController.removeFromCart(cartIndex);
                        }
                      },
                child: Container(
                  width: isSmall ? 20 : 28,
                  height: badgeHeight,
                  alignment: Alignment.center,
                  child:
                      Icon(Icons.remove, size: iconSize, color: Colors.white),
                ),
              ),

              // Quantity
              Container(
                constraints: BoxConstraints(minWidth: isSmall ? 14 : 20),
                alignment: Alignment.center,
                child: cartController.isLoading &&
                        cartController.directAddCartItemIndex == index
                    ? SizedBox(
                        height: isSmall ? 10 : 14,
                        width: isSmall ? 10 : 14,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        cartQty.toString(),
                        style: robotoBold.copyWith(
                          fontSize: fontSize,
                          color: Colors.white,
                        ),
                      ),
              ),

              // Plus button
              InkWell(
                onTap: cartController.isLoading
                    ? null
                    : () {
                        cartController.setDirectlyAddToCartIndex(index);
                        cartController.setQuantity(
                            true,
                            cartIndex,
                            cartController.cartList[cartIndex].stock,
                            cartController.cartList[cartIndex].quantityLimit);
                      },
                child: Container(
                  width: isSmall ? 20 : 28,
                  height: badgeHeight,
                  alignment: Alignment.center,
                  child: Icon(Icons.add, size: iconSize, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }

      // Blinkit style ADD button - white background with primary border
      return InkWell(
        onTap: cartController.isLoading
            ? null
            : () {
                cartController.setDirectlyAddToCartIndex(index);
                Get.find<ItemController>().itemDirectlyAddToCart(item, context);
              },
        child: child ??
            Container(
              height: badgeHeight,
              padding: EdgeInsets.symmetric(horizontal: isSmall ? 8 : 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border:
                    Border.all(color: Theme.of(context).primaryColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: cartController.isLoading &&
                        cartController.directAddCartItemIndex == index
                    ? SizedBox(
                        height: isSmall ? 10 : 14,
                        width: isSmall ? 16 : 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        ),
                      )
                    : Text(
                        'ADD',
                        style: robotoBold.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: fontSize,
                        ),
                      ),
              ),
            ),
      );
    });
  }
}
