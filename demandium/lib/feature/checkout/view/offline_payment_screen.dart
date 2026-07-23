import 'dart:convert';

import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class OfflinePaymentScreen extends StatefulWidget {
  final double? totalAmount;
  final int? index;
  final String? bookingId;
  final String? readableId;
  final String? offlinePaymentId;
  final int? isPartialPayment;
  final String fromPage;
  final SignUpBody? newUserInfo;
  final List<BookingOfflinePayment>? offlinePaymentData;
  const OfflinePaymentScreen({
    super.key,
    this.totalAmount,
    this.index,
    this.bookingId,
    this.isPartialPayment,
    required this.fromPage,
    this.newUserInfo,
    this.offlinePaymentData,
    this.offlinePaymentId,
    this.readableId,
  });
  @override
  State<OfflinePaymentScreen> createState() => _OfflinePaymentScreenState();
}

class _OfflinePaymentScreenState extends State<OfflinePaymentScreen> {
  AutoScrollController? scrollController;
  @override
  void initState() {
    scrollController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );
    scrollController!.scrollToIndex(
      widget.index ?? 0,
      preferPosition: AutoScrollPosition.middle,
    );
    scrollController!.highlight(widget.index ?? 0);
    Get.find<CheckOutController>().getOfflinePaymentMethod(
      false,
      selectedIndex: widget.index,
      shouldUpdate: true,
      scrollController: scrollController,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      onPopInvoked: () {
        Get.dialog(
          ConfirmationDialog(
            icon: Images.warning,
            title: "incomplete_offline_payment".tr,
            description: "are_you_go_back_incomplete_offline_payment",
            noButtonText: "cancel".tr,
            yesButtonText: "yes_go_back",
            onYesPressed: () {
              Get.offAllNamed(ServiceRouteHelper.getMainRoute('home'));
            },
          ),
          barrierDismissible: false,
        );
      },
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(
          title: 'offline_payment'.tr,
          onBackPressed: widget.fromPage == "checkout"
              ? () {
                  Get.dialog(
                    ConfirmationDialog(
                      icon: Images.warning,
                      title: "incomplete_offline_payment".tr,
                      description: "are_you_go_back_incomplete_offline_payment",
                      noButtonText: "cancel".tr,
                      yesButtonText: "yes_go_back",
                      onYesPressed: () {
                        Get.offAllNamed(
                          ServiceRouteHelper.getMainRoute('home'),
                        );
                      },
                    ),
                    barrierDismissible: false,
                  );
                }
              : null,
        ),
        body: SafeArea(
          child: GetBuilder<CheckOutController>(
            builder: (checkoutController) {
              bool isLtr = Get.find<ServiceLocalizationController>().isLtr;

              var offlinePaymentMethodList =
                  checkoutController.offlinePaymentModelList;
              return Column(
                children: [
                  Expanded(
                    child: FooterBaseView(
                      child: WebShadowWrap(
                        child: checkoutController.loading
                            ? const Center(child: CircularProgressIndicator())
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      ResponsiveHelper.isDesktop(context)
                                      ? 200
                                      : 0,
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: Dimensions.paddingSizeLarge,
                                    ),
                                    Image.asset(
                                      Images.offlinePayment,
                                      height: 100,
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions
                                            .paddingSizeExtraMoreLarge,
                                      ),
                                      child: Text(
                                        'pay_your_bill_using_the_info'.tr,
                                        textAlign: TextAlign.center,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.color,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeSmall,
                                    ),

                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: DefaultTextStyle.of(
                                          context,
                                        ).style,
                                        children: [
                                          TextSpan(
                                            text: "${'amount'.tr}  ",
                                            style: robotoRegular,
                                          ),
                                          TextSpan(
                                            text: PriceConverter.convertPrice(
                                              widget.totalAmount,
                                            ),
                                            style: robotoBold.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),

                                    Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        SingleChildScrollView(
                                          controller: scrollController,
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: offlinePaymentMethodList
                                                .map(
                                                  (offline) => AutoScrollTag(
                                                    controller:
                                                        scrollController!,
                                                    key: ValueKey(
                                                      offlinePaymentMethodList
                                                          .indexOf(offline),
                                                    ),
                                                    index:
                                                        offlinePaymentMethodList
                                                            .indexOf(offline),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        checkoutController
                                                            .changePaymentMethod(
                                                              offlinePaymentModel:
                                                                  offline,
                                                            );
                                                        checkoutController
                                                            .initializedOfflinePaymentTextField(
                                                              shouldUpdate:
                                                                  true,
                                                              existingOfflineId:
                                                                  widget
                                                                      .offlinePaymentId,
                                                              existingData: widget
                                                                  .offlinePaymentData,
                                                            );
                                                        checkoutController
                                                            .formKey
                                                            .currentState
                                                            ?.reset();

                                                        await scrollController!
                                                            .scrollToIndex(
                                                              offlinePaymentMethodList
                                                                  .indexOf(
                                                                    offline,
                                                                  ),
                                                              preferPosition:
                                                                  AutoScrollPosition
                                                                      .middle,
                                                            );
                                                        await scrollController!
                                                            .highlight(
                                                              offlinePaymentMethodList
                                                                  .indexOf(
                                                                    offline,
                                                                  ),
                                                            );
                                                      },
                                                      child: ConstrainedBox(
                                                        constraints:
                                                            const BoxConstraints(
                                                              minHeight: 170,
                                                            ),
                                                        child: Container(
                                                          width: 315,
                                                          padding:
                                                              const EdgeInsets.all(
                                                                Dimensions
                                                                    .paddingSizeDefault,
                                                              ),
                                                          margin: const EdgeInsets.all(
                                                            Dimensions
                                                                .paddingSizeEight,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                offline.id ==
                                                                    checkoutController
                                                                        .selectedOfflineMethod
                                                                        ?.id
                                                                ? Theme.of(
                                                                    context,
                                                                  ).cardColor
                                                                : Theme.of(
                                                                    context,
                                                                  ).hoverColor,
                                                            border:
                                                                offline.id ==
                                                                    checkoutController
                                                                        .selectedOfflineMethod
                                                                        ?.id
                                                                ? Border.all(
                                                                    color:
                                                                        Theme.of(
                                                                          context,
                                                                        ).colorScheme.primary.withValues(
                                                                          alpha:
                                                                              0.5,
                                                                        ),
                                                                    width: 0.5,
                                                                  )
                                                                : null,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  Dimensions
                                                                      .radiusSeven,
                                                                ),
                                                            boxShadow:
                                                                offline.id ==
                                                                    checkoutController
                                                                        .selectedOfflineMethod
                                                                        ?.id
                                                                ? searchBoxShadow
                                                                : null,
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    offline.methodName ??
                                                                        '',
                                                                    style: robotoMedium.copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeLarge,
                                                                      color: Theme.of(
                                                                        context,
                                                                      ).secondaryHeaderColor,
                                                                    ),
                                                                  ),

                                                                  if (offline
                                                                          .id ==
                                                                      checkoutController
                                                                          .selectedOfflineMethod
                                                                          ?.id)
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Text(
                                                                          'pay_on_this_account'
                                                                              .tr,
                                                                          style: robotoRegular.copyWith(
                                                                            color: Theme.of(
                                                                              context,
                                                                            ).colorScheme.primary,
                                                                            fontSize:
                                                                                Dimensions.fontSizeSmall,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              Dimensions.paddingSizeExtraSmall,
                                                                        ),

                                                                        Icon(
                                                                          Icons
                                                                              .check_circle_rounded,
                                                                          color: Theme.of(
                                                                            context,
                                                                          ).colorScheme.onSecondaryContainer,
                                                                          size:
                                                                              Dimensions.fontSizeDefault,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeDefault,
                                                              ),

                                                              if (offline
                                                                      .paymentInformation !=
                                                                  null)
                                                                BillInfoWidget(
                                                                  methodList:
                                                                      offline
                                                                          .paymentInformation,
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),

                                        if (ResponsiveHelper.isDesktop(context))
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              checkoutController
                                                              .selectedOfflineMethod !=
                                                          null &&
                                                      checkoutController
                                                              .offlinePaymentModelList
                                                              .indexOf(
                                                                checkoutController
                                                                    .selectedOfflineMethod!,
                                                              ) >
                                                          0
                                                  ? InkWell(
                                                      onTap: () async {
                                                        int index =
                                                            checkoutController
                                                                .offlinePaymentModelList
                                                                .indexOf(
                                                                  checkoutController
                                                                      .selectedOfflineMethod!,
                                                                ) -
                                                            1;

                                                        checkoutController
                                                            .changePaymentMethod(
                                                              offlinePaymentModel:
                                                                  checkoutController
                                                                      .offlinePaymentModelList[index],
                                                            );
                                                        checkoutController
                                                            .initializedOfflinePaymentTextField(
                                                              shouldUpdate:
                                                                  true,
                                                              existingOfflineId:
                                                                  widget
                                                                      .offlinePaymentId,
                                                              existingData: widget
                                                                  .offlinePaymentData,
                                                            );
                                                        checkoutController
                                                            .formKey
                                                            .currentState
                                                            ?.reset();

                                                        await scrollController!
                                                            .scrollToIndex(
                                                              index,
                                                              preferPosition:
                                                                  AutoScrollPosition
                                                                      .middle,
                                                            );
                                                        await scrollController!
                                                            .highlight(index);
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            100,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              6,
                                                            ),
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Theme.of(
                                                            context,
                                                          ).colorScheme.primary,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                left: isLtr
                                                                    ? 7
                                                                    : 0.0,
                                                                right: !isLtr
                                                                    ? 7
                                                                    : 0.0,
                                                              ),
                                                          child: const Icon(
                                                            Icons
                                                                .arrow_back_ios,
                                                            size: 18,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox(),

                                              checkoutController
                                                              .selectedOfflineMethod !=
                                                          null &&
                                                      checkoutController
                                                              .offlinePaymentModelList
                                                              .indexOf(
                                                                checkoutController
                                                                    .selectedOfflineMethod!,
                                                              ) <
                                                          (checkoutController
                                                                  .offlinePaymentModelList
                                                                  .length -
                                                              1)
                                                  ? InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            100,
                                                          ),
                                                      onTap: () async {
                                                        int index =
                                                            checkoutController
                                                                .offlinePaymentModelList
                                                                .indexOf(
                                                                  checkoutController
                                                                      .selectedOfflineMethod!,
                                                                ) +
                                                            1;

                                                        checkoutController
                                                            .changePaymentMethod(
                                                              offlinePaymentModel:
                                                                  checkoutController
                                                                      .offlinePaymentModelList[index],
                                                            );
                                                        checkoutController
                                                            .initializedOfflinePaymentTextField(
                                                              shouldUpdate:
                                                                  true,
                                                              existingOfflineId:
                                                                  widget
                                                                      .offlinePaymentId,
                                                              existingData: widget
                                                                  .offlinePaymentData,
                                                            );
                                                        checkoutController
                                                            .formKey
                                                            .currentState
                                                            ?.reset();

                                                        await scrollController!
                                                            .scrollToIndex(
                                                              index,
                                                              preferPosition:
                                                                  AutoScrollPosition
                                                                      .middle,
                                                            );
                                                        await scrollController!
                                                            .highlight(index);
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              6,
                                                            ),
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Theme.of(
                                                            context,
                                                          ).colorScheme.primary,
                                                        ),
                                                        child: const Icon(
                                                          size: 18,
                                                          Icons
                                                              .arrow_forward_ios,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          ),
                                      ],
                                    ),

                                    if (checkoutController
                                            .selectedOfflineMethod
                                            ?.paymentInformation !=
                                        null)
                                      PaymentInfoWidget(
                                        methodInfo: checkoutController
                                            .selectedOfflineMethod!
                                            .customerInformation,
                                        offlinePaymentId:
                                            widget.offlinePaymentId,
                                        offlinePaymentData:
                                            widget.offlinePaymentData,
                                      ),

                                    SizedBox(height: Get.height * 0.03),

                                    if (ResponsiveHelper.isWeb() &&
                                        !ResponsiveHelper.isTab(context) &&
                                        !ResponsiveHelper.isMobile(context))
                                      CustomButton(
                                        buttonText: "confirm_payment".tr,
                                        radius: Dimensions.radiusSeven,
                                        isLoading: checkoutController.isLoading,
                                        onPressed: () {
                                          submitData(checkoutController);
                                        },
                                      ),
                                    SizedBox(height: Get.height * 0.03),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),

                  if ((ResponsiveHelper.isTab(context) ||
                      ResponsiveHelper.isMobile(context)))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                      ),
                      child: CustomButton(
                        buttonText: "confirm_payment".tr,
                        radius: Dimensions.radiusSeven,
                        isLoading: checkoutController.isLoading,
                        onPressed: () {
                          submitData(checkoutController);
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void submitData(CheckOutController checkoutController) {
    if (checkoutController.formKey.currentState!.validate()) {
      Map<String, String> value = {};

      for (
        int i = 0;
        i <
            checkoutController
                .selectedOfflineMethod!
                .customerInformation!
                .length;
        i++
      ) {
        value.addAll({
          "${checkoutController.selectedOfflineMethod!.customerInformation?[i].fieldName}":
              checkoutController.offlinePaymentInputField[i].text,
        });
      }
      checkoutController.offlinePaymentInputFieldValues.add(value);

      checkoutController.submitOfflinePaymentData(
        bookingId: widget.bookingId ?? "",
        offlinePaymentId: checkoutController.selectedOfflineMethod!.id!,
        offlinePaymentInfo: base64Url.encode(
          utf8.encode(
            jsonEncode(checkoutController.offlinePaymentInputFieldValues),
          ),
        ),
        isPartialPayment: widget.isPartialPayment != null
            ? widget.isPartialPayment!
            : 0,
        fromPage: widget.fromPage,
        newUserInfo: widget.newUserInfo,
        readableId: widget.readableId,
      );
    }
  }
}

class PaymentInfoWidget extends StatefulWidget {
  final List<CustomerInformation>? methodInfo;
  final String? offlinePaymentId;
  final List<BookingOfflinePayment>? offlinePaymentData;

  const PaymentInfoWidget({
    super.key,
    required this.methodInfo,
    this.offlinePaymentId,
    this.offlinePaymentData,
  });

  @override
  State<PaymentInfoWidget> createState() => _PaymentInfoWidgetState();
}

class _PaymentInfoWidgetState extends State<PaymentInfoWidget> {
  @override
  void initState() {
    Get.find<CheckOutController>().initializedOfflinePaymentTextField(
      existingOfflineId: widget.offlinePaymentId,
      existingData: widget.offlinePaymentData,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeEight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          Text('payment_info'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          GetBuilder<CheckOutController>(
            builder: (checkoutController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSeven),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Form(
                  key: checkoutController.formKey,
                  child: Column(
                    children: [
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveHelper.isDesktop(context)
                              ? 2
                              : 1,
                          mainAxisExtent: 70,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: Dimensions.paddingSizeLarge,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            checkoutController.offlinePaymentInputField.length,
                        itemBuilder: (context, index) => CustomTextField(
                          isFromOfflinePayment: true,
                          title:
                              widget.methodInfo?[index].fieldName
                                  ?.replaceAll("_", " ")
                                  .capitalizeFirst ??
                              "",
                          hintText:
                              widget.methodInfo?[index].placeholder
                                  ?.replaceAll("_", " ")
                                  .capitalizeFirst ??
                              "",
                          controller: checkoutController
                              .offlinePaymentInputField[index],
                          onValidate: widget.methodInfo?[index].isRequired == 1
                              ? (String? value) {
                                  return FormValidation()
                                      .validateDynamicTextFiled(
                                        value!,
                                        widget.methodInfo?[index].fieldName
                                                ?.replaceAll("_", " ")
                                                .capitalizeFirst ??
                                            "",
                                      );
                                }
                              : null,
                          isRequired: widget.methodInfo?[index].isRequired == 1
                              ? true
                              : false,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
