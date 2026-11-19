import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

/// What the shops of the current service are called, as in the web app:
/// pharmacy → "Pharmacies", grocery → "Magasins", other shops → "Boutiques"
/// (food services say "Restaurants" through showRestaurantText).
String storesLabel() {
  final type = Get.find<SplashController>().module?.moduleType;
  if (type == 'pharmacy') return 'pharmacies'.tr;
  if (type == 'grocery') return 'stores'.tr;
  return 'shops_label'.tr;
}
