import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class Voucher extends StatelessWidget {
  final bool isExpired;
  final CouponModel couponModel;
  final int index;
  final bool fromCheckout;
  final Function(CouponModel couponData)? onTap;
  const Voucher({
    super.key,
    required this.couponModel,
    required this.isExpired,
    required this.index,
    this.fromCheckout = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceCouponController>(
      builder: (serviceCouponController) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            color: Theme.of(context).hoverColor,
            boxShadow: Get.find<ServiceThemeController>().darkTheme
                ? null
                : cardShadow,
          ),
          margin: EdgeInsets.symmetric(
            horizontal: fromCheckout ? 0 : Dimensions.paddingSizeDefault,
          ),
          padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
          width: context.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Image.asset(Images.voucherImage, fit: BoxFit.fitWidth),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        couponModel.discount?.discountTitle ?? "",
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiary.withValues(alpha: 0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      Wrap(
                        runAlignment: WrapAlignment.start,
                        children: [
                          Text(
                            "${'use_code'.tr} ${couponModel.couponCode!} ${'to_save_upto'.tr}",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withValues(alpha: .5),
                            ),
                          ),

                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              "${PriceConverter.convertPrice(couponModel.discount!.discountAmountType == 'amount' ? couponModel.discount!.discountAmount!.toDouble() : couponModel.discount!.maxDiscountAmount!.toDouble())} ",
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: .5),
                              ),
                            ),
                          ),

                          Text(
                            'on_your_next_purchase'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withValues(alpha: .5),
                            ),
                          ),
                        ],
                      ),

                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "valid_till".tr,
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withValues(alpha: .6),
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),
                              Text(
                                couponModel.discount!.endDate.toString(),
                                style: robotoBold.copyWith(
                                  color: Get.isDarkMode
                                      ? Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color
                                      : Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          serviceCouponController.isLoading &&
                                  index ==
                                      serviceCouponController
                                          .selectedCouponIndex &&
                                  !fromCheckout
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault,
                                  ),
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : InkWell(
                                  onTap: fromCheckout
                                      ? () {
                                          if (couponModel.isUsed != 1) {
                                            onTap!(couponModel);
                                          }
                                        }
                                      : !isExpired
                                      ? () async {
                                          serviceCouponController
                                              .updateSelectedCouponIndex(
                                                index: index,
                                              );

                                          if (Get.find<ServiceAuthController>()
                                              .isLoggedIn()) {
                                            if (Get.find<
                                                  ServiceCartController
                                                >()
                                                .cartList
                                                .isNotEmpty) {
                                              bool addCoupon = false;
                                              Get.find<ServiceCartController>()
                                                  .cartList
                                                  .forEach((cart) {
                                                    if (cart.totalCost >=
                                                        couponModel
                                                            .discount!
                                                            .minPurchase!
                                                            .toDouble()) {
                                                      addCoupon = true;
                                                    }
                                                  });
                                              if (addCoupon) {
                                                await Get.find<
                                                      ServiceCouponController
                                                    >()
                                                    .applyCoupon(
                                                      couponModel.couponCode!,
                                                    )
                                                    .then((value) async {
                                                      if (value.isSuccess!) {
                                                        Get.find<
                                                              ServiceCartController
                                                            >()
                                                            .getCartListFromServer();
                                                        if (fromCheckout) {
                                                          Get.back();
                                                        }

                                                        customCouponSnackBar(
                                                          "coupon_applied_successfully"
                                                              .tr,
                                                          subtitle:
                                                              "review_your_cart_for_applied_discounts"
                                                                  .tr,
                                                          isError: false,
                                                        );
                                                      } else {
                                                        customCouponSnackBar(
                                                          "can_not_apply_coupon",
                                                          subtitle:
                                                              "${value.message}",
                                                        );
                                                      }
                                                    });
                                              } else {
                                                customCouponSnackBar(
                                                  "can_not_apply_coupon",
                                                  subtitle:
                                                      "${'valid_for_minimum_booking_amount_of'.tr} ${PriceConverter.convertPrice(couponModel.discount?.minPurchase ?? 0)} ",
                                                );
                                              }
                                            } else {
                                              customCouponSnackBar(
                                                "oops",
                                                subtitle:
                                                    "looks_like_no_service_is_added_to_your_cart",
                                              );
                                            }
                                          } else {
                                            customCouponSnackBar(
                                              "sorry_you_can_not_use_coupon",
                                              subtitle:
                                                  "please_login_to_use_coupon",
                                            );
                                          }
                                        }
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeDefault,
                                      vertical:
                                          Dimensions.paddingSizeExtraSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isExpired || couponModel.isUsed == 1
                                          ? Theme.of(context).disabledColor
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(Dimensions.radiusSmall),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        isExpired
                                            ? 'expired'.tr
                                            : couponModel.isUsed == 1
                                            ? "used".tr.toUpperCase()
                                            : 'use'.tr.toUpperCase(),
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).primaryColorLight,
                                          fontSize: Dimensions.fontSizeDefault,
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
              ),
            ],
          ),
        );
      },
    );
  }
}
