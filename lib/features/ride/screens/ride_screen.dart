import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/ride/controllers/ride_controller.dart';
import 'package:sixam_mart/features/ride/domain/ride_models.dart';
import 'package:sixam_mart/features/ride/screens/ride_search_screen.dart';
import 'package:sixam_mart/features/ride/widgets/ride_sheets.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';

/// Noor Taxi, the Yango rider flow: a full map with a bottom sheet that
/// walks through where-to → tariffs → driver search → driver on the way →
/// arrived (start code) → ride → receipt and rating.
class RideScreen extends StatefulWidget {
  const RideScreen({super.key});

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  GoogleMapController? _map;
  LatLng? _center;
  String _framed = '';

  RideController get _c => Get.find<RideController>();

  @override
  void initState() {
    super.initState();
    if (Get.find<AuthController>().isLoggedIn()) _c.load();
  }

  bool get _picking => _c.step == RideStep.home || _c.step == RideStep.mapPick;

  Future<void> _openSearch({required bool forPickup}) async {
    final r = await Get.to<RideSearchResult>(() => RideSearchScreen(forPickup: forPickup));
    if (r == null) return;
    if (r.onMap) {
      _c.startMapPick(forPickup: forPickup);
    } else if (r.place != null) {
      _c.setPlace(r.place!, forPickup: forPickup);
    }
  }

  void _onIdle() {
    final c = _center;
    if (c == null) return;
    if (_c.step == RideStep.home) _c.movePickup(c.latitude, c.longitude);
    if (_c.step == RideStep.mapPick) _c.moveMapPoint(c.latitude, c.longitude);
  }

  /// What the camera should show; it only moves when this changes, so the
  /// customer's own panning (the pick-up pin) is never fought.
  String _frameKey() {
    final t = _c.trip;
    switch (_c.step) {
      case RideStep.home:
        return 'home|${_c.pickupTick}';
      case RideStep.mapPick:
        return 'pick|${_c.mapPickForPickup}';
      case RideStep.options:
        return 'opt|${_c.estimate?.polyline?.length}|${_c.destination?.lat}';
      case RideStep.ride:
        final d = t?.driver?.latLng;
        return 'ride|${t?.id}|${t?.status}|${d == null ? '' : '${d.latitude.toStringAsFixed(3)},${d.longitude.toStringAsFixed(3)}'}';
      default:
        return _framed;
    }
  }

  void _frame() {
    final map = _map;
    if (map == null) return;
    final key = _frameKey();
    if (key == _framed) return;
    _framed = key;
    final t = _c.trip;
    List<LatLng> pts;
    if (_c.step == RideStep.home) {
      pts = [if (_c.pickup != null) _c.pickup!.latLng];
    } else if (_c.step == RideStep.mapPick) {
      pts = [if (_c.mapPoint != null) _c.mapPoint!.latLng];
    } else if (_c.step == RideStep.options) {
      pts = [if (_c.pickup != null) _c.pickup!.latLng, if (_c.destination != null) _c.destination!.latLng, ...decodePolyline(_c.estimate?.polyline)];
    } else {
      pts = [
        if (t?.pickup != null) t!.pickup!.latLng,
        if (t?.destination != null) t!.destination!.latLng,
        if (t?.driver?.latLng != null) t!.driver!.latLng!,
        ...decodePolyline(t?.polyline),
      ];
    }
    if (pts.isEmpty) return;
    try {
      if (pts.length == 1) {
        map.animateCamera(CameraUpdate.newLatLngZoom(pts.first, 16));
      } else {
        double s = pts.first.latitude, n = s, w = pts.first.longitude, e = w;
        for (final p in pts) {
          if (p.latitude < s) s = p.latitude;
          if (p.latitude > n) n = p.latitude;
          if (p.longitude < w) w = p.longitude;
          if (p.longitude > e) e = p.longitude;
        }
        map.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e)), 60));
      }
    } catch (_) {
      _framed = ''; // the map isn't laid out yet: try again on the next build
    }
  }

  Set<Marker> _markers() {
    if (_picking) return {};
    final t = _c.step == RideStep.ride ? _c.trip : null;
    final from = t?.pickup ?? _c.pickup;
    final to = t?.destination ?? _c.destination;
    final driver = t?.driver?.latLng;
    return {
      if (from != null) Marker(markerId: const MarkerId('pickup'), position: from.latLng, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)),
      if (to != null) Marker(markerId: const MarkerId('destination'), position: to.latLng, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
      if (driver != null) Marker(markerId: const MarkerId('driver'), position: driver, zIndexInt: 3, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow)),
    };
  }

  Set<Polyline> _polylines() {
    if (_picking) return {};
    final encoded = _c.step == RideStep.ride ? _c.trip?.polyline : _c.estimate?.polyline;
    final pts = decodePolyline(encoded);
    if (pts.isEmpty) return {};
    return {Polyline(polylineId: const PolylineId('route'), points: pts, color: const Color(0xFF1C1C1E), width: 5)};
  }

  void _back() {
    switch (_c.step) {
      case RideStep.options:
      case RideStep.history:
        _c.backToHome();
        break;
      case RideStep.mapPick:
        _c.destination != null && _c.pickup != null ? _c.quote() : _c.backToHome();
        break;
      default:
        Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.find<AuthController>().isLoggedIn()) {
      return Scaffold(
        appBar: AppBar(title: Text('ride_title'.tr)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('ride_login_required'.tr, textAlign: TextAlign.center),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomButton(buttonText: 'sign_in'.tr, onPressed: () => Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.ride))),
            ]),
          ),
        ),
      );
    }

    return GetBuilder<RideController>(builder: (c) {
      if (c.step == RideStep.loading || c.config == null || c.pickup == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (!c.config!.enabled) {
        return Scaffold(
          appBar: AppBar(title: Text(c.config!.moduleName ?? 'ride_title'.tr)),
          body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('ride_unavailable'.tr, textAlign: TextAlign.center))),
        );
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => _frame());

      return PopScope(
        canPop: c.step == RideStep.home || c.step == RideStep.ride || c.step == RideStep.loading,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _back();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(children: [
            Expanded(
              child: Stack(children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: c.pickup!.latLng, zoom: 16),
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  markers: _markers(),
                  polylines: _polylines(),
                  onMapCreated: (m) {
                    _map = m;
                    _framed = '';
                    _frame();
                  },
                  onCameraMove: (p) => _center = p.target,
                  onCameraIdle: _onIdle,
                ),
                // Fixed centre pin: the map centre is the chosen point.
                if (_picking)
                  const IgnorePointer(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 44),
                        child: Icon(Icons.location_on, size: 48, color: Color(0xFF1C1C1E), shadows: [Shadow(blurRadius: 6, color: Colors.black38)]),
                      ),
                    ),
                  ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      _RoundButton(icon: Icons.arrow_back, onTap: _back),
                      const Spacer(),
                      if (c.step == RideStep.home)
                        Material(
                          color: Colors.white,
                          elevation: 3,
                          shape: const StadiumBorder(),
                          child: InkWell(
                            customBorder: const StadiumBorder(),
                            onTap: () => c.showHistory(true),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.history, size: 19),
                                const SizedBox(width: 6),
                                Text('ride_my_rides'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ),
              ]),
            ),
            RideSheet(
              controller: c,
              onSearchPickup: () => _openSearch(forPickup: true),
              onSearchDestination: () => _openSearch(forPickup: false),
            ),
          ]),
        ),
      );
    });
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon))),
    );
  }
}
