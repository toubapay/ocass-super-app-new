import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class PaymentMethodButton extends StatelessWidget {
  final String title;
  final String assetName;
  final PaymentMethodName paymentMethodName;
  final bool hidePaymentMethod;
  final double? itemHeight;
  final double? walletBalance;
  final double? bookingAmount;
  final bool? avoidDesktopDesign;
  const PaymentMethodButton({
    super.key,
    required this.title,
    required this.paymentMethodName,
    required this.assetName,
    this.hidePaymentMethod = false,
    this.itemHeight,
    this.walletBalance,
    this.bookingAmount,
    this.avoidDesktopDesign,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckOutController>(
      builder: (controller) {
        return paymentMethodName == PaymentMethodName.cos
            ? _CashPaymentView(
                title,
                assetName,
                paymentMethodName,
                controller,
                hidePaymentMethod,
                itemHeight,
                avoidDesktopDesign,
              )
            : _WalletPaymentView(
                title,
                assetName,
                paymentMethodName,
                controller,
                walletBalance,
                bookingAmount,
                avoidDesktopDesign,
              );
      },
    );
  }
}

class _WalletPaymentView extends StatelessWidget {
  final String title;
  final String assetName;
  final PaymentMethodName paymentMethodName;
  final CheckOutController controller;
  final double? walletBalance;
  final double? bookingAmount;
  final bool? avoidDesktopDesign;
  const _WalletPaymentView(
    this.title,
    this.assetName,
    this.paymentMethodName,
    this.controller,
    this.walletBalance,
    this.bookingAmount,
    this.avoidDesktopDesign,
  );

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceCartController>(
      builder: (cartController) {
        bool isDesktopView =
            ResponsiveHelper.isDesktop(context) && avoidDesktopDesign == false;

        bool walletPaymentStatus = cartController.walletPaymentStatus;

        bool isPartialPayment = CheckoutHelper.checkPartialPayment(
          walletBalance: walletBalance ?? 0,
          bookingAmount: bookingAmount ?? 0,
        );
        double paidAmount = CheckoutHelper.calculatePaidAmount(
          walletBalance: walletBalance ?? 0,
          bookingAmount: bookingAmount ?? 0,
        );
        double remainingWalletBalance =
            CheckoutHelper.calculateRemainingWalletBalance(
              walletBalance: walletBalance ?? 0,
              bookingAmount: bookingAmount ?? 0,
            );
        double remainingBill = (bookingAmount ?? 0) - paidAmount;

        return Opacity(
          opacity: ((walletBalance ?? 0) <= 0) ? 0.5 : 1,
          child: Stack(
            children: [
              !isDesktopView
                  ? Column(
                      children: [
                        walletCartWidget(
                          context,
                          walletPaymentStatus,
                          remainingWalletBalance,
                          walletBalance,
                          cartController,
                          isDesktopView,
                          isPartialPayment,
                        ),
                        if (walletPaymentStatus)
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                        if (walletPaymentStatus)
                          remainingBalanceWidget(
                            walletPaymentStatus,
                            context,
                            isPartialPayment,
                            paidAmount,
                            remainingBill,
                          ),
                        if (isPartialPayment && walletPaymentStatus)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeSmall,
                              left: 20,
                              right: 20,
                            ),
                            child: Text(
                              "pay_the_rest_amount_hint".tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    )
                  : Column(
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: walletCartWidget(
                                  context,
                                  walletPaymentStatus,
                                  remainingWalletBalance,
                                  walletBalance,
                                  cartController,
                                  isDesktopView,
                                  isPartialPayment,
                                ),
                              ),
                              if (walletPaymentStatus)
                                const SizedBox(
                                  width: Dimensions.paddingSizeDefault,
                                ),
                              if (walletPaymentStatus)
                                Expanded(
                                  child: remainingBalanceWidget(
                                    walletPaymentStatus,
                                    context,
                                    isPartialPayment,
                                    paidAmount,
                                    remainingBill,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        if (isPartialPayment && walletPaymentStatus)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeEight,
                            ),
                            child: Row(
                              children: [
                                if (isDesktopView)
                                  const Expanded(child: SizedBox()),
                                Expanded(
                                  child: Text(
                                    "pay_the_rest_amount_hint".tr,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

              if ((walletBalance ?? 0) <= 0)
                Positioned.fill(child: Container(color: Colors.transparent)),
            ],
          ),
        );
      },
    );
  }

  Widget remainingBalanceWidget(
    bool walletPaymentStatus,
    BuildContext context,
    bool isPartialPayment,
    double paidAmount,
    double remainingBill,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
        horizontal: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.all(
          Radius.circular(Dimensions.radiusSeven),
        ),
        border: Border.all(
          color: Theme.of(context).hintColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'paid_by_wallet'.tr,
                style: isPartialPayment
                    ? robotoRegular.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      )
                    : robotoMedium,
              ),
              Text(
                PriceConverter.convertPrice(paidAmount),
                style: isPartialPayment
                    ? robotoRegular.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      )
                    : robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
            ],
          ),

          if (isPartialPayment)
            const SizedBox(height: Dimensions.paddingSizeSmall),

          if (isPartialPayment)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('remaining_bill'.tr, style: robotoMedium),
                Text(
                  PriceConverter.convertPrice(remainingBill),
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  GestureDetector walletCartWidget(
    BuildContext context,
    bool walletPaymentStatus,
    double remainingWalletBalance,
    double? walletBalance,
    ServiceCartController cartController,
    bool isDesktopView,
    bool isPartialPayment,
  ) {
    return GestureDetector(
      onTap: () {
        if (paymentMethodName == PaymentMethodName.walletMoney) {
          controller.changePaymentMethod(walletPayment: true);
        } else {
          controller.changePaymentMethod();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeDefault,
          horizontal: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(Dimensions.radiusSeven),
          ),
          border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: 0.5),
            width: 0.5,
          ),
          color: isDesktopView
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.02)
              : null,
        ),
        child: Center(
          child: Row(
            children: [
              const SizedBox(width: Dimensions.paddingSizeSmall),
              if (isDesktopView) Image.asset(assetName, height: 25, width: 25),
              if (isDesktopView)
                const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      walletPaymentStatus
                          ? "wallet_remaining_balance".tr
                          : "wallet_balance".tr,
                      style: robotoRegular.copyWith(
                        overflow: TextOverflow.ellipsis,
                        fontSize: Dimensions.fontSizeDefault - 1,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      PriceConverter.convertPrice(
                        walletPaymentStatus
                            ? remainingWalletBalance
                            : walletBalance,
                      ),
                      style: robotoMedium.copyWith(
                        overflow: TextOverflow.ellipsis,
                        fontSize: Dimensions.fontSizeExtraLarge,
                      ),
                    ),
                  ],
                ),
              ),

              walletPaymentStatus
                  ? Row(
                      children: [
                        Text(
                          "applied".tr,
                          style: robotoRegular.copyWith(
                            color: Get.isDarkMode
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        InkWell(
                          onTap: () {
                            controller.getPaymentMethodList(shouldUpdate: true);
                            cartController.updateWalletPaymentStatus(false);
                            controller.changePaymentMethod();
                          },
                          child: Icon(
                            Icons.close,
                            size: 25,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: () {
                        cartController.updateWalletPaymentStatus(true);
                        controller.changePaymentMethod(walletPayment: true);
                        controller.getPaymentMethodList(
                          isPartialPayment: isPartialPayment,
                          shouldUpdate: true,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSmall,
                          ),
                          color: isDesktopView
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.02)
                              : Theme.of(context).cardColor,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeLarge,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        child: Text(
                          "apply".tr,
                          style: robotoMedium.copyWith(
                            color: Get.isDarkMode
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),

              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashPaymentView extends StatelessWidget {
  final String title;
  final String assetName;
  final PaymentMethodName paymentMethodName;
  final CheckOutController controller;
  final bool hidePaymentMethod;
  final double? itemHeight;
  final bool? avoidDesktopDesign;
  const _CashPaymentView(
    this.title,
    this.assetName,
    this.paymentMethodName,
    this.controller,
    this.hidePaymentMethod,
    this.itemHeight,
    this.avoidDesktopDesign,
  );

  @override
  Widget build(BuildContext context) {
    bool isDesktopView =
        ResponsiveHelper.isDesktop(context) && avoidDesktopDesign == false;
    return Stack(
      children: [
        Opacity(
          opacity: hidePaymentMethod ? 0.5 : 1,
          child: GestureDetector(
            onTap: () {
              if (paymentMethodName == PaymentMethodName.cos) {
                controller.changePaymentMethod(cashAfterService: true);
              } else {
                controller.changePaymentMethod();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeDefault,
                horizontal: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(Dimensions.radiusSeven),
                ),
                border: Border.all(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                  width: 0.5,
                ),
                color: isDesktopView
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.02)
                    : null,
              ),
              height: itemHeight,
              width: isDesktopView ? Dimensions.webMaxWidth / 2 - 35 : null,
              child: Row(
                children: [
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Image.asset(assetName, height: 25, width: 25),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      title,
                      style: robotoMedium.copyWith(
                        overflow: TextOverflow.ellipsis,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
                  Container(
                    height: Dimensions.paddingSizeLarge,
                    width: Dimensions.paddingSizeLarge,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          controller.selectedPaymentMethod == paymentMethodName
                          ? Colors.green
                          : Theme.of(context).cardColor,
                      border: Border.all(
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color:
                          controller.selectedPaymentMethod == paymentMethodName
                          ? Colors.white
                          : Colors.transparent,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                ],
              ),
            ),
          ),
        ),
        if (hidePaymentMethod)
          Positioned.fill(child: Container(color: Colors.transparent)),
      ],
    );
  }
}
