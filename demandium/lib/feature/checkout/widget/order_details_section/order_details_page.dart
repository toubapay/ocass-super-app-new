import 'package:demandium/feature/checkout/widget/choose_booking_type_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/choose_service_location_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/create_account_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/provider_location_info.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/repeat_booking_schedule_widget.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceLocationController>(
      builder: (locationController) {
        return GetBuilder<ServiceCartController>(
          builder: (cartController) {
            bool isLoggedIn = Get.find<ServiceAuthController>().isLoggedIn();
            bool createGuestAccount =
                Get.find<ServiceSplashController>()
                    .configModel
                    .content
                    ?.createGuestUserAccount ==
                1;
            var configModel =
                Get.find<ServiceSplashController>().configModel.content;
            AddressModel? addressModel = CheckoutHelper.selectedAddressModel(
              selectedAddress: locationController.selectedAddress,
              pickedAddress: locationController.getUserAddress(),
            );
            bool contactPersonInfoAvailable =
                addressModel != null &&
                addressModel.contactPersonNumber != null &&
                addressModel.contactPersonNumber != "";
            ProviderData? provider = cartController.cartList.isNotEmpty
                ? cartController.cartList.first.provider
                : null;

            bool allowChooseLocation =
                configModel?.serviceAtProviderLocation == 1
                ? (provider == null
                      ? true
                      : (provider.serviceLocation?.length ?? 0) > 1)
                : false;

            if (!allowChooseLocation &&
                provider != null &&
                !(provider.serviceLocation?.contains("customer") ?? true)) {
              locationController.updateSelectedServiceLocationType(
                type: ServiceLocationType.provider,
                shouldUpdate: false,
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  GetBuilder<ScheduleController>(
                    builder: (scheduleController) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        child: Column(
                          children: [
                            isLoggedIn && configModel?.repeatBooking == 1
                                ? const ChooseBookingTypeWidget()
                                : const SizedBox(),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            (scheduleController.selectedServiceType ==
                                        ServiceType.regular ||
                                    !isLoggedIn)
                                ? const ServiceSchedule()
                                : const RepeatBookingScheduleWidget(),
                          ],
                        ),
                      );
                    },
                  ),

                  GetBuilder<ServiceLocationController>(
                    builder: (locationController) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        child: Column(
                          children: [
                            allowChooseLocation
                                ? const ChooseServiceLocationWidget()
                                : const SizedBox(),
                            locationController.selectedServiceLocationType ==
                                    ServiceLocationType.provider
                                ? ProviderLocationInfo(provider: provider)
                                : const SizedBox(),
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),
                            CustomerLocationInfo(provider: provider),
                          ],
                        ),
                      );
                    },
                  ),

                  if (!isLoggedIn &&
                      createGuestAccount &&
                      contactPersonInfoAvailable)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                      ),
                      child: CreateAccountWidget(),
                    ),

                  if (!isLoggedIn &&
                      createGuestAccount &&
                      contactPersonInfoAvailable)
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                  // cartController.cartList.isNotEmpty &&  cartController.cartList.first.provider!= null ?
                  // ProviderDetailsCard( providerData: Get.find<ServiceCartController>().cartList.first.provider,): const SizedBox(),
                  Get.find<ServiceAuthController>().isLoggedIn()
                      ? const ShowVoucher()
                      : const SizedBox(),

                  const CartSummery(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
