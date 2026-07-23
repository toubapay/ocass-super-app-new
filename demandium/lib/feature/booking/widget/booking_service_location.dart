import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class BookingServiceLocation extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const BookingServiceLocation({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: Get.find<ServiceThemeController>().darkTheme
                ? null
                : searchBoxShadow,
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'service_location'.tr,
                overflow: TextOverflow.ellipsis,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.color?.withValues(alpha: 0.9),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Dimensions.paddingSizeSmall,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeEight,
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: bookingDetails.serviceLocation == "customer"
                              ? "provider_will_be_arrived_at_service_location"
                                    .tr
                              : "you_need_to_go_to_the".tr,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  " (${bookingDetails.serviceLocation == "customer" ? "customer_location".tr : 'provider_location'.tr})",
                              style: robotoSemiBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color,
                              ),
                            ),
                            TextSpan(
                              text:
                                  " ${bookingDetails.serviceLocation == "customer" ? "to_provide_the_service".tr : 'in_order_to_receive_this_service'.tr} ",
                              style: robotoRegular,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Text(
                      "${'service_location'.tr} : ",
                      overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color?.withValues(alpha: 0.8),
                      ),
                    ),

                    Row(
                      spacing: Dimensions.paddingSizeDefault,
                      children: [
                        Expanded(
                          child:
                              bookingDetails.serviceLocation == "provider" &&
                                  bookingDetails.provider == null
                              ? RichText(
                                  text: TextSpan(
                                    text: "the".tr,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: " ${'service_location'.tr} ",
                                        style: robotoSemiBold.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            " ${'will_be_available_after_a_provider_accepts_hint_booking_details'.tr} ",
                                        style: robotoRegular,
                                      ),
                                    ],
                                  ),
                                )
                              : Text(
                                  bookingDetails.serviceLocation == "provider"
                                      ? bookingDetails
                                                .provider
                                                ?.companyAddress ??
                                            'address_not_found'.tr
                                      : bookingDetails
                                                .serviceAddress
                                                ?.address ??
                                            bookingDetails
                                                .subBooking
                                                ?.serviceAddress
                                                ?.address ??
                                            'address_not_found'.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),

                        if (bookingDetails.serviceLocation == "provider" &&
                            bookingDetails.provider != null)
                          InkWell(
                            onTap: () async {
                              _checkPermission(() async {
                                Get.dialog(const CustomLoader());
                                await Geolocator.getCurrentPosition().then((
                                  position,
                                ) {
                                  MapUtils.openMap(
                                    bookingDetails
                                            .provider
                                            ?.coordinates
                                            ?.latitude ??
                                        bookingDetails
                                            .subBooking
                                            ?.provider
                                            ?.coordinates
                                            ?.latitude ??
                                        23.8103,
                                    bookingDetails
                                            .provider
                                            ?.coordinates
                                            ?.longitude ??
                                        bookingDetails
                                            .subBooking
                                            ?.provider
                                            ?.coordinates
                                            ?.longitude ??
                                        90.4125,
                                    position.latitude,
                                    position.longitude,
                                  );
                                });
                                Get.back();
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 0.6,
                                ),
                                color: Theme.of(context).cardColor,
                              ),
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeExtraSmall,
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void _checkPermission(Function onTap) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied) {
    customSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
  } else if (permission == LocationPermission.deniedForever) {
    Get.dialog(const PermissionDialog());
  } else {
    onTap();
  }
}

class MapUtils {
  MapUtils._();
  static Future<void> openMap(
    double destinationLatitude,
    double destinationLongitude,
    double userLatitude,
    double userLongitude,
  ) async {
    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$userLatitude,$userLongitude'
        '&destination=$destinationLatitude,$destinationLongitude&mode=d';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(
        Uri.parse(googleUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not open the map.';
    }
  }
}
