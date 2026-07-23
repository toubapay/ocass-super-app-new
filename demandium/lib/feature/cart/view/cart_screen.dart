import 'dart:developer';

import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/feature/cart/widget/cart_product_widget.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  const CartScreen({super.key, required this.fromNav});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  ConfigModel configModel = Get.find<ServiceSplashController>().configModel;

  ProviderData? provider;

  @override
  void initState() {
    super.initState();
    Get.find<ServiceCartController>().getCartListFromServer().then((value) {
      Future.delayed(const Duration(milliseconds: 500)).then((value) {
        Get.find<ServiceCartController>()
            .showMinimumAndMaximumOrderValueToaster();
        if (Get.find<ServiceCartController>().checkProviderUnavailability() &&
            Get.currentRoute.contains(ServiceRouteHelper.cart)) {
          showModalBottomSheet(
            useRootNavigator: true,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            context: Get.context!,
            builder: (context) => AvailableProviderWidget(
              subcategoryId: Get.find<ServiceCartController>()
                  .cartList
                  .first
                  .subCategoryId,
              showUnavailableError: true,
            ),
          );
        }
      });
    });
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
          title: 'cart'.tr,
          isBackButtonExist:
              (ResponsiveHelper.isDesktop(context) || !widget.fromNav),
          onBackPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAllNamed(ServiceRouteHelper.getMainRoute("home"));
            }
          },
        ),
        body: SafeArea(
          child: GetBuilder<ServiceCartController>(
            builder: (cartController) {
              provider = Get.find<ServiceCartController>().cartList.isNotEmpty
                  ? Get.find<ServiceCartController>().cartList[0].provider
                  : null;

              return Column(
                children: [
                  Expanded(
                    child: FooterBaseView(
                      isCenter: (cartController.cartList.isEmpty),
                      child: WebShadowWrap(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: GetBuilder<ServiceCartController>(
                            builder: (cartController) {
                              if (cartController.isLoading) {
                                return SizedBox(
                                  height: ResponsiveHelper.isMobile(context)
                                      ? MediaQuery.of(context).size.height * 0.8
                                      : MediaQuery.of(context).size.height *
                                            0.6,
                                  child: const Center(child: CustomLoader()),
                                );
                              } else {
                                if (cartController.cartList.isNotEmpty) {
                                  return ResponsiveHelper.isDesktop(context)
                                      ? Row(
                                          spacing: 20,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: WebShadowWrap(
                                                child: _CartListWidget(),
                                              ),
                                            ),
                                            Expanded(
                                              child: WebShadowWrap(
                                                child: Column(
                                                  children: [
                                                    Get.find<ServiceSplashController>()
                                                                .configModel
                                                                .content
                                                                ?.directProviderBooking ==
                                                            1
                                                        ? _ProviderInfoWidget(
                                                            provider: provider,
                                                          )
                                                        : const SizedBox(),
                                                    _PriceButtonWidget(
                                                      cartController:
                                                          cartController,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Get.find<ServiceSplashController>()
                                                        .configModel
                                                        .content
                                                        ?.directProviderBooking ==
                                                    1
                                                ? _ProviderInfoWidget(
                                                    provider: provider,
                                                  )
                                                : const SizedBox(),

                                            _CartListWidget(),
                                          ],
                                        );
                                } else {
                                  return NoDataScreen(
                                    text: "cart_is_empty".tr,
                                    type: NoDataType.cart,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  if ((ResponsiveHelper.isTab(context) ||
                          ResponsiveHelper.isMobile(context)) &&
                      cartController.cartList.isNotEmpty)
                    _PriceButtonWidget(cartController: cartController),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CartListWidget extends StatelessWidget {
  const _CartListWidget();

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<ServiceCartController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${cartController.cartList.length} ${'services_in_cart'.tr}",
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          key: UniqueKey(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: Dimensions.paddingSizeLarge,
            mainAxisSpacing: Dimensions.paddingSizeMini,
            childAspectRatio: ResponsiveHelper.isMobile(context) ? 5 : 6,
            crossAxisCount: 1,
            mainAxisExtent: ResponsiveHelper.isMobile(context) ? 125 : 135,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: cartController.cartList.length,
          itemBuilder: (context, index) {
            return cartController.cartList[index].service != null
                ? CartServiceWidget(
                    cart: cartController.cartList[index],
                    cartIndex: index,
                  )
                : const SizedBox();
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
      ],
    );
  }
}

class _PriceButtonWidget extends StatelessWidget {
  final ServiceCartController cartController;
  const _PriceButtonWidget({required this.cartController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'total_price'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.color!.withValues(alpha: .6),
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    ' ${PriceConverter.convertPrice((cartController.totalPrice), isShowLongPrice: true)} ',
                    style: robotoBold.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
            bottom: Dimensions.paddingSizeSmall,
          ),
          child: CustomButton(
            width: Get.width,
            height: ResponsiveHelper.isDesktop(context) ? 50 : 45,
            radius: Dimensions.radiusDefault,
            buttonText: 'proceed_to_checkout'.tr,
            onPressed: cartController.checkProviderUnavailability()
                ? () {
                    customSnackBar(
                      "your_selected_provider_is_unavailable_right_now".tr,
                    );
                  }
                : (Get.find<ServiceSplashController>()
                              .configModel
                              .content
                              ?.minBookingAmount ??
                          0) >
                      cartController.totalPrice
                ? () {
                    cartController.showMinimumAndMaximumOrderValueToaster();
                  }
                : () {
                    log(
                      'here ${Get.find<UserController>().userInfoModel?.toJson()}',
                    );
                    Get.find<CheckOutController>().updateState(
                      PageState.orderDetails,
                    );
                    Get.toNamed(
                      ServiceRouteHelper.getCheckoutRoute(
                        'cart',
                        'orderDetails',
                        'null',
                      ),
                    );
                  },
          ),
        ),
      ],
    );
  }
}

class _ProviderInfoWidget extends StatelessWidget {
  final ProviderData? provider;
  const _ProviderInfoWidget({this.provider});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceCartController>(
      builder: (cartController) {
        bool timeSlotAvailable;
        if (cartController.cartList[0].provider != null &&
            cartController.cartList[0].provider!.timeSchedule != null) {
          String? startTime =
              cartController.cartList[0].provider?.timeSchedule?.startTime;
          String? endTime =
              cartController.cartList[0].provider?.timeSchedule?.endTime;
          final weekends = cartController.cartList[0].provider?.weekends ?? [];
          String currentTime = DateConverter.convertStringTimeToDate(
            DateTime.now(),
          );

          String dayOfWeek = DateConverter.dateToWeek(DateTime.now());

          if (startTime != null && endTime != null) {
            timeSlotAvailable =
                _isUnderTime(currentTime, startTime, endTime) &&
                (!weekends.contains(dayOfWeek.toLowerCase()));
          } else {
            timeSlotAvailable = false;
          }
        } else {
          timeSlotAvailable = false;
        }

        return Container(
          width: ResponsiveHelper.isDesktop(context)
              ? 600
              : Dimensions.webMaxWidth,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.05),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'provider_info'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Row(
                  spacing: Dimensions.paddingSizeDefault,
                  children: [
                    provider != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSeven,
                            ),
                            child: CustomImage(
                              height: 60,
                              width: 60,
                              image: "${provider?.logoFullPath}",
                            ),
                          )
                        : const UnselectedProductWidget(),

                    provider != null
                        ? Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 5,
                              children: [
                                Text(
                                  provider?.companyName ?? "",
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                ),

                                Text(
                                  cartController.maskNumberWithoutCountryCode(
                                    provider?.contactPersonPhone ?? '',
                                  ),
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text:
                                        timeSlotAvailable &&
                                            cartController
                                                    .cartList[0]
                                                    .provider
                                                    ?.serviceAvailability ==
                                                1
                                        ? 'available_from'.tr
                                        : "provider_is_currently_on_a_break".tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodySmall!.color,
                                    ),
                                    children: <TextSpan>[
                                      if (timeSlotAvailable &&
                                          cartController
                                                  .cartList[0]
                                                  .provider
                                                  ?.serviceAvailability ==
                                              1)
                                        TextSpan(
                                          text:
                                              " : ${DateConverter.convertStringDateTimeToTime(cartController.cartList[0].provider!.timeSchedule!.startTime!)} ${'to'.tr} ${DateConverter.convertStringDateTimeToTime(cartController.cartList[0].provider!.timeSchedule!.endTime!)}",
                                          style: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge!.color,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Expanded(
                            child: Text(
                              '${'let'.tr} ${AppConstants.appName} \n${'choose_for_you'.tr}'
                                  .tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge - 1,
                              ),
                            ),
                          ),
                    InkWell(
                      onTap: () => showModalBottomSheet(
                        useRootNavigator: true,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) => AvailableProviderWidget(
                          subcategoryId: cartController.subcategoryId,
                        ),
                      ),
                      child: Image.asset(
                        Images.editButton,
                        width: 20.0,
                        height: 20.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isUnderTime(String time, String startTime, String? endTime) {
    return DateConverter.convertTimeToDateTime(
          time,
        ).isAfter(DateConverter.convertTimeToDateTime(startTime)) &&
        DateConverter.convertTimeToDateTime(
          time,
        ).isBefore(DateConverter.convertTimeToDateTime(endTime!));
  }
}
