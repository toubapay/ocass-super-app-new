import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class BookingOtpWidget extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const BookingOtpWidget({super.key, required this.bookingDetails});

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
        vertical: Dimensions.paddingSizeSmall,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'otp_verification_code'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: RichText(
              text: TextSpan(
                text: "${'your_otp_is'.tr} : ",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.color!.withValues(alpha: 1),
                ),
                children: <TextSpan>[
                  TextSpan(
                    text:
                        bookingDetails.bookingOtp?.replaceAll("null", " ") ??
                        "",
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Row(),
        ],
      ),
    );
  }
}
