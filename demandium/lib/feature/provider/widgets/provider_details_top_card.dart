import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class ProviderDetailsTopCard extends StatelessWidget {
  final String providerId;
  final Color? color;
  const ProviderDetailsTopCard({
    super.key,
    required this.providerId,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLtr = Get.find<ServiceLocalizationController>().isLtr;

    return GetBuilder<ProviderBookingController>(
      builder: (providerController) {
        ProviderData providerDetails =
            providerController.providerDetailsContent!.provider!;
        Rating? providerReview =
            providerController.providerDetailsContent?.providerRating;
        return Column(
          children: [
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                if (ResponsiveHelper.isDesktop(context)) {
                  Get.dialog(
                    Center(
                      child: ProviderAvailabilityWidget(providerId: providerId),
                    ),
                  );
                } else {
                  showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (context) =>
                        ProviderAvailabilityWidget(providerId: providerId),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color ?? Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(
                    color: color != null
                        ? Colors.transparent
                        : Theme.of(context).hintColor.withValues(alpha: 0.15),
                  ),
                ),
                margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeDefault,
                        ),
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: ResponsiveHelper.isDesktop(context)
                                        ? 15
                                        : 0,
                                    right:
                                        ResponsiveHelper.isDesktop(context) &&
                                            isLtr
                                        ? Dimensions.paddingSizeLarge
                                        : 0,
                                    left:
                                        ResponsiveHelper.isDesktop(context) &&
                                            !isLtr
                                        ? 0
                                        : Dimensions.paddingSizeLarge,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusExtraMoreLarge,
                                            ),
                                            child: CustomImage(
                                              height: 90,
                                              width: 90,
                                              fit: BoxFit.cover,
                                              image:
                                                  providerDetails
                                                      .logoFullPath ??
                                                  "",
                                              placeholder:
                                                  Images.userPlaceHolder,
                                            ),
                                          ),

                                          Container(
                                            decoration: BoxDecoration(
                                              boxShadow: searchBoxShadow,
                                              color: Theme.of(
                                                context,
                                              ).cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeEight,
                                              vertical: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.circle,
                                                  size: 10,
                                                  color:
                                                      providerDetails
                                                              .serviceAvailability ==
                                                          1
                                                      ? Colors.green
                                                      : Theme.of(
                                                          context,
                                                        ).colorScheme.error,
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeTine,
                                                ),

                                                Text(
                                                  providerDetails
                                                              .serviceAvailability ==
                                                          1
                                                      ? "available".tr
                                                      : "unavailable".tr,
                                                  style: robotoMedium.copyWith(
                                                    color:
                                                        providerDetails
                                                                .serviceAvailability ==
                                                            1
                                                        ? Colors.green
                                                        : Theme.of(
                                                            context,
                                                          ).colorScheme.error,
                                                    fontSize:
                                                        Dimensions
                                                            .fontSizeSmall -
                                                        2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeDefault,
                                      ),

                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              providerDetails.companyName ?? '',
                                              style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeEight,
                                            ),

                                            Row(
                                              children: [
                                                Image.asset(
                                                  Images.iconLocation,
                                                  height: 12,
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall,
                                                ),

                                                Flexible(
                                                  child: Text(
                                                    providerDetails
                                                            .companyAddress ??
                                                        "",
                                                    style: robotoRegular
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.color
                                                                  ?.withValues(
                                                                    alpha: 0.7,
                                                                  ),
                                                        ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            if (ResponsiveHelper.isDesktop(
                                              context,
                                            )) ...[
                                              SizedBox(
                                                height:
                                                    Dimensions.paddingSizeLarge,
                                              ),
                                              _ReviewInfoCard(
                                                providerReview: providerReview,
                                                providerId: providerId,
                                                providerDetails:
                                                    providerDetails,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Positioned.fill(
                                  right: ResponsiveHelper.isDesktop(context)
                                      ? 0
                                      : isLtr
                                      ? -20
                                      : 0,
                                  left: ResponsiveHelper.isDesktop(context)
                                      ? 0
                                      : isLtr
                                      ? 0
                                      : -20,
                                  top: -20,
                                  child: Align(
                                    alignment: isLtr
                                        ? Alignment.topRight
                                        : Alignment.topLeft,
                                    child: FavoriteIconWidget(
                                      value: providerDetails.isFavorite,
                                      providerId: providerDetails.id,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            if (!ResponsiveHelper.isDesktop(context))
                              _ReviewInfoCard(
                                providerReview: providerReview,
                                providerId: providerId,
                                providerDetails: providerDetails,
                              ),
                          ],
                        ),
                      ),
                    ),

                    if (ResponsiveHelper.isDesktop(context))
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(
                                isLtr ? Dimensions.radiusDefault : 0,
                              ),
                              topRight: Radius.circular(
                                isLtr ? Dimensions.radiusDefault : 0,
                              ),
                              bottomLeft: Radius.circular(
                                isLtr ? 0 : Dimensions.radiusDefault,
                              ),
                              topLeft: Radius.circular(
                                isLtr ? 0 : Dimensions.radiusDefault,
                              ),
                            ),
                            border: Border.all(
                              color: color != null
                                  ? Colors.transparent
                                  : Theme.of(
                                      context,
                                    ).hintColor.withValues(alpha: 0.15),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(
                                isLtr ? Dimensions.radiusDefault : 0,
                              ),
                              topRight: Radius.circular(
                                isLtr ? Dimensions.radiusDefault : 0,
                              ),
                              bottomLeft: Radius.circular(
                                isLtr ? 0 : Dimensions.radiusDefault,
                              ),
                              topLeft: Radius.circular(
                                isLtr ? 0 : Dimensions.radiusDefault,
                              ),
                            ),
                            child: CustomImage(
                              image:
                                  providerController
                                      .providerDetailsContent
                                      ?.provider
                                      ?.coverImageFullPath ??
                                  '',
                              placeholder: Images.placeholder,
                              width: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.webMaxWidth / 2
                                  : context.width,
                              height:
                                  (ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.webMaxWidth / 2
                                      : context.width) /
                                  3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReviewInfoCard extends StatelessWidget {
  final Rating? providerReview;
  final ProviderData providerDetails;
  final String providerId;
  const _ReviewInfoCard({
    required this.providerReview,
    required this.providerId,
    required this.providerDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              if (ResponsiveHelper.isDesktop(context)) {
                Get.dialog(
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: Get.height * 0.8),
                      child: Container(
                        width: ResponsiveHelper.isDesktop(context)
                            ? Dimensions.webMaxWidth / 2
                            : Dimensions.webMaxWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSeven,
                          ),
                          color: Theme.of(context).cardColor,
                        ),
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeSmall,
                        ),
                        child: ProviderReviewBody(providerId: providerId),
                      ),
                    ),
                  ),
                );
              } else {
                Get.toNamed(
                  ServiceRouteHelper.getProviderReviewScreen(providerId),
                );
              }
            },
            child: Flex(
              spacing: Dimensions.paddingSizeExtraSmall,
              direction: ResponsiveHelper.isDesktop(context)
                  ? Axis.horizontal
                  : Axis.vertical,
              children: [
                Row(
                  children: [
                    Image.asset(
                      Images.starIcon,
                      color: Theme.of(context).colorScheme.secondary,
                      height: 15,
                      fit: BoxFit.fitHeight,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeTine),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        providerDetails.avgRating!.toStringAsFixed(2),
                        style: robotoBold.copyWith(
                          color: Get.isDarkMode
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Theme.of(context).colorScheme.primary,
                          fontSize: ResponsiveHelper.isDesktop(context)
                              ? Dimensions.fontSizeSmall
                              : Dimensions.fontSizeDefault,
                        ),
                      ),
                    ),

                    Gaps.horizontalGapOf(5),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        "(${providerReview?.ratingCount ?? ""})",
                        style: robotoBold.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                          fontSize: ResponsiveHelper.isDesktop(context)
                              ? Dimensions.fontSizeSmall
                              : Dimensions.fontSizeDefault,
                        ),
                      ),
                    ),
                  ],
                ),

                Text(
                  '${providerReview?.reviewCount ?? ""} ${'reviews'.tr}',
                  style: robotoRegular.copyWith(
                    color: Get.isDarkMode
                        ? Theme.of(context).hintColor
                        : Theme.of(context).colorScheme.primary,
                    fontSize: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.fontSizeSmall
                        : Dimensions.fontSizeDefault,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 1,
            height: ResponsiveHelper.isDesktop(context)
                ? Dimensions.paddingSizeDefault
                : 30,
            margin: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeExtraSmall,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withValues(alpha: 0.5),
            ),
          ),

          Flex(
            direction: ResponsiveHelper.isDesktop(context)
                ? Axis.horizontal
                : Axis.vertical,
            spacing: Dimensions.paddingSizeExtraSmall,
            children: [
              Text(
                '${providerDetails.totalServiceServed ?? "0"}',
                style: robotoBold.copyWith(
                  fontSize: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.fontSizeSmall
                      : Dimensions.fontSizeDefault,
                ),
              ),

              Text(
                'services_provided'.tr,
                style: robotoRegular.copyWith(
                  fontSize: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.fontSizeSmall
                      : Dimensions.fontSizeDefault,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          if (ResponsiveHelper.isDesktop(context))
            SizedBox(width: Dimensions.paddingSizeSmall),
        ],
      ),
    );
  }
}
