import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer>
    with SingleTickerProviderStateMixin {
  late final List<Menu> _menuList = [
    Menu(
      icon: Images.profileIcon,
      title: 'profile'.tr,
      onTap: () {
        Get.back();
        Get.toNamed(ServiceRouteHelper.getProfileRoute());
      },
    ),
    Menu(
      icon: Images.chatImage,
      title: 'inbox'.tr,
      onTap: () {
        Get.back();
        Get.toNamed(ServiceRouteHelper.getInboxScreenRoute());
      },
    ),
    Menu(
      icon: Images.translate,
      title: 'language'.tr,
      onTap: () {
        Get.back();
        Get.toNamed(ServiceRouteHelper.getLanguageScreen('menuDrawer'));
      },
    ),
    Menu(
      icon: Images.settings,
      title: 'settings'.tr,
      onTap: () {
        Get.back();
        Get.toNamed(ServiceRouteHelper.getSettingRoute());
      },
    ),
    Menu(
      icon: Images.bookingsIcon,
      title:
          Get.find<ServiceSplashController>()
                      .configModel
                      .content
                      ?.guestCheckout ==
                  0 ||
              Get.find<ServiceAuthController>().isLoggedIn()
          ? 'bookings'.tr
          : "track_booking".tr,
      onTap: () {
        Get.back();

        Get.toNamed(
          !Get.find<ServiceAuthController>().isLoggedIn() &&
                  Get.find<ServiceSplashController>()
                          .configModel
                          .content
                          ?.guestCheckout ==
                      1
              ? ServiceRouteHelper.getTrackBookingRoute()
              : ServiceRouteHelper.getBookingScreenRoute(true),
        );
      },
    ),

    if (Get.find<ServiceSplashController>()
            .configModel
            .content
            ?.biddingStatus ==
        1)
      Menu(
        icon: Images.customPostIcon,
        title: 'my_posts'.tr,
        onTap: () {
          Get.back();
          Get.toNamed(ServiceRouteHelper.getMyPostScreen());
        },
      ),

    Menu(
      icon: Images.voucherIcon,
      title: 'vouchers'.tr,
      onTap: () {
        Get.back();

        if (Get.find<ServiceLocationController>().getUserAddress() != null) {
          Get.toNamed(ServiceRouteHelper.getVoucherRoute(fromPage: "menu"));
        } else {
          Get.toNamed(
            ServiceRouteHelper.getPickMapRoute(
              ServiceRouteHelper.voucherScreen,
              true,
              'false',
              null,
              null,
            ),
          );
        }
      },
    ),

    Menu(
      icon: Images.myFavorite,
      title: 'my_favorite'.tr,
      onTap: () {
        Get.back();
        Get.toNamed(ServiceRouteHelper.getMyFavoriteScreen());
      },
    ),

    if (Get.find<ServiceSplashController>().configModel.content!.walletStatus !=
            0 &&
        Get.find<ServiceAuthController>().isLoggedIn())
      Menu(
        icon: Images.walletMenu,
        title: 'my_wallet'.tr,
        onTap: () {
          Get.back();
          Get.toNamed(ServiceRouteHelper.getMyWalletScreen());
        },
      ),
    if (Get.find<ServiceSplashController>()
                .configModel
                .content!
                .loyaltyPointStatus !=
            0 &&
        Get.find<ServiceAuthController>().isLoggedIn())
      Menu(
        icon: Images.myPoint,
        title: 'loyalty_point'.tr,
        onTap: () {
          Get.back();
          Get.toNamed(ServiceRouteHelper.getLoyaltyPointScreen());
        },
      ),

    if (Get.find<ServiceSplashController>()
            .configModel
            .content
            ?.referEarnStatus ==
        1)
      Menu(
        title: 'refer_and_earn'.tr,
        icon: Images.shareIcon,
        onTap: () {
          Get.back();
          Get.toNamed(ServiceRouteHelper.getReferAndEarnScreen());
        },
      ),

    ...(Get.find<ServiceSplashController>()
                .configModel
                .content!
                .businessPages ??
            [])
        .map(
          (page) => Menu(
            icon: page.pageKey == HtmlType.aboutUs.value
                ? Images.aboutUs
                : page.pageKey == HtmlType.termsAndCondition.value
                ? Images.termsIcon
                : page.pageKey == HtmlType.privacyPolicy.value
                ? Images.privacyPolicyIcon
                : page.pageKey == HtmlType.cancellationPolicy.value
                ? Images.cancellationPolicy
                : page.pageKey == HtmlType.refundPolicy.value
                ? Images.refundPolicy
                : Images.othersPageIcon, // Or choose icon based on page
            title: _getPageTitle(page),
            onTap: () {
              Get.back();
              Get.toNamed(_getPageRoute(page));
            },
          ),
        ),

    Menu(
      icon: Images.helpIcon,
      title: 'help_&_support'.tr,
      onTap: () {
        Get.back();
        Get.toNamed(ServiceRouteHelper.getSupportRoute());
      },
    ),

    Menu(
      icon: Images.areaMenuIcon,
      title: 'service_area'.tr,
      onTap: () {
        Get.back();
        Get.toNamed(ServiceRouteHelper.getServiceArea());
      },
    ),

    Menu(
      icon: Images.logout,
      title: Get.find<ServiceAuthController>().isLoggedIn()
          ? 'logout'.tr
          : 'sign_in'.tr,
      onTap: () {
        Get.back();
        if (Get.find<ServiceAuthController>().isLoggedIn()) {
          Get.dialog(
            ConfirmationDialog(
              icon: Images.logoutIcon,
              title: 'are_you_sure_to_logout'.tr,
              description: "if_you_logged_out_your_cart_will_be_removed".tr,
              yesButtonColor: Theme.of(Get.context!).colorScheme.primary,
              onYesPressed: () {
                Get.find<ServiceAuthController>().logOut();
                Get.find<ServiceAuthController>().clearSharedData();
                Get.find<ServiceAuthController>().googleLogout();
                Get.find<ServiceAuthController>().signOutWithFacebook();
                Get.offAllNamed(ServiceRouteHelper.getInitialRoute());
                customSnackBar(
                  "logged_out_successfully".tr,
                  type: ToasterMessageType.success,
                );
              },
            ),
            useSafeArea: false,
          );
        } else {
          Get.toNamed(
            ServiceRouteHelper.getSignInRoute(redirectUrl: Get.currentRoute),
          );
        }
      },
    ),
  ];

  String _getPageTitle(BusinessPage page) {
    return page.pageKey == HtmlType.aboutUs.value
        ? 'about_us'.tr
        : page.pageKey == HtmlType.termsAndCondition.value
        ? 'terms_and_conditions'.tr
        : page.pageKey == HtmlType.privacyPolicy.value
        ? 'privacy_policy'.tr
        : page.pageKey == HtmlType.cancellationPolicy.value
        ? 'cancellation_policy'.tr
        : page.pageKey == HtmlType.refundPolicy.value
        ? 'refund_policy'.tr
        : page.title ?? '';
  }

  String _getPageRoute(BusinessPage page) {
    return page.pageKey == HtmlType.aboutUs.value
        ? ServiceRouteHelper.getAboutUsRoute()
        : page.pageKey == HtmlType.termsAndCondition.value
        ? ServiceRouteHelper.getTermsAndConditionsRoute()
        : page.pageKey == HtmlType.privacyPolicy.value
        ? ServiceRouteHelper.getPrivacyPolicyRoute()
        : page.pageKey == HtmlType.cancellationPolicy.value
        ? ServiceRouteHelper.getCancellationPolicyRoute()
        : page.pageKey == HtmlType.refundPolicy.value
        ? ServiceRouteHelper.getRefundPolicyRoute()
        : ''; // No route for custom pages - only standard HTML types are supported
  }

  static const _initialDelayTime = Duration(milliseconds: 200);
  static const _itemSlideTime = Duration(milliseconds: 250);
  static const _staggerTime = Duration(milliseconds: 50);
  static const _buttonDelayTime = Duration(milliseconds: 150);
  static const _buttonTime = Duration(milliseconds: 500);
  final _animationDuration =
      _initialDelayTime + (_staggerTime * 7) + _buttonDelayTime + _buttonTime;

  late AnimationController _staggeredController;
  final List<Interval> _itemSlideIntervals = [];

  @override
  void initState() {
    super.initState();

    _createAnimationIntervals();
    _staggeredController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();
  }

  void _createAnimationIntervals() {
    for (var i = 0; i < _menuList.length; ++i) {
      final startTime = _initialDelayTime + (_staggerTime * i);
      final endTime = startTime + _itemSlideTime;
      _itemSlideIntervals.add(
        Interval(
          startTime.inMilliseconds / _animationDuration.inMilliseconds,
          endTime.inMilliseconds / _animationDuration.inMilliseconds,
        ),
      );
    }
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? _buildContent()
        : const SizedBox();
  }

  Widget _buildContent() {
    return Align(
      alignment: Get.find<ServiceLocalizationController>().isLtr
          ? Alignment.topRight
          : Alignment.topLeft,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
          ),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeLarge,
                horizontal: 25,
              ),
              margin: const EdgeInsets.only(right: 30),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(Dimensions.radiusExtraLarge),
                ),
                color: Theme.of(context).primaryColor,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                'menu'.tr,
                style: robotoBold.copyWith(fontSize: 20, color: Colors.white),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: _menuList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _staggeredController,
                    builder: (context, child) {
                      final animationPercent = Curves.easeOut.transform(
                        _itemSlideIntervals[index].transform(
                          _staggeredController.value,
                        ),
                      );
                      final opacity = animationPercent;
                      final slideDistance = (1.0 - animationPercent) * 150;

                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(slideDistance, 0),
                          child: child,
                        ),
                      );
                    },
                    child: InkWell(
                      onTap: _menuList[index].onTap as void Function()?,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusExtraLarge,
                                ),
                                color: Theme.of(context).primaryColor,
                              ),
                              child: Image.asset(
                                _menuList[index].icon!,
                                height: 30,
                                width: 30,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(
                              child: Text(
                                _menuList[index].title ?? '',
                                style: robotoMedium,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Menu {
  String? icon;
  String? title;
  Function onTap;

  Menu({required this.icon, required this.title, required this.onTap});
}
