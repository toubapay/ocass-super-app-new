import 'package:google_maps_flutter/google_maps_flutter.dart';

double _d(dynamic v) => v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);
double? _dn(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
int _i(dynamic v) => v == null ? 0 : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
Map<String, dynamic> _m(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

/// A point of the ride with its address text.
class RidePlace {
  final double lat;
  final double lng;
  final String address;
  const RidePlace(this.lat, this.lng, this.address);

  LatLng get latLng => LatLng(lat, lng);
  RidePlace withAddress(String a) => RidePlace(lat, lng, a);

  /// The first two parts of the address, as on the web app.
  String get short => address.split(',').take(2).join(',').trim();

  static RidePlace? fromJson(dynamic json) {
    final m = _m(json);
    final lat = _dn(m['lat']);
    final lng = _dn(m['lng']);
    if (lat == null || lng == null) return null;
    return RidePlace(lat, lng, (m['address'] ?? '').toString());
  }
}

class PlaceSuggestion {
  final String placeId;
  final String main;
  final String secondary;
  const PlaceSuggestion(this.placeId, this.main, this.secondary);
}

class RideConfig {
  final bool enabled;
  final String? moduleName;
  final List<String> paymentMethods;
  final double walletBalance;

  RideConfig.fromJson(Map<String, dynamic> j)
      : enabled = j['enabled'] == true,
        moduleName = j['module_name']?.toString(),
        paymentMethods = (j['payment_methods'] as List? ?? []).map((e) => e.toString()).toList(),
        walletBalance = _d(j['wallet_balance']);
}

class RideCategory {
  final int id;
  final String name;
  final String description;
  final String vehicleType;
  final int seats;

  RideCategory.fromJson(Map<String, dynamic> j)
      : id = _i(j['id']),
        name = (j['name'] ?? '').toString(),
        description = (j['description'] ?? '').toString(),
        vehicleType = (j['vehicle_type'] ?? 'car').toString(),
        seats = _i(j['seats']);
}

class RideOption {
  final RideCategory category;
  final double fare;
  final int? etaMin;
  final bool driversNearby;

  RideOption.fromJson(Map<String, dynamic> j)
      : category = RideCategory.fromJson(_m(j['category'])),
        fare = _d(j['fare']),
        etaMin = j['eta_min'] == null ? null : _i(j['eta_min']),
        driversNearby = j['drivers_nearby'] == true;
}

class RideEstimate {
  final double distanceKm;
  final int durationMin;
  final String? polyline;
  final String? surgeLabel;
  final double surgeMultiplier;
  final List<RideOption> options;

  RideEstimate.fromJson(Map<String, dynamic> j)
      : distanceKm = _d(j['distance_km']),
        durationMin = _i(j['duration_min']),
        polyline = j['polyline']?.toString(),
        surgeLabel = _m(j['surge'])['label']?.toString(),
        surgeMultiplier = _d(_m(j['surge'])['multiplier'] ?? 1),
        options = (j['options'] as List? ?? []).map((o) => RideOption.fromJson(_m(o))).toList();
}

class RideDriver {
  final String name;
  final String? phone;
  final String? imageUrl;
  final double rating;
  final int totalTrips;
  final String vehicle;
  final String color;
  final String plate;
  final double? lat;
  final double? lng;
  final double heading;
  /// gold | silver | blue, and its French label.
  final String tier;
  final String tierLabel;
  final int ratingCount;
  final int totalKm;
  final DateTime? memberSince;

  RideDriver.fromJson(Map<String, dynamic> j)
      : name = (j['name'] ?? '').toString(),
        phone = j['phone']?.toString(),
        imageUrl = j['image_full_url']?.toString(),
        rating = _d(j['rating'] ?? 5),
        totalTrips = _i(j['total_trips']),
        vehicle = (j['vehicle'] ?? '').toString(),
        color = (j['color'] ?? '').toString(),
        plate = (j['plate'] ?? '').toString(),
        lat = _dn(j['lat']),
        lng = _dn(j['lng']),
        heading = _d(j['heading']),
        tier = (_m(j['tier'])['key'] ?? 'blue').toString(),
        tierLabel = (_m(j['tier'])['label'] ?? 'Bleu').toString(),
        ratingCount = _i(j['rating_count']),
        totalKm = _i(j['total_km']),
        memberSince = DateTime.tryParse('${j['member_since']}');

  LatLng? get latLng => lat == null || lng == null ? null : LatLng(lat!, lng!);
}

/// What the rider sees while the ride is on: minutes until the driver
/// reaches the pick-up (with the driver's route), the waiting time once
/// arrived, or the arrival time at the destination.
class RideLive {
  /// to_pickup | waiting | to_destination
  final String phase;
  final int? etaMin;
  final DateTime? etaAt;
  final double distanceKm;
  final String? route;
  final int waitedSeconds;
  final int freeWaitingMinutes;
  final bool paidWaiting;
  final double waitingFeePerMinute;
  final DateTime receivedAt;

  RideLive.fromJson(Map<String, dynamic> j)
      : phase = (j['phase'] ?? '').toString(),
        etaMin = j['eta_min'] == null ? null : _i(j['eta_min']),
        etaAt = DateTime.tryParse('${j['eta_at']}')?.toLocal(),
        distanceKm = _d(j['distance_km']),
        route = j['route']?.toString(),
        waitedSeconds = _i(j['waited_seconds']),
        freeWaitingMinutes = _i(j['free_waiting_minutes']),
        paidWaiting = j['paid_waiting'] == true,
        waitingFeePerMinute = _d(j['waiting_fee_per_minute']),
        receivedAt = DateTime.now();
}

/// A free car around the pick-up, for the map (position and heading only).
class NearbyCar {
  final LatLng position;
  final double heading;
  NearbyCar.fromJson(Map<String, dynamic> j)
      : position = LatLng(_d(j['lat']), _d(j['lng'])),
        heading = _d(j['heading']);
}

class NearbyCars {
  final List<NearbyCar> cars;
  final int? etaMin;
  NearbyCars.fromJson(Map<String, dynamic> j)
      : cars = (j['cars'] as List? ?? []).map((c) => NearbyCar.fromJson(_m(c))).toList(),
        etaMin = j['eta_min'] == null ? null : _i(j['eta_min']);
}

/// A chat message of the ride (from: rider | driver).
class RideMessage {
  final int id;
  final String from;
  final String text;
  final DateTime? at;
  final bool read;
  RideMessage.fromJson(Map<String, dynamic> j)
      : id = _i(j['id']),
        from = (j['from'] ?? '').toString(),
        text = (j['text'] ?? '').toString(),
        at = DateTime.tryParse('${j['at']}')?.toLocal(),
        read = j['read'] == true;
}

class RideTrip {
  static const active = ['searching', 'accepted', 'arrived', 'in_progress'];

  final int id;
  final String reference;
  final String status;
  final RideCategory? category;
  final RidePlace? pickup;
  final RidePlace? destination;
  final double distanceKm;
  final int durationMin;
  final String? polyline;
  final double estimatedFare;
  final double? finalFare;
  final double waitingFee;
  final double cancellationFee;
  final String paymentMethod;
  final String? otp;
  final RideDriver? driver;
  final int? riderRating;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final RideLive? live;
  final int unreadMessages;
  final bool chatOpen;

  RideTrip.fromJson(Map<String, dynamic> j)
      : id = _i(j['id']),
        reference = (j['reference'] ?? '').toString(),
        status = (j['status'] ?? '').toString(),
        category = j['category'] is Map ? RideCategory.fromJson(_m(j['category'])) : null,
        pickup = RidePlace.fromJson(j['pickup']),
        destination = RidePlace.fromJson(j['destination']),
        distanceKm = _d(j['distance_km']),
        durationMin = _i(j['duration_min']),
        polyline = j['polyline']?.toString(),
        estimatedFare = _d(j['estimated_fare']),
        finalFare = _dn(j['final_fare']),
        waitingFee = _d(j['waiting_fee']),
        cancellationFee = _d(j['cancellation_fee']),
        paymentMethod = (j['payment_method'] ?? 'cash').toString(),
        otp = j['otp']?.toString(),
        driver = j['driver'] is Map ? RideDriver.fromJson(_m(j['driver'])) : null,
        riderRating = j['rider_rating'] == null ? null : _i(j['rider_rating']),
        createdAt = DateTime.tryParse('${j['created_at']}')?.toLocal(),
        acceptedAt = DateTime.tryParse('${j['accepted_at']}')?.toLocal(),
        live = j['live'] is Map ? RideLive.fromJson(_m(j['live'])) : null,
        unreadMessages = _i(j['unread_messages']),
        chatOpen = j['chat_open'] == true;

  bool get isActive => active.contains(status);
  double get fare => finalFare ?? estimatedFare;
}

/// Google's encoded polyline format.
List<LatLng> decodePolyline(String? encoded) {
  final points = <LatLng>[];
  if (encoded == null || encoded.isEmpty) return points;
  int index = 0, lat = 0, lng = 0;
  while (index < encoded.length) {
    for (var axis = 0; axis < 2; axis++) {
      int result = 0, shift = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < encoded.length);
      final delta = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      if (axis == 0) {
        lat += delta;
      } else {
        lng += delta;
      }
    }
    points.add(LatLng(lat / 1e5, lng / 1e5));
  }
  return points;
}
