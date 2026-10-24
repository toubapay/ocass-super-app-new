import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/insurance/screens/insurance_policy_screen.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the PayDunya checkout for a policy, then shows that policy once
/// PayDunya sends the customer back to the callback URL.
class InsurancePaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final int policyId;
  const InsurancePaymentScreen({super.key, required this.paymentUrl, required this.policyId});

  @override
  State<InsurancePaymentScreen> createState() => _InsurancePaymentScreenState();
}

class _InsurancePaymentScreenState extends State<InsurancePaymentScreen> {
  _InsuranceCheckoutBrowser? _browser;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    if (GetPlatform.isWeb) {
      await launchUrl(Uri.parse(widget.paymentUrl), webOnlyWindowName: '_self');
      return;
    }
    _browser = _InsuranceCheckoutBrowser(onFinished: _finish);
    await _browser!.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(widget.paymentUrl)),
      settings: InAppBrowserClassSettings(
        webViewSettings: InAppWebViewSettings(useShouldOverrideUrlLoading: true),
        browserSettings: InAppBrowserSettings(hideUrlBar: true, hideToolbarTop: GetPlatform.isAndroid),
      ),
    );
  }

  /// Whatever the flag, the policy screen shows the real status from the backend.
  void _finish() {
    Get.off(() => InsurancePolicyScreen(policyId: widget.policyId, fromPayment: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'payment'.tr, onBackPressed: _finish),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
          const SizedBox(height: 16),
          Text('ins_payment_in_progress'.tr, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(onPressed: _finish, child: Text('ins_see_my_policy'.tr)),
        ]),
      ),
    );
  }
}

class _InsuranceCheckoutBrowser extends InAppBrowser {
  final VoidCallback onFinished;
  bool _done = false;

  _InsuranceCheckoutBrowser({required this.onFinished});

  static bool _isExternal(Uri uri) =>
      uri.scheme == 'wave' ||
      uri.scheme == 'market' ||
      uri.host == 'pay.wave.com' ||
      uri.host == 'play.google.com' ||
      uri.host == 'apps.apple.com' ||
      !['http', 'https', 'about', 'data', 'javascript'].contains(uri.scheme);

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(NavigationAction navigationAction) async {
    final uri = navigationAction.request.url;
    if (uri == null) return NavigationActionPolicy.ALLOW;
    // Mobile-money apps (Wave, Orange Money...) open outside the web view.
    if (_isExternal(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  Future onLoadStart(WebUri? url) async => _check(url);

  @override
  Future onLoadStop(WebUri? url) async => _check(url);

  void _check(WebUri? url) {
    if (_done || url == null) return;
    if (kDebugMode) debugPrint('insurance payment: $url');
    if (url.toString().startsWith(AppConstants.baseUrl + AppConstants.insurancePaymentCallbackPath)) {
      _done = true;
      close();
      Future.delayed(const Duration(milliseconds: 300), onFinished);
    }
  }

  @override
  void onExit() {
    // Closed by the customer before PayDunya finished: show the policy anyway.
    if (!_done) {
      _done = true;
      onFinished();
    }
  }
}
