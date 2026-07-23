import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/map_view_widget.dart';

class PickMapDialogWidget extends StatefulWidget {
  final AddressModel? previousAddress;

  const PickMapDialogWidget({super.key, this.previousAddress});

  @override
  State<PickMapDialogWidget> createState() => _PickMapDialogWidgetState();
}

class _PickMapDialogWidgetState extends State<PickMapDialogWidget> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  LatLng? _initialPosition;

  @override
  void initState() {
    super.initState();

    // Initialize map position
    if (widget.previousAddress != null &&
        widget.previousAddress!.latitude != null &&
        widget.previousAddress!.longitude != null) {
      _initialPosition = LatLng(
        double.tryParse(widget.previousAddress!.latitude!) ?? 0,
        double.tryParse(widget.previousAddress!.longitude!) ?? 0,
      );
    } else {
      _initialPosition = LatLng(
        Get.find<ServiceSplashController>()
                .configModel
                .content
                ?.defaultLocation
                ?.latitude ??
            23.00000,
        Get.find<ServiceSplashController>()
                .configModel
                .content
                ?.defaultLocation
                ?.longitude ??
            90.00000,
      );
    }

    // Set pick data for location controller
    Get.find<ServiceLocationController>().setPickData();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      backgroundColor: Theme.of(context).cardColor,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: Dimensions.webMaxWidth * 0.8,
        height: Get.height * 0.85,
        child: Column(
          children: [
            // Dialog Header
            const _DialogHeader(),

            // Map View
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: MapViewWidget(
                    fromAddAddress: true,
                    initialPosition: _initialPosition,
                    polygons: {},
                    onMapCreated: _onMapCreated,
                    onCameraMove: _onCameraMove,
                    onCameraMoveStarted: _onCameraMoveStarted,
                    onCameraIdle: _onCameraIdle,
                    onLocationTap: _onLocationTap,
                    onPickLocationTap: _onPickLocationTap,
                    getMapController: () => _mapController,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Map callback methods
  void _onMapCreated(GoogleMapController mapController) {
    _mapController = mapController;
    Get.find<ServiceLocationController>().getCurrentLocation(
      false,
      mapController: mapController,
    );
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    _cameraPosition = cameraPosition;
  }

  void _onCameraMoveStarted() {
    Get.find<ServiceLocationController>().updateCameraMovingStatus(true);
    Get.find<ServiceLocationController>().disableButton();
  }

  void _onCameraIdle() {
    Get.find<ServiceLocationController>().updateCameraMovingStatus(false);
    try {
      Get.find<ServiceLocationController>().updatePosition(
        _cameraPosition!,
        false,
        formCheckout: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating position: $e');
      }
    }
  }

  void _onLocationTap() {
    _checkPermission(() {
      Get.find<ServiceLocationController>().getCurrentLocation(
        false,
        deviceCurrentLocation: true,
        mapController: _mapController,
      );
    });
  }

  void _onPickLocationTap() {
    final locationController = Get.find<ServiceLocationController>();
    if (locationController.pickPosition.latitude != 0 &&
        locationController.pickAddress.address!.isNotEmpty) {
      String? firstName;

      if (Get.find<ServiceAuthController>().isLoggedIn() &&
          Get.find<UserController>().userInfoModel?.phone != null &&
          Get.find<UserController>().userInfoModel?.fName != null) {
        firstName = "${Get.find<UserController>().userInfoModel?.fName} ";
      }

      AddressModel address = AddressModel(
        latitude: locationController.pickPosition.latitude.toString(),
        longitude: locationController.pickPosition.longitude.toString(),
        addressType: 'others',
        address: locationController.pickAddress.address ?? "",
        city: locationController.pickAddress.city ?? "",
        country: locationController.pickAddress.country ?? "",
        house: locationController.pickAddress.house ?? "",
        street: locationController.pickAddress.street ?? "",
        zipCode: locationController.pickAddress.zipCode ?? "",
        addressLabel: AddressLabel.home.name,
        contactPersonNumber: firstName != null
            ? Get.find<UserController>().userInfoModel?.phone ?? ""
            : "",
        contactPersonName: firstName != null
            ? "$firstName${Get.find<UserController>().userInfoModel?.lName ?? ""}"
            : "",
      );

      locationController.saveAddressAndNavigate(
        address,
        false,
        ServiceRouteHelper.getMainRoute('home'),
        false,
        true,
      );

      Get.back(); // Close dialog
    } else {
      customSnackBar('pick_an_address'.tr, type: ToasterMessageType.info);
    }
  }

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
}

/// Dialog header with title and close button
class _DialogHeader extends StatelessWidget {
  const _DialogHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).hintColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        color: Theme.of(context).hintColor.withValues(alpha: 0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'set_location'.tr,
            style: robotoSemiBold.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          InkWell(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
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
    );
  }
}
