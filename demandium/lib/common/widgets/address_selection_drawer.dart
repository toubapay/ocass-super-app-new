import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/address_selection_bottom_sheet.dart';

class AddressSelectionDrawer extends StatelessWidget {
  const AddressSelectionDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<ServiceAuthController>().isLoggedIn();

    if (isLoggedIn) {
      Get.find<ServiceLocationController>().getAddressList();
    }

    return Drawer(
      width: 500, // Fixed width as per Figma design
      child: GetBuilder<ServiceLocationController>(
        builder: (locationController) {
          return Container(
            color: Theme.of(context).cardColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drawer Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeTextFieldGap,
                    vertical: Dimensions.paddingSizeLarge,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    color: Theme.of(
                      context,
                    ).primaryColorDark.withValues(alpha: 0.06),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'select_your_address'.tr,
                        style: robotoSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeExtraSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: Dimensions.paddingSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // My Addresses header with Add New Address link (only for logged in users with addresses)
                if (isLoggedIn &&
                    (locationController.addressList?.isNotEmpty ?? false))
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeTextFieldGap,
                      vertical: Dimensions.paddingSizeLarge,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'my_address'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.toNamed(
                              ServiceRouteHelper.getAddAddressRoute(false),
                            );
                          },
                          child: Text(
                            'add_new_address_plus'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Scrollable Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeTextFieldGap,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Address list or empty state (centered)
                        if (isLoggedIn &&
                            (locationController.addressList?.isNotEmpty ??
                                false))
                          AddressListContent(
                            locationController: locationController,
                            onAddressTap: (address) async {
                              final navigator = Navigator.of(context);
                              Get.dialog(
                                const CustomLoader(),
                                barrierDismissible: false,
                              );
                              await locationController.setAddressIndex(
                                address,
                                fromAddressScreen: false,
                              );
                              locationController.saveAddressAndNavigate(
                                address,
                                false,
                                '',
                                false,
                                true,
                              );
                              Get.back(); // Close loader
                              navigator.pop(); // Close drawer
                            },
                          )
                        else
                          // Center the empty state content
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeExtraLarge * 2,
                              ),
                              child: const EmptyAddressState(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Fixed Action Buttons at Bottom
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: AddressActionButtons(
                    locationController: locationController,
                    isLoggedIn: isLoggedIn,
                    fromDrawer: true,
                  ),
                ),
                SizedBox(height: Dimensions.paddingSizeExtraLarge),
              ],
            ),
          );
        },
      ),
    );
  }
}
