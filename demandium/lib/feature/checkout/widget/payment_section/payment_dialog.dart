import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class PaymentDialog extends StatefulWidget {
  final BookingDetailsContent? booking;
  const PaymentDialog({super.key, this.booking});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  @override
  void initState() {
    super.initState();
    Get.find<ServiceCartController>().updateWalletPaymentStatus(
      false,
      shouldUpdate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).padding.bottom;

    double? bookingAmount;
    bool isPartialPayment =
        widget.booking?.partialPayments != null &&
        (widget.booking?.partialPayments?.isNotEmpty ?? false);

    if (isPartialPayment) {
      widget.booking?.partialPayments?.forEach((element) {
        if (element.paidWith == "wallet") {
          bookingAmount = element.dueAmount ?? 0;
        }
      });
    } else {
      bookingAmount = widget.booking?.totalBookingAmount;
    }

    return GetBuilder<ServiceCartController>(
      builder: (cartController) {
        return GetBuilder<CheckOutController>(
          builder: (checkoutController) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(Dimensions.paddingSizeDefault),
                  topRight: const Radius.circular(
                    Dimensions.paddingSizeDefault,
                  ),
                  bottomLeft: ResponsiveHelper.isDesktop(context)
                      ? const Radius.circular(Dimensions.paddingSizeDefault)
                      : Radius.zero,
                  bottomRight: ResponsiveHelper.isDesktop(context)
                      ? const Radius.circular(Dimensions.paddingSizeDefault)
                      : Radius.zero,
                ),
              ),
              child: SizedBox(
                width: Dimensions.webMaxWidth / 2.5,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                text: "${'total_amount'.tr}  ",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                              ),
                              TextSpan(
                                text: PriceConverter.convertPrice(
                                  bookingAmount,
                                ),
                                style: robotoBold.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),

                        Flexible(
                          child: PaymentPage(
                            addressId: "",
                            tooltipController: JustTheController(),
                            fromPage: "payment_dialog",
                            avoidDesktopDesign: true,
                            bookingAmount: bookingAmount,
                            avoidPartialPayment: isPartialPayment,
                          ),
                        ),

                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          child: CustomButton(
                            buttonText: 'complete_payment'.tr,
                            onPressed: () {
                              _confirmPayment(
                                checkoutController: checkoutController,
                                cartController: cartController,
                                bookingAmount: bookingAmount ?? 0,
                                bookingId: widget.booking?.id ?? "",
                              );
                            },
                            isLoading: checkoutController.isLoading,
                            radius: Dimensions.radiusSeven,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),

                        SizedBox(
                          height: bottomPadding > 0
                              ? bottomPadding
                              : Dimensions.paddingSizeDefault,
                        ),
                      ],
                    ),
                    Positioned(
                      top: 10,
                      right: 0,
                      child: InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeTine,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmPayment({
    required CheckOutController checkoutController,
    required ServiceCartController cartController,
    required double bookingAmount,
    required String bookingId,
  }) {
    double walletBalance = cartController.walletBalance;
    bool isPartialPayment = CheckoutHelper.checkPartialPayment(
      walletBalance: walletBalance,
      bookingAmount: bookingAmount,
    );

    if (cartController.walletPaymentStatus &&
        isPartialPayment &&
        checkoutController.selectedPaymentMethod ==
            PaymentMethodName.walletMoney) {
      customSnackBar(
        "select_another_payment_method_to_pay_remaining_bill".tr,
        type: ToasterMessageType.info,
        showDefaultSnackBar: false,
      );
    } else if (checkoutController.selectedPaymentMethod ==
        PaymentMethodName.none) {
      customSnackBar(
        "select_payment_method".tr,
        type: ToasterMessageType.info,
        showDefaultSnackBar: false,
      );
    } else if (checkoutController.selectedPaymentMethod ==
        PaymentMethodName.cos) {
      checkoutController.switchPaymentMethod(
        bookingId: widget.booking?.id ?? "",
        paymentMethod: "cash_after_service",
        isPartial: isPartialPayment && cartController.walletPaymentStatus
            ? 1
            : 0,
      );
    } else if (checkoutController.selectedPaymentMethod ==
        PaymentMethodName.walletMoney) {
      checkoutController.switchPaymentMethod(
        bookingId: widget.booking?.id ?? "",
        paymentMethod: "wallet_payment",
        isPartial: isPartialPayment && cartController.walletPaymentStatus
            ? 1
            : 0,
      );
    } else if (checkoutController.selectedPaymentMethod ==
        PaymentMethodName.offline) {
      if (checkoutController.selectedOfflineMethod != null) {
        int selectedOfflinePaymentIndex = checkoutController
            .offlinePaymentModelList
            .indexOf(checkoutController.selectedOfflineMethod!);
        Get.back();
        Get.toNamed(
          ServiceRouteHelper.getOfflinePaymentRoute(
            totalAmount: bookingAmount,
            index: selectedOfflinePaymentIndex != -1
                ? selectedOfflinePaymentIndex
                : 0,
            bookingId: bookingId,
            isPartialPayment:
                isPartialPayment && cartController.walletPaymentStatus ? 1 : 0,
            fromPage: "others",
          ),
        );
      } else {
        customSnackBar(
          "provide_offline_payment_info".tr,
          type: ToasterMessageType.info,
          showDefaultSnackBar: false,
        );
      }
    } else if (checkoutController.selectedPaymentMethod ==
        PaymentMethodName.digitalPayment) {
      if (checkoutController.selectedDigitalPaymentMethod != null &&
          checkoutController.selectedDigitalPaymentMethod?.gateway !=
              "offline") {
        _makeDigitalPayment(
          paymentMethod: checkoutController.selectedDigitalPaymentMethod,
          isPartialPayment: isPartialPayment,
          bookingId: bookingId,
        );
      } else {
        customSnackBar(
          "select_any_payment_method".tr,
          type: ToasterMessageType.info,
          showDefaultSnackBar: false,
        );
      }
    }

    if (isPartialPayment) {
      cartController.getCartListFromServer();
    }
  }

  Future<void> _makeDigitalPayment({
    DigitalPaymentMethod? paymentMethod,
    required bool isPartialPayment,
    required String bookingId,
  }) async {
    String url = '';
    String hostname = html.window.location.hostname!;
    String protocol = html.window.location.protocol;
    String port = html.window.location.port;
    String? path = ServiceRouteHelper.bookingDetailsScreen;

    String userId =
        Get.find<UserController>().userInfoModel?.id ??
        Get.find<ServiceSplashController>().getGuestId();
    String callbackUrl = GetPlatform.isWeb
        ? "$protocol//$hostname:$port$path"
        : AppConstants.baseUrl;
    int isPartial =
        Get.find<ServiceCartController>().walletPaymentStatus &&
            isPartialPayment
        ? 1
        : 0;
    String platform = ResponsiveHelper.isWeb() ? "web" : "app";

    url =
        '${AppConstants.baseUrl}/payment?payment_method=${paymentMethod?.gateway}&access_token=${base64Url.encode(utf8.encode(userId))}'
        '&booking_id=$bookingId&switch_offline_to_digital=1&callback=$callbackUrl&is_partial=$isPartial&payment_platform=$platform';

    if (GetPlatform.isWeb) {
      printLog("url_with_digital_payment:$url");
      html.window.open(url, "_self");
    } else {
      Get.back();
      printLog("url_with_digital_payment_mobile:$url");
      await Get.to(
        () => PaymentScreen(url: url, fromPage: "switch-payment-method"),
      );
      Get.find<BookingDetailsController>().getBookingDetails(
        bookingId: bookingId,
      );
    }
  }
}
