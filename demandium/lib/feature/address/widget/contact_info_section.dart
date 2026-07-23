import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class ContactInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController numberController;
  final FocusNode nameNode;
  final FocusNode numberNode;
  final FocusNode? nextFocus;

  const ContactInfoSection({
    super.key,
    required this.nameController,
    required this.numberController,
    required this.nameNode,
    required this.numberNode,
    this.nextFocus,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceLocationController>(
      builder: (locationController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'contact_info'.tr,
              style: robotoSemiBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            CustomTextField(
              title: 'name'.tr,
              hintText: 'contact_person_name_hint'.tr,
              inputType: TextInputType.name,
              controller: nameController,
              focusNode: nameNode,
              nextFocus: numberNode,
              capitalization: TextCapitalization.words,
              onValidate: (String? value) {
                return FormValidation().isValidLength(value!);
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            CustomTextField(
              onCountryChanged: (CountryCode countryCode) {
                locationController.countryDialCode = countryCode.dialCode!;
              },
              countryDialCode: locationController.countryDialCode,
              title: 'phone_number'.tr,
              hintText: 'contact_person_number_hint'.tr,
              inputType: TextInputType.phone,
              inputAction: nextFocus != null
                  ? TextInputAction.next
                  : TextInputAction.done,
              focusNode: numberNode,
              nextFocus: nextFocus,
              controller: numberController,
              onValidate: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'please_enter_phone_number'.tr;
                }
                return FormValidation().isValidPhone(
                  locationController.countryDialCode + (value),
                  fromAuthPage: false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
