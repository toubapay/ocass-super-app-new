import 'package:demandium/helper/extension_helper.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class BookingStatusButtonWidget extends StatelessWidget {
  final String? bookingStatus;
  const BookingStatusButtonWidget({super.key, this.bookingStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeTine, horizontal: Dimensions.paddingSizeEight),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(3),
        color: context.customThemeColors.buttonBackgroundColorMap[bookingStatus],
      ),
      child: Text(bookingStatus?.tr ?? "",
        style:robotoMedium.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: Dimensions.fontSizeSmall,
          color: context.customThemeColors.buttonTextColorMap[bookingStatus],
        ),
      ),
    );
  }
}
