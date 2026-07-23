import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class PaymentFailedDialog extends StatelessWidget {
  final bool isAddFound;
  const PaymentFailedDialog({super.key, required this.isAddFound});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Image.asset(Images.warning, width: 70, height: 70),
        ),
        Text(
          isAddFound
              ? 'are_you_agree_with_this_payment_fail'.tr
              : 'are_you_agree_with_this_order_fail'.tr,
          textAlign: TextAlign.center,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        CustomButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          buttonText: 'retry'.tr,
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        TextButton(
          onPressed: () {
            Get.offAllNamed(ServiceRouteHelper.getInitialRoute());
          },
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).disabledColor.withValues(alpha: 0.3),
            minimumSize: const Size(Dimensions.webMaxWidth, 45),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
          ),
          child: Text(
            isAddFound
                ? 'continue_with_payment_fail'.tr
                : 'continue_with_order_fail'.tr,
            textAlign: TextAlign.center,
            style: robotoBold.copyWith(
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
        ),
      ],
    );
  }
}
