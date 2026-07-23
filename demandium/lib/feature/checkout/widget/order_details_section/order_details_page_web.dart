import 'package:demandium/feature/checkout/widget/choose_booking_type_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/choose_service_location_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/create_account_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/provider_location_info.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/repeat_booking_schedule_widget.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class OrderDetailsPageWeb extends StatelessWidget {
  final String pageState;
  final String addressId;
  const OrderDetailsPageWeb({
    super.key,
    required this.pageState,
    required this.addressId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: Dimensions.webMaxWidth * 0.9,
        child: GetBuilder<ScheduleController>(
          builder: (scheduleController) {
            return GetBuilder<ServiceLocationController>(
              builder: (locationController) {
                return GetBuilder<ServiceSplashController>(
                  builder: (splashController) {
                    return GetBuilder<ServiceCartController>(
                      builder: (cartController) {
                        bool isLoggedIn = Get.find<ServiceAuthController>()
                            .isLoggedIn();
                        var configModel = splashController.configModel.content;
                        bool createGuestAccount =
                            splashController
                                .configModel
                                .content
                                ?.createGuestUserAccount ==
                            1;
                        ProviderData? provider =
                            cartController.cartList.isNotEmpty
                            ? cartController.cartList.first.provider
                            : null;
                        AddressModel?
                        addressModel = CheckoutHelper.selectedAddressModel(
                          selectedAddress: locationController.selectedAddress,
                          pickedAddress: locationController.getUserAddress(),
                        );
                        bool contactPersonInfoAvailable =
                            addressModel != null &&
                            addressModel.contactPersonNumber != null &&
                            addressModel.contactPersonNumber != "";
                        bool allowChooseLocation =
                            configModel?.serviceAtProviderLocation == 1
                            ? (provider == null
                                  ? true
                                  : (provider.serviceLocation?.length ?? 0) > 1)
                            : false;

                        if (!allowChooseLocation &&
                            provider != null &&
                            !(provider.serviceLocation?.contains("customer") ??
                                true)) {
                          locationController.updateSelectedServiceLocationType(
                            type: ServiceLocationType.provider,
                            shouldUpdate: false,
                          );
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: WebShadowWrap(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.03),
                                minHeight: Get.height * 0.1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    isLoggedIn &&
                                            configModel?.repeatBooking == 1
                                        ? const ChooseBookingTypeWidget()
                                        : const SizedBox(),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeSmall,
                                    ),

                                    (scheduleController.selectedServiceType ==
                                                ServiceType.regular ||
                                            !isLoggedIn)
                                        ? const ServiceSchedule()
                                        : const RepeatBookingScheduleWidget(),

                                    GetBuilder<ServiceLocationController>(
                                      builder: (locationController) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            allowChooseLocation
                                                ? ChooseServiceLocationWidget(
                                                    provider: provider,
                                                  )
                                                : const SizedBox(),
                                            locationController
                                                        .selectedServiceLocationType ==
                                                    ServiceLocationType.provider
                                                ? ProviderLocationInfo(
                                                    provider: provider,
                                                  )
                                                : const SizedBox(),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeDefault,
                                            ),
                                            CustomerLocationInfo(
                                              provider: provider,
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    if (!isLoggedIn &&
                                        createGuestAccount &&
                                        contactPersonInfoAvailable)
                                      const CreateAccountWidget(),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),

                                    Get.find<ServiceAuthController>()
                                            .isLoggedIn()
                                        ? const ShowVoucher()
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),
                            Expanded(
                              child: WebShadowWrap(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.03),
                                minHeight: Get.height * 0.1,
                                child: Column(
                                  children: [
                                    const CartSummery(),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeEight,
                                    ),
                                    ProceedToCheckoutButtonWidget(
                                      pageState: pageState,
                                      addressId: addressId,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
