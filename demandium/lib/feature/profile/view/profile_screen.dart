import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:demandium/feature/profile/model/profile_cart_item_model.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    if (Get.find<ServiceAuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo(reload: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool pickedAddress =
        Get.find<ServiceLocationController>().getUserAddress() != null;

    final profileCartModelList = [
      ProfileCardItemModel(
        'my_address'.tr,
        Images.address,
        ServiceRouteHelper.getAddressRoute('fromProfileScreen'),
      ),
      ProfileCardItemModel(
        'notifications'.tr,
        Images.notification,
        pickedAddress
            ? ServiceRouteHelper.getNotificationRoute()
            : ServiceRouteHelper.getPickMapRoute(
                ServiceRouteHelper.notification,
                true,
                'false',
                null,
                null,
              ),
      ),
      if (!Get.find<ServiceAuthController>().isLoggedIn())
        ProfileCardItemModel(
          'sign_in'.tr,
          Images.logout,
          ServiceRouteHelper.getSignInRoute(
            redirectUrl: ServiceRouteHelper.profile,
          ),
        ),

      if (Get.find<ServiceAuthController>().isLoggedIn())
        ProfileCardItemModel(
          'suggest_new_service'.tr,
          Images.suggestServiceIcon,
          pickedAddress
              ? ServiceRouteHelper.getNewSuggestedServiceScreen()
              : ServiceRouteHelper.getPickMapRoute(
                  ServiceRouteHelper.suggestService,
                  true,
                  'false',
                  null,
                  null,
                ),
        ),

      // if (Get.find<ServiceAuthController>().isLoggedIn())
      //   ProfileCardItemModel(
      //     'delete_account'.tr,
      //     Images.accountDelete,
      //     'delete_account',
      //   ),
      if (Get.find<ServiceAuthController>().isLoggedIn())
        ProfileCardItemModel('logout'.tr, Images.logout, 'sign_out'),
    ];

    return CustomPopWidget(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(
          title: 'profile'.tr,
          centerTitle: true,
          bgColor: Theme.of(context).primaryColor,
          isBackButtonExist: true,
          onBackPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAllNamed(ServiceRouteHelper.getMainRoute("home"));
            }
          },
        ),

        body: GetBuilder<UserController>(
          builder: (userController) {
            return userController.userInfoModel == null &&
                    Get.find<ServiceAuthController>().isLoggedIn()
                ? const Center(child: CircularProgressIndicator())
                : FooterBaseView(
                    child: WebShadowWrap(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ProfileHeader(
                            userInfoModel: userController.userInfoModel,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      ResponsiveHelper.isMobile(context)
                                      ? 1
                                      : 2,
                                  childAspectRatio: 6,
                                  crossAxisSpacing:
                                      Dimensions.paddingSizeExtraLarge,
                                  mainAxisSpacing: Dimensions.paddingSizeSmall,
                                ),
                            itemCount: profileCartModelList.length,
                            itemBuilder: (context, index) {
                              return ProfileCardItem(
                                title: profileCartModelList[index].title,
                                leadingIcon:
                                    profileCartModelList[index].loadingIcon,
                                onTap: () {
                                  if (profileCartModelList[index].routeName ==
                                      'sign_out') {
                                    if (Get.find<ServiceAuthController>()
                                        .isLoggedIn()) {
                                      Get.dialog(
                                        ConfirmationDialog(
                                          icon: Images.logoutIcon,
                                          title: 'are_you_sure_to_logout'.tr,
                                          description:
                                              "if_you_logged_out_your_cart_will_be_removed"
                                                  .tr,
                                          yesButtonColor: Theme.of(
                                            Get.context!,
                                          ).colorScheme.primary,
                                          onYesPressed: () async {
                                            //main app logout
                                            // Get.find<AuthController>()
                                            //     .resetOtpView();
                                            // Get.find<ProfileController>()
                                            //     .clearUserInfo();
                                            // Get.find<AuthController>()
                                            //     .socialLogout();
                                            // Get.find<CartController>()
                                            //     .clearCartList(
                                            //       canRemoveOnline: false,
                                            //     );
                                            // Get.find<FavouriteController>()
                                            //     .removeFavourite();
                                            // await Get.find<AuthController>()
                                            //     .clearSharedData();
                                            // Get.find<HomeController>()
                                            //     .forcefullyNullCashBackOffers();
                                            // Get.find<TaxiCartController>()
                                            //     .getCarCartList();

                                            //logout from service module
                                            Get.find<ServiceAuthController>()
                                                .clearSharedData();
                                            Get.find<ServiceAuthController>()
                                                .googleLogout();
                                            Get.find<ServiceAuthController>()
                                                .signOutWithFacebook();
                                            Get.find<ServiceAuthController>()
                                                .signOutWithFacebook();
                                            Get.offAllNamed(
                                              ServiceRouteHelper.getInitialRoute(),
                                            );
                                          },
                                        ),
                                        useSafeArea: false,
                                      );
                                    } else {
                                      Get.toNamed(
                                        ServiceRouteHelper.getSignInRoute(),
                                      );
                                    }
                                  } else if (profileCartModelList[index]
                                          .routeName ==
                                      'delete_account') {
                                    Get.dialog(
                                      ConfirmationDialog(
                                        icon: Images.deleteProfile,
                                        title:
                                            'are_you_sure_to_delete_your_account'
                                                .tr,
                                        description:
                                            'it_will_remove_your_all_information'
                                                .tr,
                                        yesButtonText: 'delete',
                                        noButtonText: 'cancel',
                                        onYesPressed: () =>
                                            userController.removeUser(),
                                      ),
                                      useSafeArea: false,
                                    );
                                  } else {
                                    Get.toNamed(
                                      profileCartModelList[index].routeName,
                                    );
                                  }
                                },
                              );
                            },
                          ),

                          const SizedBox(height: Dimensions.paddingSizeDefault),
                        ],
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }
}
