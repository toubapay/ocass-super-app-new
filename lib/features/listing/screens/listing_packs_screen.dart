import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/listing/listing_api.dart';
import 'package:sixam_mart/features/listing/widgets/listing_ui.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Packages and one extra listing, paid with the Noor wallet or PayDunya
/// (Orange Money, Wave, card). Pops with true once something was bought.
class ListingPacksScreen extends StatefulWidget {
  final String? reason; // "quota": the free listings are used up
  const ListingPacksScreen({super.key, this.reason});

  @override
  State<ListingPacksScreen> createState() => _ListingPacksScreenState();
}

class _ListingPacksScreenState extends State<ListingPacksScreen> {
  Map? _me;
  String? _error;
  Map<String, dynamic>? _picked; // {kind, package_id?, label, amount}
  bool _busy = false;
  bool _bought = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await ListingApi.me();
    if (!mounted) return;
    setState(() {
      if (r.statusCode == 200 && r.body is Map) {
        _me = r.body;
      } else {
        _error = ListingApi.error(r);
      }
    });
  }

  Future<void> _pay(String method) async {
    final p = _picked;
    if (p == null) return;
    setState(() => _busy = true);
    final r = await ListingApi.pay({'kind': p['kind'], if (p['package_id'] != null) 'package_id': p['package_id'], 'method': method});
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.statusCode != 200 || r.body is! Map) {
      showCustomSnackBar(ListingApi.error(r));
      return;
    }
    final link = r.body['redirect_link'];
    if (link is String && link.isNotEmpty) {
      await listingCheckout(link);
    }
    _bought = true;
    await _load();
    final status = await _lastStatus();
    showCustomSnackBar(status == 'paid' ? 'lst_payment_done'.tr : 'lst_payment_pending'.tr, isError: status != 'paid');
    setState(() => _picked = null);
  }

  /// Status of the newest payment, as the backend recorded it.
  Future<String?> _lastStatus() async {
    final r = await ListingApi.payments();
    if (r.statusCode != 200 || r.body is! Map) return null;
    final list = (r.body['payments'] ?? []) as List;
    return list.isEmpty ? null : '${list.first['status']}';
  }

  @override
  Widget build(BuildContext context) {
    final settings = (_me?['settings'] ?? {}) as Map;
    final pay = (settings['payments'] ?? {}) as Map;
    final packages = (_me?['packages'] ?? []) as List;
    final quota = (_me?['quota'] ?? {}) as Map;
    final sub = quota['subscription'] as Map?;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Get.back(result: _bought);
      },
      child: Scaffold(
        backgroundColor: LColors.bg,
        appBar: ListingBar(title: 'lst_packs_title'.tr),
        body: _me == null
            ? (_error != null ? ListingEmpty(emoji: '🙁', text: _error!) : const Center(child: CircularProgressIndicator(color: LColors.green)))
            : ListView(padding: const EdgeInsets.all(16), children: [
                if (widget.reason == 'quota')
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFFF4F0), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF6D3C8))),
                    child: Text('lst_quota_reached'.tr, style: robotoMedium.copyWith(color: const Color(0xFF9B3412))),
                  ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF3B2A03), LColors.goldDark, LColors.goldLight], stops: [0, .6, 1]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('lst_current_plan'.tr, style: robotoRegular.copyWith(color: Colors.white70, fontSize: 12)),
                    Text(
                      sub != null
                          ? '${sub['name']} · ${sub['listings_limit'] == null ? '∞' : '${sub['listings_used']} / ${sub['listings_limit']}'}'
                          : 'lst_quota_free'.trParams({'left': '${quota['free_left'] ?? 0}', 'total': '${quota['free_total'] ?? 0}'}),
                      style: robotoBold.copyWith(color: Colors.white, fontSize: 17),
                    ),
                    const SizedBox(height: 6),
                    Text('${'lst_wallet'.tr} : ${listingMoney(_me?['wallet_balance'])}', style: robotoMedium.copyWith(color: Colors.white, fontSize: 12.5)),
                  ]),
                ),
                const SizedBox(height: 16),
                Text('lst_choose_pack'.tr, style: robotoBold.copyWith(fontSize: 16)),
                const SizedBox(height: 10),
                for (final p in packages)
                  _pack(
                    key: 'p${p['id']}',
                    title: '${p['name']}',
                    price: (p['price'] as num).toDouble(),
                    best: p['highlight'] == true,
                    lines: [
                      p['listings_limit'] == null ? 'lst_unlimited'.tr : 'lst_n_listings'.trParams({'n': '${p['listings_limit']}'}),
                      'lst_n_days'.trParams({'n': '${p['duration_days']}'}),
                      if ((p['featured_count'] ?? 0) > 0) 'lst_n_boosts'.trParams({'n': '${p['featured_count']}'}),
                      if ((p['description'] ?? '').toString().isNotEmpty) '${p['description']}',
                    ],
                    value: {'kind': 'package', 'package_id': p['id'], 'amount': p['price']},
                  ),
                _pack(
                  key: 'extra',
                  title: 'lst_one_extra'.tr,
                  price: (settings['extra_listing_price'] ?? 0).toDouble(),
                  lines: ['lst_one_extra_hint'.tr],
                  value: {'kind': 'extra', 'amount': settings['extra_listing_price']},
                ),
                const SizedBox(height: 90),
              ]),
        bottomNavigationBar: _picked == null
            ? null
            : SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: LColors.line))),
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('${'lst_to_pay'.tr} : ${listingMoney(_picked!['amount'])}', textAlign: TextAlign.center, style: robotoBold.copyWith(fontSize: 15)),
                    const SizedBox(height: 8),
                    Row(children: [
                      if (pay['paydunya'] == true) Expanded(child: ListingButton(text: 'lst_pay_mobile'.tr, busy: _busy, onTap: () => _pay('paydunya'))),
                      if (pay['paydunya'] == true && pay['wallet'] == true) const SizedBox(width: 8),
                      if (pay['wallet'] == true) Expanded(child: ListingButton(text: 'lst_pay_wallet'.tr, style: 'outline', busy: _busy, onTap: () => _pay('wallet'))),
                    ]),
                  ]),
                ),
              ),
      ),
    );
  }

  Widget _pack({required String key, required String title, required double price, required List<String> lines, required Map<String, dynamic> value, bool best = false}) {
    final picked = _picked != null && _picked!['_key'] == key;
    return GestureDetector(
      onTap: () => setState(() => _picked = {...value, '_key': key}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: best ? const Color(0xFFFFFAF0) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: picked ? LColors.green : (best ? LColors.gold : LColors.line), width: picked || best ? 2 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: robotoBold.copyWith(fontSize: 15.5))),
            if (best) Padding(padding: const EdgeInsets.only(right: 8), child: ListingPill(text: 'lst_most_chosen'.tr, gold: true)),
            Text(listingMoney(price), style: robotoBold.copyWith(fontSize: 18, color: LColors.green)),
          ]),
          const SizedBox(height: 6),
          for (final l in lines) Text('• $l', style: robotoRegular.copyWith(fontSize: 12.5, color: LColors.muted, height: 1.6)),
        ]),
      ),
    );
  }
}

/// Opens the PayDunya checkout and returns once the customer comes back to
/// the callback page (or closes it). The real status comes from the backend.
Future<void> listingCheckout(String url) async {
  if (GetPlatform.isWeb) {
    await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
    return;
  }
  final browser = _ListingCheckoutBrowser();
  await browser.openUrlRequest(
    urlRequest: URLRequest(url: WebUri(url)),
    settings: InAppBrowserClassSettings(
      webViewSettings: InAppWebViewSettings(useShouldOverrideUrlLoading: true),
      browserSettings: InAppBrowserSettings(hideUrlBar: true, hideToolbarTop: GetPlatform.isAndroid),
    ),
  );
  await browser.done.future;
}

class _ListingCheckoutBrowser extends InAppBrowser {
  final done = Completer<void>();

  static bool _isExternal(Uri uri) =>
      uri.host == 'pay.wave.com' || uri.host == 'play.google.com' || uri.host == 'apps.apple.com' || !['http', 'https', 'about', 'data', 'javascript'].contains(uri.scheme);

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(NavigationAction navigationAction) async {
    final uri = navigationAction.request.url;
    if (uri != null && _isExternal(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  Future onLoadStart(WebUri? url) async => _check(url);

  void _check(WebUri? url) {
    if (url == null || done.isCompleted) return;
    if (kDebugMode) debugPrint('listing payment: $url');
    if (url.toString().startsWith(AppConstants.baseUrl + AppConstants.listingPaymentCallbackPath)) {
      close();
      done.complete();
    }
  }

  @override
  void onExit() {
    if (!done.isCompleted) done.complete();
  }
}
