import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

/// Wave / Orange Money straight from the app (PayDunya SOFTPAY), as in the
/// web app's PayChooser.
///
/// Before a PayDunya payment the customer picks Wave or Orange Money: the
/// backend (POST /api/v1/payment/softpay) turns the payment link the app
/// already has into a Wave link or an Orange Money / Max it link, which opens
/// the wallet's own app. A "Paiement en cours" screen then checks the payment
/// every few seconds (and when the app comes back to the screen) and closes
/// itself on the result. "Autre moyen" keeps PayDunya's page (cards, Free
/// Money...).
///
/// Result of [payWithMobileMoney]: 'paid', 'failed', 'hosted' (open
/// PayDunya's page as before) or null (the customer gave up).
Future<String?> payWithMobileMoney({required String link, required Future<String> Function() check}) async {
  final choice = await Get.bottomSheet<_Choice>(_ChooserSheet(initialPhone: await _knownPhone()), isScrollControlled: true, backgroundColor: Colors.transparent);
  if (choice == null) return null;
  if (choice.method == 'other') return 'hosted';

  final started = await _start(link, choice.method, choice.phone);
  if (!started) return null;

  return Get.to<String>(() => _WaitingScreen(check: check), fullscreenDialog: true);
}

const _phoneKey = 'noor_pay_phone';

Future<String> _knownPhone() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_phoneKey);
    if (saved != null && saved.isNotEmpty) return saved;
  } catch (_) {}
  try {
    final phone = Get.find<ProfileController>().userInfoModel?.phone;
    if (phone != null) return _local(phone);
  } catch (_) {}
  return '';
}

String _local(String p) {
  var d = p.replaceAll(RegExp(r'\D'), '');
  if (d.startsWith('00221')) {
    d = d.substring(5);
  } else if (d.startsWith('221') && d.length == 12) {
    d = d.substring(3);
  }
  return d;
}

bool _valid(String p) => RegExp(r'^7\d{8}$').hasMatch(_local(p));

Future<bool> _start(String link, String method, String phone) async {
  final r = await Get.find<ApiClient>().postData(AppConstants.softpayUri, {'link': link, 'method': method, 'phone': _local(phone)}, handleError: false);
  final body = r.body;
  if (r.statusCode != 200 || body is! Map || body['url'] == null) {
    String message = 'pay_mm_unavailable'.tr;
    if (body is Map && body['errors'] is List && (body['errors'] as List).isNotEmpty) {
      message = '${(body['errors'] as List).first['message'] ?? message}';
    }
    showCustomSnackBar(message);
    return false;
  }
  try {
    (await SharedPreferences.getInstance()).setString(_phoneKey, _local(phone));
  } catch (_) {}

  final String url = body['url'];
  final String? appUrl = body['app_url'] ?? body['maxit_url'];
  // Orange Money: the OM (or Max it) app first, the page with the QR code otherwise.
  if (method == 'orange_money' && appUrl != null) {
    if (await _launch(appUrl)) return true;
  }
  if (await _launch(url)) return true;
  showCustomSnackBar('pay_mm_unavailable'.tr);
  return false;
}

Future<bool> _launch(String url) async {
  try {
    return await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

class _Choice {
  final String method;
  final String phone;
  const _Choice(this.method, this.phone);
}

class _ChooserSheet extends StatefulWidget {
  final String initialPhone;
  const _ChooserSheet({required this.initialPhone});

  @override
  State<_ChooserSheet> createState() => _ChooserSheetState();
}

class _ChooserSheetState extends State<_ChooserSheet> {
  String _method = 'wave';
  late final TextEditingController _phone = TextEditingController(text: widget.initialPhone);

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Widget _option(String method, String emoji, String label, Color color, Color bg) {
    final on = _method == method;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _method = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: on ? bg : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: on ? color : const Color(0xFFE3EBE7), width: 2),
          ),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final ok = _valid(_phone.text);
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 22, 20, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('pay_mm_title'.tr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(children: [
            _option('wave', '🐧', 'Wave', const Color(0xFF1DC3F5), const Color(0xFFEAFAFF)),
            const SizedBox(width: 10),
            _option('orange_money', '🟠', 'Orange Money', const Color(0xFFFF7900), const Color(0xFFFFF4EA)),
          ]),
          const SizedBox(height: 14),
          Text(_method == 'wave' ? 'pay_mm_wave_number'.tr : 'pay_mm_om_number'.tr, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6B7A73))),
          const SizedBox(height: 6),
          Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: '77 123 45 67',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: ok ? () => Get.back(result: _Choice(_method, _phone.text)) : null,
              child: Text(_method == 'wave' ? 'pay_mm_pay_wave'.tr : 'pay_mm_pay_om'.tr, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 8),
          Text('pay_mm_hint'.tr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7A73))),
          TextButton(
            onPressed: () => Get.back(result: const _Choice('other', '')),
            child: Text('pay_mm_other'.tr, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6B7A73))),
          ),
        ]),
      ),
    );
  }
}

class _WaitingScreen extends StatefulWidget {
  final Future<String> Function() check;
  const _WaitingScreen({required this.check});

  @override
  State<_WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<_WaitingScreen> with WidgetsBindingObserver {
  Timer? _timer;
  bool _checking = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    if (_checking || _done) return;
    if (mounted) setState(() => _checking = true);
    String status = 'pending';
    try {
      status = await widget.check();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _checking = false);
    if (status == 'paid' || status == 'failed') {
      _done = true;
      Get.back(result: status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Center(child: SizedBox(width: 46, height: 46, child: CircularProgressIndicator(strokeWidth: 4, color: primary))),
              const SizedBox(height: 20),
              Text('pay_mm_waiting_title'.tr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text('pay_mm_waiting_text'.tr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14.5, height: 1.45, color: Color(0xFF3D4A44))),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: _checking ? null : _check,
                  child: Text(_checking ? 'pay_mm_checking'.tr : 'pay_mm_check_now'.tr, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () { _done = true; Get.back(result: 'hosted'); },
                child: Text('pay_mm_other'.tr, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6B7A73))),
              ),
              TextButton(
                onPressed: () { _done = true; Get.back(); },
                child: Text('pay_mm_cancel'.tr, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6B7A73))),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
