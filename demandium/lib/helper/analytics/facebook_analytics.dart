import 'package:facebook_app_events/facebook_app_events.dart';

class FacebookAnalyticsService {
  static final FacebookAppEvents _instance = FacebookAppEvents();

  static Future<void> logAddToCart({
    required String itemId,
    required String currency,
    required double totalPrice,
  }) async {
    await _instance.logEvent(
      name: FacebookAppEvents.eventNameAddedToCart,
      parameters: {
        FacebookAppEvents.paramNameContentId: itemId,
        FacebookAppEvents.paramNameContentType: 'service',
        FacebookAppEvents.paramNameCurrency: currency,
      },
      valueToSum: totalPrice,
    );
  }
}