import 'package:demandium/feature/booking/widget/custom_booking_details_expansion_tile.dart';
import 'package:demandium/feature/booking/widget/repeat/make_repeat_booking_payment.dart';
import 'package:demandium/feature/checkout/widget/payment_section/payment_dialog.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class PaymentView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final bool isSubBooking;
  const PaymentView({
    super.key,
    required this.bookingDetails,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    return isSubBooking &&
            bookingDetails.isPaid == 0 &&
            (bookingDetails.bookingStatus == "ongoing" ||
                bookingDetails.bookingStatus == "accepted")
        ? _MakePaymentView(bookingDetails)
        : _PaidPaymentView(bookingDetails);
  }
}

class _PaidPaymentView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;

  const _PaidPaymentView(this.bookingDetails);

  @override
  Widget build(BuildContext context) {
    bool isPartialPayment =
        bookingDetails.partialPayments != null &&
        bookingDetails.partialPayments!.isNotEmpty;
    double payAmount = bookingDetails.totalBookingAmount ?? 0;
    if (isPartialPayment) {
      bookingDetails.partialPayments?.forEach((element) {
        if (element.paidWith == "wallet") {
          payAmount = element.dueAmount ?? 0;
        }
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bookingDetails.offlinePaymentDeniedNote != null &&
            bookingDetails.paymentMethod == "offline_payment")
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSeven),
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(),
                Text(
                  "# ${"denied_note".tr} :",
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  "${bookingDetails.offlinePaymentDeniedNote}",
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ),

        if (bookingDetails.offlinePaymentDeniedNote != null &&
            bookingDetails.paymentMethod == "offline_payment")
          const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: Get.find<ServiceThemeController>().darkTheme
                ? null
                : searchBoxShadow,
          ), //boxShadow: shadow),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "payment_method".tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color?.withValues(alpha: 0.9),
                    ),
                  ),

                  Text(
                    bookingDetails.isPaid == 0 ? "unpaid".tr : "paid".tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault + 1,
                      color: bookingDetails.isPaid == 0
                          ? Theme.of(context).colorScheme.error
                          : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${bookingDetails.paymentMethod}'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault + 1,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),

                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      PriceConverter.convertPrice(
                        payAmount,
                        isShowLongPrice: true,
                      ),
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Get.isDarkMode
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),

              bookingDetails.paymentMethod == 'offline_payment' &&
                      bookingDetails.bookingOfflinePayment != null &&
                      bookingDetails.bookingOfflinePayment!.isNotEmpty
                  ? CustomBookingDetailsExpansionTile(
                      isShowExpandIcon: true,
                      tilePadding: EdgeInsets.zero,
                      isShowTrailingExpandIcon: false,
                      bookingTitle: 'payment_info'.tr,
                      bookingType:
                          bookingDetails.offlinePaymentMethodName ?? "",
                      children: [
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.2),
                        ),
                        SizedBox(
                          width: Get.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: bookingDetails
                                    .bookingOfflinePayment
                                    ?.length,
                                padding: const EdgeInsets.only(
                                  bottom: Dimensions.paddingSizeExtraSmall,
                                ),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      top: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    child: Text(
                                      "${bookingDetails.bookingOfflinePayment?[index].key?.replaceAll("_", " ").capitalizeFirst} "
                                      ": ${bookingDetails.bookingOfflinePayment?[index].value}",
                                      style: robotoRegular.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : bookingDetails.paymentMethod != "offline_payment" &&
                        bookingDetails.paymentMethod != "cash_after_service"
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Text(
                            "transaction_id".tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault + 1,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),
                          Text(
                            " : ${bookingDetails.transactionId?.replaceAll("_", " ").capitalizeFirst}",
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),

              (bookingDetails.isPaid == 0 &&
                      bookingDetails.paymentMethod == 'offline_payment' &&
                      bookingDetails.bookingOfflinePayment != null &&
                      bookingDetails.bookingOfflinePayment!.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              buttonText: "switch_to_cas_short".tr,
                              backgroundColor: Colors.transparent,
                              height: ResponsiveHelper.isDesktop(context)
                                  ? 45
                                  : 40,
                              textColor: Get.isDarkMode
                                  ? Theme.of(context).primaryColorLight
                                  : Theme.of(context).colorScheme.primary,
                              showBorder: true,
                              fontSize: Dimensions.fontSizeSmall,
                              radius: Dimensions.radiusSeven,
                              onPressed: () {
                                Get.dialog(
                                  ConfirmationDialog(
                                    icon: Images.warning,
                                    title: "switch_to_cas".tr,
                                    description:
                                        "are_you_sure_to_change_payment_offline_to_cas"
                                            .tr,
                                    noButtonText: "cancel".tr,
                                    yesButtonText: "yes_continue".tr,
                                    yesButtonColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    onYesPressed: () async {
                                      Get.back();
                                      Get.dialog(
                                        const CustomLoader(),
                                        barrierDismissible: false,
                                      );
                                      await Get.find<CheckOutController>()
                                          .switchPaymentMethod(
                                            bookingId: bookingDetails.id ?? "",
                                            paymentMethod: "cash_after_service",
                                          );

                                      Get.back();
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeLarge),
                          Expanded(
                            child: CustomButton(
                              height: ResponsiveHelper.isDesktop(context)
                                  ? 45
                                  : 40,
                              buttonText: "update_payment_info".tr,
                              radius: Dimensions.radiusSeven,
                              fontSize: Dimensions.fontSizeSmall,
                              onPressed: () {
                                var checkoutController =
                                    Get.find<CheckOutController>();
                                var offlinePaymentMethodList =
                                    checkoutController.offlinePaymentModelList;
                                int index = offlinePaymentMethodList.indexWhere(
                                  (offline) =>
                                      offline.id ==
                                      bookingDetails.offlinePaymentId,
                                );

                                if (index != -1) {
                                  checkoutController.changePaymentMethod(
                                    offlinePaymentModel:
                                        offlinePaymentMethodList[index],
                                  );
                                }

                                Get.toNamed(
                                  ServiceRouteHelper.getOfflinePaymentRoute(
                                    fromPage: 'booking_details',
                                    totalAmount: payAmount,
                                    index: index != -1 ? index : 0,
                                    offlinePaymentData:
                                        bookingDetails.bookingOfflinePayment,
                                    bookingId: bookingDetails.id,
                                    offlinePaymentId:
                                        bookingDetails.offlinePaymentId,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : (bookingDetails.paymentMethod == 'offline_payment' &&
                        bookingDetails.bookingOfflinePayment == null &&
                        bookingDetails.bookingStatus != "canceled")
                  ? Padding(
                      padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeEight,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusSmall,
                              ),
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.1),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: 5,
                            ),
                            child: Text(
                              "payment_incomplete".tr,
                              style: robotoMedium.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          CustomButton(
                            buttonText: "pay_now".tr,
                            height: 40,
                            width: 120,
                            radius: Dimensions.radiusSeven,
                            onPressed: () {
                              Get.find<CheckOutController>()
                                  .changePaymentMethod(shouldUpdate: false);
                              if (ResponsiveHelper.isDesktop(context)) {
                                Get.dialog(
                                  Center(
                                    child: PaymentDialog(
                                      booking: bookingDetails,
                                    ),
                                  ),
                                );
                              } else {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) {
                                    return PaymentDialog(
                                      booking: bookingDetails,
                                    );
                                  },
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }
}

class _MakePaymentView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const _MakePaymentView(this.bookingDetails);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: Get.find<ServiceThemeController>().darkTheme
            ? null
            : searchBoxShadow,
      ), //boxShadow: shadow),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: ResponsiveHelper.isDesktop(context) ? 4 : 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("${"total_amount".tr} :  ", style: robotoLight),
                    Text(
                      PriceConverter.convertPrice(
                        bookingDetails.totalBookingAmount ?? 0,
                      ),
                      style: robotoMedium,
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeTine),
                Row(
                  children: [
                    Text("${"payment_status".tr} :  ", style: robotoLight),
                    Text(
                      bookingDetails.isPaid == 1 ? "paid".tr : "unpaid".tr,
                      style: robotoMedium.copyWith(
                        color: bookingDetails.isPaid == 1
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                        fontSize: Dimensions.fontSizeSmall + 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: CustomButton(
              buttonText: "make_payment".tr,
              fontSize: Dimensions.fontSizeDefault,
              height: 40,
              onPressed: () {
                if (ResponsiveHelper.isDesktop(context)) {
                  Get.dialog(
                    RepeatBookingPaymentDialog(bookingDetails: bookingDetails),
                  );
                } else {
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => RepeatBookingPaymentDialog(
                      bookingDetails: bookingDetails,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
