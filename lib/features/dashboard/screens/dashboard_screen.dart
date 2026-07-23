import 'dart:async';
import 'dart:io';

import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:sixam_mart/common/widgets/custom_dialog.dart';
import 'package:sixam_mart/common/widgets/login_suggestion_bottomsheet.dart';
import 'package:sixam_mart/features/address/screens/address_screen.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/checkout/widgets/congratulation_dialogue.dart';
import 'package:sixam_mart/features/coupon/screens/coupon_screen.dart';
import 'package:sixam_mart/features/dashboard/widgets/address_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/dashboard/widgets/custom_curved_nav_bar.dart';
import 'package:sixam_mart/features/dashboard/widgets/parcel_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/dashboard/widgets/store_registration_success_bottom_sheet.dart';
import 'package:sixam_mart/features/favourite/screens/favourite_screen.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/menu/screens/menu_screen.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/order/screens/order_screen.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/taxi_cart_screen.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/screens/vehicle_favourite_screen.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/taxi_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';

import '../../cart/controllers/cart_controller.dart';
import '../widgets/running_order_view_widget.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromSplash;

  const DashboardScreen({
    super.key,
    required this.pageIndex,
    this.fromSplash = false,
  });

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late PageController _pageController;
  int _pageIndex = 0;

  late bool _isLogin;
  bool _canExit = GetPlatform.isWeb;
  bool active = false;

  @override
  void initState() {
    super.initState();

    _isLogin = AuthHelper.isLoggedIn();
    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: _pageIndex);

    _showRegistrationSuccessBottomSheet();

    if (!_isLogin &&
        Get.find<SplashController>().showLoginSuggestion() &&
        (GetPlatform.isAndroid || GetPlatform.isIOS)) {
      Future.delayed(const Duration(seconds: 3), () {
        Get.bottomSheet(
          LoginSuggestionBottomSheet(),
          isScrollControlled: true,
        ).then((_) {
          Get.find<SplashController>().disableLoginSuggestion();
        });
      });
    }

    if (_isLogin) {
      suggestAddressBottomSheet();
      Get.find<OrderController>().getRunningOrders(1, fromDashboard: true);
    }
  }

  Future<void> suggestAddressBottomSheet() async {
    active = await Get.find<LocationController>().checkLocationActive();
    if (widget.fromSplash &&
        Get.find<LocationController>().showLocationSuggestion &&
        active) {
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => const AddressBottomSheetWidget(),
        ).then((_) {
          Get.find<LocationController>().showSuggestedLocation(false);
        });
      });
    }
  }

  void _showRegistrationSuccessBottomSheet() {
    if (Get.find<HomeController>().getRegistrationSuccessfulSharedPref()) {
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => const StoreRegistrationSuccessBottomSheet(),
        ).then((_) {
          Get.find<HomeController>()
              .saveRegistrationSuccessfulSharedPref(false);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          // Get.find<SplashController>().setModule(null);
          if (_canExit) {
            SystemNavigator.pop();
          } else if (Get.find<SplashController>().module != null) {
            Get.find<SplashController>().setModule(null);
          } else {
            _canExit = true;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('back_press_again_to_exit'.tr),
                duration: const Duration(seconds: 1),
              ),
            );
            Timer(const Duration(seconds: 1), () => _canExit = false);
          }
        }
      },
      child: GetBuilder<SplashController>(builder: (splash) {
        bool isTaxi = splash.module?.moduleType == AppConstants.taxi;
        bool isParcel =
            splash.configModel?.moduleConfig?.module?.isParcel ?? false;

        /// 🔥 FIXED SCREENS (OrderScreen = index 3)
        final screens = [
          const HomeScreen(), // 0
          isParcel
              ? const AddressScreen(fromDashboard: true)
              : isTaxi
                  ? const VehicleFavouriteScreen()
                  : const FavouriteScreen(), // 1
          CouponScreen(), // 2
          OrderScreen(index: isTaxi ? 1 : 0), // 3 ✅
          const MenuScreen(), // 4
        ];

        return Scaffold(
          body: ExpandableBottomSheet(
            background: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: screens,
                ),
                if (!ResponsiveHelper.isDesktop(context) && !keyboardVisible)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: CustomCurvedNavBar(
                      currentIndex: _pageIndex,
                      cartCount: Get.find<CartController>().cartList.length,
                      onTap: _setPage,
                      items: [
                        NavBarItem(iconPath: Images.home, label: 'Home'.tr),
                        NavBarItem(iconPath: Images.cart, label: 'Cart'.tr),
                        NavBarItem(iconPath: Images.promo, label: 'Promo'.tr),
                        NavBarItem(
                            iconPath: Images.discount,
                            label: isTaxi ? 'Trips'.tr : 'Orders'.tr),
                        NavBarItem(iconPath: Images.chatSvg, label: 'Chat'.tr),
                      ],
                    ),
                  ),
              ],
            ),
            expandableContent: const SizedBox(),
          ),
        );
      }),
    );
  }

  /// 🔥 PERFECT PAGE HANDLING
  void _setPage(int index) {
    // Cart
    if (index == 1) {
      Get.toNamed(RouteHelper.getCartRoute());
      return;
    }

    // Chat
    if (index == 4) {
      Get.toNamed(RouteHelper.getConversationRoute());
      return;
    }

    _pageIndex = index;
    _pageController.jumpToPage(index);
    setState(() {});
  }

  Widget trackView(BuildContext context, {required bool status}) {
    return Container(
        height: 3,
        decoration: BoxDecoration(
            color: status
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault)));
  }
}
