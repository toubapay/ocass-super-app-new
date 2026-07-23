import 'package:demandium/feature/checkout/widget/coupon_bottom_sheet_widget.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class ApplyVoucher extends StatelessWidget {
  const ApplyVoucher({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeDefault),
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 :  Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSeven), color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Center( child: GestureDetector(
        onTap: () async {
          if (ResponsiveHelper.isDesktop(context)) {
            Get.dialog(
              const Center(child: CouponBottomSheetWidget(orderAmount: 100))
            );
          } else {
            showModalBottomSheet(context: context,
              isScrollControlled: true, backgroundColor: Colors.transparent,
              builder: (c) => const CouponBottomSheetWidget(orderAmount: 100)
            );
          }
        },

        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('add_coupon'.tr, style: robotoMedium.copyWith()),

          Text('add_plus'.tr,
            style: robotoBold.copyWith(
              color:Get.isDarkMode ? Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .6):Theme.of(context).primaryColor,
            ),
          ),
          ]
        )
      )),
    );
  }
}
