import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class CustomPostCartSummary extends StatelessWidget {
  final PostDetailsContent? postDetails;
  final String amount;
  const CustomPostCartSummary({
    super.key,
    required this.postDetails,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    ConfigModel configModel = Get.find<ServiceSplashController>().configModel;
    double additionalCharge = CheckoutHelper.getAdditionalCharge();
    return Column(
      children: [
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Text(
          "cart_summary".tr,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          width: Get.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(
              color: Theme.of(context).hintColor.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    postDetails?.service?.name ?? "",
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.color!.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Text(
                    PriceConverter.convertPrice(double.tryParse(amount)),
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              GetBuilder<CheckOutController>(
                builder: (controller) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "vat".tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.color!.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Text(
                        "(+)${PriceConverter.convertPrice(controller.totalVat, isShowLongPrice: true)}",
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  );
                },
              ),
              (configModel.content?.additionalChargeLabelName != "" &&
                      configModel.content?.additionalCharge == 1)
                  ? const SizedBox(height: Dimensions.paddingSizeExtraSmall)
                  : const SizedBox(),

              (configModel.content?.additionalChargeLabelName != "" &&
                      configModel.content?.additionalCharge == 1)
                  ? GetBuilder<CheckOutController>(
                      builder: (controller) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              configModel.content?.additionalChargeLabelName ??
                                  "",
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeDefault,
                            ),
                            Text(
                              "(+)${PriceConverter.convertPrice(additionalCharge, isShowLongPrice: true)}",
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : const SizedBox(),

              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              (Get.find<CheckOutController>().referralDiscountAmount > 0)
                  ? GetBuilder<CheckOutController>(
                      builder: (controller) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "referral_discount".tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeDefault,
                            ),
                            Text(
                              "(-)${PriceConverter.convertPrice(controller.referralDiscountAmount, isShowLongPrice: true)}",
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : const SizedBox(),

              Divider(
                color: Theme.of(context).hintColor.withValues(alpha: 0.4),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "grand_total".tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.color!.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Text(
                    PriceConverter.convertPrice(
                      Get.find<CheckOutController>().totalAmount,
                      isShowLongPrice: true,
                    ),
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
      ],
    );
  }
}
