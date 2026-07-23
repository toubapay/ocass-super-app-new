import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class AddressMapSection extends StatelessWidget {
  final LatLng initialPosition;
  final Completer<GoogleMapController> controller;
  final Function(CameraPosition) onCameraMove;
  final Function() onCameraIdle;
  final Function(GoogleMapController) onMapCreated;
  final bool fromCheckout;
  final bool isDesktop;
  final bool isUpdate;
  final TextEditingController serviceAddressController;

  const AddressMapSection({
    super.key,
    required this.initialPosition,
    required this.controller,
    required this.onCameraMove,
    required this.onCameraIdle,
    required this.onMapCreated,
    required this.fromCheckout,
    this.isDesktop = false,
    this.isUpdate = false,
    required this.serviceAddressController,
  });

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      customSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    } else {
      onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceLocationController>(
      builder: (locationController) {
        return GestureDetector(
          onHorizontalDragStart: (_) {},
          onVerticalDragStart: (_) {},
          child: Container(
            height: isDesktop
                ? (ResponsiveHelper.isDesktop(context) ? 570 : 150)
                : 150,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            padding: const EdgeInsets.all(1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GoogleMap(
                    minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                    initialCameraPosition: CameraPosition(
                      target: initialPosition,
                      zoom: isDesktop ? 14.4746 : 16,
                    ),
                    zoomControlsEnabled: ResponsiveHelper.isDesktop(context)
                        ? true
                        : false,
                    onCameraIdle: onCameraIdle,
                    onCameraMove: onCameraMove,
                    onMapCreated: onMapCreated,
                    style: Get.isDarkMode
                        ? Get.find<ServiceThemeController>().darkMap
                        : Get.find<ServiceThemeController>().lightMap,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    webCameraControlEnabled: false,
                  ),
                  if (ResponsiveHelper.isDesktop(context))
                    Positioned(
                      top: Dimensions.paddingSizeLarge,
                      left: Dimensions.paddingSizeSmall,
                      right: Dimensions.paddingSizeSmall,
                      child: LocationSearchDialog(
                        getMapController: () =>
                            Get.find<ServiceLocationController>().mapController,
                        pickedLocation: serviceAddressController.text.isEmpty
                            ? 'search_location'.tr
                            : serviceAddressController.text,
                        child: Container(
                          height: 35,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Theme.of(context).disabledColor,
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall,
                              ),
                              Expanded(
                                child: Text(
                                  serviceAddressController.text.isEmpty
                                      ? 'search_location'.tr
                                      : serviceAddressController.text,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),
                              Icon(
                                Icons.search,
                                size: 16,
                                color: Theme.of(context).disabledColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (locationController.loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Center(
                      child: Image.asset(Images.marker, height: 40, width: 40),
                    ),

                  // My Location Button
                  Positioned(
                    bottom: 115,
                    left: Get.find<ServiceLocalizationController>().isLtr
                        ? null
                        : Dimensions.paddingSizeSmall,
                    right: Get.find<ServiceLocalizationController>().isLtr
                        ? -8
                        : null,
                    child: InkWell(
                      onTap: () => _checkPermission(() {
                        locationController.getCurrentLocation(
                          true,
                          deviceCurrentLocation: true,
                          isFromCheckout: fromCheckout,
                          mapController: locationController.mapController,
                        );
                      }),
                      child: Container(
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.only(
                          right: Dimensions.paddingSizeLarge,
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 5.0,
                              offset: Offset(5.0, 5.0),
                              spreadRadius: 2.0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSmall,
                          ),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
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
