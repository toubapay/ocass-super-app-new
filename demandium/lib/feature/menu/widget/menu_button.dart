import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class MenuButton extends StatelessWidget {
  final MenuModel menu;
  const MenuButton({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    int count = ResponsiveHelper.isTab(context) ? 6 : 4;
    double size =
        ((context.width > Dimensions.webMaxWidth
                ? Dimensions.webMaxWidth
                : context.width) /
            count) -
        Dimensions.paddingSizeDefault;

    return Stack(
      children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(Dimensions.paddingSizeExtraSmall),
                ),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
              height: size - (size * 0.25),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              margin: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
              ),
              alignment: Alignment.center,
              child: Image.asset(menu.icon!, width: size, height: size),
            ),
            const SizedBox(height: Dimensions.paddingSizeEight),
            Text(
              menu.title!,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Positioned.fill(
          child: RippleButton(
            onTap: () async {
              if (menu.isLogout) {
                Get.back();
                if (Get.find<ServiceAuthController>().isLoggedIn()) {
                  Get.dialog(
                    ConfirmationDialog(
                      icon: Images.logoutIcon,
                      title: 'are_you_sure_to_logout'.tr,
                      description:
                          "if_you_logged_out_your_cart_will_be_removed".tr,
                      onYesPressed: () {
                        Get.find<ServiceAuthController>().clearSharedData();
                        Get.find<ServiceAuthController>().logOut();
                        Get.find<ServiceAuthController>().googleLogout();
                        Get.find<ServiceAuthController>().signOutWithFacebook();
                        Get.find<ServiceLocationController>()
                            .updateSelectedAddress(null);
                        Get.offAllNamed(ServiceRouteHelper.getInitialRoute());
                        // customSnackBar("logged_out_successfully".tr, type : ToasterMessageType.success);
                      },
                    ),
                    useSafeArea: false,
                  );
                } else {
                  Get.toNamed(ServiceRouteHelper.getSignInRoute());
                }
              } else if (menu.route!.startsWith('http')) {
                if (await canLaunchUrlString(menu.route!)) {
                  launchUrlString(
                    menu.route!,
                    mode: LaunchMode.externalApplication,
                  );
                }
              } else {
                if (menu.route!.contains('/language')) {
                  Get.back();
                  Get.bottomSheet(
                    const ChooseLanguageBottomSheet(),
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                  );
                } else {
                  Get.offNamed(menu.route!);
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
