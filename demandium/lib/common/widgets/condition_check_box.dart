import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class ConditionCheckBox extends StatelessWidget {
  final bool checkBoxValue;
  final Function(bool? value) onTap;
  const ConditionCheckBox({
    super.key,
    required this.checkBoxValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24.0,
              child: Checkbox(
                activeColor: Theme.of(context).colorScheme.primary,

                value: checkBoxValue,
                onChanged: onTap,
              ),
            ),
            Text(
              'i_agree_with_the'.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Get.isDarkMode
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () =>
              Get.toNamed(ServiceRouteHelper.getTermsAndConditionsRoute()),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            child: Text(
              'terms_and_conditions'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Get.isDarkMode
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
