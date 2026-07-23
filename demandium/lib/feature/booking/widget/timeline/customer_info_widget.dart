import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class CustomerInfoWidget extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const CustomerInfoWidget({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: Get.find<ServiceThemeController>().darkTheme
            ? null
            : searchBoxShadow,
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Text(
              'customer_info'.tr,
              overflow: TextOverflow.ellipsis,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge!.color?.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: Theme.of(context).hintColor.withValues(alpha: 0.5),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: 5,
            ),
            child: Text(
              bookingDetails.serviceAddress?.contactPersonName ??
                  bookingDetails
                      .subBooking
                      ?.serviceAddress
                      ?.contactPersonName ??
                  "",
              style: robotoRegular,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Text(
              bookingDetails.serviceAddress?.contactPersonNumber ??
                  bookingDetails
                      .subBooking
                      ?.serviceAddress
                      ?.contactPersonNumber ??
                  "",
              style: robotoRegular,
            ),
          ),
        ],
      ),
    );
  }
}
