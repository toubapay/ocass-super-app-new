import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class AddressDetailsSection extends StatelessWidget {
  final TextEditingController serviceAddressController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final TextEditingController zipController;
  final TextEditingController streetController;

  final FocusNode serviceAddressNode;
  final FocusNode houseNode;
  final FocusNode floorNode;
  final FocusNode cityNode;
  final FocusNode countryNode;
  final FocusNode zipNode;
  final FocusNode streetNode;

  final FocusNode? nextFocus;
  final GlobalKey? headerKey;

  const AddressDetailsSection({
    super.key,
    required this.serviceAddressController,
    required this.houseController,
    required this.floorController,
    required this.cityController,
    required this.countryController,
    required this.zipController,
    required this.streetController,
    required this.serviceAddressNode,
    required this.houseNode,
    required this.floorNode,
    required this.cityNode,
    required this.countryNode,
    required this.zipNode,
    required this.streetNode,
    this.nextFocus,
    this.headerKey,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceLocationController>(
      builder: (locationController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddressHeaderWidget(
              headerKey: headerKey,
              serviceAddressNode: serviceAddressNode,
              houseNode: houseNode,
              serviceAddressController: serviceAddressController,
            ),

            const AddressLabelWidget(),
            const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    title: 'house'.tr,
                    hintText: 'enter_house_no'.tr,
                    inputType: TextInputType.streetAddress,
                    focusNode: houseNode,
                    nextFocus: floorNode,
                    controller: houseController
                      ..text = locationController.address.house ?? "",
                    onChanged: (text) =>
                        locationController.setPlaceMark(house: text),
                    isRequired: false,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeTextFieldGap),
                Expanded(
                  child: CustomTextField(
                    title: 'floor'.tr,
                    hintText: 'enter_floor_no'.tr,
                    inputType: TextInputType.streetAddress,
                    focusNode: floorNode,
                    nextFocus: cityNode,
                    controller: floorController
                      ..text = locationController.address.floor ?? "",
                    onChanged: (text) =>
                        locationController.setPlaceMark(floor: text),
                    isRequired: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    title: 'city'.tr,
                    hintText: 'enter_city'.tr,
                    inputType: TextInputType.streetAddress,
                    focusNode: cityNode,
                    nextFocus: countryNode,
                    controller: cityController
                      ..text = locationController.address.city ?? "",
                    onChanged: (text) =>
                        locationController.setPlaceMark(city: text),
                    isRequired: false,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeTextFieldGap),
                Expanded(
                  child: CustomTextField(
                    title: 'country'.tr,
                    hintText: 'enter_country'.tr,
                    inputType: TextInputType.text,
                    focusNode: countryNode,
                    inputAction: TextInputAction.next,
                    nextFocus: zipNode,
                    controller: countryController
                      ..text = locationController.address.country ?? "",
                    onChanged: (text) =>
                        locationController.setPlaceMark(country: text),
                    isRequired: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    title: 'zip_code'.tr,
                    hintText: 'enter_zip_code'.tr,
                    inputType: TextInputType.text,
                    focusNode: zipNode,
                    nextFocus: streetNode,
                    controller: zipController
                      ..text = locationController.address.zipCode ?? "",
                    onChanged: (text) =>
                        locationController.setPlaceMark(zipCode: text),
                    isRequired: false,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeTextFieldGap),
                Expanded(
                  child: CustomTextField(
                    title: 'street'.tr,
                    hintText: 'enter_street'.tr,
                    inputType: TextInputType.streetAddress,
                    focusNode: streetNode,
                    nextFocus: nextFocus,
                    controller: streetController
                      ..text = locationController.address.street ?? "",
                    onChanged: (text) =>
                        locationController.setPlaceMark(street: text),
                    isRequired: false,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class AddressHeaderWidget extends StatelessWidget {
  const AddressHeaderWidget({
    super.key,
    required this.headerKey,
    required this.serviceAddressNode,
    required this.houseNode,
    required this.serviceAddressController,
  });

  final GlobalKey<State<StatefulWidget>>? headerKey;
  final FocusNode serviceAddressNode;
  final FocusNode houseNode;
  final TextEditingController serviceAddressController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceLocationController>(
      builder: (locationController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          key: headerKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'address_info'.tr,
              style: robotoSemiBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            CustomTextField(
              title: 'service_address'.tr,
              hintText: 'service_address_hint'.tr,
              inputType: TextInputType.streetAddress,
              focusNode: serviceAddressNode,
              nextFocus: houseNode,
              controller: serviceAddressController
                ..text = locationController.address.address ?? "",
              onChanged: (text) =>
                  locationController.setPlaceMark(address: text),
              onValidate: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'enter_your_address'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],
        );
      },
    );
  }
}
