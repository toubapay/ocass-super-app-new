import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart'; // Add this import
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class SpecialOfferItemCard extends StatelessWidget {
  final Item item;
  final bool isFood;
  final bool isShop;
  final int? index;
  final int? moduleId;

  const SpecialOfferItemCard(
      {super.key,
      required this.item,
      required this.isFood,
      required this.isShop,
      this.index,
      this.moduleId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomInkWell(
        onTap: () => Get.find<ItemController>()
            .navigateToItemPage(item, context, moduleId: moduleId),
        radius: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Product Image with tags ===
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: CustomImage(
                      image: item.imageFullUrl ?? Images.placeholder,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Favourite icon
                  Positioned(
                    top: 5,
                    right: 5,
                    child: _buildFavouriteIcon(context),
                  ),
                  // Animated Discount tag - REPLACED with your animated version
                  if ((item.discount ?? 0) > 0)
                    DiscountTag(
                      discount: item.discount,
                      discountType: item.discountType,
                      fromTop: 5,
                      fontSize: 8, // Adjusted for small card
                      inLeft: true,
                      freeDelivery: false,
                      isFloating: true,
                    ),
                  // Organic tag
                  if (item.organic == 1 && item.moduleType == 'grocery')
                    Positioned(
                      bottom: 5,
                      left: 5,
                      child: _buildOrganicTag(),
                    ),
                  // Not available overlay
                  if (!Get.find<ItemController>().isAvailable(item))
                    NotAvailableWidget(
                      radius: 10,
                      isAllSideRound: false,
                    ),
                ],
              ),
            ),

            // === Content Section ===
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unit + Time
                    Row(
                      children: [
                        if (item.unitType != null)
                          Flexible(
                            child: Text(
                              item.unitType ?? '',
                              style: robotoRegular.copyWith(
                                fontSize: 9,
                                color: Theme.of(context).hintColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(width: 3),
                        Icon(Icons.access_time, size: 10, color: Colors.green),
                        const SizedBox(width: 2),
                        Text(
                          "15Min",
                          style: robotoRegular.copyWith(
                            fontSize: 9,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Name
                    Expanded(
                      child: Text(
                        item.name ?? '',
                        style: robotoBold.copyWith(fontSize: 10),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Price + ADD Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.discount != null && item.discount! > 0)
                                Text(
                                  PriceConverter.convertPrice(
                                    Get.find<ItemController>()
                                        .getStartingPrice(item),
                                  ),
                                  style: robotoRegular.copyWith(
                                    fontSize: 8,
                                    color: Theme.of(context).disabledColor,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                PriceConverter.convertPrice(
                                  Get.find<ItemController>()
                                      .getStartingPrice(item),
                                  discount: item.discount,
                                  discountType: item.discountType,
                                ),
                                style: robotoMedium.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {}, // Absorb tap to prevent parent InkWell
                          child: CartCountView(
                            item: item,
                            index: index,
                            isSmall: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavouriteIcon(BuildContext context) {
    return GetBuilder<FavouriteController>(
      builder: (favouriteController) {
        bool isWished = favouriteController.wishItemIdList.contains(item.id);
        return InkWell(
          onTap: favouriteController.isRemoving
              ? null
              : () {
                  if (AuthHelper.isLoggedIn()) {
                    isWished
                        ? favouriteController.removeFromFavouriteList(
                            item.id, false)
                        : favouriteController.addToFavouriteList(
                            item, null, false);
                  } else {
                    showCustomSnackBar('you_are_not_logged_in'.tr);
                  }
                },
          child: Icon(
            isWished ? CupertinoIcons.heart_solid : CupertinoIcons.heart,
            color: isWished
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColor.withOpacity(0.3),
            size: 18,
          ),
        );
      },
    );
  }

  Widget _buildOrganicTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco_outlined, size: 8, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            'organic'.tr.toUpperCase(),
            style: robotoMedium.copyWith(
              color: Colors.white,
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }
}
