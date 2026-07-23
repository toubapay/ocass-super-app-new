import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/add_favourite_view.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/common/widgets/new_tag.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

import '../custom_image.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final bool? isTopOffers;
  const StoreCard({super.key, required this.store, this.isTopOffers = false});

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.pharmacy;
    double distance = Get.find<StoreController>().getRestaurantDistance(
      LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
    );
    double discount = store.discount?.discount ?? 0;
    String discountType = store.discount?.discountType ?? '';
    bool isRightSide =
        Get.find<SplashController>().configModel!.currencySymbolDirection ==
            'right';
    String currencySymbol =
        Get.find<SplashController>().configModel!.currencySymbol!;
    bool isAvailable = store.open == 1 && store.active!;

    return Stack(
      children: [
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
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
                arguments: StoreScreen(store: store, fromModule: false),
              );
            },
            radius: 16,
            child: TextHover(builder: (hovered) {
              return Column(
                children: [
                  // === Top Section with Cover Image ===
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.8),
                          Theme.of(context).primaryColor.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background Image with Overlay
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.2),
                              BlendMode.darken,
                            ),
                            child: CustomImage(
                              image: store.coverPhotoFullUrl ??
                                  store.logoFullUrl ??
                                  Images.placeholder,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Store Logo in Center
                        Positioned(
                          bottom: -25,
                          left: 0,
                          right: 0,
                          child: Align(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CustomImage(
                                  image: '${store.logoFullUrl}',
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Favourite Button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: AddFavouriteView(
                            item: null,
                            storeId: store.id,
                            // size: 20,
                            // padding: 6,
                          ),
                        ),

                        // Discount Badge for Top Offers
                        if (isTopOffers! && discount > 0)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.error,
                                    Colors.orange,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                discount > 0
                                    ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} OFF'
                                    : 'FREE DELIVERY',
                                style: robotoBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // === Store Details ===
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Store Name and Rating
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  store.name ?? '',
                                  style: robotoBold.copyWith(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Rating or Pharmacy Info
                              if (!isPharmacy && store.ratingCount! > 0)
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      RatingBar(
                                        rating: store.avgRating,
                                        ratingCount: null,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${store.ratingCount})',
                                        style: robotoRegular.copyWith(
                                          fontSize: 11,
                                          color:
                                              Theme.of(context).disabledColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (isPharmacy)
                                Center(
                                  child: Text(
                                    '${store.itemCount}' ' ' 'items'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: 12,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Address Info
                          if (!isPharmacy)
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Theme.of(context).disabledColor,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    store.address ?? '',
                                    style: robotoRegular.copyWith(
                                      fontSize: 11,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                          // Bottom Info Row
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.1),
                              ),
                            ),
                            child: isTopOffers!
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Distance
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Image.asset(
                                              Images.distanceLine,
                                              height: 14,
                                              width: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Distance',
                                                style: robotoRegular.copyWith(
                                                  fontSize: 10,
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                ),
                                              ),
                                              Text(
                                                '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} km',
                                                style: robotoBold.copyWith(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      // Open Status
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Get.find<StoreController>()
                                                  .isOpenNow(store)
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          Get.find<StoreController>()
                                                  .isOpenNow(store)
                                              ? 'OPEN'
                                              : 'CLOSED',
                                          style: robotoMedium.copyWith(
                                            fontSize: 10,
                                            color: Get.find<StoreController>()
                                                    .isOpenNow(store)
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Distance with Icon
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Image.asset(
                                              Images.distanceLine,
                                              height: 14,
                                              width: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Distance',
                                                style: robotoRegular.copyWith(
                                                  fontSize: 10,
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                ),
                                              ),
                                              Text(
                                                '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} km',
                                                style: robotoBold.copyWith(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      // Open Status with Clock Icon
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Get.find<StoreController>()
                                                      .isOpenNow(store)
                                                  ? Colors.green
                                                  : Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Image.asset(
                                              Images.clockIcon,
                                              height: 12,
                                              width: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Status',
                                                style: robotoRegular.copyWith(
                                                  fontSize: 10,
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                ),
                                              ),
                                              Text(
                                                Get.find<StoreController>()
                                                        .isOpenNow(store)
                                                    ? 'Open Now'
                                                    : 'Closed',
                                                style: robotoBold.copyWith(
                                                  fontSize: 12,
                                                  color: Get.find<
                                                              StoreController>()
                                                          .isOpenNow(store)
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),

        // New Tag
        if (!isTopOffers!)
          Positioned(
            top: 8,
            left: 8,
            child: NewTag(
                // backgroundColor: Theme.of(context).primaryColor,
                // textColor: Colors.white,
                ),
          ),

        // Availability Overlay
        if (!isAvailable)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: NotAvailableWidget(
                isStore: true,
                store: store,
                fontSize: Dimensions.fontSizeSmall,
                isAllSideRound: true,
              ),
            ),
          ),
      ],
    );
  }
}
