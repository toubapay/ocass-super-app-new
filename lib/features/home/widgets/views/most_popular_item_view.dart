import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/common/widgets/card_design/special_offer_item_card.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../item/screens/item_view_all_screen.dart';

class MostPopularItemView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const MostPopularItemView(
      {super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    bool isShopModule = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.ecommerce;
    
    // Check if this is grocery module (not food, not shop)
    bool isGrocery = !isFood && !isShop;

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: GetBuilder<ItemController>(builder: (itemController) {
        List<Item>? itemList = itemController.popularItemList;

        return (itemList != null)
            ? itemList.isNotEmpty
                ? Container(
                    color: isGrocery 
                        ? const Color(0xFFFFF6A5).withOpacity(0.3)
                        : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: Dimensions.paddingSizeDefault,
                            left: Dimensions.paddingSizeDefault,
                            right: Dimensions.paddingSizeDefault),
                        child: TitleWidget(
                          title: isShopModule
                              ? 'most_popular_products'.tr
                              : 'most_popular_items'.tr,
                          image: Images.mostPopularIcon,
                          onTap: () => Get.toNamed(
                              RouteHelper.getItemViewAllScreen(true, false)),
                        ),
                      ),
                      
                      // Use grid layout for grocery, horizontal list for others
                      if (isGrocery)
                        Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: itemList.length > 6 ? 6 : itemList.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.68,
                            ),
                            itemBuilder: (context, index) {
                              return SpecialOfferItemCard(
                                item: itemList[index],
                                isFood: isFood,
                                isShop: isShop,
                                index: index,
                              );
                            },
                          ),
                        )
                      else Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: itemList.length > 6 ? 6 : itemList.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.68,
                          ),
                          itemBuilder: (context, index) {
                            return SpecialOfferItemCard(
                              item: itemList[index],
                              isFood: isFood,
                              isShop: isShop,
                              index: index,
                            );
                          },
                        ),
                      )
                        // SizedBox(
                        //   height: 308,
                        //   child: ListView.builder(
                        //     scrollDirection: Axis.horizontal,
                        //     physics: const BouncingScrollPhysics(),
                        //     padding: const EdgeInsets.only(
                        //         left: Dimensions.paddingSizeDefault),
                        //     itemCount: itemList.length,
                        //     itemBuilder: (context, index) {
                        //       return Padding(
                        //         padding: const EdgeInsets.only(
                        //             bottom: Dimensions.paddingSizeDefault,
                        //             right: Dimensions.paddingSizeExtraSmall1,
                        //             top: Dimensions.paddingSizeDefault),
                        //         child: ItemCard(
                        //           isPopularItem: isShopModule ? false : true,
                        //           isPopularItemCart: true,
                        //           item: itemList[index],
                        //           isShop: isShop,
                        //           isFood: isFood,
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                    ]),
                  )
                : const SizedBox()
            : isGrocery ? const MostPopularItemShimmerGrid() : const ItemShimmerView();
      }),
    );
  }
}

/// Shimmer placeholder in grid form for Most Popular Items
class MostPopularItemShimmerGrid extends StatelessWidget {
  const MostPopularItemShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for horizontal list
class ItemShimmerView extends StatelessWidget {
  const ItemShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 308,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(
                bottom: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeExtraSmall1,
                top: Dimensions.paddingSizeDefault),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Container(
                width: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}