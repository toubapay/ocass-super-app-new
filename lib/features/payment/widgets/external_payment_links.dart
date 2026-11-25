import 'package:url_launcher/url_launcher.dart';

/// Links a payment web view must hand to the phone instead of loading:
/// Wave (pay.wave.com, wave://), Orange Money / Max it (custom schemes),
/// Android `intent://` links that PayDunya uses, and the app stores.
///
/// Loading them inside the web view left a blank page (the wallet page only
/// redirects to its app). Call [isExternalPaymentLink] from
/// `shouldOverrideUrlLoading` and cancel the navigation when it is true,
/// after [openExternalPaymentLink].
bool isExternalPaymentLink(Uri uri) {
  if (uri.host == 'pay.wave.com' || uri.host == 'play.google.com' || uri.host == 'apps.apple.com') return true;
  return !const ['http', 'https', 'file', 'chrome', 'data', 'javascript', 'about', 'blob'].contains(uri.scheme);
}

/// Opens [uri] in the wallet's app (or the browser / store as a fallback).
/// Returns true when something was opened.
Future<bool> openExternalPaymentLink(Uri uri) async {
  if (uri.scheme == 'intent') return _openIntent(uri);
  if (await _launch(uri)) return true;
  return false;
}

/// intent://HOST/PATH#Intent;scheme=S;package=P;S.browser_fallback_url=U;end
/// (url_launcher cannot open intent:// itself): the app's own link first,
/// then the fallback page, then the app's Play Store page.
Future<bool> _openIntent(Uri uri) async {
  final raw = uri.toString();
  final hash = raw.indexOf('#Intent;');
  final target = hash < 0 ? raw : raw.substring(0, hash);
  final params = <String, String>{};
  if (hash >= 0) {
    for (final part in raw.substring(hash + 8).split(';')) {
      final eq = part.indexOf('=');
      if (eq > 0) params[part.substring(0, eq)] = part.substring(eq + 1);
    }
  }
  final scheme = params['scheme'];
  if (scheme != null) {
    final direct = Uri.tryParse(target.replaceFirst('intent://', '$scheme://'));
    if (direct != null && await _launch(direct)) return true;
  }
  final fallback = params['S.browser_fallback_url'];
  if (fallback != null) {
    final f = Uri.tryParse(Uri.decodeComponent(fallback));
    if (f != null && await _launch(f)) return true;
  }
  final package = params['package'];
  if (package != null && await _launch(Uri.parse('market://details?id=$package'))) return true;
  return false;
}

Future<bool> _launch(Uri uri) async {
  try {
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return true;
  } catch (_) {}
  try {
    return await launchUrl(uri, mode: LaunchMode.platformDefault);
  } catch (_) {
    return false;
  }
}
