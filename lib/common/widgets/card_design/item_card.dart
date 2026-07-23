import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/add_favourite_view.dart';
import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/hover/on_hover.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/common/widgets/organic_tag.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final bool isPopularItem;
  final bool isFood;
  final bool isShop;
  final bool isPopularItemCart;
  final int? index;
  const ItemCard(
      {super.key,
      required this.item,
      this.isPopularItem = false,
      required this.isFood,
      required this.isShop,
      this.isPopularItemCart = false,
      this.index});

  @override
  Widget build(BuildContext context) {
    double? discount = item.discount;
    String? discountType = item.discountType;

    return OnHover(
      isItem: true,
      child: Container(
        width: 150,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CustomInkWell(
          onTap: () =>
              Get.find<ItemController>().navigateToItemPage(item, context),
          radius: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Product Image with tags ===
              SizedBox(
                height: 141,
                width: double.infinity,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: CustomImage(
                        image: item.imageFullUrl ?? Images.placeholder,
                        height: 141,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    AddFavouriteView(item: item),
                    DiscountTag(
                      discount: item.discount,
                      discountType: item.discountType,
                      freeDelivery: false,
                    ),
                    OrganicTag(item: item, placeInImage: true),
                    !Get.find<ItemController>().isAvailable(item)
                        ? NotAvailableWidget(
                            radius: 12,
                            isAllSideRound: false,
                          )
                        : const SizedBox(),
                  ],
                ),
              ),

              // === Unit + Time ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    if (item.unitType != null)
                      Text(
                        item.unitType ?? '',
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    const SizedBox(width: 6),
                    const Icon(Icons.access_time,
                        size: 14, color: Colors.green),
                    const SizedBox(width: 3),
                    Text(
                      "15Min",
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // === Name ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.name ?? '',
                  style: robotoBold.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // === Rating ===
              if (item.ratingCount != null && item.ratingCount! > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.star,
                          size: 14, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 3),
                      Text(
                        item.avgRating!.toStringAsFixed(1),
                        style: robotoRegular.copyWith(fontSize: 12),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "(${item.ratingCount})",
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // === Price + ADD Button ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.discount != null && item.discount! > 0)
                          Text(
                            PriceConverter.convertPrice(
                              Get.find<ItemController>().getStartingPrice(item),
                            ),
                            style: robotoRegular.copyWith(
                              fontSize: 11,
                              color: Theme.of(context).disabledColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          PriceConverter.convertPrice(
                            Get.find<ItemController>().getStartingPrice(item),
                            discount: item.discount,
                            discountType: item.discountType,
                          ),
                          style: robotoMedium.copyWith(fontSize: 14),
                        ),
                      ],
                    ),

                    // ADD Button (CartCountView)
                    CartCountView(
                      item: item,
                      index: index,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          // border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "ADD",
                          style: robotoMedium.copyWith(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
