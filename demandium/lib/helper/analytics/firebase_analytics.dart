import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService {
  static final FirebaseAnalytics _instance = FirebaseAnalytics.instance;

  static Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required double price,
    required int quantity,
    required String currency,
  }) async {
    await _instance.logAddToCart(
      currency: currency,
      value: price * quantity,
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          price: price,
          quantity: quantity,
          currency: currency,
        ),
      ],
    );
  }
}
