import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/auth/domain/reposotories/auth_repository_interface.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';

/// Sign-in with the phone number and a 4-digit PIN (same Noor account and
/// PIN as Noor Pro and the web app). The SMS code proves the number at
/// sign-up and when the PIN is forgotten; the customer then chooses a PIN.
class PinLoginResult {
  final bool ok;
  final String? code; // no_pin | wrong_pin | locked | blocked | invalid
  final String? message;
  PinLoginResult(this.ok, {this.code, this.message});
}

class PinAuth {
  static const String _resetKey = 'noor_pin_reset_pending';

  static Future<PinLoginResult> login(String phone, String pin) async {
    final api = Get.find<ApiClient>();
    final repo = Get.find<AuthRepositoryInterface>();
    final guestId = repo.getSharedPrefGuestId();
    final Response r = await api.postData(
      '/api/v1/auth/pin-login',
      {'phone': phone, 'pin': pin, if (guestId.isNotEmpty) 'guest_id': guestId},
      handleError: false,
    );
    if (r.statusCode == 200 && r.body is Map && r.body['token'] != null) {
      await repo.saveUserToken(r.body['token'].toString());
      await repo.updateToken();
      await repo.clearSharedPrefGuestId();
      Get.find<ProfileController>().getUserInfo();
      Get.find<CartController>().getCartDataOnline();
      return PinLoginResult(true);
    }
    String? code;
    String? message = r.statusText;
    if (r.body is Map && r.body['errors'] is List && (r.body['errors'] as List).isNotEmpty) {
      code = r.body['errors'][0]['code']?.toString();
      message = r.body['errors'][0]['message']?.toString();
    }
    if (r.statusCode == 1 || r.statusCode == null) message = 'connection_to_api_server_failed'.tr;
    return PinLoginResult(false, code: code, message: message);
  }

  static Future<bool?> hasPin() async {
    final Response r = await Get.find<ApiClient>().getData('/api/v1/customer/pin', handleError: false);
    return r.statusCode == 200 && r.body is Map ? r.body['has_pin'] == true : null;
  }

  static Future<String?> setPin(String pin, {String? currentPin}) async {
    final Response r = await Get.find<ApiClient>().postData(
      '/api/v1/customer/pin',
      {'pin': pin, if (currentPin != null) 'current_pin': currentPin},
      handleError: false,
    );
    if (r.statusCode == 200) return null;
    if (r.body is Map && r.body['errors'] is List && (r.body['errors'] as List).isNotEmpty) {
      return r.body['errors'][0]['message']?.toString();
    }
    return r.statusText ?? 'Une erreur est survenue.';
  }

  /// "Code PIN oublié ?": after the SMS sign-in, ask for a new PIN.
  static Future<void> markReset() async => (await SharedPreferences.getInstance()).setBool(_resetKey, true);

  /// After a sign-in (home screen): a customer without a PIN, or who forgot
  /// it, is offered to choose one (at most once a day when dismissed).
  static Future<void> promptIfNeeded() async {
    if (!AuthHelper.isLoggedIn()) return;
    final prefs = await SharedPreferences.getInstance();
    final reset = prefs.getBool(_resetKey) ?? false;
    if (!reset) {
      final has = await hasPin();
      if (has != false) return;
    }
    // After the first SMS sign-in (or "Code PIN oublié ?") the PIN is required.
    final saved = await showPinSheet(change: false, reset: reset, required: true);
    if (saved) await prefs.remove(_resetKey);
  }
}

/// Choose, reset or change the 4-digit PIN.
Future<bool> showPinSheet({bool change = false, bool reset = false, bool required = false}) async {
  final ok = await Get.bottomSheet<bool>(
    PopScope(canPop: !required, child: _PinSheet(change: change, reset: reset, required: required)),
    isScrollControlled: true,
    isDismissible: !required,
    enableDrag: !required,
  );
  return ok == true;
}

class _PinSheet extends StatefulWidget {
  final bool change;
  final bool reset;
  final bool required;
  const _PinSheet({required this.change, required this.reset, this.required = false});

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  final _current = TextEditingController();
  final _pin = TextEditingController();
  final _pin2 = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _pin.dispose();
    _pin2.dispose();
    super.dispose();
  }

  bool get _ready => (!widget.change || _current.text.length == 4) && _pin.text.length == 4 && _pin2.text.length == 4;

  Future<void> _save() async {
    if (_pin.text != _pin2.text) {
      setState(() => _error = 'Les deux codes ne sont pas identiques.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await PinAuth.setPin(_pin.text, currentPin: widget.change ? _current.text : null);
    if (!mounted) return;
    if (err == null) {
      Get.back(result: true);
      Get.snackbar('Noor', 'Code PIN enregistré.', snackPosition: SnackPosition.BOTTOM);
    } else {
      setState(() {
        _busy = false;
        _error = err;
      });
    }
  }

  Widget _field(String label, TextEditingController c, {bool autofocus = false}) {
    final primary = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          autofocus: autofocus,
          obscureText: true,
          obscuringCharacter: '●',
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 14),
          decoration: InputDecoration(
            hintText: '••••',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primary, width: 1.5)),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.change ? 'Changer mon code PIN' : (widget.reset ? 'Nouveau code PIN' : 'Choisis ton code PIN');
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Tu te connecteras avec ton numéro et ce code à 4 chiffres, sans attendre de SMS.',
              style: TextStyle(color: Theme.of(context).hintColor)),
          const SizedBox(height: 16),
          if (widget.change) _field('Code PIN actuel', _current, autofocus: true),
          _field(widget.change ? 'Nouveau code PIN' : 'Code PIN', _pin, autofocus: !widget.change),
          _field('Confirme le code', _pin2),
          if (_error != null)
            Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600))),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _ready && !_busy ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: _busy
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                  : const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
          if (!widget.change && !widget.required)
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Plus tard')),
        ]),
      ),
    );
  }
}
