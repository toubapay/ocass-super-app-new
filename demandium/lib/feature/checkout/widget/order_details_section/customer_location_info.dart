import 'package:demandium/feature/checkout/widget/order_details_section/select_address_dialog.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class CustomerLocationInfo extends StatelessWidget {
  final bool isFromCreatePostPage;
  final ProviderData? provider;
  const CustomerLocationInfo({
    super.key,
    this.isFromCreatePostPage = false,
    this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Get.find<ServiceAuthController>().isLoggedIn();

    return GetBuilder<ServiceLocationController>(
      initState: (state) async {
        await Get.find<ServiceLocationController>().getAddressList();
      },
      builder: (locationController) {
        ServiceLocationType selectedLocationType =
            locationController.selectedServiceLocationType;

        AddressModel? addressModel = CheckoutHelper.selectedAddressModel(
          selectedAddress: locationController.selectedAddress,
          pickedAddress: locationController.getUserAddress(),
          selectedLocationType: selectedLocationType,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isFromCreatePostPage
                ? const SizedBox()
                : Text(
                    'customer_details'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeDefault,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSeven),
                color: Theme.of(context).cardColor,
                border: Border.all(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      spacing: Dimensions.paddingSizeSmall,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (addressModel!.contactPersonName != null &&
                            addressModel.contactPersonName != "" &&
                            !addressModel.contactPersonName.toString().contains(
                              'null',
                            ))
                          Padding(
                            padding: const EdgeInsets.only(
                              left: Dimensions.paddingSizeExtraSmall,
                            ),
                            child: Text(
                              addressModel.contactPersonName.toString(),
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ),

                        if (addressModel.contactPersonNumber != null &&
                            addressModel.contactPersonNumber != "" &&
                            !addressModel.contactPersonNumber
                                .toString()
                                .contains('null'))
                          Padding(
                            padding: const EdgeInsets.only(
                              left: Dimensions.paddingSizeExtraSmall,
                            ),
                            child: Text(
                              addressModel.contactPersonNumber ?? "",
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: .6),
                              ),
                            ),
                          ),

                        if (addressModel.address != null &&
                            addressModel.address != "")
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_sharp,
                                size: 15,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  addressModel.address ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        if (addressModel.contactPersonName != null &&
                            addressModel.contactPersonName != "" &&
                            addressModel.contactPersonNumber != null &&
                            addressModel.country != null &&
                            addressModel.country != "")
                          Padding(
                            padding: const EdgeInsets.only(
                              left: Dimensions.paddingSizeExtraSmall,
                            ),
                            child: Text(
                              addressModel.country ?? "",
                              style: robotoRegular.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color!,
                                fontSize: Dimensions.fontSizeExtraSmall,
                              ),
                            ),
                          ),

                        if (addressModel.contactPersonName == null ||
                            addressModel.contactPersonName == "" ||
                            addressModel.contactPersonNumber == null)
                          selectedLocationType == ServiceLocationType.provider
                              ? Text(
                                  "add_your_name_and_phone".tr,
                                  style: robotoRegular,
                                )
                              : Text(
                                  "* ${"please_input_contact_person_name_and_phone_number".tr}",
                                  style: robotoMedium.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.error.withValues(alpha: 0.8),
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                  ),
                                ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (!isLoggedIn &&
                          selectedLocationType ==
                              ServiceLocationType.customer) {
                        final AddressModel?
                        addressModel = CheckoutHelper.selectedAddressModel(
                          selectedAddress: Get.find<ServiceLocationController>()
                              .selectedAddress,
                          pickedAddress: Get.find<ServiceLocationController>()
                              .getUserAddress(),
                        );
                        print('-----------add---> ${addressModel?.toJson()}');

                        Get.toNamed(
                          ServiceRouteHelper.getEditAddressRoute(
                            addressModel ?? AddressModel(),
                            true,
                          ),
                        );
                        return;
                      }

                      showGeneralDialog(
                        barrierColor: Colors.black.withValues(alpha: 0.5),
                        transitionBuilder: (context, a1, a2, widget) {
                          return Transform.scale(
                            scale: a1.value,
                            child: Opacity(
                              opacity: a1.value,
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                    color: Theme.of(context).cardColor,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeLarge,
                                    vertical: 100,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    clipBehavior: Clip.none,
                                    children: [
                                      selectedLocationType ==
                                              ServiceLocationType.provider
                                          ? _CustomerInfoInputWidget(
                                              address: addressModel,
                                            )
                                          : SelectAddressDialog(
                                              addressList:
                                                  locationController
                                                      .addressList ??
                                                  [],
                                              selectedAddressId:
                                                  addressModel.id,
                                            ),
                                      Positioned(
                                        top: -20,
                                        right: -20,
                                        child: Icon(
                                          Icons.cancel,
                                          color: Theme.of(context).cardColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 200),
                        barrierDismissible: true,
                        barrierLabel: '',
                        context: Get.context!,
                        pageBuilder: (context, animation1, animation2) {
                          return Container();
                        },
                      );
                    },
                    child:
                        selectedLocationType == ServiceLocationType.provider &&
                            (addressModel.contactPersonName == null ||
                                addressModel.contactPersonName == "" ||
                                addressModel.contactPersonNumber == null)
                        ? const Icon(Icons.add_circle_outline, size: 20)
                        : Image.asset(Images.editButton, height: 20, width: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
        );
      },
    );
  }
}

class _CustomerInfoInputWidget extends StatefulWidget {
  final AddressModel? address;

  const _CustomerInfoInputWidget({this.address});

  @override
  State<_CustomerInfoInputWidget> createState() =>
      _CustomerInfoInputWidgetState();
}

class _CustomerInfoInputWidgetState extends State<_CustomerInfoInputWidget> {
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  final TextEditingController _contactPersonNameController =
      TextEditingController();
  final TextEditingController _contactPersonNumberController =
      TextEditingController();

  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _contactPersonNameController.text = widget.address?.contactPersonName ?? "";

    String numberAfterValidation = PhoneVerificationHelper.isPhoneValid(
      widget.address?.contactPersonNumber ??
          Get.find<UserController>().userInfoModel?.phone ??
          "",
      fromAuthPage: false,
    );
    if (numberAfterValidation == "") {
      _contactPersonNumberController.text =
          widget.address?.contactPersonNumber?.replaceAll("null", "") ?? "";
    } else {
      _contactPersonNumberController.text = numberAfterValidation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceLocationController>(
      builder: (locationController) {
        return SizedBox(
          width: Dimensions.webMaxWidth / 2.3,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeLarge,
            ),
            child: Form(
              key: addressFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Text("edit_details".tr, style: robotoMedium),

                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  CustomTextField(
                    title: 'name'.tr,
                    hintText: 'contact_person_name_hint'.tr,
                    inputType: TextInputType.name,
                    controller: _contactPersonNameController,
                    focusNode: _nameNode,
                    nextFocus: _numberNode,
                    capitalization: TextCapitalization.words,
                    onValidate: (String? value) {
                      return FormValidation().isValidLength(value!);
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  CustomTextField(
                    onCountryChanged: (CountryCode countryCode) {
                      locationController.countryDialCode =
                          countryCode.dialCode!;
                    },
                    countryDialCode: locationController.countryDialCode,
                    title: 'phone_number'.tr,
                    hintText: 'contact_person_number_hint'.tr,
                    inputType: TextInputType.phone,
                    inputAction: TextInputAction.done,
                    focusNode: _numberNode,
                    controller: _contactPersonNumberController,
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
                  const SizedBox(
                    height: Dimensions.paddingSizeExtraLarge * 1.4,
                  ),

                  CustomButton(
                    radius: Dimensions.radiusDefault,
                    fontSize: Dimensions.fontSizeLarge,
                    isLoading: locationController.isLoading,
                    buttonText: 'update_your_details'.tr,
                    onPressed: () {
                      final isValid = addressFormKey.currentState!.validate();

                      String name = _contactPersonNameController.text;
                      String phone =
                          locationController.countryDialCode +
                          PhoneVerificationHelper.isPhoneValid(
                            locationController.countryDialCode +
                                _contactPersonNumberController.text,
                            fromAuthPage: false,
                          );

                      AddressModel? addressModel =
                          CheckoutHelper.selectedAddressModel(
                            selectedAddress: locationController.selectedAddress,
                            pickedAddress: locationController.getUserAddress(),
                          );

                      if (isValid) {
                        addressFormKey.currentState!.save();
                        addressModel?.contactPersonName = name;
                        addressModel?.contactPersonNumber = phone;
                        locationController.updateSelectedAddress(addressModel);
                        Get.back();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
