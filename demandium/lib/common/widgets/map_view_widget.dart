import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:lottie/lottie.dart';

/// Reusable map view widget with complete map functionality
/// Used in both PickMapScreen and PickmapDialogWidget
class MapViewWidget extends StatelessWidget {
  final bool fromAddAddress;
  final LatLng? initialPosition;
  final Set<Polygon> polygons;
  final Function(GoogleMapController) onMapCreated;
  final Function(CameraPosition) onCameraMove;
  final Function() onCameraMoveStarted;
  final Function() onCameraIdle;
  final Function() onLocationTap;
  final Function() onPickLocationTap;
  final GoogleMapController? Function() getMapController;

  const MapViewWidget({
    super.key,
    required this.fromAddAddress,
    required this.initialPosition,
    required this.polygons,
    required this.onMapCreated,
    required this.onCameraMove,
    required this.onCameraMoveStarted,
    required this.onCameraIdle,
    required this.onLocationTap,
    required this.onPickLocationTap,
    required this.getMapController,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceLocationController>(
      builder: (locationController) {
        return Stack(
          children: [
            // Wrap GoogleMap with AbsorbPointer to prevent scroll propagation on web
            AbsorbPointer(
              absorbing: false,
              child: GestureDetector(
                // This prevents scroll events from propagating to parent widgets
                onVerticalDragStart: (_) {},
                onHorizontalDragStart: (_) {},
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: fromAddAddress
                        ? LatLng(
                            locationController.position.latitude,
                            locationController.position.longitude,
                          )
                        : initialPosition!,
                    zoom: 16,
                  ),
                  minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                  onMapCreated: onMapCreated,
                  onCameraMove: onCameraMove,
                  onCameraMoveStarted: onCameraMoveStarted,
                  onCameraIdle: onCameraIdle,
                  style: Get.isDarkMode
                      ? Get.find<ServiceThemeController>().darkMap
                      : Get.find<ServiceThemeController>().lightMap,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    // This allows the map to capture all gestures
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  polygons: polygons,
                ),
              ),
            ),

            // Center map icon
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: Dimensions.pickMapIconSize * 0.65,
                ),
                child: locationController.isCameraMoving
                    ? const AnimatedMapIconExtended()
                    : const AnimatedMapIconMinimised(),
              ),
            ),

            // Search bar - using LocationSearchDialog directly for in-place search
            Positioned(
              top: Dimensions.paddingSizeLarge,
              left: Dimensions.paddingSizeSmall,
              right: Dimensions.paddingSizeSmall,
              child: LocationSearchDialog(
                getMapController: getMapController,
                pickedLocation:
                    locationController.pickAddress.address ??
                    'search_location'.tr,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 25,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withValues(alpha: .6),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Expanded(
                        child: Text(
                          locationController.pickAddress.address ??
                              'search_location'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Icon(
                        Icons.search,
                        size: 25,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Location button
            Positioned(
              bottom: 80,
              right: Dimensions.paddingSizeSmall,
              child: FloatingActionButton(
                hoverColor: Colors.transparent,
                mini: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: onLocationTap,
                child: Icon(
                  Icons.my_location,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),

            // Pick location button
            Positioned(
              bottom: 30.0,
              left: Dimensions.paddingSizeSmall,
              right: Dimensions.paddingSizeSmall,
              child: CustomButton(
                fontSize: Dimensions.fontSizeDefault,
                buttonText: locationController.inZone
                    ? fromAddAddress
                          ? 'pick_address'.tr
                          : 'pick_location'.tr
                    : 'service_not_available_in_this_area'.tr,
                onPressed:
                    (locationController.buttonDisabled ||
                        locationController.loading)
                    ? null
                    : onPickLocationTap,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Animated map icon - extended version (when camera is moving)
class AnimatedMapIconExtended extends StatefulWidget {
  const AnimatedMapIconExtended({super.key});

  @override
  State<AnimatedMapIconExtended> createState() =>
      _AnimatedMapIconExtendedState();
}

class _AnimatedMapIconExtendedState extends State<AnimatedMapIconExtended> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceLocationController>(
      builder: (locationController) {
        return Center(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Lottie.asset(
                Images.mapIconExtended,
                repeat: false,
                height: Dimensions.pickMapIconSize,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(const [
                      'Red circle Outlines',
                      '**',
                    ], value: Theme.of(context).colorScheme.primary),
                    ValueDelegate.color(const [
                      'Shape Layer 1',
                      '**',
                    ], value: Theme.of(context).colorScheme.primary),
                    ValueDelegate.color(const [
                      'Layer 4',
                      'Group 1',
                      'Stroke 1',
                      '**',
                    ], value: Theme.of(context).colorScheme.primary),
                    // Change color of Stroke 1 in Group 2
                    ValueDelegate.color(const [
                      'Layer 4',
                      'Group 2',
                      'Stroke 1',
                      '**',
                    ], value: Theme.of(context).colorScheme.primary),
                    // Change color of Stroke 1 in Group 3
                    ValueDelegate.color(const [
                      'Layer 4',
                      'Group 3',
                      'Stroke 1',
                      '**',
                    ], value: Theme.of(context).colorScheme.primary),
                    ValueDelegate.color(const [
                      'shadow Outlines',
                      '**',
                    ], value: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: Dimensions.pickMapIconSize * 0.4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(9, (index) {
                    return Icon(
                      Icons.circle,
                      size: index == 8
                          ? Dimensions.pickMapIconSize * 0.06
                          : Dimensions.pickMapIconSize * 0.03,
                      color: Theme.of(context).colorScheme.primary,
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated map icon - minimised version (when camera is idle)
class AnimatedMapIconMinimised extends StatefulWidget {
  const AnimatedMapIconMinimised({super.key});

  @override
  State<AnimatedMapIconMinimised> createState() =>
      _AnimatedMapIconMinimisedState();
}

class _AnimatedMapIconMinimisedState extends State<AnimatedMapIconMinimised>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceLocationController>(
      builder: (locationController) {
        return Center(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Lottie.asset(
                Images.mapIconMinimised,
                repeat: false,
                height: Dimensions.pickMapIconSize,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(const [
                      'Red circle Outlines',
                      '**',
                    ], value: Theme.of(context).colorScheme.primary),
                    ValueDelegate.color(const [
                      'Shape Layer 1',
                      '**',
                    ], value: Theme.of(context).colorScheme.primary),
                    ValueDelegate.color(const [
                      'shadow Outlines',
                      '**',
                    ], value: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 0.1),
                duration: const Duration(milliseconds: 400),
                builder: (BuildContext context, double value, Widget? child) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: Dimensions.pickMapIconSize * 0.4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(9, (index) {
                        return Icon(
                          Icons.circle,
                          size: index == 8
                              ? Dimensions.pickMapIconSize * 0.06
                              : Dimensions.pickMapIconSize * 0.03,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: value),
                        );
                      }),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
