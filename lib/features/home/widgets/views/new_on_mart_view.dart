import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/features/home/widgets/web/web_new_on_view_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class NewOnMartView extends StatelessWidget {
  final bool isPharmacy;
  final bool isShop;
  final bool isNewStore;
  const NewOnMartView(
      {super.key,
      required this.isPharmacy,
      required this.isShop,
      this.isNewStore = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      List<Store>? storeList = storeController.latestStoreList;

      return storeList != null
          ? storeList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeDefault),
                  child: Column(children: [
                    // Custom Header with rounded container and black arrow button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${'new_on'.tr} ${AppConstants.appName}',
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed(
                                  RouteHelper.getAllStoreRoute('latest')),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(
                              left: Dimensions.paddingSizeDefault),
                          itemCount: storeList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: Dimensions.paddingSizeDefault,
                                  bottom: Dimensions.paddingSizeSmall,
                                  top: Dimensions.paddingSizeSmall),
                              child: _buildGroceryStoreCard(
                                  storeList[index], context, isNewStore),
                            );
                          }),
                    ),
                  ]),
                )
              : const SizedBox.shrink()
          : const WebNewOnShimmerView();
    });
  }

  Widget _buildGroceryStoreCard(
      Store store, BuildContext context, bool showNewBadge) {
    // Calculate real distance
    double distance = (store.distance != null) ? (store.distance! / 1000) : 0.0;

    // Get real discount info
    double discount = Get.find<StoreController>().getDiscount(store) ?? 0.0;
    String discountType =
        Get.find<StoreController>().getDiscountType(store) ?? 'percent';
    bool isRightSide =
        Get.find<SplashController>().configModel!.currencySymbolDirection ==
            'right';
    String currencySymbol =
        Get.find<SplashController>().configModel!.currencySymbol!;

    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CustomInkWell(
        onTap: () {
          if (Get.find<SplashController>().moduleList != null) {
            for (ModuleModel module
                in Get.find<SplashController>().moduleList!) {
              if (module.id == store.moduleId) {
                Get.find<SplashController>().setModule(module);
                break;
              }
            }
          }
          Get.toNamed(
            RouteHelper.getStoreRoute(id: store.id, page: 'store'),
            arguments: StoreScreen(store: store, fromModule: true),
          );
        },
        radius: Dimensions.radiusDefault,
        child: Stack(
          children: [
            // Store Cover Image
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
              child: CustomImage(
                image: store.coverPhotoFullUrl ?? '',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusExtraLarge),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Store Info Overlay
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name
                  Text(
                    store.name ?? '',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Delivery Info
                  Text(
                    '${store.deliveryTime ?? 'Delivered in'} ${'just_minutes'.tr}',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Distance
                  Text(
                    '${distance > 100 ? '100+' : distance.toStringAsFixed(1)} ${'km'.tr}',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Delivery Badge (Free Delivery or Discount)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      (store.freeDelivery ?? false)
                          ? 'free_delivery'.tr
                          : discount > 0
                              ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}${discount.toStringAsFixed(0)}${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'
                              : 'delivery_available'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // NEW Badge - show when it's a new store
            if (showNewBadge)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'new'.tr.toUpperCase(),
                    style: robotoBold.copyWith(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Discount Badge (top left) - show when there's a discount and no NEW badge
            if (!showNewBadge && discount > 0)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}${discount.toStringAsFixed(0)}${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}',
                    style: robotoBold.copyWith(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Store Status (if closed)
            if (!Get.find<StoreController>().isOpenNow(store))
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'closed_now'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.white,
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

class PopularStoreShimmer extends StatelessWidget {
  final StoreController storeController;
  const PopularStoreShimmer({super.key, required this.storeController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
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
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[300]!, blurRadius: 10, spreadRadius: 1)
              ],
            ),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 90,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(Dimensions.radiusSmall)),
                        color: Colors.grey[300],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(
                            Dimensions.paddingSizeExtraSmall),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  height: 10,
                                  width: 100,
                                  color: Colors.grey[300]),
                              const SizedBox(height: 5),
                              Container(
                                  height: 10,
                                  width: 130,
                                  color: Colors.grey[300]),
                              const SizedBox(height: 5),
                              const RatingBar(
                                  rating: 0.0, size: 12, ratingCount: 0),
                            ]),
                      ),
                    ),
                  ]),
            ),
          );
        },
      ),
    );
  }
}
