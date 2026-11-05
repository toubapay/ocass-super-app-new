import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/mobile_money/controllers/mobile_money_controller.dart';
import 'package:sixam_mart/features/mobile_money/domain/models/mobile_money_models.dart';
import 'package:sixam_mart/features/mobile_money/screens/mobile_money_pin_screen.dart';
import 'package:sixam_mart/features/mobile_money/screens/money_amount_screen.dart';
import 'package:sixam_mart/features/mobile_money/screens/money_scan_screen.dart';
import 'package:sixam_mart/features/mobile_money/widgets/money_widgets.dart';
import 'package:sixam_mart/features/mobile_money/widgets/my_qr_sheet.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Ocass Money, step 1 as in Wave: who receives the money. A search field
/// ("À", name or number), a new number, scan to send, my QR code, then
/// favourites and the phone's contacts.
class MobileMoneyScreen extends StatefulWidget {
  const MobileMoneyScreen({super.key});

  @override
  State<MobileMoneyScreen> createState() => _MobileMoneyScreenState();
}

class _PhoneContact {
  final String name;
  final String digits;
  const _PhoneContact(this.name, this.digits);
}

class _MobileMoneyScreenState extends State<MobileMoneyScreen> {
  final _query = TextEditingController();
  final _focus = FocusNode();
  bool _numberMode = false;
  Timer? _debounce;
  int _lookupId = 0;
  MoneyContact? _found;
  String? _foundError;
  bool _busy = false;
  List<_PhoneContact>? _contacts; // null = not loaded yet
  bool _contactsDenied = false;

  MobileMoneyController get _c => Get.find<MobileMoneyController>();

  @override
  void initState() {
    super.initState();
    if (Get.find<AuthController>().isLoggedIn()) {
      _c.load();
      _loadContacts(ask: false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _loadContacts({required bool ask}) async {
    try {
      // Asked once on opening, as Wave lists the phone's contacts; [ask] retries after a refusal.
      final granted = await FlutterContacts.requestPermission(readonly: true);
      if (!granted) {
        if (mounted) setState(() => _contactsDenied = true);
        return;
      }
      final all = await FlutterContacts.getContacts(withProperties: true, withPhoto: false);
      final seen = <String>{};
      final list = <_PhoneContact>[];
      for (final c in all) {
        for (final p in c.phones) {
          final d = localDigits(p.number);
          if (d.length == 9 && d.startsWith('7') && seen.add(d)) list.add(_PhoneContact(c.displayName, d));
        }
      }
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      if (mounted) setState(() => _contacts = list);
    } catch (_) {
      if (mounted) setState(() => _contactsDenied = true);
    }
  }

  String get _q => _query.text.trim();
  bool get _isNumber => _q.isNotEmpty && RegExp(r'^[\d\s+().-]+$').hasMatch(_q);

  void _onQuery(String _) {
    setState(() {
      _found = null;
      _foundError = null;
    });
    _debounce?.cancel();
    final digits = localDigits(_q);
    if (!_isNumber || digits.length != 9) return;
    final id = ++_lookupId;
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final person = await _c.lookup(digits, quiet: true);
      if (!mounted || id != _lookupId) return;
      setState(() {
        _found = person;
        _foundError = person == null ? (_c.lookupError ?? 'mm_no_account'.tr) : null;
      });
    });
  }

  /// From a number (contact, scan): check the account, then go to the amount.
  Future<void> _pickDigits(String digits) async {
    setState(() => _busy = true);
    final person = await _c.lookup(digits);
    if (mounted) setState(() => _busy = false);
    if (person != null) _pick(person);
  }

  Future<void> _pick(MoneyContact person) async {
    if (!(_c.config?.hasPin ?? false)) {
      final created = await Get.to(() => const MobileMoneyPinScreen());
      if (created != true) return;
    }
    await Get.to(() => MoneyAmountScreen(person: person));
    if (mounted) setState(() {});
  }

  Future<void> _scan() async {
    final digits = await Get.to<String>(() => const MoneyScanScreen());
    if (digits != null) _pickDigits(digits);
  }

  void _newNumber() {
    _query.clear();
    setState(() => _numberMode = true);
    _focus.unfocus();
    Future.delayed(const Duration(milliseconds: 60), () => _focus.requestFocus());
  }

  Widget _action(IconData icon, String label, VoidCallback onTap, {bool filled = false}) {
    final gold = Theme.of(context).primaryColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: filled ? gold : Colors.transparent, shape: BoxShape.circle),
            child: Icon(icon, color: filled ? Colors.white : gold, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: robotoMedium.copyWith(fontSize: 18))),
        ]),
      ),
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 4),
        child: Text(text, style: robotoBold.copyWith(fontSize: 21)),
      );

  @override
  Widget build(BuildContext context) {
    if (!Get.find<AuthController>().isLoggedIn()) {
      return Scaffold(
        appBar: CustomAppBar(title: 'mm_title'.tr),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('mm_login_required'.tr, textAlign: TextAlign.center),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomButton(buttonText: 'sign_in'.tr, onPressed: () => Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.mobileMoney))),
            ]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'mm_title'.tr),
      body: SafeArea(
        child: GetBuilder<MobileMoneyController>(builder: (c) {
          if (c.config == null) return const Center(child: CircularProgressIndicator());
          if (!c.config!.enabled) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('mm_unavailable'.tr, textAlign: TextAlign.center)));
          }
          final q = _q.toLowerCase();
          final digits = localDigits(_q);
          bool match(String name, String d) => q.isEmpty || name.toLowerCase().contains(q) || (digits.isNotEmpty && d.contains(digits));
          final favourites = c.favourites.where((p) => match(p.name, localDigits(p.phone))).toList();
          final favDigits = favourites.map((p) => localDigits(p.phone)).toSet();
          final contacts = (_contacts ?? []).where((p) => !favDigits.contains(p.digits) && match(p.name, p.digits)).toList();

          return Column(children: [
            if (_busy) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
                Text('mm_to'.tr, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
                TextField(
                  controller: _query,
                  focusNode: _focus,
                  autofocus: true,
                  onChanged: _onQuery,
                  keyboardType: _numberMode ? TextInputType.phone : TextInputType.text,
                  style: robotoRegular.copyWith(fontSize: 20),
                  decoration: InputDecoration(
                    hintText: 'mm_name_or_number'.tr,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _q.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _query.clear();
                              _onQuery('');
                            }),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
                  ),
                ),
                if (_found != null)
                  MoneyPersonRow(name: _found!.name, phone: _found!.phone, imageUrl: _found!.imageFullUrl, onTap: () => _pick(_found!))
                else if (_foundError != null)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFFFF7E6), borderRadius: BorderRadius.circular(14)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('+221 ${formatLocal(digits)}', style: robotoBold),
                      Text(_foundError!, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                    ]),
                  ),
                const SizedBox(height: 8),
                _action(Icons.add, 'mm_new_number'.tr, _newNumber, filled: true),
                _action(Icons.qr_code_scanner, 'mm_scan_to_send'.tr, _scan),
                _action(Icons.qr_code_2, 'mm_my_qr_receive'.tr, MyQrSheet.show),
                if (favourites.isNotEmpty) ...[
                  _title('mm_favourites'.tr),
                  ...favourites.map((p) => MoneyPersonRow(name: p.name, phone: p.phone, imageUrl: p.imageFullUrl, onTap: () => _pick(p))),
                ],
                if (contacts.isNotEmpty) ...[
                  _title('mm_contacts'.tr),
                  ...contacts.map((p) => MoneyPersonRow(name: p.name, phone: p.digits, onTap: () => _pickDigits(p.digits))),
                ] else if (_contactsDenied)
                  _action(Icons.contacts_outlined, 'mm_allow_contacts'.tr, () => _loadContacts(ask: true)),
                _title('mm_my_transfers'.tr),
                if (c.transfers == null)
                  const Center(child: CircularProgressIndicator())
                else if (c.transfers!.isEmpty)
                  Padding(padding: const EdgeInsets.all(16), child: Text('mm_no_transfers'.tr, textAlign: TextAlign.center))
                else
                  ...c.transfers!.take(20).map((t) => TransferTile(transfer: t)),
                TextButton.icon(
                  onPressed: () => Get.to(() => const MobileMoneyPinScreen(change: true)),
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: Text('mm_change_pin'.tr),
                ),
              ]),
            ),
          ]);
        }),
      ),
    );
  }
}
