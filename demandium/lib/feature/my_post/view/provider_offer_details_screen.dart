import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class ProviderOfferDetailsScreen extends StatelessWidget {
  final ProviderOfferData? providerOfferData;
  final String? postId;
  const ProviderOfferDetailsScreen({
    super.key,
    required this.providerOfferData,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        appBar: CustomAppBar(title: "provider_offers".tr),
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        body: FooterBaseView(
          child: WebShadowWrap(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.3),
                      ),
                    ),
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusSmall,
                              ),
                              child: CustomImage(
                                height: 65,
                                width: 65,
                                fit: BoxFit.cover,
                                image:
                                    providerOfferData?.provider?.logoFullPath ??
                                    "",
                              ),
                            ),

                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  providerOfferData?.provider?.companyName ??
                                      "",
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      size: 10,
                                    ),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        " ${providerOfferData?.provider?.avgRating ?? ""}",
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color!
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeSmall,
                                    ),
                                    InkWell(
                                      child: Text(
                                        '${providerOfferData?.provider?.ratingCount ?? ""} ${'reviews'.tr}',
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color!
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "price_offered".tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeSmall,
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        double.tryParse(
                                          providerOfferData?.offeredPrice ??
                                              "0",
                                        ),
                                      ),
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        Text(
                          "description".tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),

                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text(
                          providerOfferData?.providerNote ?? "",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  Get.dialog(
                                    ConfirmationDialog(
                                      icon: Images.ignore,
                                      title: 'decline'.tr,
                                      description:
                                          'do_you_want_to_decline_this_request'
                                              .tr,
                                      yesButtonText: 'decline',
                                      onYesPressed: () async {
                                        Get.back();
                                        Get.dialog(
                                          const CustomLoader(),
                                          barrierDismissible: false,
                                        );
                                        await Get.find<CreatePostController>()
                                            .updatePostStatus(
                                              postId ?? "",
                                              providerOfferData?.provider?.id ??
                                                  "",
                                              'deny',
                                            );
                                        Get.back();
                                        Get.offAllNamed(
                                          ServiceRouteHelper.getMyPostScreen(),
                                        );
                                      },
                                    ),
                                    useSafeArea: true,
                                  );
                                },
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.error.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault,
                                    vertical: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'decline'.tr,
                                      style: robotoRegular.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  if (Get.find<CreatePostController>()
                                      .checkProviderAvailability(
                                        providerData:
                                            providerOfferData?.provider ??
                                            ProviderData(),
                                      )) {
                                    Get.toNamed(
                                      ServiceRouteHelper.getCustomPostCheckoutRoute(
                                        postId ?? "",
                                        providerOfferData?.provider?.id ?? "",
                                        providerOfferData?.offeredPrice ?? "",
                                        providerOfferData?.id ?? "",
                                      ),
                                    );
                                  } else {
                                    customSnackBar(
                                      "your_selected_provider_is_unavailable_right_now"
                                          .tr,
                                    );
                                  }
                                },
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault,
                                    vertical: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'accept'.tr,
                                      style: robotoRegular.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
