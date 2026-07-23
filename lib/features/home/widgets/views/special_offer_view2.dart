import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/card_design/special_offer_item_card.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';

class SpecialOfferView2 extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const SpecialOfferView2(
      {super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? discountedItemList = itemController.discountedItemList;

      return discountedItemList != null
          ? discountedItemList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeDefault),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, // start from top
                        end: Alignment.bottomRight, // end to bottom-right
                        colors: [
                          Color(0xFFFFF6A5), // sky blue
                          Color(0xFFFFFFFF), // yellow
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeDefault,
                              left: Dimensions.paddingSizeDefault,
                              right: Dimensions.paddingSizeDefault),
                          child: TitleWidget(
                            title: 'special_offer'.tr,
                            image: Images.discountOfferIcon,
                            onTap: () => Get.toNamed(
                                RouteHelper.getItemViewAllScreen(false, true)),
                          ),
                        ),

                        // Grid of special offer items
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeDefault),
                          child: SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: discountedItemList.length > 10
                                  ? 10
                                  : discountedItemList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: SizedBox(
                                    width: 120,
                                    child: SpecialOfferItemCard(
                                      item: discountedItemList[index],
                                      isFood: isFood,
                                      isShop: isShop,
                                      index: index,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox()
          : const ItemShimmerGrid();
    });
  }
}

/// Shimmer placeholder in grid form
class ItemShimmerGrid extends StatelessWidget {
  const ItemShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Container(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeDefault,
                  left: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeDefault),
              child: TitleWidget(
                title: 'special_offer'.tr,
                image: Images.discountOfferIcon,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) => Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: true,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusLarge),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
