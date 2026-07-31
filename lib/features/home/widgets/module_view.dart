import 'dart:developer';

import 'package:demandium/feature/bottomNav/view/bottom_nav_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/item_widget2.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/airtime/controllers/airtime_controller.dart';
import 'package:sixam_mart/features/home/widgets/components/review_item_card_widget.dart';
import 'package:sixam_mart/features/home/widgets/popular_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promo_code_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promo_code_banner_view1.dart';
import 'package:sixam_mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/menu/screens/menu_screen.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

import '../../../common/widgets/wallet_card.dart';
import '../../banner/controllers/banner_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import 'banner_view.dart';
import 'module_page_last.dart';

class ModuleView extends StatefulWidget {
  final SplashController splashController;
  const ModuleView({super.key, required this.splashController});

  @override
  State<ModuleView> createState() => _ModuleViewState();
}

class _ModuleViewState extends State<ModuleView> {
  bool isLoggedIn = AuthHelper.isLoggedIn();

  final ScrollController _horizontalController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeSmall,
              Dimensions.paddingSizeSmall,
              Dimensions.paddingSizeSmall,
              Dimensions.paddingSizeLarge,
            ),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                /// 🔹 LOCATION PILL + PROFILE
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        onTap: () => Get.find<LocationController>().navigateToLocationScreen('home'),
                        child: GetBuilder<LocationController>(
                          builder: (locationController) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.home_filled, color: primaryColor, size: 20),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      AuthHelper.isLoggedIn()
                                          ? AddressHelper.getUserAddressFromSharedPref()!.address!
                                          : 'Livraison'.tr,
                                      style: robotoBold.copyWith(
                                        color: Colors.black87,
                                        fontSize: Dimensions.fontSizeDefault,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.expand_more, color: Colors.black54, size: 18),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GetBuilder<NotificationController>(
                      builder: (notificationController) {
                        return GetBuilder<ProfileController>(
                          builder: (profileController) {
                            final bool isLoggedIn = AuthHelper.isLoggedIn();
                            final String? image = profileController.userInfoModel?.userInfo?.imageFullUrl;

                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => Get.to(MenuScreen()),
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.white,
                                    backgroundImage: isLoggedIn && image != null && image.isNotEmpty
                                        ? NetworkImage(image)
                                        : null,
                                    child: (!isLoggedIn || image == null || image.isEmpty)
                                        ? Icon(CupertinoIcons.person, color: primaryColor, size: 22)
                                        : null,
                                  ),
                                ),
                                if (notificationController.hasNotification)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      height: 10,
                                      width: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(width: 1, color: Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                /// 🔹 CATEGORY GRID
                widget.splashController.moduleList != null
                    ? widget.splashController.moduleList!.isNotEmpty
                        ? Builder(
                            builder: (context) {
                              List<Widget> tiles = [];
                              for (int index = 0; index < widget.splashController.moduleList!.length; index++) {
                                final module = widget.splashController.moduleList![index];
                                tiles.add(_buildModuleTile(
                                  icon: CustomImage(image: module.iconFullUrl ?? '', width: 44, height: 44, fit: BoxFit.contain),
                                  label: module.moduleName ?? '',
                                  onTap: () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setInt('mid', module.id!);
                                    widget.splashController.switchModule(index, true);
                                  },
                                ));
                              }

                              bool showAirtime = (widget.splashController.configModel?.airtimeStatus ?? 0) == 1;
                              bool showBillPayment = (widget.splashController.configModel?.billPaymentStatus ?? 0) == 1;

                              if (showAirtime) {
                                tiles.add(_buildModuleTile(
                                  icon: (widget.splashController.configModel?.airtimeLogo != null &&
                                          widget.splashController.configModel!.airtimeLogo!.isNotEmpty)
                                      ? CustomImage(image: widget.splashController.configModel?.airtimeLogoFullUrl ?? '', width: 44, height: 44, isLogo: true, fit: BoxFit.contain)
                                      : Image.asset('assets/image/airtime.jpeg', width: 44, height: 44, fit: BoxFit.contain),
                                  label: widget.splashController.configModel?.airtimeName ?? 'AirTime',
                                  onTap: () => Get.toNamed(RouteHelper.getAirtimeRoute()),
                                ));
                              }

                              if (showBillPayment) {
                                tiles.add(_buildModuleTile(
                                  icon: (widget.splashController.configModel?.billPaymentLogo != null &&
                                          widget.splashController.configModel!.billPaymentLogo!.isNotEmpty)
                                      ? CustomImage(image: widget.splashController.configModel?.billPaymentLogoFullUrl ?? '', width: 44, height: 44, isLogo: true, fit: BoxFit.contain)
                                      : Icon(Icons.receipt_long_rounded, color: primaryColor, size: 40),
                                  label: widget.splashController.configModel?.billPaymentName ?? 'Bill Pay',
                                  onTap: () => Get.toNamed(RouteHelper.getBillPaymentRoute()),
                                ));
                              }

                              tiles.add(_buildModuleTile(
                                icon: Image.asset('assets/image/listing.jpeg', width: 44, height: 44, fit: BoxFit.contain),
                                label: 'Listing'.tr,
                                onTap: () async {
                                  SharedPreferences prefs = Get.find();
                                  log('entering listing with user model ${Get.find<ProfileController>().userInfoModel?.phone}');
                                  if (Get.find<ProfileController>().userInfoModel != null) {
                                    prefs.setString(
                                        'listingName',
                                        ((Get.find<ProfileController>().userInfoModel!.fName) ?? '') +
                                            " " +
                                            (Get.find<ProfileController>().userInfoModel!.lName ?? ''));
                                    prefs.setString('listingEmail', Get.find<ProfileController>().userInfoModel!.email ?? '');
                                    prefs.setString('listingNumber', Get.find<ProfileController>().userInfoModel!.phone ?? '');
                                  } else {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.remove('listingNumber');
                                  }
                                },
                              ));

                              tiles.add(_buildModuleTile(
                                icon: Image.asset('demandium/assets/images/service.png', width: 44, height: 44, fit: BoxFit.contain),
                                label: 'Service'.tr,
                                onTap: () {
                                  log('address : ${AddressHelper.getUserAddressFromSharedPref()?.toJson()}');
                                  Get.to(BottomNavScreen(pageIndex: 0, showServiceNotAvailableDialog: false));
                                },
                              ));

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: tiles.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: Dimensions.paddingSizeLarge,
                                  crossAxisSpacing: Dimensions.paddingSizeSmall,
                                  childAspectRatio: 0.85,
                                ),
                                itemBuilder: (context, index) => tiles[index],
                              );
                            },
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                              child: Text('no_module_found'.tr, style: const TextStyle(color: Colors.white)),
                            ),
                          )
                    : ModuleShimmer(isEnabled: widget.splashController.moduleList == null),
              ],
            ),
          ),

          /// 🔹 WHITE CONTENT AREA
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.paddingSizeDefault),

                GetBuilder<ProfileController>(
                  builder: (profileController) {
                    final balance = profileController.userInfoModel?.walletBalance ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: WalletCard(title: "OcassWallet", balance: "$balance"),
                    );
                  },
                ),

                GetBuilder<AddressController>(
                  builder: (locationController) {
                    if (AuthHelper.isLoggedIn() && locationController.addressList == null) {
                      return AddressShimmer(isEnabled: true);
                    }
                    return const SizedBox();
                  },
                ),

                GetBuilder<BannerController>(
                  builder: (bannerController) {
                    return const BannerView(isFeatured: true);
                  },
                ),
                isLoggedIn ? const PromoCodeBannerView() : const SizedBox(),
                const PopularStoreView(isPopular: false, isFeatured: true),
                const SizedBox(height: 30),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTile({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomInkWell(
          onTap: onTap,
          radius: Dimensions.radiusExtraLarge,
          child: Container(
            width: 76,
            height: 76,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: icon,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Container(
          constraints: const BoxConstraints(maxWidth: 96),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class ModuleShimmer extends StatelessWidget {
  final bool isEnabled;
  const ModuleShimmer({super.key, required this.isEnabled});
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: Dimensions.paddingSizeLarge,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        childAspectRatio: 0.85,
      ),
      padding: EdgeInsets.zero,
      itemCount: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          enabled: isEnabled,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 76,
                width: 76,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Container(
                height: 18,
                width: 76,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddressShimmer extends StatelessWidget {
  final bool isEnabled;
  const AddressShimmer({super.key, required this.isEnabled});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
          ),
          child: TitleWidget(title: 'deliver_to'.tr),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        SizedBox(
          height: 70,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: 5,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
            ),
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                padding: const EdgeInsets.only(
                  right: Dimensions.paddingSizeSmall,
                ),
                child: Container(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeDefault
                        : Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: ResponsiveHelper.isDesktop(context) ? 50 : 40,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Shimmer(
                          duration: const Duration(seconds: 2),
                          enabled: isEnabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 15,
                                width: 100,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),
                              Container(
                                height: 10,
                                width: 150,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TopCropper extends CustomClipper<Rect> {
  final double cropHeight;

  TopCropper(this.cropHeight);

  @override
  Rect getClip(Size size) {
    // Crop from top: rectangle from (0, cropHeight) to (width, height)
    return Rect.fromLTRB(0, cropHeight, size.width, size.height);
  }

  @override
  bool shouldReclip(TopCropper oldClipper) {
    return oldClipper.cropHeight != cropHeight;
  }
}
