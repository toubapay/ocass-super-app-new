import 'dart:convert';
import 'package:universal_html/html.dart' as html;

class GoogleTagManager {
  /// Pushes a map of data to the window.dataLayer array
  static void push(String eventName, Map<String, dynamic> params) {
    final payload = {
      'event': eventName,
      ...params,
    };

    final script = html.ScriptElement();
    script.innerHtml =
    "window.dataLayer = window.dataLayer || []; window.dataLayer.push(${jsonEncode(payload)});";
    html.document.head?.append(script);
    script.remove();
  }

  static void logAddToCart({
    required String itemId,
    required String itemName,
    required double totalPrice,
    required int quantity,
    required String currency,
  }) {
    push('add_to_cart', {
      'product_id': itemId,
      'product_name': itemName,
      'content_type': 'service',
      'value': totalPrice,
      'currency': currency,
      'quantity': quantity,
    });
  }
}