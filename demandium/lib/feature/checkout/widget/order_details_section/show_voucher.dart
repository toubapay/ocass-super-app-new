import 'package:demandium/feature/checkout/widget/coupon_bottom_sheet_widget.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class ShowVoucher extends StatelessWidget {
  const ShowVoucher({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScheduleController>(
      builder: (scheduleController) {
        return GetBuilder<ServiceCartController>(
          builder: (cartController) {
            bool couponApplied =
                cartController.cartList.isNotEmpty &&
                cartController.cartList[0].couponCode != null &&
                cartController.cartList[0].couponCode != "";

            int scheduleDaysCount = scheduleController.scheduleDaysCount > 0
                ? scheduleController.scheduleDaysCount
                : 1;
            int applicableCouponCount =
                CheckoutHelper.getNumberOfDaysForApplicableCoupon(
                  pickedScheduleDays: scheduleDaysCount,
                ) ??
                1;
            double couponDisCount = CheckoutHelper.calculateDiscount(
              cartList: cartController.cartList,
              discountType: DiscountType.coupon,
              daysCount: applicableCouponCount,
            );

            return couponApplied
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.isDesktop(context)
                          ? 0
                          : Dimensions.paddingSizeDefault,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeDefault,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                      color: Theme.of(
                        context,
                      ).hintColor.withValues(alpha: 0.05),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  Images.successIcon,
                                  height: 18,
                                  width: 18,
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),

                                Text(
                                  'coupon_applied'.tr,
                                  style: robotoMedium.copyWith(),
                                ),
                              ],
                            ),

                            InkWell(
                              onTap: () {
                                if (ResponsiveHelper.isDesktop(context)) {
                                  Get.dialog(
                                    const Center(
                                      child: CouponBottomSheetWidget(
                                        orderAmount: 100,
                                      ),
                                    ),
                                  );
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (c) =>
                                        const CouponBottomSheetWidget(
                                          orderAmount: 100,
                                        ),
                                  );
                                }
                              },
                              child: Image.asset(
                                Images.editButton,
                                color: Get.isDarkMode
                                    ? Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color
                                    : Theme.of(context).colorScheme.primary,
                                height: 16,
                                width: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        Container(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeSmall + 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.40),
                              width: 0.5,
                            ),
                            color: Theme.of(context).cardColor,
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    Images.appliedCouponPercentIcon,
                                    height: 20,
                                    width: 20,
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeSmall,
                                  ),

                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        TextSpan(
                                          text:
                                              cartController
                                                  .cartList[0]
                                                  .couponCode ??
                                              "",
                                          style: robotoMedium.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        const WidgetSpan(
                                          child: SizedBox(
                                            width: Dimensions.paddingSizeSmall,
                                          ),
                                        ),

                                        TextSpan(
                                          text:
                                              '(-${PriceConverter.convertPrice(couponDisCount)} ${'off'.tr.toLowerCase()})',
                                          style: robotoMedium.copyWith(
                                            color: Get.isDarkMode
                                                ? Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge?.color
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              GetBuilder<ServiceCouponController>(
                                builder: (serviceCouponController) {
                                  return InkWell(
                                    onTap: serviceCouponController.isLoading
                                        ? null
                                        : () async {
                                            await Get.find<
                                                  ServiceCouponController
                                                >()
                                                .removeCoupon(
                                                  fromCheckout: true,
                                                );
                                            Get.find<ServiceCouponController>()
                                                .getCouponList();
                                            Get.find<ServiceCartController>()
                                                .openWalletPaymentConfirmDialog();
                                          },

                                    child: Icon(
                                      Icons.close,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      size: 20,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const ApplyVoucher();
          },
        );
      },
    );
  }
}

// Container(
//   width: MediaQuery.of(context).size.width,
//   margin:  EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault),
//   padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge,vertical: Dimensions.paddingSizeDefault),
//   decoration: BoxDecoration(color: Get.isDarkMode? Theme.of(context).hoverColor : Theme.of(context).cardColor, boxShadow: Get.find<ThemeController>().darkTheme ? null : cardShadow),
//   child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//
//     InkWell(
//       onTap: () => Get.toNamed(ServiceRouteHelper.getVoucherRoute(fromPage: 'checkout')),
//       child: Row( children: [
//         Image.asset(Images.couponIcon,width: 20.0,height: 20.0,),
//         const SizedBox(width: Dimensions.paddingSizeDefault,),
//         Text(cartController.cartList[0].couponCode??"",
//           style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),),
//         Text("applied".tr,style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .6),),),
//       ]),
//     ),
//
//     GetBuilder<ServiceCouponController>(builder: (ServiceCouponController){
//       return TextButton(
//         onPressed: ServiceCouponController.isLoading ? null : () async {
//           await Get.find<ServiceCouponController>().removeCoupon(fromCheckout: true);
//           Get.find<ServiceCartController>().openWalletPaymentConfirmDialog();
//         },
//         child: Text('remove'.tr,
//           style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error),),
//       );
//     })
//   ]),
// )
