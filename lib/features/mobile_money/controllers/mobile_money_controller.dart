import 'dart:math';

import 'package:get/get.dart';
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
