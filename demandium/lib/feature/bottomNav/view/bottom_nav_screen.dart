import 'dart:developer';

import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class BottomNavScreen extends StatefulWidget {
  final AddressModel? previousAddress;
  final bool showServiceNotAvailableDialog;
  final int pageIndex;
  const BottomNavScreen({
    super.key,
    required this.pageIndex,
    this.previousAddress,
    required this.showServiceNotAvailableDialog,
  });

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _pageIndex = 0;
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.pageIndex;

    if (_pageIndex == 1) {
      Get.find<BottomNavController>().changePage(
        BnbItem.bookings,
        shouldUpdate: false,
      );
    } else if (_pageIndex == 2) {
      Get.find<BottomNavController>().changePage(
        BnbItem.cart,
        shouldUpdate: false,
      );
    } else if (_pageIndex == 3) {
      Get.find<BottomNavController>().changePage(
        BnbItem.offers,
        shouldUpdate: false,
      );
    } else {
      Get.find<BottomNavController>().changePage(
        BnbItem.homePage,
        shouldUpdate: false,
      );
    }
    Get.find<ServiceSplashController>().getConfigData();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    bool isUserLoggedIn = Get.find<ServiceAuthController>().isLoggedIn();

    return CustomPopWidget(
      isExit: true,
      onPopInvoked: () {
        // if (Get.find<BottomNavController>().currentPage != BnbItem.homePage) {
        //   Get.find<BottomNavController>().changePage(BnbItem.homePage);
        // } else {
        //   if (_canExit) {
        //     if (!GetPlatform.isWeb) {
        //       SystemNavigator.pop();
        //     }
        //   } else {
        //     customSnackBar(
        //       'back_press_again_to_exit'.tr,
        //       type: ToasterMessageType.info,
        //     );
        //     _canExit = true;
        //     Timer(const Duration(seconds: 2), () {
        //       _canExit = false;
        //     });
        //   }
        // }
        log('Back button pressed ${Get.currentRoute}');
        Get.currentRoute == '/service' ? Get.offAllNamed('/') : Get.back();
      },

      child: Scaffold(
        floatingActionButton:
            (ResponsiveHelper.isDesktop(context) ||
                MediaQuery.of(context).viewInsets.bottom != 0)
            ? null
            : InkWell(
                onTap: () => Get.toNamed(ServiceRouteHelper.getCartRoute()),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CartWidget(
                        color: Get.isDarkMode
                            ? Theme.of(context).primaryColorLight
                            : Colors.grey.shade700,
                        size: 30,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'cart'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color:
                              Get.find<BottomNavController>()
                                      .currentPage
                                      .index ==
                                  2
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,

        bottomNavigationBar: ResponsiveHelper.isDesktop(context)
            ? const SizedBox()
            : Container(
                padding: EdgeInsets.only(
                  // top: Dimensions.paddingSizeSmall,
                  bottom: padding.bottom > 15
                      ? 0
                      : Dimensions.paddingSizeDefault,
                ),
                color: Colors.white,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeExtraSmall,
                    ),
                    child: Row(
                      children: [
                        _bnbItem(
                          icon: Images.home,
                          bnbItem: BnbItem.homePage,
                          context: context,
                          onTap: () => Get.find<BottomNavController>()
                              .changePage(BnbItem.homePage),
                        ),

                        _bnbItem(
                          icon: Images.bookings,
                          bnbItem: BnbItem.bookings,
                          context: context,
                          onTap: () {
                            if (!isUserLoggedIn &&
                                Get.find<ServiceSplashController>()
                                        .configModel
                                        .content
                                        ?.guestCheckout ==
                                    1) {
                              Get.toNamed(
                                ServiceRouteHelper.getTrackBookingRoute(),
                              );
                            } else if (!isUserLoggedIn) {
                              Get.toNamed(
                                ServiceRouteHelper.getBookingScreenRoute(true),
                              );
                            } else {
                              Get.find<BottomNavController>().changePage(
                                BnbItem.bookings,
                              );
                            }
                          },
                        ),

                        _bnbItem(
                          icon: '',
                          bnbItem: BnbItem.cart,
                          context: context,
                          onTap: () {
                            if (!isUserLoggedIn) {
                              Get.toNamed(
                                ServiceRouteHelper.getSignInRoute(
                                  redirectUrl: ServiceRouteHelper.home,
                                ),
                              );
                            } else {
                              Get.find<BottomNavController>().changePage(
                                BnbItem.cart,
                              );
                            }
                          },
                        ),

                        _bnbItem(
                          icon: Images.offerMenu,
                          bnbItem: BnbItem.offers,
                          context: context,
                          onTap: () => Get.find<BottomNavController>()
                              .changePage(BnbItem.offers),
                        ),

                        _bnbItem(
                          icon: Images.menu,
                          bnbItem: BnbItem.more,
                          context: context,
                          onTap: () => Get.bottomSheet(
                            const MenuScreen(),
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

        body: GetBuilder<BottomNavController>(
          builder: (navController) {
            return _bottomNavigationView(
              widget.previousAddress,
              widget.showServiceNotAvailableDialog,
            );
          },
        ),
      ),
    );
  }

  Widget _bnbItem({
    required String icon,
    required BnbItem bnbItem,
    required GestureTapCallback onTap,
    context,
  }) {
    return GetBuilder<BottomNavController>(
      builder: (bottomNavController) {
        return Expanded(
          child: InkWell(
            onTap: bnbItem != BnbItem.cart ? onTap : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                bottomNavController.currentPage == bnbItem
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          height: 4,
                          width: double.infinity,

                          decoration: BoxDecoration(
                            color: bottomNavController.currentPage == bnbItem
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            boxShadow:
                                bottomNavController.currentPage == bnbItem
                                ? [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 5),
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      )
                    : SizedBox(height: 12),
                icon.isEmpty
                    ? const SizedBox(width: 20, height: 20)
                    : Image.asset(
                        icon,
                        width: 22,
                        height: 23,
                        color:
                            Get.find<BottomNavController>().currentPage ==
                                bnbItem
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade700,
                      ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  bnbItem != BnbItem.cart ? bnbItem.name.tr : '',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color:
                        Get.find<BottomNavController>().currentPage == bnbItem
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  dynamic _bottomNavigationView(
    AddressModel? previousAddress,
    bool showServiceNotAvailableDialog,
  ) {
    PriceConverter.getCurrency();
    switch (Get.find<BottomNavController>().currentPage) {
      case BnbItem.homePage:
        return HomeScreen(
          addressModel: previousAddress,
          showServiceNotAvailableDialog: showServiceNotAvailableDialog,
        );
      case BnbItem.bookings:
        if (!Get.find<ServiceAuthController>().isLoggedIn()) {
          break;
        } else {
          return const BookingListScreen();
        }
      case BnbItem.cart:
        if (!Get.find<ServiceAuthController>().isLoggedIn()) {
          break;
        } else {
          return Get.toNamed(ServiceRouteHelper.getCartRoute());
        }
      case BnbItem.offers:
        return const OfferScreen();
      case BnbItem.more:
        break;
    }
  }
}
