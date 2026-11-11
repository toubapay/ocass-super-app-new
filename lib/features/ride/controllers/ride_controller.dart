import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/ride/domain/ride_models.dart';
import 'package:sixam_mart/features/ride/domain/ride_repository.dart';
import 'package:sixam_mart/helper/address_helper.dart';

/// Screens of the ride flow, as in Yango: home (where to?), choosing a point
/// on the map, tariffs, the ongoing ride, and the ride history.
enum RideStep { loading, home, mapPick, options, ride, history }

class RideController extends GetxController {
  final RideRepository _repo = RideRepository();
  static const _touba = RidePlace(14.8546, -15.8836, '');

  RideConfig? config;
  RideStep step = RideStep.loading;
  RidePlace? pickup;
  RidePlace? destination;
  RidePlace? mapPoint;
  bool mapPickForPickup = false;
  RideEstimate? estimate;
  int? categoryId;
  String payment = 'cash';
  RideTrip? trip;
  List<RideTrip> history = [];
  bool busy = false;

  /// Bumped when the pick-up is set by the app (GPS, search), so the map
  /// recentres on it; moving the map pin itself doesn't bump it.
  int pickupTick = 0;

  Timer? _poll;
  int _lookup = 0;

  /// Free cars around the pick-up, shown on the map before booking and
  /// while searching (refreshed every 8 s).
  NearbyCars? nearby;
  Timer? _nearbyTimer;

  bool get _wantsNearby =>
      pickup != null && (step == RideStep.home || step == RideStep.mapPick || step == RideStep.options || (step == RideStep.ride && trip?.status == 'searching'));

  void _syncNearby() {
    if (_wantsNearby) {
      if (_nearbyTimer == null) {
        _loadNearby();
        _nearbyTimer = Timer.periodic(const Duration(seconds: 8), (_) => _loadNearby());
      }
    } else {
      _nearbyTimer?.cancel();
      _nearbyTimer = null;
    }
  }

  Future<void> _loadNearby() async {
    final at = step == RideStep.ride ? trip?.pickup : pickup;
    if (at == null) return;
    final cat = step == RideStep.options || step == RideStep.ride ? (trip?.category?.id ?? categoryId) : null;
    final r = await _repo.nearby(at.lat, at.lng, categoryId: cat);
    if (r.statusCode == 200 && r.body is Map) {
      nearby = NearbyCars.fromJson(Map<String, dynamic>.from(r.body));
      super.update();
    }
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    _syncNearby();
    super.update(ids, condition);
  }

  RideOption? get selected => estimate?.options.firstWhereOrNull((o) => o.category.id == categoryId);

  /// Up to four recent destinations, for one-tap re-ordering.
  List<RidePlace> get recent {
    final out = <RidePlace>[];
    for (final t in history) {
      final d = t.destination;
      if (d != null && d.address.isNotEmpty && !out.any((r) => r.address == d.address)) out.add(d);
      if (out.length >= 4) break;
    }
    return out;
  }

  String _error(Response r) => r.statusText ?? 'ride_unavailable'.tr;

  Future<void> load() async {
    step = RideStep.loading;
    update();
    final c = await _repo.config();
    if (c.statusCode == 200 && c.body is Map) {
      config = RideConfig.fromJson(Map<String, dynamic>.from(c.body));
      if (config!.paymentMethods.isNotEmpty && !config!.paymentMethods.contains('cash')) payment = config!.paymentMethods.first;
    } else {
      showCustomSnackBar(_error(c));
    }
    _loadHistory();
    final cur = await _repo.current();
    if (cur.statusCode == 200 && cur.body is Map && cur.body['trip'] is Map) {
      _setTrip(RideTrip.fromJson(Map<String, dynamic>.from(cur.body['trip'])));
      step = RideStep.ride;
    } else if (cur.statusCode == 200 && cur.body is Map && cur.body['to_rate'] is Map) {
      // A finished ride not rated yet: ask for the rating first.
      _setTrip(RideTrip.fromJson(Map<String, dynamic>.from(cur.body['to_rate'])));
      step = RideStep.ride;
    } else {
      step = RideStep.home;
    }
    update();
    _locate();
  }

  Future<void> _loadHistory() async {
    final r = await _repo.history();
    if (r.statusCode == 200 && r.body is Map && r.body['trips'] is List) {
      history = (r.body['trips'] as List).map((t) => RideTrip.fromJson(Map<String, dynamic>.from(t))).toList();
      update();
    }
  }

  /// Pick-up from GPS, else the saved delivery address, else Touba.
  Future<void> _locate() async {
    final saved = AddressHelper.getUserAddressFromSharedPref();
    final lat = double.tryParse(saved?.latitude ?? '');
    final lng = double.tryParse(saved?.longitude ?? '');
    pickup ??= lat != null && lng != null ? RidePlace(lat, lng, saved?.address ?? '') : _touba;
    pickupTick++;
    update();
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      final p = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 12));
      await movePickup(p.latitude, p.longitude, force: true);
    } catch (_) {
      // Stay on the fallback position.
    }
  }

  Future<RidePlace?> currentPlace() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return null;
      final p = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 12));
      final address = await _repo.addressAt(p.latitude, p.longitude);
      return RidePlace(p.latitude, p.longitude, address.isEmpty ? 'ride_my_position'.tr : address);
    } catch (_) {
      return null;
    }
  }

  /// On the home map the pick-up follows the centre pin.
  Future<void> movePickup(double lat, double lng, {bool force = false}) async {
    if (!force && pickup != null && (pickup!.lat - lat).abs() < 1e-5 && (pickup!.lng - lng).abs() < 1e-5) return;
    final id = ++_lookup;
    pickup = RidePlace(lat, lng, '');
    if (force) pickupTick++;
    update();
    final address = await _repo.addressAt(lat, lng);
    if (id == _lookup) {
      pickup = RidePlace(lat, lng, address.isEmpty ? 'ride_point_on_map'.tr : address);
      update();
    }
  }

  void startMapPick({required bool forPickup}) {
    mapPickForPickup = forPickup;
    mapPoint = forPickup ? pickup : (destination ?? pickup);
    step = RideStep.mapPick;
    update();
  }

  Future<void> moveMapPoint(double lat, double lng) async {
    final id = ++_lookup;
    mapPoint = RidePlace(lat, lng, '');
    update();
    final address = await _repo.addressAt(lat, lng);
    if (id == _lookup) {
      mapPoint = RidePlace(lat, lng, address);
      update();
    }
  }

  void confirmMapPoint() {
    final p = mapPoint;
    if (p == null) return;
    setPlace(p.address.isEmpty ? p.withAddress('ride_point_on_map'.tr) : p, forPickup: mapPickForPickup);
  }

  Future<List<PlaceSuggestion>> search(String text) => _repo.searchPlaces(text);
  Future<RidePlace?> placeDetails(String id) => _repo.placeDetails(id);

  /// Sets one end of the ride; once both are known, fetches the tariffs.
  void setPlace(RidePlace place, {required bool forPickup}) {
    if (forPickup) {
      pickup = place;
      pickupTick++;
    } else {
      destination = place;
    }
    if (pickup != null && destination != null) {
      quote();
    } else {
      step = RideStep.home;
      update();
    }
  }

  Future<void> quote() async {
    busy = true;
    estimate = null;
    step = RideStep.options;
    update();
    final r = await _repo.estimate(pickup!, destination!);
    busy = false;
    if (r.statusCode == 200 && r.body is Map) {
      estimate = RideEstimate.fromJson(Map<String, dynamic>.from(r.body));
      final opts = estimate!.options;
      if (!opts.any((o) => o.category.id == categoryId)) {
        categoryId = (opts.firstWhereOrNull((o) => o.driversNearby && o.category.vehicleType == 'car') ??
                opts.firstWhereOrNull((o) => o.driversNearby) ??
                opts.firstOrNull)
            ?.category
            .id;
      }
    } else {
      showCustomSnackBar(_error(r));
      step = RideStep.home;
    }
    update();
  }

  void selectCategory(int id) {
    categoryId = id;
    update();
  }

  void selectPayment(String method) {
    payment = method;
    update();
  }

  void showHistory(bool show) {
    step = show ? RideStep.history : RideStep.home;
    if (show) _loadHistory();
    update();
  }

  void backToHome() {
    step = RideStep.home;
    update();
  }

  Future<void> order() async {
    if (selected == null || busy) return;
    busy = true;
    update();
    final r = await _repo.request(from: pickup!, to: destination!, categoryId: categoryId!, payment: payment);
    busy = false;
    if ((r.statusCode == 200 || r.statusCode == 201) && r.body is Map) {
      _setTrip(RideTrip.fromJson(Map<String, dynamic>.from(r.body)));
      step = RideStep.ride;
    } else {
      showCustomSnackBar(_error(r));
    }
    update();
  }

  Future<void> cancel() async {
    final t = trip;
    if (t == null || busy) return;
    busy = true;
    update();
    final r = await _repo.cancel(t.id);
    busy = false;
    if (r.statusCode == 200 && r.body is Map) {
      _setTrip(RideTrip.fromJson(Map<String, dynamic>.from(r.body)));
      Get.find<ProfileController>().getUserInfo();
    } else {
      showCustomSnackBar(_error(r));
    }
    update();
  }

  Future<void> rate(int stars, String comment) async {
    final t = trip;
    if (t == null || busy) return;
    busy = true;
    update();
    final r = await _repo.rate(t.id, stars, comment);
    busy = false;
    if (r.statusCode == 200 && r.body is Map) {
      _setTrip(RideTrip.fromJson(Map<String, dynamic>.from(r.body)));
    } else {
      showCustomSnackBar(_error(r));
    }
    update();
  }

  void newRide() {
    _setTrip(null);
    destination = null;
    estimate = null;
    step = RideStep.home;
    _loadHistory();
    update();
  }

  /// Follows the ride every few seconds while it is ongoing.
  void _setTrip(RideTrip? t) {
    final wasActive = trip?.isActive ?? false;
    trip = t;
    if (t != null && t.isActive) {
      _poll ??= Timer.periodic(const Duration(seconds: 4), (_) => _refresh());
    } else {
      _poll?.cancel();
      _poll = null;
      if (wasActive && t?.status == 'completed') Get.find<ProfileController>().getUserInfo();
    }
  }

  Future<void> _refresh() async {
    final t = trip;
    if (t == null) return;
    final r = await _repo.trip(t.id);
    if (r.statusCode == 200 && r.body is Map && trip?.id == t.id) {
      _setTrip(RideTrip.fromJson(Map<String, dynamic>.from(r.body)));
      update();
    }
  }

  Future<List<RideMessage>?> messages(int tripId) async {
    final r = await _repo.messages(tripId);
    if (r.statusCode == 200 && r.body is Map && r.body['messages'] is List) {
      return (r.body['messages'] as List).map((m) => RideMessage.fromJson(Map<String, dynamic>.from(m))).toList();
    }
    return null;
  }

  /// Sends a chat message; returns it, or the error to show.
  Future<(RideMessage?, String?)> sendMessage(int tripId, String text) async {
    final r = await _repo.sendMessage(tripId, text);
    if ((r.statusCode == 200 || r.statusCode == 201) && r.body is Map) return (RideMessage.fromJson(Map<String, dynamic>.from(r.body)), null);
    return (null, _error(r));
  }

  @override
  void onClose() {
    _poll?.cancel();
    _nearbyTimer?.cancel();
    super.onClose();
  }
}
