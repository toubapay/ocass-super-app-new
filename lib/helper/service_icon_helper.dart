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

  static const Map<String, String> _byType = {
    'grocery': grocery,
    'food': food,
    'pharmacy': pharmacy,
    'ecommerce': shop,
    'parcel': parcel,
    'rental': car,
    'mobile_money': money,
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
}
