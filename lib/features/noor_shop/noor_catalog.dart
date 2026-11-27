import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

/// Noor colours, as in the web app (marcheocass).
class NoorShopColors {
  static const green = Color(0xFF0E4D3A);
  static const gold = Color(0xFFB8901F);
  static const goldLight = Color(0xFFE2B33C);
  static const muted = Color(0xFF6E6E73);
  static const line = Color(0xFFE3EBE7);
  static const bg = Color(0xFFF4F6F5);
}

/// The module types that sell products (as SHOP_TYPES in the web app).
const noorShopTypes = ['grocery', 'food', 'pharmacy', 'ecommerce'];

bool isNoorShopModule(ModuleModel? m) => m != null && noorShopTypes.contains(m.moduleType);

/// The catalogue calls of the web app (marcheocass/src/api.js), each made
/// for one module (moduleId header) whatever module the app has selected.
class NoorCatalog {
  static Future<dynamic> _get(String uri, int moduleId) async {
    final api = Get.find<ApiClient>();
    final headers = Map<String, String>.from(api.getHeader());
    headers[AppConstants.moduleId] = '$moduleId';
    final r = await api.getData(uri, headers: headers, handleError: false);
    if (r.statusCode != 200) throw Exception(r.statusText ?? 'error');
    return r.body;
  }

  static List<Item> _items(dynamic body) {
    final list = body is Map ? (body['products'] ?? body['items']) : body;
    if (list is! List) return [];
    final out = <Item>[];
    for (final e in list) {
      if (e is Map) {
        try {
          out.add(Item.fromJson(Map<String, dynamic>.from(e)));
        } catch (_) {}
      }
    }
    return out;
  }

  static List<Map<String, dynamic>> _maps(dynamic list) =>
      list is List ? list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : [];

  static Future<List<Map<String, dynamic>>> banners(int moduleId) async {
    final b = await _get(AppConstants.bannerUri, moduleId);
    return _maps(b is Map ? b['banners'] : null).where((x) => '${x['image_full_url'] ?? ''}'.isNotEmpty).toList();
  }

  /// The module's home slide show (admin: Module home slides manager).
  static Future<List<Map<String, dynamic>>> moduleSlides(int moduleId) async {
    final b = await _get('/api/v1/module-home-slides?module_id=$moduleId', moduleId);
    return _maps(b is Map ? b['slides'] : null).where((x) => '${x['title'] ?? ''}'.isNotEmpty).toList();
  }

  static Future<List<Map<String, dynamic>>> categories(int moduleId) async =>
      _maps(await _get(AppConstants.categoryUri, moduleId));

  static Future<List<Item>> popular(int moduleId, {int limit = 10}) async =>
      _items(await _get('${AppConstants.popularItemUri}?type=all&offset=1&limit=$limit', moduleId));

  static Future<List<Item>> newArrivals(int moduleId, {int limit = 10}) async =>
      _items(await _get('/api/v1/items/new-arrival?type=all&offset=1&limit=$limit', moduleId));

  static Future<List<Item>> categoryItems(int moduleId, int categoryId, {int limit = 30}) async =>
      _items(await _get('${AppConstants.categoryItemUri}$categoryId?type=all&offset=1&limit=$limit', moduleId));

  static Future<List<Item>> brandItems(int moduleId, int brandId) async =>
      _items(await _get('${AppConstants.brandItemUri}/$brandId?offset=1&limit=50&type=all', moduleId));

  static Future<List<Item>> itemCampaigns(int moduleId) async => _items(await _get(AppConstants.itemCampaignUri, moduleId));

  static Future<List<Map<String, dynamic>>> brands(int moduleId) async => _maps(await _get(AppConstants.brandListUri, moduleId));

  static Future<List<Map<String, dynamic>>> basicCampaigns(int moduleId) async =>
      _maps(await _get(AppConstants.basicCampaignUri, moduleId));

  static Future<List<Store>> stores(int moduleId, {int limit = 30}) async {
    final b = await _get('${AppConstants.storeUri}/all?offset=1&limit=$limit&type=all&store_type=all', moduleId);
    final out = <Store>[];
    for (final s in _maps(b is Map ? b['stores'] : null)) {
      try {
        out.add(Store.fromJson(s));
      } catch (_) {}
    }
    return out;
  }

  /// Flash sale of the module with its products (each carrying its sale price).
  static Future<({String? endDate, List<Item> items})> flashSale(int moduleId) async {
    final f = await _get(AppConstants.flashSaleUri, moduleId);
    if (f is! Map || f['id'] == null) return (endDate: null, items: <Item>[]);
    final items = <Item>[];
    for (final p in _maps(f['active_products'])) {
      final raw = p['item'];
      if (raw is! Map) continue;
      try {
        final item = Item.fromJson(Map<String, dynamic>.from(raw));
        final sale = p['discounted_price'] ?? p['price'];
        if (sale != null) {
          final price = double.tryParse('$sale');
          if (price != null && item.price != null && price < item.price!) {
            item.discount = item.price! - price;
            item.discountType = 'amount';
          }
        }
        items.add(item);
      } catch (_) {}
    }
    return (endDate: f['end_date']?.toString(), items: items);
  }

  // ---- Navigation, the same screens as the rest of the app ----

  static void _selectModule(int? moduleId) {
    if (moduleId == null) return;
    final splash = Get.find<SplashController>();
    if (splash.module?.id == moduleId) return;
    for (final m in splash.moduleList ?? const <ModuleModel>[]) {
      if (m.id == moduleId) {
        splash.setModule(m);
        break;
      }
    }
  }

  static void openItem(Item item, BuildContext context, {bool campaign = false}) {
    Get.find<ItemController>().navigateToItemPage(item, context, isCampaign: campaign, moduleId: item.moduleId);
  }

  static void openStore({required int id, String? name, int? moduleId}) {
    _selectModule(moduleId);
    final store = Store(id: id, name: name, moduleId: moduleId);
    Get.toNamed(RouteHelper.getStoreRoute(id: id, page: 'module'), arguments: StoreScreen(store: store, fromModule: true));
  }

  static void openBrand(int id, String name) => Get.toNamed(RouteHelper.getBrandsItemScreen(id, name));
}
