import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/common/widgets/staggered_list_animation.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class AddressScreen extends StatefulWidget {
  final String? fromPage;
  const AddressScreen({super.key, this.fromPage});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<ServiceLocationController>().getAddressList(
      fromCheckout: widget.fromPage == "checkout" ? true : false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        appBar: CustomAppBar(title: 'my_address'.tr),
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,

        body: GetBuilder<ServiceLocationController>(
          builder: (locationController) {
            List<AddressModel>? addressList = locationController.addressList;
            List<AddressModel>? zoneBasedAddress = [];
            if (addressList != null && addressList.isNotEmpty) {
              zoneBasedAddress = addressList
                  .where(
                    (element) =>
                        element.zoneId ==
                        Get.find<ServiceLocationController>()
                            .getUserAddress()
                            ?.zoneId,
                  )
                  .toList();
            }
            if (widget.fromPage == "checkout") {
              addressList = zoneBasedAddress;
            }

            AddressModel? addressModel;
            addressModel = locationController.getUserAddress();

            if (locationController.addressList != null) {
              return FooterBaseView(
                isCenter: (addressList == null || addressList.isEmpty),
                child: WebShadowWrap(
                  child: Column(
                    children: [
                      ResponsiveHelper.isDesktop(context)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomButton(
                                  width: 200,
                                  buttonText: 'add_new_address'.tr,
                                  onPressed: () => Get.toNamed(
                                    ServiceRouteHelper.getAddAddressRoute(
                                      widget.fromPage == 'checkout'
                                          ? true
                                          : false,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      addressList!.isNotEmpty
                          ? RefreshIndicator(
                              onRefresh: () async {
                                await locationController.getAddressList();
                              },
                              child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: (addressList.isNotEmpty)
                                    ? StaggeredListAnimationWrapper(
                                        key: ValueKey(addressList.length),
                                        duration: const Duration(
                                          milliseconds: 600,
                                        ),
                                        child: GridView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    ResponsiveHelper.isMobile(
                                                      context,
                                                    )
                                                    ? 1
                                                    : 2,
                                                childAspectRatio:
                                                    ResponsiveHelper.isMobile(
                                                      context,
                                                    )
                                                    ? 4
                                                    : 6,
                                                crossAxisSpacing: Dimensions
                                                    .paddingSizeExtraLarge,
                                                mainAxisExtent: Dimensions
                                                    .addressItemHeight,
                                                mainAxisSpacing:
                                                    ResponsiveHelper.isDesktop(
                                                          context,
                                                        ) ||
                                                        ResponsiveHelper.isTab(
                                                          context,
                                                        )
                                                    ? Dimensions
                                                          .paddingSizeExtraLarge
                                                    : 2.0,
                                              ),

                                          padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeSmall,
                                          ),
                                          itemCount: addressList.length,
                                          itemBuilder: (context, index) {
                                            return StaggeredListAnimationItem(
                                              index: index,
                                              child: AddressWidget(
                                                selectedUserAddressId:
                                                    addressModel?.id,
                                                address: addressList![index],
                                                fromAddress: true,
                                                fromCheckout:
                                                    widget.fromPage ==
                                                        'checkout'
                                                    ? true
                                                    : false,

                                                onTap: () async {
                                                  if (widget.fromPage ==
                                                      'checkout') {
                                                    if (isRedundentClick(
                                                      DateTime.now(),
                                                    )) {
                                                      return;
                                                    }
                                                    Get.dialog(
                                                      const CustomLoader(),
                                                      barrierDismissible: false,
                                                    );
                                                    await locationController
                                                        .setAddressIndex(
                                                          addressList![index],
                                                        )
                                                        .then((isSuccess) {
                                                          Get.back();
                                                          if (!isSuccess) {
                                                            customSnackBar(
                                                              'this_service_not_available'
                                                                  .tr,
                                                            );
                                                          }
                                                        });
                                                    Get.back();
                                                  }
                                                },

                                                onEditPressed: () {
                                                  Get.toNamed(
                                                    ServiceRouteHelper.getEditAddressRoute(
                                                      addressList![index],
                                                      false,
                                                    ),
                                                  );
                                                },
                                                onRemovePressed: () {
                                                  if (Get.isSnackbarOpen) {
                                                    Get.back();
                                                  }
                                                  Get.dialog(
                                                    ConfirmationDialog(
                                                      icon: Images.warning,
                                                      description:
                                                          'are_you_sure_want_to_delete_address'
                                                              .tr,
                                                      onYesPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();

                                                        Get.dialog(
                                                          const CustomLoader(),
                                                          barrierDismissible:
                                                              false,
                                                        );
                                                        locationController
                                                            .deleteUserAddressByID(
                                                              addressList![index],
                                                            )
                                                            .then((response) {
                                                              Get.back();
                                                              customSnackBar(
                                                                response
                                                                    .message!
                                                                    .tr
                                                                    .capitalizeFirst,
                                                                type:
                                                                    ToasterMessageType
                                                                        .success,
                                                              );
                                                            });
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : const SizedBox(),
                              ),
                            )
                          : SizedBox(
                              height: Get.height * 0.6,
                              child: Center(
                                child: NoDataScreen(
                                  text: 'no_address_found'.tr,
                                  type: NoDataType.address,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),

        floatingActionButton:
            (!ResponsiveHelper.isDesktop(context) &&
                Get.find<ServiceAuthController>().isLoggedIn())
            ? GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: Get.isDarkMode ? null : shadow,
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusExtraMoreLarge,
                    ),
                  ),
                  height: Dimensions.addAddressHeight,
                  width: Dimensions.addAddressWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 20),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        'add_new_address'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Get.toNamed(
                    ServiceRouteHelper.getAddAddressRoute(
                      widget.fromPage == 'checkout' ? true : false,
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}
