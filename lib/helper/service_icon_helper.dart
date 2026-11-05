import 'package:sixam_mart/common/models/module_model.dart';

/// Illustrated service icons, the same set as the Noor web app
/// (assets/image/services/*.svg).
class ServiceIcons {
  static const String _dir = 'assets/image/services';
  static const String grocery = '$_dir/grocery.svg';
  static const String food = '$_dir/food.svg';
  static const String pharmacy = '$_dir/pharmacy.svg';
  static const String shop = '$_dir/shop.svg';
  static const String parcel = '$_dir/parcel.svg';
  static const String car = '$_dir/car.svg';
  static const String insurance = '$_dir/insurance.svg';
  static const String money = '$_dir/money.svg';
  static const String airtime = '$_dir/airtime.svg';
  static const String bill = '$_dir/bill.svg';
  static const String beauty = '$_dir/beauty.svg';
  static const String smartHome = '$_dir/smart_home.svg';
  static const String rider = '$_dir/rider.svg';
  static const String safety = '$_dir/safety.svg';
  static const String handover = '$_dir/handover.svg';
  static const String electronics = '$_dir/electronics.svg';
  static const String taxi = '$_dir/taxi.svg';
  static const String motoTaxi = '$_dir/moto_taxi.svg';
  static const String van = '$_dir/van.svg';

  static const Map<String, String> _byType = {
    'grocery': grocery,
    'food': food,
    'pharmacy': pharmacy,
    'ecommerce': shop,
    // Delivery module tile: the rider on his motorbike.
    'parcel': rider,
    'rental': car,
    'mobile_money': money,
    'taxi': taxi,
  };

  /// Picture for a module: by its type, or by its name for shop modules
  /// named after a category (cosmetics, smart home), as on the web app.
  static String? forModule(ModuleModel module) {
    final name = (module.moduleName ?? '').toLowerCase();
    if (module.moduleType == 'ecommerce') {
      if (RegExp(r'cosm|beaut|parfum').hasMatch(name)) return beauty;
      if (RegExp(r'home|maison|domo').hasMatch(name)) return smartHome;
    }
    return _byType[module.moduleType];
  }

  /// Picture for a ride category's vehicle type.
  static String forVehicle(String type) => type == 'moto' || type == 'tricycle' ? motoTaxi : type == 'van' ? van : car;

  /// Picture for a parcel type by its name, as on the web app.
  static String forParcelType(String? name) {
    final n = (name ?? '').toLowerCase();
    if (RegExp(r'electr|phone|t[ée]l[ée]phon|ordinat').hasMatch(n)) return electronics;
    if (RegExp(r'aliment|food|course|march[ée]|grocer').hasMatch(n)) return grocery;
    if (RegExp(r'restau|repas|meal').hasMatch(n)) return food;
    if (RegExp(r'document|papier|lettre').hasMatch(n)) return bill;
    return parcel;
  }

  /// Picture for a "why choose us" point by its title, as on the web app.
  static String forWhyChoose(String? title, int index) {
    final t = (title ?? '').toLowerCase();
    if (RegExp(r'safe|s[ée]cur|protect|care|soin').hasMatch(t)) return safety;
    if (RegExp(r'fast|rapid|express|vite|delivery|livraison').hasMatch(t)) return rider;
    if (RegExp(r'24|service|dispon|anytime').hasMatch(t)) return handover;
    return [safety, rider, handover][index % 3];
  }
}
