import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/card_design/special_offer_item_card.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/home/widgets/components/review_item_card2.dart';
import 'package:sixam_mart/features/home/widgets/components/review_item_card_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view2.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class PopularStoreView extends StatelessWidget {
  final bool isPopular;
  final bool isFeatured;
  const PopularStoreView(
      {super.key, required this.isPopular, required this.isFeatured});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (item) {
      return GetBuilder<StoreController>(builder: (storeController) {
        List<Store>? storeList = isFeatured
            ? storeController.featuredStoreList
            : isPopular
                ? storeController.popularStoreList
                : storeController.latestStoreList;

        return (storeList != null && storeList.isEmpty)
            ? const SizedBox()
            : Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(10, isPopular ? 2 : 15, 10, 10),
                    child: TitleWidget(
                      title: isFeatured
                          ? 'featured_stores'.tr
                          : isPopular
                              ? Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig!
                                      .module!
                                      .showRestaurantText!
                                  ? 'popular_restaurants'.tr
                                  : 'popular_stores'.tr
                              : '${'new_on'.tr} ${AppConstants.appName}',
                      onTap: () =>
                          Get.toNamed(RouteHelper.getAllStoreRoute(isFeatured
                              ? 'featured'
                              : isPopular
                                  ? 'popular'
                                  : 'latest')),
                    ),
                  ),
                  SizedBox(
                    height: 170,
                    child: storeList != null
                        ? ListView.builder(
                            controller: ScrollController(),
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(
                                left: Dimensions.paddingSizeSmall),
                            itemCount:
                                storeList.length > 10 ? 10 : storeList.length,
                            itemBuilder: (context, index) {
                              final store = storeList[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                    right: Dimensions.paddingSizeDefault,
                                    bottom: 5),
                                child: Container(
                                  width: 230,
                                  margin: const EdgeInsets.only(
                                      top: Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusExtraLarge),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withValues(alpha: 0.15),
                                          blurRadius: 7,
                                          spreadRadius: 0)
                                    ],
                                  ),
                                  child: CustomInkWell(
                                    onTap: () {
                                      if (isFeatured &&
                                          Get.find<SplashController>()
                                                  .moduleList !=
                                              null) {
                                        for (ModuleModel module
                                            in Get.find<SplashController>()
                                                .moduleList!) {
                                          if (module.id == store.moduleId) {
                                            Get.find<SplashController>()
                                                .setModule(module);
                                            break;
                                          }
                                        }
                                      }
                                      Get.toNamed(
                                        RouteHelper.getStoreRoute(
                                            id: store.id,
                                            page: isFeatured
                                                ? 'module'
                                                : 'store'),
                                        arguments: StoreScreen(
                                            store: store,
                                            fromModule: isFeatured),
                                      );
                                    },
                                    radius: Dimensions.radiusSmall,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusExtraLarge),
                                          child: CustomImage(
                                            image: '${store.coverPhotoFullUrl}',
                                            height: 170,
                                            width: 230,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusExtraLarge),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.1),
                                                Colors.black.withOpacity(0.7),
                                              ],
                                            ),
                                          ),
                                        ),
                                        DiscountTag(
                                          discount: storeController
                                              .getDiscount(store),
                                          discountType: storeController
                                              .getDiscountType(store),
                                          freeDelivery: store.freeDelivery,
                                        ),
                                        storeController.isOpenNow(store)
                                            ? const SizedBox()
                                            : const NotAvailableWidget(
                                                isStore: true),
                                        Positioned(
                                          top: Dimensions.paddingSizeExtraSmall,
                                          right:
                                              Dimensions.paddingSizeExtraSmall,
                                          child:
                                              GetBuilder<FavouriteController>(
                                                  builder:
                                                      (favouriteController) {
                                            bool isWished = favouriteController
                                                .wishStoreIdList
                                                .contains(store.id);
                                            return InkWell(
                                              onTap: () {
                                                if (AuthHelper.isLoggedIn()) {
                                                  isWished
                                                      ? favouriteController
                                                          .removeFromFavouriteList(
                                                              store.id, true)
                                                      : favouriteController
                                                          .addToFavouriteList(
                                                              null,
                                                              store.id,
                                                              true);
                                                } else {
                                                  showCustomSnackBar(
                                                      'you_are_not_logged_in'
                                                          .tr);
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                    Dimensions
                                                        .paddingSizeExtraSmall),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall),
                                                ),
                                                child: Icon(
                                                  isWished
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  size: 15,
                                                  color: isWished
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Theme.of(context)
                                                          .disabledColor,
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                        Positioned(
                                          left: Dimensions.paddingSizeSmall,
                                          right: Dimensions.paddingSizeSmall,
                                          bottom: Dimensions.paddingSizeSmall,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                store.name ?? '',
                                                style: robotoMedium.copyWith(
                                                  color: Colors.white,
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              RatingBar(
                                                rating: store.avgRating,
                                                ratingCount: store.ratingCount,
                                                size: 12,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                store.address ?? '',
                                                style: robotoRegular.copyWith(
                                                    color: Colors.white70,
                                                    fontSize: Dimensions
                                                        .fontSizeSmall),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : PopularStoreShimmer(storeController: storeController),
                  ),
                  Get.find<SplashController>().module == null
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: Get.find<ItemController>()
                                  .moduleWiseItems
                                  .isNotEmpty
                              ? Get.find<ItemController>()
                                  .moduleWiseItems
                                  ?.where((module) =>
                                      module?.items?.isNotEmpty ?? false)
                                  .toList()
                                  .length
                              : 0,
                          itemBuilder: (context, index2) {
                            final module = Get.find<ItemController>()
                                .moduleWiseItems
                                ?.where((module) =>
                                    module?.items?.isNotEmpty ?? false)
                                .toList()[index2];

                            var indoo = Get.find<ItemController>()
                                .moduleWiseItems
                                ?.indexOf(module);

                            if ((indoo ?? 0) >
                                Get.find<SplashController>()
                                        .moduleList!
                                        .length -
                                    1) {
                              indoo = Get.find<SplashController>()
                                      .moduleList!
                                      .length -
                                  1;
                            }

                            int moduleId =
                                Get.find<ItemController>().moduleWiseIDs[
                                        module?.items?.first.moduleType] ??
                                    1;

                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            child: Text(
                                              Get.find<SplashController>()
                                                      .moduleList
                                                      ?.where((test) =>
                                                          test.id == moduleId)
                                                      .first
                                                      .moduleName ??
                                                  ''
                                                      '',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Get.find<SplashController>().switchModule(
                                                  Get.find<SplashController>()
                                                          .moduleList
                                                          ?.indexOf(Get.find<
                                                                  SplashController>()
                                                              .moduleList!
                                                              .where((test) =>
                                                                  test.id ==
                                                                  moduleId)
                                                              .first) ??
                                                      1,
                                                  true);
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Visit'.tr,
                                                    style:
                                                        robotoMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 12,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: Get.find<SplashController>()
                                                  .moduleList
                                                  ?.where((test) =>
                                                      test.id == moduleId)
                                                  .first
                                                  .moduleName ==
                                              'OcassFood'
                                          ? 200
                                          : 360,
                                      child: GridView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: module?.items?.length ?? 0,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              Get.find<SplashController>()
                                                          .moduleList
                                                          ?.where((test) =>
                                                              test.id ==
                                                              moduleId)
                                                          .first
                                                          .moduleName ==
                                                      'OcassFood'
                                                  ? 1
                                                  : 2, // 2 rows
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                          childAspectRatio:
                                              Get.find<SplashController>()
                                                          .moduleList
                                                          ?.where((test) =>
                                                              test.id ==
                                                              moduleId)
                                                          .first
                                                          .moduleName ==
                                                      'OcassFood'
                                                  ? 1.7
                                                  : 1.5,
                                        ),
                                        itemBuilder: (context, index) {
                                          return SpecialOfferItemCard(
                                            item: module!.items![index],
                                            isFood: false,
                                            isShop: true,
                                            index: index,
                                            moduleId: moduleId,
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : SizedBox(),
                  Get.find<SplashController>().module == null
                      ? SpecialOfferView2(
                          isFood: false,
                          isShop: true,
                        )
                      : SizedBox()
                ],
              );
      });
    });
  }
}

class PopularStoreShimmer extends StatelessWidget {
  final StoreController storeController;
  const PopularStoreShimmer({super.key, required this.storeController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          height: 150,
          width: 200,
          margin: const EdgeInsets.only(
              right: Dimensions.paddingSizeSmall, bottom: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[300]!, blurRadius: 10, spreadRadius: 1)
              ]),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusExtraLarge)),
            ),
          ),
        );
      },
    );
  }
}
