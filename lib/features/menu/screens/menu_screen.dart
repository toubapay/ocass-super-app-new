import 'package:demandium/feature/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/notification/screens/notification_screen.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  initState() {
    super.initState();
    Get.find<ProfileController>().getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<ProfileController>(builder: (profileController) {
        final bool isLoggedIn = AuthHelper.isLoggedIn();

        return Column(children: [
          // Header Section - Updated Design
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeLarge,
                right: Dimensions.paddingSizeLarge,
                top: 50,
                bottom: Dimensions.paddingSizeLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Get.back();
                        } else {
                          Get.offAllNamed(RouteHelper.getInitialRoute());
                        }
                      },
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      'profile'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeOverLarge,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Row(children: [
                    // Profile icon with background color
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: profileController.userInfoModel?.userInfo
                                        ?.imageFullUrl !=
                                    null &&
                                profileController.userInfoModel!.userInfo!
                                    .imageFullUrl!.isNotEmpty
                            ? Image.network(
                                profileController
                                    .userInfoModel!.userInfo!.imageFullUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Theme.of(context).primaryColor,
                                  );
                                },
                              )
                            : Icon(
                                Icons.person,
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              ),
                      ),
                    ),

                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // text
                            Text(
                              'nice_to_see_you'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),

                            // User name or Guest User
                            isLoggedIn &&
                                    profileController.userInfoModel == null
                                ? Shimmer(
                                    child: Container(
                                      height: 20,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  )
                                : Text(
                                    isLoggedIn
                                        ? '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}'
                                        : 'guest_user'.tr,
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeExtraLarge,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                            const SizedBox(height: 4),

                            // Login prompt or join date
                            isLoggedIn &&
                                    profileController.userInfoModel == null
                                ? Shimmer(
                                    child: Container(
                                      height: 14,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  )
                                : isLoggedIn
                                    ? Text(
                                        profileController.userInfoModel != null
                                            ? '${'member_since'.tr} ${DateConverter.containTAndZToUTCFormat(profileController.userInfoModel!.createdAt!)}'
                                            : '',
                                        style: robotoMedium.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          color: Colors.grey[500],
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () async {
                                          if (!ResponsiveHelper.isDesktop(
                                              context)) {
                                            await Get.toNamed(
                                                RouteHelper.getSignInRoute(
                                                    Get.currentRoute));
                                            if (AuthHelper.isLoggedIn()) {
                                              profileController.getUserInfo();
                                            }
                                          } else {
                                            Get.dialog(const Center(
                                                child: AuthDialogWidget(
                                                    exitFromApp: true,
                                                    backFromThis: true)));
                                          }
                                        },
                                        child: Text(
                                          'login_to_view_all_the_features'.tr,
                                          style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                          ]),
                    ),
                  ]),
                ],
              ),
            ),
          ),

          Expanded(
              child: SingleChildScrollView(
            child: Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
              child: Column(children: [
                // General Section
                _buildSection(
                  title: 'general'.tr,
                  children: [
                    _buildMenuItem(
                      icon: Icons.person,
                      title: 'profile'.tr,
                      onTap: () => Get.toNamed(RouteHelper.getProfileRoute()),
                    ),
                    _buildMenuItem(
                      icon: Icons.location_on,
                      title: 'my_address'.tr,
                      onTap: () => Get.toNamed(RouteHelper.getAddressRoute()),
                    ),
                    _buildMenuItem(
                      icon: Icons.language,
                      title: 'language'.tr,
                      onTap: () => _manageLanguageFunctionality(),
                      showDivider: false,
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications,
                      title: 'notification'.tr,
                      onTap: () => Get.to(NotificationScreen()),
                      showDivider: false,
                    ),
                  ],
                ),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Promotional Activity Section
                _buildSection(
                  title: 'promotional_activity'.tr,
                  children: [
                    _buildMenuItem(
                      icon: Icons.local_offer,
                      title: 'coupon'.tr,
                      onTap: () => Get.toNamed(RouteHelper.getCouponRoute()),
                      showDivider: Get.find<SplashController>()
                                  .configModel!
                                  .loyaltyPointStatus ==
                              1 ||
                          Get.find<SplashController>()
                                  .configModel!
                                  .customerWalletStatus ==
                              1,
                    ),
                    if (Get.find<SplashController>()
                            .configModel!
                            .loyaltyPointStatus ==
                        1)
                      _buildMenuItem(
                        icon: Icons.star,
                        title: 'loyalty_points'.tr,
                        onTap: () => Get.toNamed(RouteHelper.getLoyaltyRoute()),
                        suffix: !isLoggedIn
                            ? null
                            : '${profileController.userInfoModel?.loyaltyPoint != null ? profileController.userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}',
                        showDivider: Get.find<SplashController>()
                                .configModel!
                                .customerWalletStatus ==
                            1,
                      ),
                    if (Get.find<SplashController>()
                            .configModel!
                            .customerWalletStatus ==
                        1)
                      _buildMenuItem(
                        icon: Icons.wallet,
                        title: 'my_wallet'.tr,
                        onTap: () => Get.toNamed(RouteHelper.getWalletRoute()),
                        suffix: !isLoggedIn
                            ? null
                            : PriceConverter.convertPrice(
                                profileController.userInfoModel != null
                                    ? profileController
                                        .userInfoModel!.walletBalance
                                    : 0),
                        showDivider: false,
                      ),
                  ],
                ),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Earnings Section
                if ((Get.find<SplashController>()
                            .configModel!
                            .refEarningStatus ==
                        1) ||
                    (Get.find<SplashController>()
                            .configModel!
                            .toggleDmRegistration! &&
                        !ResponsiveHelper.isDesktop(context)) ||
                    (Get.find<SplashController>()
                            .configModel!
                            .toggleStoreRegistration! &&
                        !ResponsiveHelper.isDesktop(context)))
                  _buildSection(
                    title: 'earnings'.tr,
                    children: [
                      if (Get.find<SplashController>()
                              .configModel!
                              .refEarningStatus ==
                          1)
                        _buildMenuItem(
                          icon: Icons.card_giftcard,
                          title: 'refer_and_earn'.tr,
                          onTap: () =>
                              Get.toNamed(RouteHelper.getReferAndEarnRoute()),
                          showDivider: (Get.find<SplashController>()
                                      .configModel!
                                      .toggleDmRegistration! &&
                                  !ResponsiveHelper.isDesktop(context)) ||
                              (Get.find<SplashController>()
                                      .configModel!
                                      .toggleStoreRegistration! &&
                                  !ResponsiveHelper.isDesktop(context)),
                        ),
                      if (Get.find<SplashController>()
                              .configModel!
                              .toggleDmRegistration! &&
                          !ResponsiveHelper.isDesktop(context))
                        _buildMenuItem(
                          icon: Icons.delivery_dining,
                          title: 'join_as_a_delivery_man'.tr,
                          onTap: () => Get.toNamed(
                              RouteHelper.getDeliverymanRegistrationRoute()),
                          showDivider: (Get.find<SplashController>()
                                  .configModel!
                                  .toggleStoreRegistration! &&
                              !ResponsiveHelper.isDesktop(context)),
                        ),
                      if (Get.find<SplashController>()
                              .configModel!
                              .toggleStoreRegistration! &&
                          !ResponsiveHelper.isDesktop(context))
                        _buildMenuItem(
                          icon: Icons.store,
                          title: 'open_store'.tr,
                          onTap: () => Get.toNamed(
                              RouteHelper.getRestaurantRegistrationRoute()),
                          showDivider: false,
                        ),
                    ],
                  ),

                if ((Get.find<SplashController>()
                            .configModel!
                            .refEarningStatus ==
                        1) ||
                    (Get.find<SplashController>()
                            .configModel!
                            .toggleDmRegistration! &&
                        !ResponsiveHelper.isDesktop(context)) ||
                    (Get.find<SplashController>()
                            .configModel!
                            .toggleStoreRegistration! &&
                        !ResponsiveHelper.isDesktop(context)))
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                // Help & Support Section
                _buildSection(
                  title: 'help_support'.tr,
                  children: [
                    _buildMenuItem(
                      icon: Icons.chat,
                      title: 'live_chat'.tr,
                      onTap: () =>
                          Get.toNamed(RouteHelper.getConversationRoute()),
                    ),
                    _buildMenuItem(
                      icon: Icons.help_center,
                      title: 'help_support'.tr,
                      onTap: () => Get.toNamed(RouteHelper.getSupportRoute()),
                    ),
                    _buildMenuItem(
                      icon: Icons.info,
                      title: 'about_us'.tr,
                      onTap: () =>
                          Get.toNamed(RouteHelper.getHtmlRoute('about-us')),
                    ),
                    _buildMenuItem(
                      icon: Icons.description,
                      title: 'terms_conditions'.tr,
                      onTap: () => Get.toNamed(
                          RouteHelper.getHtmlRoute('terms-and-condition')),
                    ),
                    _buildMenuItem(
                      icon: Icons.privacy_tip,
                      title: 'privacy_policy'.tr,
                      onTap: () => Get.toNamed(
                          RouteHelper.getHtmlRoute('privacy-policy')),
                    ),
                    if (Get.find<SplashController>()
                            .configModel!
                            .refundPolicyStatus ==
                        1)
                      _buildMenuItem(
                        icon: Icons.assignment_return,
                        title: 'refund_policy'.tr,
                        onTap: () => Get.toNamed(
                            RouteHelper.getHtmlRoute('refund-policy')),
                        showDivider: (Get.find<SplashController>()
                                    .configModel!
                                    .cancellationPolicyStatus ==
                                1) ||
                            (Get.find<SplashController>()
                                    .configModel!
                                    .shippingPolicyStatus ==
                                1),
                      ),
                    if (Get.find<SplashController>()
                            .configModel!
                            .cancellationPolicyStatus ==
                        1)
                      _buildMenuItem(
                        icon: Icons.cancel,
                        title: 'cancellation_policy'.tr,
                        onTap: () => Get.toNamed(
                            RouteHelper.getHtmlRoute('cancellation-policy')),
                        showDivider: (Get.find<SplashController>()
                                .configModel!
                                .shippingPolicyStatus ==
                            1),
                      ),
                    if (Get.find<SplashController>()
                            .configModel!
                            .shippingPolicyStatus ==
                        1)
                      _buildMenuItem(
                        icon: Icons.local_shipping,
                        title: 'shipping_policy'.tr,
                        onTap: () => Get.toNamed(
                            RouteHelper.getHtmlRoute('shipping-policy')),
                        showDivider: false,
                      ),
                  ],
                ),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Logout Button
                InkWell(
                  onTap: () async {
                    if (AuthHelper.isLoggedIn()) {
                      Get.dialog(
                          ConfirmationDialog(
                              icon: Images.support,
                              description: 'are_you_sure_to_logout'.tr,
                              isLogOut: true,
                              onYesPressed: () async {
                                Get.find<AuthController>().resetOtpView();
                                Get.find<ProfileController>().clearUserInfo();
                                Get.find<AuthController>().socialLogout();
                                Get.find<CartController>()
                                    .clearCartList(canRemoveOnline: false);
                                Get.find<FavouriteController>()
                                    .removeFavourite();
                                await Get.find<AuthController>()
                                    .clearSharedData();
                                Get.find<HomeController>()
                                    .forcefullyNullCashBackOffers();
                                Get.find<TaxiCartController>().getCarCartList();
                                //logout from service module
                                Get.find<ServiceAuthController>()
                                    .clearSharedData();
                                Get.find<ServiceAuthController>()
                                    .googleLogout();
                                Get.find<ServiceAuthController>()
                                    .signOutWithFacebook();
                                Get.find<ServiceAuthController>()
                                    .signOutWithFacebook();
                                //main app route to intial
                                Get.offAllNamed(RouteHelper.getInitialRoute());
                              }),
                          useSafeArea: false);
                    } else {
                      Get.find<FavouriteController>().removeFavourite();
                      await Get.toNamed(
                          RouteHelper.getSignInRoute(Get.currentRoute));
                      if (AuthHelper.isLoggedIn()) {
                        await Get.find<FavouriteController>()
                            .getFavouriteList();
                        profileController.getUserInfo();
                      }
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault,
                        horizontal: Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.power_settings_new,
                            size: 20, color: Colors.white),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          AuthHelper.isLoggedIn() ? 'logout'.tr : 'sign_in'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                    height: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeExtremeLarge
                        : 100),
              ]),
            ),
          )),
        ]);
      }),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeSmall,
                bottom: Dimensions.paddingSizeSmall),
            child: Text(
              title,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? suffix,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: suffix != null
              ? Text(
                  suffix,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Divider(
              height: 1,
              color: Colors.grey[100],
              thickness: 1,
            ),
          ),
      ],
    );
  }

  _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true,
      useRootNavigator: true,
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(
        Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }
}
