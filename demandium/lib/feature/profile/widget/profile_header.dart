import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class ProfileHeader extends GetView<UserController> {
  final UserInfoModel? userInfoModel;
  const ProfileHeader({super.key, required this.userInfoModel});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Get.find<ServiceAuthController>().isLoggedIn();
    return GetBuilder<UserController>(
      builder: (userController) {
        return SizedBox(
          width: Get.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault,
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: Get.width,
                  child: Column(
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(150.0),
                            ),
                            child: CustomImage(
                              width: 130.0,
                              height: 130.0,
                              image:
                                  userController.userInfoModel?.imageFullPath ??
                                  "",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: Dimensions.paddingSizeLarge,
                        height: Dimensions.paddingSizeExtraLarge,
                      ),
                      if (!isLoggedIn)
                        Text(
                          'guest_user'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withValues(alpha: .5),
                          ),
                        ),
                      if (isLoggedIn &&
                          userInfoModel?.fName != null &&
                          userInfoModel?.lName != null)
                        Text(
                          "${userInfoModel?.fName!} ${userInfoModel?.lName!}",
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color,
                          ),
                        ),

                      const SizedBox(
                        width: Dimensions.paddingSizeLarge,
                        height: Dimensions.paddingSizeExtraLarge,
                      ),
                      isLoggedIn
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (userInfoModel?.bookingsCount != null)
                                  ColumnText(
                                    amount: userInfoModel?.bookingsCount ?? 0,
                                    title: 'bookings'.tr,
                                  ),
                                ColumnText(
                                  isProfileTimeAgo: true,
                                  accountAgo: Get.find<UserController>()
                                      .createdAccountAgo
                                      .tr,
                                  amount: 340,
                                  title: 'since_joined'.tr,
                                ),
                              ],
                            )
                          : const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],
                  ),
                ),

                isLoggedIn
                    ? Positioned(
                        right: Get.find<ServiceLocalizationController>().isLtr
                            ? Dimensions.paddingSizeDefault
                            : null,
                        left: Get.find<ServiceLocalizationController>().isLtr
                            ? null
                            : Dimensions.paddingSizeDefault,
                        top: Dimensions.paddingSizeSmall,
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              ServiceRouteHelper.getEditProfileRoute(),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                'edit'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  color: Get.isDarkMode
                                      ? Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall,
                              ),
                              Icon(
                                Icons.edit,
                                color: Get.isDarkMode
                                    ? Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color
                                    : Theme.of(context).colorScheme.primary,
                                size: Dimensions.fontSizeExtraLarge,
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }
}
