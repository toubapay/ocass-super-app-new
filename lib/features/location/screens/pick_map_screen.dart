import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/widgets/serach_location_widget.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class PickMapScreen extends StatefulWidget {
  final bool fromSignUp;
  final bool fromAddAddress;
  final bool canRoute;
  final String? route;
  final GoogleMapController? googleMapController;
  final Function(AddressModel address)? onPicked;
  final bool fromLandingPage;
  const PickMapScreen({
    super.key,
    required this.fromSignUp,
    required this.fromAddAddress,
    required this.canRoute,
    required this.route,
    this.googleMapController,
    this.onPicked,
    this.fromLandingPage = false,
  });

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  late LatLng _initialPosition;
  bool locationAlreadyAllow = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.fromAddAddress) {
      Get.find<LocationController>().setPickData();
    }
    _initialPosition = LatLng(
      double.parse(
          Get.find<SplashController>().configModel!.defaultLocation!.lat ??
              '0'),
      double.parse(
          Get.find<SplashController>().configModel!.defaultLocation!.lng ??
              '0'),
    );
    _checkAlreadyLocationEnable();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _fabAnimationController, curve: Curves.easeOutBack),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkAlreadyLocationEnable() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse) {
      locationAlreadyAllow = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDesktop ? Colors.transparent : backgroundColor,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: Center(
          child: Container(
            height: isDesktop ? 700 : null,
            width: isDesktop ? 750 : Dimensions.webMaxWidth,
            decoration: isDesktop
                ? BoxDecoration(
                    color: backgroundColor,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusExtraLarge),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  )
                : null,
            child: GetBuilder<LocationController>(
              builder: (locationController) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: isDesktop
                      ? const EdgeInsets.all(Dimensions.paddingSizeLarge)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.grey.shade900,
                              Colors.black,
                            ],
                          )
                        : null,
                  ),
                  child: isDesktop
                      ? _buildDesktopUI(locationController, primaryColor,
                          backgroundColor, isDark)
                      : _buildMobileUI(locationController, primaryColor,
                          backgroundColor, isDark),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopUI(LocationController locationController,
      Color primaryColor, Color backgroundColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Icon(Icons.map_outlined,
                          color: primaryColor, size: 24),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Text('select_location'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                        )),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text('pick_exact_location_desc'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.grey.shade600,
                    )),
              ],
            ),
            IconButton(
              onPressed: () => Get.back(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Icon(Icons.close, color: Colors.grey.shade700, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: SearchLocationWidget(
            mapController: _mapController,
            pickedAddress: locationController.pickAddress,
            isEnabled: null,
            fromDialog: true,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        // Map Container
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.fromAddAddress
                        ? LatLng(locationController.position.latitude,
                            locationController.position.longitude)
                        : _initialPosition,
                    zoom: 16,
                  ),
                  minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                  myLocationButtonEnabled: false,
                  onMapCreated: (GoogleMapController mapController) async {
                    _mapController = mapController;
                    if (!widget.fromAddAddress && widget.route != 'splash') {
                      Get.find<LocationController>()
                          .getCurrentLocation(false,
                              mapController: mapController)
                          .then((value) async {
                        if (widget.fromLandingPage &&
                            !locationAlreadyAllow &&
                            await _locationCheck()) {
                          _onPickAddressButtonPressed(locationController);
                        }
                      });
                    }
                  },
                  scrollGesturesEnabled: !Get.isDialogOpen!,
                  zoomControlsEnabled: false,
                  onCameraMove: (CameraPosition cameraPosition) {
                    _cameraPosition = cameraPosition;
                  },
                  onCameraMoveStarted: () {
                    locationController.disableButton();
                  },
                  onCameraIdle: () {
                    Get.find<LocationController>()
                        .updatePosition(_cameraPosition, false);
                  },
                  style: isDark
                      ? Get.find<ThemeController>().darkMap
                      : Get.find<ThemeController>().lightMap,
                ),

                // Center Marker with Pulse Animation
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!locationController.loading)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulse Animation
                            for (int i = 0; i < 3; i++)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 2000),
                                curve: Curves.easeInOut,
                                width: 30 + (i * 15),
                                height: 30 + (i * 15),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      primaryColor.withOpacity(0.1 * (3 - i)),
                                ),
                              ),
                            // Main Marker
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(Icons.location_pin,
                                  color: Colors.white, size: 28),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      const SizedBox(height: 40),
                      // Address Card
                      Material(
                        elevation: 8,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: primaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 300),
                                child: Text(
                                  locationController.pickAddress ??
                                      'searching_address'.tr,
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Current Location FAB
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: ScaleTransition(
                    scale: _fabAnimation,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () =>
                          Get.find<LocationController>().checkPermission(() {
                        Get.find<LocationController>().getCurrentLocation(false,
                            mapController: _mapController);
                      }),
                      child: Icon(Icons.my_location,
                          color: primaryColor, size: 24),
                    ),
                  ),
                ),

                // Zone Status Indicator
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: locationController.inZone
                          ? Colors.green.withOpacity(0.9)
                          : Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          locationController.inZone
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          locationController.inZone
                              ? 'service_available'.tr
                              : 'service_unavailable'.tr,
                          style: robotoMedium.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeSmall),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        // Action Button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            gradient: locationController.inZone &&
                    !locationController.buttonDisabled &&
                    !locationController.loading
                ? LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: !locationController.inZone ? Colors.grey.shade300 : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: locationController.isLoading
                  ? () {}
                  : (locationController.buttonDisabled ||
                          locationController.loading)
                      ? null
                      : () {
                          _onPickAddressButtonPressed(locationController);
                        },
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (locationController.isLoading)
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      Icon(
                        widget.fromAddAddress ? Icons.home : Icons.location_on,
                        color: locationController.inZone
                            ? Colors.white
                            : Colors.grey,
                        size: 20,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        locationController.inZone
                            ? widget.fromAddAddress
                                ? 'confirm_this_address'.tr
                                : 'use_this_location'.tr
                            : 'service_not_available_in_this_area'.tr,
                        style: robotoBold.copyWith(
                          color: locationController.inZone
                              ? Colors.white
                              : Colors.grey,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (!locationController.isLoading &&
                        locationController.inZone)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: locationController.inZone
                            ? Colors.white
                            : Colors.grey,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileUI(LocationController locationController,
      Color primaryColor, Color backgroundColor, bool isDark) {
    return Stack(
      children: [
        // Background Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.fromAddAddress
                ? LatLng(locationController.position.latitude,
                    locationController.position.longitude)
                : _initialPosition,
            zoom: 16,
          ),
          minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
          myLocationButtonEnabled: false,
          onMapCreated: (GoogleMapController mapController) {
            _mapController = mapController;
            if (!widget.fromAddAddress &&
                widget.route != RouteHelper.onBoarding) {
              Get.find<LocationController>()
                  .getCurrentLocation(false, mapController: mapController);
            }
          },
          scrollGesturesEnabled: !Get.isDialogOpen!,
          zoomControlsEnabled: false,
          onCameraMove: (CameraPosition cameraPosition) {
            _cameraPosition = cameraPosition;
          },
          onCameraMoveStarted: () {
            locationController.disableButton();
          },
          onCameraIdle: () {
            Get.find<LocationController>()
                .updatePosition(_cameraPosition, false);
          },
          style: isDark
              ? Get.find<ThemeController>().darkMap
              : Get.find<ThemeController>().lightMap,
        ),

        // Gradient Overlay at Top
        Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Top Bar with Back Button and Title
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  // Back Button
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'pick_location'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'drag_to_adjust'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.fromAddAddress ? Icons.home : Icons.map,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Search Bar (Floating)
        Positioned(
          top: 100,
          left: Dimensions.paddingSizeLarge,
          right: Dimensions.paddingSizeLarge,
          child: ScaleTransition(
            scale: _fabAnimation,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusExtraLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 25,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusExtraLarge),
                child: SearchLocationWidget(
                  mapController: _mapController,
                  pickedAddress: locationController.pickAddress,
                  isEnabled: null,
                ),
              ),
            ),
          ),
        ),

        // Center Marker with Floating Address Card
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing Marker
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Rings for pulse effect
                  for (int i = 0; i < 2; i++)
                    Container(
                      width: 80 + (i * 20),
                      height: 80 + (i * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2 * (2 - i)),
                          width: 2,
                        ),
                      ),
                    ),

                  // Main Marker
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Floating Address Card
              Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Zone Status
                      Row(
                        children: [
                          Icon(
                            locationController.inZone
                                ? Icons.check_circle
                                : Icons.error,
                            color: locationController.inZone
                                ? Colors.green
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              locationController.inZone
                                  ? 'delivery_available'.tr
                                  : 'not_in_service_area'.tr,
                              style: robotoMedium.copyWith(
                                color: locationController.inZone
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(height: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 8),

                      // Address Text
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              locationController.pickAddress ??
                                  'searching_location'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Current Location FAB (Bottom Right)
        Positioned(
          bottom: 140,
          right: Dimensions.paddingSizeLarge,
          child: ScaleTransition(
            scale: _fabAnimation,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () =>
                    Get.find<LocationController>().checkPermission(() {
                  Get.find<LocationController>()
                      .getCurrentLocation(false, mapController: _mapController);
                }),
                icon: Icon(Icons.my_location, color: primaryColor, size: 24),
              ),
            ),
          ),
        ),

        // Bottom Action Button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  backgroundColor.withOpacity(0.9),
                  backgroundColor,
                ],
              ),
            ),
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusExtraLarge),
                  gradient: locationController.inZone &&
                          !locationController.buttonDisabled &&
                          !locationController.loading
                      ? LinearGradient(
                          colors: [
                            primaryColor,
                            Color.lerp(primaryColor, Colors.black, 0.2)!
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color:
                      !locationController.inZone ? Colors.grey.shade300 : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: locationController.isLoading
                        ? () {}
                        : (locationController.buttonDisabled ||
                                locationController.loading)
                            ? null
                            : () {
                                _onPickAddressButtonPressed(locationController);
                              },
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusExtraLarge),
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (locationController.isLoading)
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else
                            Icon(
                              widget.fromAddAddress
                                  ? Icons.home
                                  : Icons.location_on,
                              color: locationController.inZone
                                  ? Colors.white
                                  : Colors.grey,
                              size: 22,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              locationController.inZone
                                  ? widget.fromAddAddress
                                      ? 'confirm_location'.tr
                                      : 'select_this_spot'.tr
                                  : 'service_not_available'.tr,
                              style: robotoBold.copyWith(
                                color: locationController.inZone
                                    ? Colors.white
                                    : Colors.grey,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (!locationController.isLoading &&
                              locationController.inZone)
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onPickAddressButtonPressed(LocationController locationController) {
    if (locationController.pickPosition.latitude != 0 &&
        locationController.pickAddress!.isNotEmpty) {
      if (widget.onPicked != null) {
        AddressModel address = AddressModel(
          latitude: locationController.pickPosition.latitude.toString(),
          longitude: locationController.pickPosition.longitude.toString(),
          addressType: 'others',
          address: locationController.pickAddress,
          contactPersonName:
              AddressHelper.getUserAddressFromSharedPref()!.contactPersonName,
          contactPersonNumber:
              AddressHelper.getUserAddressFromSharedPref()!.contactPersonNumber,
        );
        widget.onPicked!(address);
        Get.back();
      } else if (widget.fromAddAddress) {
        if (widget.googleMapController != null) {
          widget.googleMapController!
              .moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
                  target: LatLng(
                    locationController.pickPosition.latitude,
                    locationController.pickPosition.longitude,
                  ),
                  zoom: 16)));
          locationController.setAddAddressData();
        }
        Get.back();
      } else {
        AddressModel address = AddressModel(
          latitude: locationController.pickPosition.latitude.toString(),
          longitude: locationController.pickPosition.longitude.toString(),
          addressType: 'others',
          address: locationController.pickAddress,
        );

        if (widget.fromLandingPage) {
          if (!AuthHelper.isGuestLoggedIn() && !AuthHelper.isLoggedIn()) {
            Get.find<AuthController>().guestLogin().then((response) {
              if (response.isSuccess) {
                Get.find<ProfileController>().setForceFullyUserEmpty();
                Get.back();
                locationController.saveAddressAndNavigate(
                  address,
                  widget.fromSignUp,
                  widget.route,
                  widget.canRoute,
                  ResponsiveHelper.isDesktop(Get.context),
                );
              }
            });
          } else {
            Get.back();
            locationController.saveAddressAndNavigate(
              address,
              widget.fromSignUp,
              widget.route,
              widget.canRoute,
              ResponsiveHelper.isDesktop(context),
            );
          }
        } else {
          locationController.saveAddressAndNavigate(
            address,
            widget.fromSignUp,
            widget.route,
            widget.canRoute,
            ResponsiveHelper.isDesktop(context),
          );
        }
      }
    } else {
      showCustomSnackBar('pick_an_address'.tr);
    }
  }

  Future<bool> _locationCheck() async {
    bool locationServiceEnabled = true;
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      locationServiceEnabled = false;
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      locationServiceEnabled = false;
    }
    return locationServiceEnabled;
  }
}
