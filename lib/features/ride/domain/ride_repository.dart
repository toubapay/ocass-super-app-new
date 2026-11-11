import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/ride/domain/ride_models.dart';
import 'package:sixam_mart/util/app_constants.dart';

/// Calls to /api/v1/customer/taxi plus the server-side Google place and
/// geocoding endpoints. Errors are left to the controller (handleError:
/// false) so the backend's French message is shown as is.
class RideRepository {
  ApiClient get _api => Get.find<ApiClient>();

  Future<Response> config() => _api.getData(AppConstants.rideConfigUri, handleError: false);

  Future<Response> estimate(RidePlace from, RidePlace to) => _api.postData(
        AppConstants.rideEstimateUri,
        {'pickup_lat': from.lat, 'pickup_lng': from.lng, 'destination_lat': to.lat, 'destination_lng': to.lng},
        handleError: false,
      );

  Future<Response> request({required RidePlace from, required RidePlace to, required int categoryId, required String payment}) => _api.postData(
        AppConstants.rideTripsUri,
        {
          'pickup_lat': from.lat,
          'pickup_lng': from.lng,
          'pickup_address': from.address,
          'destination_lat': to.lat,
          'destination_lng': to.lng,
          'destination_address': to.address,
          'vehicle_category_id': categoryId,
          'payment_method': payment,
        },
        handleError: false,
      );

  Future<Response> current() => _api.getData(AppConstants.rideCurrentUri, handleError: false);

  Future<Response> trip(int id) => _api.getData('${AppConstants.rideTripsUri}/$id', handleError: false);

  Future<Response> cancel(int id) => _api.postData('${AppConstants.rideTripsUri}/$id/cancel', {}, handleError: false);

  Future<Response> rate(int id, int rating, String comment) =>
      _api.postData('${AppConstants.rideTripsUri}/$id/rate', {'rating': rating, if (comment.isNotEmpty) 'comment': comment}, handleError: false);

  /// Free cars around a point (as in Yango), with the waiting time.
  Future<Response> nearby(double lat, double lng, {int? categoryId}) => _api.getData(
        AppConstants.rideNearbyUri,
        query: {'lat': '$lat', 'lng': '$lng', if (categoryId != null) 'category_id': '$categoryId'},
        handleError: false,
      );

  Future<Response> messages(int id) => _api.getData('${AppConstants.rideTripsUri}/$id/messages', handleError: false);

  Future<Response> sendMessage(int id, String text) => _api.postData('${AppConstants.rideTripsUri}/$id/messages', {'text': text}, handleError: false);

  Future<Response> history() => _api.getData(AppConstants.rideTripsUri, query: {'limit': '20', 'offset': '1'}, handleError: false);

  Future<List<PlaceSuggestion>> searchPlaces(String text) async {
    final r = await _api.getData('${AppConstants.searchLocationUri}?search_text=${Uri.encodeQueryComponent(text)}', handleError: false);
    if (r.statusCode != 200 || r.body is! Map || r.body['suggestions'] is! List) return [];
    return (r.body['suggestions'] as List)
        .map((s) => s is Map ? s['placePrediction'] : null)
        .whereType<Map>()
        .map((p) => PlaceSuggestion(
              '${p['placeId']}',
              '${p['structuredFormat']?['mainText']?['text'] ?? p['text']?['text'] ?? ''}',
              '${p['structuredFormat']?['secondaryText']?['text'] ?? ''}',
            ))
        .toList();
  }

  Future<RidePlace?> placeDetails(String placeId) async {
    final r = await _api.getData('${AppConstants.placeDetailsUri}?placeid=$placeId', handleError: false);
    if (r.statusCode != 200 || r.body is! Map || r.body['location'] is! Map) return null;
    final loc = r.body['location'];
    return RidePlace(
      (loc['latitude'] as num).toDouble(),
      (loc['longitude'] as num).toDouble(),
      '${r.body['formattedAddress'] ?? r.body['displayName']?['text'] ?? ''}',
    );
  }

  Future<String> addressAt(double lat, double lng) async {
    final r = await _api.getData('${AppConstants.geocodeUri}?lat=$lat&lng=$lng', handleError: false);
    if (r.statusCode == 200 && r.body is Map && r.body['results'] is List && (r.body['results'] as List).isNotEmpty) {
      return '${r.body['results'][0]['formatted_address']}';
    }
    return '';
  }
}
