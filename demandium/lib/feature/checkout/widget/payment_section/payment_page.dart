import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class PaymentPage extends StatefulWidget {
  final String addressId;
  final JustTheController tooltipController;
  final String fromPage;
  final double? bookingAmount;
  final bool? avoidDesktopDesign;
  final bool avoidPartialPayment;
  const PaymentPage({
    super.key,
    required this.addressId,
    required this.tooltipController,
    required this.fromPage,
    this.avoidDesktopDesign = false,
    this.bookingAmount,
    this.avoidPartialPayment = false,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  void initState() {
    super.initState();
    Get.find<CheckOutController>().getOfflinePaymentMethod(true);
    Get.find<CheckOutController>().getPaymentMethodList(
      avoidPartialPayment:
          (widget.avoidPartialPayment ||
          Get.find<ServiceSplashController>()
                  .configModel
                  .content
                  ?.partialPayment ==
              0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GetBuilder<CheckOutController>(
        builder: (checkoutController) {
          return GetBuilder<ServiceCartController>(
            builder: (cartController) {
              double walletBalance = cartController.walletBalance;
              double bookingAmount =
                  widget.bookingAmount ??
                  (widget.fromPage == "custom-checkout"
                      ? checkoutController.totalAmount
                      : cartController.totalPrice);
              bool walletPaymentStatus = cartController.walletPaymentStatus;
              bool isPartialPayment = CheckoutHelper.checkPartialPayment(
                walletBalance: walletBalance,
                bookingAmount: bookingAmount,
              );
              bool hidePaymentMethod = walletPaymentStatus && !isPartialPayment;
              bool isRepeatBooking =
                  Get.find<ScheduleController>().selectedServiceType ==
                  ServiceType.repeat;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: 0,
                ),
                child:
                    (checkoutController.othersPaymentList.isEmpty &&
                        checkoutController.digitalPaymentList.isEmpty)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeLarge * 2,
                        ),
                        child: Text(
                          "no_payment_method_available".tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      )
                    : isRepeatBooking
                    ? const _RepeatBookingCashPaymentCard()
                    : Column(
                        children: [
                          if (checkoutController.othersPaymentList.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeDefault,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    " ${'choose_payment_method'.tr} ",
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'click_one_of_the_option_bellow'.tr,
                                      style: robotoLight.copyWith(
                                        fontSize: Dimensions.fontSizeSmall - 2,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          (checkoutController.othersPaymentList.isNotEmpty) &&
                                  ResponsiveHelper.isDesktop(context) &&
                                  widget.avoidDesktopDesign == false
                              ? GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            cartController.walletPaymentStatus
                                            ? 1
                                            : 2,
                                        mainAxisExtent:
                                            cartController
                                                    .walletPaymentStatus &&
                                                isPartialPayment
                                            ? Get.find<
                                                        ServiceLocalizationController
                                                      >()
                                                      .isLtr
                                                  ? 110
                                                  : 100
                                            : 90,
                                        crossAxisSpacing: 15,
                                        mainAxisSpacing: 0,
                                      ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: checkoutController
                                      .othersPaymentList
                                      .length,
                                  itemBuilder: (ctx, index) {
                                    return PaymentMethodButton(
                                      title: checkoutController
                                          .othersPaymentList[index]
                                          .title,
                                      paymentMethodName: checkoutController
                                          .othersPaymentList[index]
                                          .paymentMethodName,
                                      assetName: checkoutController
                                          .othersPaymentList[index]
                                          .assetName,
                                      hidePaymentMethod: hidePaymentMethod,
                                      itemHeight: 75,
                                      walletBalance: walletBalance,
                                      bookingAmount: bookingAmount,
                                      avoidDesktopDesign:
                                          widget.avoidDesktopDesign,
                                    );
                                  },
                                )
                              : (checkoutController
                                    .othersPaymentList
                                    .isNotEmpty)
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: checkoutController
                                      .othersPaymentList
                                      .length,
                                  itemBuilder: (ctx, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: Dimensions.paddingSizeDefault,
                                      ),
                                      child: PaymentMethodButton(
                                        title: checkoutController
                                            .othersPaymentList[index]
                                            .title,
                                        paymentMethodName: checkoutController
                                            .othersPaymentList[index]
                                            .paymentMethodName,
                                        assetName: checkoutController
                                            .othersPaymentList[index]
                                            .assetName,
                                        hidePaymentMethod: hidePaymentMethod,
                                        walletBalance: walletBalance,
                                        bookingAmount: bookingAmount,
                                        avoidDesktopDesign:
                                            widget.avoidDesktopDesign,
                                      ),
                                    );
                                  },
                                )
                              : const SizedBox(),

                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Stack(
                            children: [
                              Opacity(
                                opacity: hidePaymentMethod ? 0.5 : 1,
                                child: Column(
                                  children: [
                                    if (checkoutController
                                        .digitalPaymentList
                                        .isNotEmpty)
                                      Row(
                                        children: [
                                          Text(
                                            " ${'pay_via_online'.tr} ",
                                            style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'faster_and_secure_way_to_pay_bill'
                                                  .tr,
                                              style: robotoLight.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall -
                                                    2,
                                                color: Theme.of(
                                                  context,
                                                ).hintColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (checkoutController
                                        .digitalPaymentList
                                        .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: Dimensions.paddingSizeDefault,
                                        ),
                                        child: DigitalPaymentMethodView(
                                          paymentList: checkoutController
                                              .digitalPaymentList,
                                          onTap: (index) => checkoutController
                                              .changePaymentMethod(
                                                digitalMethod: checkoutController
                                                    .digitalPaymentList[index],
                                              ),
                                          tooltipController:
                                              widget.tooltipController,
                                          fromPage: widget.fromPage,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              if (hidePaymentMethod)
                                Positioned.fill(
                                  child: Container(color: Colors.transparent),
                                ),
                            ],
                          ),
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RepeatBookingCashPaymentCard extends StatelessWidget {
  const _RepeatBookingCashPaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSeven),
        boxShadow: searchBoxShadow,
      ),
      width: ResponsiveHelper.isDesktop(context) ? 350 : 270,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      margin: EdgeInsets.only(
        top: ResponsiveHelper.isDesktop(context) ? 10 : 0,
        bottom: ResponsiveHelper.isDesktop(context) ? 100 : 0,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Image.asset(Images.completed, width: 20),
          ),
          SizedBox(height: ResponsiveHelper.isDesktop(context) ? 10 : 0),
          Image.asset(Images.cod, width: 50),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text('cash_after_service'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          SizedBox(height: ResponsiveHelper.isDesktop(context) ? 10 : 0),
        ],
      ),
    );
  }
}

class DigitalPaymentMethodView extends StatelessWidget {
  final Function(int index) onTap;
  final List<DigitalPaymentMethod> paymentList;
  final JustTheController tooltipController;
  final String fromPage;
  const DigitalPaymentMethodView({
    super.key,
    required this.onTap,
    required this.paymentList,
    required this.tooltipController,
    required this.fromPage,
  });

  @override
  Widget build(BuildContext context) {
    List<String> offlinePaymentTooltipTextList = [
      'to_pay_offline_you_have_to_pay_the_bill_from_a_option_below',
      'save_the_necessary_information_that_is_necessary_to_identify_or_confirmation_of_the_payment',
      'insert_the_information_and_proceed',
    ];

    return GetBuilder<CheckOutController>(
      builder: (checkoutController) {
        return SingleChildScrollView(
          child: ListView.builder(
            itemCount: paymentList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              bool isSelected =
                  paymentList[index] ==
                  Get.find<CheckOutController>().selectedDigitalPaymentMethod;
              bool isOffline = paymentList[index].gateway == 'offline';

              return InkWell(
                onTap: isOffline ? null : () => onTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).hoverColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.2),
                            width: 0.5,
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: isOffline ? () => onTap(index) : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: Dimensions.paddingSizeLarge,
                                  width: Dimensions.paddingSizeLarge,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.green
                                        : Theme.of(context).cardColor,
                                    border: Border.all(
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeDefault,
                                ),

                                isOffline
                                    ? const SizedBox()
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall,
                                        ),
                                        child: CustomImage(
                                          height: Dimensions.paddingSizeLarge,
                                          fit: BoxFit.contain,
                                          image:
                                              paymentList[index]
                                                  .gatewayImageFullPath ??
                                              "",
                                        ),
                                      ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),

                                Text(
                                  isOffline
                                      ? 'pay_offline'.tr
                                      : paymentList[index].label ?? "",
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                ),
                              ],
                            ),

                            isOffline
                                ? JustTheTooltip(
                                    backgroundColor: Colors.black87,
                                    controller: tooltipController,
                                    preferredDirection: AxisDirection.down,
                                    tailLength: 14,
                                    tailBaseWidth: 20,
                                    content: Padding(
                                      padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeDefault,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "note".tr,
                                            style: robotoBold.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: Dimensions.paddingSizeSmall,
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: offlinePaymentTooltipTextList
                                                .map(
                                                  (element) => Padding(
                                                    padding: const EdgeInsets.only(
                                                      bottom: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    child: Text(
                                                      "●  ${element.tr}",
                                                      style: robotoRegular
                                                          .copyWith(
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ],
                                      ),
                                    ),

                                    child: (isOffline && isSelected)
                                        ? InkWell(
                                            onTap: () =>
                                                tooltipController.showTooltip(),
                                            child: Icon(
                                              Icons.info,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          )
                                        : const SizedBox(),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),

                      if (isOffline && isSelected)
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            top: Dimensions.paddingSizeExtraLarge,
                          ),
                          scrollDirection: Axis.horizontal,
                          child:
                              checkoutController
                                  .offlinePaymentModelList
                                  .isNotEmpty
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: checkoutController
                                      .offlinePaymentModelList
                                      .map(
                                        (offlineMethod) => InkWell(
                                          onTap: () {
                                            if (isOffline) {
                                              checkoutController
                                                  .changePaymentMethod(
                                                    offlinePaymentModel:
                                                        offlineMethod,
                                                  );
                                            } else {
                                              checkoutController
                                                  .changePaymentMethod(
                                                    digitalMethod:
                                                        paymentList[index],
                                                  );
                                            }
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical:
                                                  Dimensions.paddingSizeSmall,
                                              horizontal: Dimensions
                                                  .paddingSizeExtraLarge,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  checkoutController
                                                          .selectedOfflineMethod ==
                                                      offlineMethod
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                  : Theme.of(context).cardColor,
                                              border: Border.all(
                                                width: 1,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(
                                                      alpha:
                                                          checkoutController
                                                                  .selectedOfflineMethod ==
                                                              offlineMethod
                                                          ? 0.7
                                                          : 0.2,
                                                    ),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.radiusDefault,
                                                  ),
                                            ),
                                            child: Text(
                                              offlineMethod.methodName ?? '',
                                              style: robotoMedium.copyWith(
                                                color:
                                                    checkoutController
                                                            .selectedOfflineMethod ==
                                                        offlineMethod
                                                    ? Colors.white
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                              : Text(
                                  "no_offline_payment_method_available".tr,
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
