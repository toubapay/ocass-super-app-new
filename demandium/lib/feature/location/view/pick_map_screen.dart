import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';
import 'package:demandium/common/widgets/map_view_widget.dart';

class PickMapScreen extends StatefulWidget {
  final bool? fromSignUp;
  final bool? fromAddAddress;
  final bool? canRoute;
  final String? route;
  final bool formCheckout;
  final GoogleMapController? googleMapController;
  final ZoneModel? zone;
  final AddressModel? previousAddress;
  const PickMapScreen({
    super.key,
    required this.fromSignUp,
    required this.fromAddAddress,
    required this.canRoute,
    required this.route,
    this.googleMapController,
    required this.formCheckout,
    required this.zone,
    this.previousAddress,
  });

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  LatLng? _initialPosition;
  LatLng? _centerLatLng;

  Set<Polygon> _polygone = {};
  List<LatLng> zoneLatLongList = [];

  String? pageTitle;
  String? pageSubTitle;

  @override
  void initState() {
    super.initState();
    if (widget.fromAddAddress!) {
      Get.find<ServiceLocationController>().setPickData();
    }

    if (widget.zone != null) {
      _centerLatLng = Get.find<ServiceAreaController>().computeCentroid(
        coordinates: widget.zone!.formattedCoordinates!,
      );
      _initialPosition = LatLng(
        _centerLatLng!.latitude,
        _centerLatLng!.longitude,
      );

      widget.zone?.formattedCoordinates?.forEach((element) {
        zoneLatLongList.add(LatLng(element.latitude!, element.longitude!));
      });

      List<Polygon> polygonList = [];

      polygonList.add(
        Polygon(
          polygonId: const PolygonId('1'),
          points: zoneLatLongList,
          strokeWidth: 2,
          strokeColor: Get.theme.colorScheme.primary,
          fillColor: Get.theme.colorScheme.primary.withValues(alpha: .2),
        ),
      );

      _polygone = HashSet<Polygon>.of(polygonList);
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

    if (widget.route == "search_service") {
      pageTitle = "search_services_near_you".tr;
      pageSubTitle =
          "${'you_must_select_location_first_to_view'.tr} ${'services'.tr.toLowerCase()}";
    } else if (widget.route == ServiceRouteHelper.allServiceScreen) {
      pageTitle = "services_near_you".tr;
      pageSubTitle =
          "${'you_must_select_location_first_to_view'.tr} ${'services'.tr.toLowerCase()}";
    } else if (widget.route == ServiceRouteHelper.home) {
      pageTitle = "home".tr;
      pageSubTitle =
          "${'you_must_select_location_first_to_view'.tr} ${'home_content'.tr.toLowerCase()}";
    } else if (widget.route == ServiceRouteHelper.categories ||
        widget.route == ServiceRouteHelper.cart ||
        widget.route == ServiceRouteHelper.offers ||
        widget.route == ServiceRouteHelper.notification ||
        widget.route == ServiceRouteHelper.voucherScreen) {
      pageTitle = widget.route?.replaceAll("/", "").tr;
      pageSubTitle =
          "${'you_must_select_location_first_to_view'.tr} ${widget.route?.replaceAll("/", "").tr.toLowerCase()}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      isExit: true,
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const WebMenuBar()
            : CustomAppBar(title: 'set_location'.tr),
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        body: SafeArea(
          child: ResponsiveHelper.isDesktop(context)
              ? CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Center(
                        child: WebShadowWrap(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PageHeaderWidget(
                                title: pageTitle,
                                subtitle: pageSubTitle,
                              ),
                              SizedBox(
                                height: Dimensions.webMaxWidth * 0.5,
                                child: MapViewWidget(
                                  fromAddAddress: widget.fromAddAddress!,
                                  initialPosition: _initialPosition,
                                  polygons: _polygone,
                                  onMapCreated: _onMapCreated,
                                  onCameraMove: _onCameraMove,
                                  onCameraMoveStarted: _onCameraMoveStarted,
                                  onCameraIdle: _onCameraIdle,
                                  onLocationTap: _onLocationTap,
                                  onPickLocationTap: _onPickLocationTap,
                                  getMapController: () => _mapController,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (ResponsiveHelper.isDesktop(context))
                      SliverToBoxAdapter(child: FooterView()),
                  ],
                )
              : Center(
                  child: WebShadowWrap(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PageHeaderWidget(
                          title: pageTitle,
                          subtitle: pageSubTitle,
                        ),
                        Expanded(
                          child: MapViewWidget(
                            fromAddAddress: widget.fromAddAddress!,
                            initialPosition: _initialPosition,
                            polygons: _polygone,
                            onMapCreated: _onMapCreated,
                            onCameraMove: _onCameraMove,
                            onCameraMoveStarted: _onCameraMoveStarted,
                            onCameraIdle: _onCameraIdle,
                            onLocationTap: _onLocationTap,
                            onPickLocationTap: _onPickLocationTap,
                            getMapController: () => _mapController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // Callback methods for _MapViewWidget
  void _onMapCreated(GoogleMapController mapController) {
    _mapController = mapController;
    if (!widget.fromAddAddress!) {
      if (widget.zone != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          mapController.animateCamera(
            CameraUpdate.newLatLngBounds(
              MapHelper.boundsFromLatLngList(zoneLatLongList),
              100.5,
            ),
          );
        });
      } else {
        Get.find<ServiceLocationController>().getCurrentLocation(
          false,
          mapController: mapController,
          isFromCheckout: widget.formCheckout,
        );
      }
    }
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
        formCheckout: widget.formCheckout,
      );
    } catch (e) {
      if (kDebugMode) {
        print('');
      }
    }
  }

  void _onLocationTap() {
    _checkPermission(() {
      Get.find<ServiceLocationController>().getCurrentLocation(
        false,
        deviceCurrentLocation: true,
        isFromCheckout: widget.formCheckout,
        mapController: _mapController,
      );
    });
  }

  void _onPickLocationTap() {
    final locationController = Get.find<ServiceLocationController>();
    if (locationController.pickPosition.latitude != 0 &&
        locationController.pickAddress.address!.isNotEmpty) {
      if (widget.fromAddAddress!) {
        if (widget.googleMapController != null) {
          widget.googleMapController!.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  locationController.pickPosition.latitude,
                  locationController.pickPosition.longitude,
                ),
                zoom: 16,
              ),
            ),
          );
          locationController.setAddAddressData();
        }
        Get.back();
      } else {
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

        if (kDebugMode) {
          print("Inside Here ===> Route === > ${widget.route}");
        }
        locationController.saveAddressAndNavigate(
          address,
          widget.fromSignUp!,
          widget.route ?? ServiceRouteHelper.getMainRoute('home'),
          widget.canRoute!,
          true,
        );
      }
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

/// Reusable widget for page header with title and subtitle
class _PageHeaderWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const _PageHeaderWidget({this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    if (title == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? "",
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        const SizedBox(height: Dimensions.paddingSizeEight),
        Text(
          subtitle ?? "",
          style: robotoRegular.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
      ],
    );
  }
}
