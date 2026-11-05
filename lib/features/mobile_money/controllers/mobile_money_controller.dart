import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/mobile_money/domain/models/mobile_money_models.dart';
import 'package:sixam_mart/features/mobile_money/domain/repositories/mobile_money_repository.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';

class MobileMoneyController extends GetxController {
  final MobileMoneyRepository _repository = MobileMoneyRepository();

  MobileMoneyConfig? _config;
  MobileMoneyConfig? get config => _config;

  List<MoneyTransfer>? _transfers;
  List<MoneyTransfer>? get transfers => _transfers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    await _loadRecent();
    final response = await _repository.getConfig();
    if (response.statusCode == 200 && response.body is Map) {
      _config = MobileMoneyConfig.fromJson(Map<String, dynamic>.from(response.body));
    } else {
      showCustomSnackBar(response.statusText ?? 'mm_unavailable'.tr);
    }
    update();
    loadTransfers();
  }

  Future<void> loadTransfers() async {
    final response = await _repository.getTransfers();
    if (response.statusCode == 200 && response.body is Map && response.body['data'] is List) {
      _transfers = (response.body['data'] as List).map((t) => MoneyTransfer.fromJson(Map<String, dynamic>.from(t))).toList();
    } else {
      _transfers ??= [];
    }
    update();
  }

  /// The account behind a number, or null with the server's message shown when [quiet] is false.
  Future<MoneyContact?> lookup(String phone, {bool quiet = false}) async {
    final response = await _repository.lookup(phone);
    if (response.statusCode == 200 && response.body is Map) {
      return MoneyContact.fromJson(Map<String, dynamic>.from(response.body));
    }
    _lookupError = response.statusText;
    if (!quiet) showCustomSnackBar(response.statusText ?? 'mm_unavailable'.tr);
    return null;
  }

  String? _lookupError;
  String? get lookupError => _lookupError;

  // ── Favourites: people this customer sent to, newest first (this phone + history).
  static const _recentKey = 'noor_money_recent';
  List<MoneyContact> _recent = [];

  Future<void> _loadRecent() async {
    try {
      final raw = Get.find<SharedPreferences>().getString(_recentKey);
      if (raw != null) {
        _recent = (jsonDecode(raw) as List).map((e) => MoneyContact.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (_) {}
  }

  Future<void> rememberRecipient(MoneyContact c) async {
    _recent = [c, ..._recent.where((r) => localDigits(r.phone) != localDigits(c.phone))].take(12).toList();
    try {
      await Get.find<SharedPreferences>().setString(
        _recentKey,
        jsonEncode(_recent.map((r) => {'id': r.id, 'name': r.name, 'phone': r.phone, 'image_full_url': r.imageFullUrl}).toList()),
      );
    } catch (_) {}
  }

  List<MoneyContact> get favourites {
    final seen = <String>{};
    final out = <MoneyContact>[];
    for (final c in [..._recent, ...?_transfers?.where((t) => t.sent && t.counterpart != null).map((t) => t.counterpart!)]) {
      final d = localDigits(c.phone);
      if (d.isEmpty || !seen.add(d)) continue;
      out.add(c);
    }
    return out;
  }

  /// Same rule as MobileMoneySettings::quote on the server.
  MoneyQuote quote(double amount) {
    final cfg = _config!;
    var fee = amount * cfg.feePercent / 100 + cfg.feeFixed;
    if (fee < cfg.minFee) fee = cfg.minFee;
    if (cfg.maxFee > 0 && fee > cfg.maxFee) fee = cfg.maxFee;
    fee = ((fee * 1000).round() / 1000).ceilToDouble();
    return cfg.feeBearer == 'receiver'
        ? MoneyQuote(amount: amount, fee: fee, sent: amount, received: amount - fee)
        : MoneyQuote(amount: amount, fee: fee, sent: amount + fee, received: amount);
  }

  /// Transfer amount for what the sender wants to spend…
  double amountFromSent(double sent) {
    if (_config!.feeBearer == 'receiver') return sent;
    var a = (sent / (1 + _config!.feePercent / 100)).floorToDouble();
    while (a > 0 && quote(a).sent > sent) {
      a--;
    }
    while (quote(a + 1).sent <= sent) {
      a++;
    }
    return a < 0 ? 0 : a;
  }

  /// …or for what the recipient must get.
  double amountFromReceived(double received) {
    if (_config!.feeBearer != 'receiver') return received;
    var a = received;
    while (quote(a).received < received) {
      a++;
    }
    return a;
  }

  /// Checks the recipient, amount and fee before asking for the PIN.
  Future<MoneyPreview?> preview(String phone, double amount) async {
    _setLoading(true);
    final response = await _repository.preview(phone, amount);
    _setLoading(false);
    if (response.statusCode == 200 && response.body is Map) {
      return MoneyPreview.fromJson(Map<String, dynamic>.from(response.body));
    }
    showCustomSnackBar(response.statusText ?? 'mm_unavailable'.tr);
    return null;
  }

  /// One id per confirmation screen, so a retried request can't send twice.
  String newRequestId() {
    final random = Random.secure();
    return '${DateTime.now().microsecondsSinceEpoch}-${List.generate(8, (_) => random.nextInt(16).toRadixString(16)).join()}';
  }

  Future<MoneyTransfer?> send({required String phone, required double amount, required String pin, String? note, required String requestId}) async {
    _setLoading(true);
    final response = await _repository.send(phone: phone, amount: amount, pin: pin, note: note, requestId: requestId);
    _setLoading(false);
    if (response.statusCode == 200 && response.body is Map && response.body['transfer'] is Map) {
      Get.find<ProfileController>().getUserInfo();
      loadTransfers();
      return MoneyTransfer.fromJson(Map<String, dynamic>.from(response.body['transfer']));
    }
    showCustomSnackBar(response.statusText ?? 'mm_unavailable'.tr);
    return null;
  }

  Future<bool> setPin(String pin, {String? currentPin}) async {
    _setLoading(true);
    final response = await _repository.setPin(pin, currentPin: currentPin);
    _setLoading(false);
    if (response.statusCode == 200) {
      _config = _config?.withPin();
      update();
      showCustomSnackBar('mm_pin_saved'.tr, isError: false);
      return true;
    }
    showCustomSnackBar(response.statusText ?? 'mm_unavailable'.tr);
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    update();
  }
}
