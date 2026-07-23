import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class CompletePage extends StatelessWidget {
  final String? token;

  const CompletePage({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GetBuilder<CheckOutController>(
              builder: (controller) {
                return Column(
                  children: [
                    const SizedBox(
                      height: Dimensions.paddingSizeExtraMoreLarge,
                    ),
                    Image.asset(Images.orderComplete, scale: 4.5),
                    const SizedBox(
                      height: Dimensions.paddingSizeExtraMoreLarge,
                    ),
                    Text(
                      controller.isPlacedOrderSuccessfully
                          ? 'you_placed_the_booking_successfully'.tr
                          : 'your_bookings_is_failed_to_place'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: controller.isPlacedOrderSuccessfully
                            ? null
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),

                    if (controller.bookingReadableId.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeDefault,
                        ),
                        child: Text(
                          "${'booking_id'.tr} ${controller.bookingReadableId}",
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: Dimensions.paddingSizeExtraMoreLarge,
                    ),

                    CustomButton(
                      buttonText: "explore_more_service".tr,
                      width: 280,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      textStyle: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                      ),
                      onPressed: () {
                        Get.find<CheckOutController>().updateState(
                          PageState.orderDetails,
                        );
                        Get.offAllNamed(
                          ServiceRouteHelper.getMainRoute('home'),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
