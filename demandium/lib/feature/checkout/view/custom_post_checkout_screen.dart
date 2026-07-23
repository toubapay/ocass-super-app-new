import 'dart:convert';
import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/util/core_export.dart';

import 'package:get/get.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

import 'package:universal_html/html.dart' as html;

class CustomPostCheckoutScreen extends StatefulWidget {
  final String postId;
  final String providerId;
  final String bidId;
  final String amount;
  const CustomPostCheckoutScreen({
    super.key,
    required this.postId,
    required this.providerId,
    required this.amount,
    required this.bidId,
  });

  @override
  State<CustomPostCheckoutScreen> createState() =>
      _CustomPostCheckoutScreenState();
}

class _CustomPostCheckoutScreenState extends State<CustomPostCheckoutScreen> {
  ConfigModel configModel = Get.find<ServiceSplashController>().configModel;
  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();

    Get.find<CheckOutController>().getPostDetails(widget.postId, widget.bidId);
    Get.find<CheckOutController>().changePaymentMethod(shouldUpdate: false);
    Get.find<ServiceAuthController>().cancelTermsAndCondition();
    Get.find<ServiceCartController>().updateWalletPaymentStatus(
      false,
      shouldUpdate: false,
    );
    Get.find<CheckOutController>().getOfflinePaymentMethod(true);
    Get.find<CheckOutController>().toggleTerms(
      value: false,
      shouldUpdate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(
          title: 'checkout'.tr,

          onBackPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.toNamed(ServiceRouteHelper.getMainRoute("home"));
            }
          },
        ),
        body: GetBuilder<ServiceCartController>(
          builder: (cartController) {
            return GetBuilder<CheckOutController>(
              builder: (checkoutController) {
                if (checkoutController.postDetails != null) {
                  Get.find<ScheduleController>().updateSelectedDate(
                    checkoutController.postDetails?.bookingSchedule,
                  );
                  Get.find<CheckOutController>().calculateTotalAmount(
                    double.tryParse(widget.amount.toString()) ?? 0,
                  );
                  return FooterBaseView(
                    isCenter: true,
                    child: WebShadowWrap(
                      child: Column(
                        children: [
                          CustomPostServiceInfo(
                            postDetails: checkoutController.postDetails,
                          ),
                          DescriptionExpansionTile(
                            title: "description",
                            subTitle:
                                checkoutController
                                    .postDetails
                                    ?.serviceDescription ??
                                "",
                          ),

                          (checkoutController.postDetails != null &&
                                  checkoutController
                                      .postDetails!
                                      .additionInstructions!
                                      .isNotEmpty)
                              ? DescriptionExpansionTile(
                                  title: "additional_instruction",
                                  additionalInstruction: checkoutController
                                      .postDetails!
                                      .additionInstructions,
                                )
                              : const SizedBox(),

                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                            ),
                            child: ServiceSchedule(),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                            ),
                            child: CustomerLocationInfo(),
                          ),

                          CustomPostCartSummary(
                            postDetails: checkoutController.postDetails,
                            amount: widget.amount,
                          ),

                          PaymentPage(
                            addressId: '',
                            tooltipController: JustTheController(),
                            fromPage: "custom-checkout",
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: ResponsiveHelper.isDesktop(context)
                                  ? 15
                                  : 0,
                            ),
                            child: ConditionCheckBox(
                              checkBoxValue: checkoutController.acceptTerms,
                              onTap: (bool? value) {
                                checkoutController.toggleTerms();
                              },
                            ),
                          ),
                          if (ResponsiveHelper.isDesktop(context))
                            GetBuilder<ServiceCartController>(
                              builder: (cartController) {
                                double totalAmount =
                                    checkoutController.totalAmount;
                                return SizedBox(
                                  height: 90,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${"total_price".tr} ',
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge!.color,
                                              ),
                                            ),
                                            Directionality(
                                              textDirection: TextDirection.ltr,
                                              child: Text(
                                                PriceConverter.convertPrice(
                                                  totalAmount,
                                                  isShowLongPrice: true,
                                                ),
                                                style: robotoBold.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            _makePayment(
                                              checkoutController,
                                              cartController,
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.radiusDefault,
                                                  ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'proceed_to_checkout'.tr,
                                                style: robotoMedium.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColorLight,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          SizedBox(
                            height: ResponsiveHelper.isDesktop(context)
                                ? 70
                                : 130,
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const FooterBaseView(
                    isCenter: true,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            );
          },
        ),

        bottomSheet: SafeArea(
          child: GetBuilder<CheckOutController>(
            builder: (checkoutController) {
              double padding = MediaQuery.of(context).padding.bottom;
              return !ResponsiveHelper.isDesktop(context) &&
                      checkoutController.postDetails != null
                  ? GetBuilder<ServiceCartController>(
                      builder: (cartController) {
                        double totalAmount = checkoutController.totalAmount;

                        return SizedBox(
                          height: 90 + padding,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${"total_price".tr} ',
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge!.color,
                                      ),
                                    ),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        PriceConverter.convertPrice(
                                          totalAmount,
                                          isShowLongPrice: true,
                                        ),
                                        style: robotoBold.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          fontSize: Dimensions.fontSizeLarge,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                ),
                                child: CustomButton(
                                  buttonText: 'proceed_to_checkout'.tr,
                                  onPressed: () {
                                    _makePayment(
                                      checkoutController,
                                      cartController,
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 15),
                            ],
                          ),
                        );
                      },
                    )
                  : const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  void _makePayment(
    CheckOutController checkoutController,
    ServiceCartController cartController, {
    int? selectedOfflinePaymentIndex,
  }) async {
    AddressModel? addressModel =
        Get.find<ServiceLocationController>().selectedAddress ??
        Get.find<ServiceLocationController>().getUserAddress();
    bool isPartialPayment =
        Get.find<CheckOutController>().totalAmount >
        Get.find<ServiceCartController>().walletBalance;
    double bookingAmount = isPartialPayment
        ? (checkoutController.totalAmount - cartController.walletBalance)
        : checkoutController.totalAmount;

    if (Get.find<CheckOutController>().acceptTerms) {
      if ((addressModel?.contactPersonName == "null" ||
              addressModel?.contactPersonName == null ||
              addressModel!.contactPersonName!.isEmpty) ||
          (addressModel.contactPersonNumber == "null" ||
              addressModel.contactPersonNumber == null ||
              addressModel.contactPersonNumber!.isEmpty)) {
        customSnackBar(
          "please_input_contact_person_name_and_phone_number".tr,
          type: ToasterMessageType.info,
        );
      } else if (cartController.walletPaymentStatus &&
          isPartialPayment &&
          checkoutController.selectedPaymentMethod ==
              PaymentMethodName.walletMoney) {
        customSnackBar(
          "select_another_payment_method_to_pay_remaining_bill".tr,
          type: ToasterMessageType.info,
        );
      } else if (checkoutController.selectedPaymentMethod ==
          PaymentMethodName.none) {
        customSnackBar(
          "select_payment_method".tr,
          type: ToasterMessageType.info,
        );
      } else if (checkoutController.selectedPaymentMethod ==
          PaymentMethodName.cos) {
        Get.dialog(const CustomLoader(), barrierDismissible: false);
        Response response = await Get.find<CreatePostController>()
            .updatePostStatus(
              widget.postId,
              widget.providerId,
              'accept',
              isPartial: isPartialPayment && cartController.walletPaymentStatus
                  ? 1
                  : 0,
              serviceAddressId:
                  (addressModel.id == "null") || (addressModel.id == null)
                  ? ""
                  : addressModel.id,
              serviceAddress: jsonEncode(addressModel),
            );
        Get.back();
        if (response.statusCode == 200 &&
            response.body['response_code'] == "default_update_200") {
          Get.offNamed(ServiceRouteHelper.getOrderSuccessRoute('success'));
        } else {
          Get.offNamed(ServiceRouteHelper.getOrderSuccessRoute('failed'));
        }
      } else if (checkoutController.selectedPaymentMethod ==
          PaymentMethodName.walletMoney) {
        Get.dialog(const CustomLoader(), barrierDismissible: false);
        Response response = await Get.find<CreatePostController>().makePayment(
          postId: widget.postId,
          providerId: widget.providerId,
          paymentMethod: "wallet_payment",
          isPartial: isPartialPayment && cartController.walletPaymentStatus
              ? 1
              : 0,
        );
        Get.back();

        if (response.statusCode == 200 &&
            response.body['response_code'] == "booking_place_success_200") {
          Get.offNamed(ServiceRouteHelper.getOrderSuccessRoute('success'));
        } else {
          customSnackBar(
            response.body['message'].toString().capitalizeFirst ??
                response.statusText,
          );
        }
      } else if (checkoutController.selectedPaymentMethod ==
          PaymentMethodName.offline) {
        if (checkoutController.selectedOfflineMethod != null) {
          Get.dialog(const CustomLoader(), barrierDismissible: false);
          Response response = await Get.find<CreatePostController>()
              .makePayment(
                postId: widget.postId,
                providerId: widget.providerId,
                paymentMethod: "offline_payment",
                offlinePaymentId: checkoutController.selectedOfflineMethod?.id,
                isPartial:
                    isPartialPayment && cartController.walletPaymentStatus
                    ? 1
                    : 0,
              );

          Get.back();

          if (response.statusCode == 200 &&
              response.body['response_code'] == "booking_place_success_200") {
            String? bookingId = response.body['content']['booking_id'];
            customSnackBar(
              'now_pay_you_bill_using_the_payment_method'.tr,
              toasterTitle: 'your_booking_has_been_placed_successfully'.tr,
              type: ToasterMessageType.success,
              duration: 4,
            );

            Get.offAllNamed(
              ServiceRouteHelper.getOfflinePaymentRoute(
                totalAmount: bookingAmount,
                index: selectedOfflinePaymentIndex ?? 0,
                bookingId: bookingId,
                fromPage: "custom-post",
              ),
            );
          } else {
            customSnackBar(
              response.body['message'].toString().capitalizeFirst ??
                  response.statusText,
            );
          }
        } else {
          customSnackBar(
            "provide_offline_payment_info".tr,
            type: ToasterMessageType.info,
          );
        }
      } else if (checkoutController.selectedPaymentMethod ==
          PaymentMethodName.digitalPayment) {
        if (checkoutController.selectedDigitalPaymentMethod != null &&
            checkoutController.selectedDigitalPaymentMethod?.gateway ==
                "offline") {
          customSnackBar(
            'select_any_payment_method'.tr,
            type: ToasterMessageType.info,
          );
        } else {
          String url = '';
          String hostname = html.window.location.hostname!;
          String protocol = html.window.location.protocol;
          String port = html.window.location.port;
          String? path = html.window.location.pathname?.replaceAll(
            ServiceRouteHelper.customPostCheckout,
            "",
          );
          String? schedule = Get.find<ScheduleController>().scheduleTime;
          String userId =
              Get.find<UserController>().userInfoModel?.id ??
              Get.find<ServiceSplashController>().getGuestId();
          String encodedAddress = base64Encode(
            utf8.encode(jsonEncode(addressModel.toJson())),
          );
          String addressId =
              (addressModel.id == "null" || addressModel.id == null)
              ? ""
              : addressModel.id ?? "";
          String zoneId =
              Get.find<ServiceLocationController>().getUserAddress()?.zoneId ??
              "";
          String callbackUrl = GetPlatform.isWeb
              ? "$protocol//$hostname:$port$path${ServiceRouteHelper.orderSuccess}"
              : AppConstants.baseUrl;
          int isPartial = cartController.walletPaymentStatus && isPartialPayment
              ? 1
              : 0;
          String platform = ResponsiveHelper.isWeb() ? "web" : "app";
          String serviceLocation = "customer";

          url =
              '${AppConstants.baseUrl}/payment?payment_method=${checkoutController.selectedDigitalPaymentMethod?.gateway}&access_token=${base64Url.encode(utf8.encode(userId))}&zone_id=$zoneId'
              '&callback=$callbackUrl&payment_platform=$platform&service_address=$encodedAddress&service_address_id=$addressId'
              '&is_partial=$isPartial&service_schedule=$schedule&post_id=${widget.postId}&provider_id=${widget.providerId}'
              '&service_location=$serviceLocation';

          if (GetPlatform.isWeb) {
            printLog("url_with_digital_payment:$url");
            html.window.open(url, "_self");
          } else {
            printLog("url_with_digital_payment_mobile:$url");
            Get.to(() => PaymentScreen(url: url, fromPage: "custom-checkout"));
          }
        }
      }
    } else {
      customSnackBar(
        'please_agree_with_terms_conditions'.tr,
        type: ToasterMessageType.info,
      );
    }
  }
}
