import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/home/widgets/web/web_new_on_view_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class RecommendedStoreView extends StatelessWidget {
  const RecommendedStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      List<Store>? storeList = storeController.recommendedStoreList;

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
                              'recommended_store'.tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed(
                                  RouteHelper.getAllStoreRoute('recommended')),
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
                                  storeList[index], context),
                            );
                          }),
                    ),
                  ]),
                )
              : const SizedBox.shrink()
          : const WebNewOnShimmerView();
    });
  }

  Widget _buildGroceryStoreCard(Store store, BuildContext context) {
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
                    '${store.deliveryTime ?? 'Delivered in'}',
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

            // Discount Badge (top left) - only show if there's a discount
            if (discount > 0)
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
