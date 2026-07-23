import 'package:demandium/util/core_export.dart';

import 'facebook_analytics.dart';
import 'firebase_analytics.dart';
import 'google_tag_manager.dart';

class AnalyticsHelper {
  static Future<void> init() async {
    if (kIsWeb) {
      return;
    }
    // await TikTokAnalyticsService.init();
  }

  static Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required double price,
    required int quantity,
    required String currency,
  }) async {
    final double totalPrice = price * quantity;

    try {
      await FirebaseAnalyticsService.logAddToCart(
        itemId: itemId,
        itemName: itemName,
        price: price,
        quantity: quantity,
        currency: currency,
      );

      if (kIsWeb) {
        GoogleTagManager.logAddToCart(
          itemId: itemId,
          itemName: itemName,
          totalPrice: totalPrice,
          quantity: quantity,
          currency: currency,
        );
      } else {
        await FacebookAnalyticsService.logAddToCart(
          itemId: itemId,
          currency: currency,
          totalPrice: totalPrice,
        );
        // await TikTokAnalyticsService.logAddToCart(
        //   itemId: itemId,
        //   itemName: itemName,
        //   totalPrice: totalPrice,
        //   quantity: quantity,
        //   currency: currency,
        // );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Analytics Helper Error: $e");
      }
    }
  }
}
