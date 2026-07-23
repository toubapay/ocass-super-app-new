import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class ExploreProviderCard extends StatelessWidget {
  final bool showShimmer;
  const ExploreProviderCard({super.key, required this.showShimmer});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProviderBookingController>(
      builder: (providerBookingController) {
        return (showShimmer || providerBookingController.providerList == null)
            ? const ExploreProviderCardShimmer()
            : providerBookingController.providerList != null &&
                  providerBookingController.providerList!.isNotEmpty
            ? Stack(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                        child: Image.asset(
                          Images.mapBackground,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Theme.of(
                                  context,
                                ).cardColor.withValues(alpha: 0.7)
                              : Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.09),
                        ),
                      ),

                      Align(
                        alignment:
                            Get.find<ServiceLocalizationController>().isLtr
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft,
                        child: Image.asset(
                          Images.exploreProvider,
                          height: 140,
                          width: 120,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        top: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  right:
                                      Get.find<ServiceLocalizationController>()
                                          .isLtr
                                      ? Dimensions.paddingSizeExtraMoreLarge
                                      : 0,
                                  left:
                                      Get.find<ServiceLocalizationController>()
                                          .isLtr
                                      ? 0
                                      : Dimensions.paddingSizeExtraMoreLarge,
                                ),
                                child: Text(
                                  "explore_nearby_providers".tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),
                              Text(
                                "find_services_just_near_you".tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withValues(alpha: 0.6),
                                ),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              Row(
                                children: [
                                  Text(
                                    "see_providers".tr,
                                    style: robotoRegular.copyWith(
                                      color: Get.isDarkMode
                                          ? Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeSmall,
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Get.isDarkMode
                                        ? Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color
                                        : Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned.fill(
                    child: RippleButton(
                      onTap: () {
                        Get.toNamed(
                          ServiceRouteHelper.getNearByProviderScreen(
                            tabIndex: 1,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox();
      },
    );
  }
}

class ExploreProviderCardShimmer extends StatelessWidget {
  const ExploreProviderCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),

        child: Stack(
          children: [
            Opacity(
              opacity: Get.isDarkMode ? 0.1 : 0.9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: Image.asset(
                  Images.mapBackground,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Get.isDarkMode
                    ? Theme.of(context).shadowColor
                    : Theme.of(context).shadowColor.withValues(alpha: 0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 15,
                    width: 150,
                    color: Theme.of(context).cardColor,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 15,
                    width: 100,
                    color: Theme.of(context).cardColor,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 10,
                    width: 120,
                    color: Theme.of(context).cardColor,
                  ),
                ],
              ),
            ),

            Align(
              alignment: Get.find<ServiceLocalizationController>().isLtr
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              child: Image.asset(
                Images.exploreProvider,
                height: 120,
                width: 110,
                color: Theme.of(context).shadowColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
