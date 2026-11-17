import 'dart:math';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';

/// Noor Annonces: quick classified listings, the same module as the /listing/
/// web app. Anyone can browse; a signed-in customer sells with their own Noor
/// account ("particulier"). Buyers have no account in the chat: a random id
/// kept on the phone identifies their conversations.
class ListingApi {
  static ApiClient get _api => Get.find<ApiClient>();
  static const _buyerKey = 'listing_buyer';
  static String? _buyer;

  /// The buyer id of this phone, created once.
  static Future<String> buyerToken() async {
    if (_buyer != null) return _buyer!;
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(_buyerKey);
    if (token == null || token.length < 24) {
      final r = Random.secure();
      token = List.generate(24, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
      await prefs.setString(_buyerKey, token);
    }
    return _buyer = token;
  }

  static Future<Map<String, String>> _headers() async => {..._api.getHeader(), 'X-Listing-Buyer': await buyerToken()};

  static Future<Response> _get(String uri, {Map<String, dynamic>? query}) async {
    final q = <String, dynamic>{};
    query?.forEach((k, v) {
      if (v != null && '$v'.isNotEmpty) q[k] = '$v';
    });
    final qs = q.isEmpty ? '' : '?${Uri(queryParameters: q.map((k, v) => MapEntry(k, '$v'))).query}';
    return _api.getData('$uri$qs', headers: await _headers(), handleError: false);
  }

  static Future<Response> _post(String uri, Map<String, dynamic> body, {int? timeout}) async =>
      _api.postData(uri, body, headers: {...await _headers(), 'Content-Type': 'application/json; charset=UTF-8'}, handleError: false, timeout: timeout);

  // ── Public ──
  static Future<Response> config() => _get('${AppConstants.listingUri}/config');
  static Future<Response> items(Map<String, dynamic> query) => _get('${AppConstants.listingUri}/items', query: query);
  static Future<Response> item(int id) => _get('${AppConstants.listingUri}/items/$id');
  static Future<void> contact(int id, String type) async {
    await _post('${AppConstants.listingUri}/items/$id/contact', {'type': type});
  }

  // ── Buyer chat ──
  static Future<Response> startChat(int id, String name, String message) =>
      _post('${AppConstants.listingUri}/items/$id/chat', {'name': name, 'message': message});
  static Future<Response> buyerChats() => _get('${AppConstants.listingUri}/chats');
  static Future<Response> buyerChat(int id) => _get('${AppConstants.listingUri}/chats/$id');
  static Future<Response> buyerSend(int id, String message) => _post('${AppConstants.listingUri}/chats/$id/messages', {'message': message});

  // ── Seller (the signed-in customer) ──
  static const _s = AppConstants.listingSellerUri;
  static Future<Response> me() => _get('$_s/me');
  static Future<Response> myItems() => _get('$_s/items');
  static Future<Response> update(int id, Map<String, dynamic> body) => _post('$_s/items/$id', body);
  static Future<Response> remove(int id) async => _api.deleteData('$_s/items/$id', headers: await _headers(), handleError: false);
  static Future<Response> boostIncluded(int id) => _post('$_s/items/$id/boost-included', {});
  static Future<Response> pay(Map<String, dynamic> body) => _post('$_s/pay', {
        ...body,
        'callback': AppConstants.baseUrl + AppConstants.listingPaymentCallbackPath,
      }, timeout: 60);
  static Future<Response> payments() => _get('$_s/payments');
  static Future<Response> sellerChats() => _get('$_s/chats');
  static Future<Response> sellerChat(int id) => _get('$_s/chats/$id');
  static Future<Response> sellerSend(int id, String message) => _post('$_s/chats/$id/messages', {'message': message});

  static Future<Response> post(Map<String, String> fields, List<XFile> photos) async => _api.postMultipartData(
        '$_s/items',
        fields,
        [for (final p in photos) MultipartBody('images[]', p)],
        headers: await _headers(),
        handleError: false,
      );

  static Future<Response> ai(List<XFile> photos) async => _api.postMultipartData(
        '$_s/ai',
        {},
        [for (final p in photos.take(3)) MultipartBody('images[]', p)],
        headers: await _headers(),
        handleError: false,
      );

  /// The backend's error message, or a generic one.
  static String error(Response r) {
    final body = r.body;
    if (body is Map && body['errors'] is List && (body['errors'] as List).isNotEmpty) {
      return '${(body['errors'] as List).first['message']}';
    }
    if (body is Map && body['message'] is String) return body['message'];
    if (r.statusCode == 1) return 'lst_no_internet'.tr;
    return 'lst_error'.tr;
  }
}

class ListingCategory {
  final int id;
  final String name;
  final String icon;
  final int count;
  ListingCategory(this.id, this.name, this.icon, this.count);
  factory ListingCategory.fromJson(Map j) => ListingCategory(j['id'], '${j['name']}', '${j['icon'] ?? '📦'}', j['count'] ?? 0);
}

/// What the module allows, from /listing/config (cached for the session).
class ListingConfig {
  final bool status;
  final bool aiFill;
  final int maxPhotos;
  final int freeListings;
  final double extraPrice;
  final double boostPerDay;
  final Map<String, bool> contacts;
  final Map<String, bool> payments;
  final List<ListingCategory> categories;
  final bool allowUsers;

  ListingConfig({
    required this.status,
    required this.aiFill,
    required this.maxPhotos,
    required this.freeListings,
    required this.extraPrice,
    required this.boostPerDay,
    required this.contacts,
    required this.payments,
    required this.categories,
    required this.allowUsers,
  });

  static ListingConfig? _cached;

  static Future<ListingConfig?> load({bool refresh = false}) async {
    if (_cached != null && !refresh) return _cached;
    final r = await ListingApi.config();
    if (r.statusCode != 200 || r.body is! Map) return _cached;
    final s = r.body['settings'] ?? {};
    Map<String, bool> flags(dynamic m) => (m is Map ? m : {}).map((k, v) => MapEntry('$k', v == true));
    return _cached = ListingConfig(
      status: s['status'] != false,
      aiFill: s['ai_fill'] == true,
      maxPhotos: (s['max_photos'] ?? 5) as int,
      freeListings: (s['free_listings_users'] ?? s['free_listings'] ?? 3) as int,
      extraPrice: (s['extra_listing_price'] ?? 0).toDouble(),
      boostPerDay: (s['boost_price_per_day'] ?? 0).toDouble(),
      contacts: flags(s['contacts']),
      payments: flags(s['payments']),
      allowUsers: s['allow_users'] != false,
      categories: [for (final c in (r.body['categories'] ?? [])) ListingCategory.fromJson(c)],
    );
  }
}

class ListingItem {
  final int id;
  final String title;
  final double price;
  final String? image;
  final List<String> images;
  final ListingCategory? category;
  final bool featured;
  final int views;
  final double? distanceKm;
  final String? city;
  final String status;
  final DateTime? createdAt;
  final String? description;
  final String? address;
  final double? lat;
  final double? lng;
  final Map? seller;
  final int contacts;
  final String? adminNote;
  final DateTime? featuredUntil;

  ListingItem.fromJson(Map j)
      : id = j['id'],
        title = '${j['title'] ?? ''}',
        price = (j['price'] ?? 0).toDouble(),
        image = j['image'],
        images = [for (final i in (j['images'] ?? [])) '$i'],
        category = j['category'] is Map ? ListingCategory.fromJson(j['category']) : null,
        featured = j['is_featured'] == true,
        views = j['views'] ?? 0,
        distanceKm = j['distance_km'] == null ? null : (j['distance_km'] as num).toDouble(),
        city = j['city'],
        status = '${j['status'] ?? 'active'}',
        createdAt = DateTime.tryParse('${j['created_at']}'),
        description = j['description'],
        address = j['address'],
        lat = j['latitude'] == null ? null : double.tryParse('${j['latitude']}'),
        lng = j['longitude'] == null ? null : double.tryParse('${j['longitude']}'),
        seller = j['seller'] is Map ? j['seller'] : null,
        contacts = j['contacts'] ?? 0,
        adminNote = j['admin_note'],
        featuredUntil = DateTime.tryParse('${j['featured_until']}');
}

/// "35 000 F"
String listingMoney(num? value) {
  final n = (value ?? 0).round().toString();
  final b = StringBuffer();
  for (var i = 0; i < n.length; i++) {
    if (i > 0 && (n.length - i) % 3 == 0) b.write(' ');
    b.write(n[i]);
  }
  return '$b F';
}

/// "il y a 5 min"
String listingAgo(DateTime? d) {
  if (d == null) return '';
  final m = DateTime.now().difference(d.toLocal()).inMinutes;
  if (m < 1) return 'lst_now'.tr;
  if (m < 60) return 'lst_minutes_ago'.trParams({'n': '$m'});
  if (m < 60 * 24) return 'lst_hours_ago'.trParams({'n': '${m ~/ 60}'});
  return 'lst_days_ago'.trParams({'n': '${m ~/ (60 * 24)}'});
}

/// "à côté", "800 m", "3,2 km"
String? listingKm(double? d) {
  if (d == null) return null;
  if (d < 0.1) return 'lst_next_to_you'.tr;
  if (d < 1) return '${(d * 10).round() * 100} m';
  return '${d.toStringAsFixed(1).replaceAll('.', ',')} km';
}

/// Senegal numbers in international form, for WhatsApp, calls and SMS.
String listingIntlPhone(String phone) {
  var p = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (p.startsWith('00')) p = '+${p.substring(2)}';
  if (!p.startsWith('+')) p = p.startsWith('221') ? '+$p' : '+221$p';
  return p;
}
