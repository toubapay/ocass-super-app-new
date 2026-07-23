import 'dart:developer';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart/features/airtime/domain/models/airtime_model.dart';
import 'package:sixam_mart/features/airtime/domain/repositories/airtime_repository.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class AirtimeController extends GetxController {
  final AirtimeRepository _repository = AirtimeRepository();

  // — State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Contacts
  List<Contact> _contacts = [];
  List<Contact> get contacts => _contacts;
  bool _contactsLoaded = false;
  bool get contactsLoaded => _contactsLoaded;
  bool _contactsPermissionGranted = false;
  bool get contactsPermissionGranted => _contactsPermissionGranted;

  // Filtering
  String _contactSearchQuery = '';
  String get contactSearchQuery => _contactSearchQuery;
  List<Contact> get filteredContacts {
    if (_contactSearchQuery.isEmpty) return _contacts;
    return _contacts
        .where((c) =>
            c.displayName
                .toLowerCase()
                .contains(_contactSearchQuery.toLowerCase()) ||
            c.phones.any((p) => p.number.contains(_contactSearchQuery)))
        .toList();
  }

  // Selected contact
  Contact? _selectedContact;
  Contact? get selectedContact => _selectedContact;

  // Manual phone entry
  String _manualPhone = '';
  String get manualPhone => _manualPhone;
  bool _useManualPhone = false;
  bool get useManualPhone => _useManualPhone;

  // Selected operator
  AirtimeOperator? _selectedOperator;
  AirtimeOperator? get selectedOperator => _selectedOperator;

  // Selected plan
  AirtimePlan? _selectedPlan;
  AirtimePlan? get selectedPlan => _selectedPlan;

  // Custom amount
  String _customAmount = '';
  String get customAmount => _customAmount;
  bool _useCustomAmount = true;
  bool get useCustomAmount => _useCustomAmount;

  // Result

  AirtimeTransactionResponse? _lastTransaction;
  AirtimeTransactionResponse? get lastTransaction => _lastTransaction;
  bool _transactionSuccess = false;
  bool get transactionSuccess => _transactionSuccess;

  // ──────────────────────────────────────────────
  // CONTACTS PERMISSION & LOAD
  // ──────────────────────────────────────────────

  Future<void> requestContactsAndLoad() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      _contactsPermissionGranted = true;
      update();
      await _loadContacts();
    } else {
      _contactsPermissionGranted = false;
      update();
    }
  }

  Future<void> _loadContacts() async {
    _isLoading = true;
    update();
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
        withAccounts: false,
      );
      // Only keep contacts that have phone numbers
      _contacts = contacts.where((c) => c.phones.isNotEmpty).toList();
      _contactsLoaded = true;
    } catch (_) {
      _contacts = [];
    }
    _isLoading = false;
    update();
  }

  void setContactSearch(String query) {
    _contactSearchQuery = query;
    update();
  }

  void selectContact(Contact contact) {
    _selectedContact = contact;
    _useManualPhone = false;
    _manualPhone = '';
    update();
  }

  void clearSelectedContact() {
    _selectedContact = null;
    update();
  }

  void setManualPhone(String phone) {
    _manualPhone = phone;
    _contactSearchQuery = phone; // Sync search with manual entry
    if (phone.isNotEmpty) {
      _selectedContact = null;
    }
    update();
  }

  void toggleManualPhone(bool val) {
    _useManualPhone = val;
    // We don't necessarily want to clear everything here if we are transitioning
    update();
  }

  // ──────────────────────────────────────────────
  // OPERATOR + PLAN
  // ──────────────────────────────────────────────

  void selectOperator(AirtimeOperator op) {
    _selectedOperator = op;
    update();
  }

  void selectPlan(AirtimePlan plan) {
    _selectedPlan = plan;
    _useCustomAmount = false;
    _customAmount = '';
    update();
  }

  void setCustomAmount(String amount) {
    _customAmount = amount;
    log('setting...');
    _selectedPlan = null;
    update();
  }

  void toggleCustomAmount(bool val) {
    _useCustomAmount = val;
    if (val) _selectedPlan = null;
    update();
  }

  // ──────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────

  String get effectivePhone {
    if (_selectedContact != null && _selectedContact!.phones.isNotEmpty) {
      // Strip non-numeric characters but keep + if present? No, LAM usually wants digits.
      return _selectedContact!.phones.first.number
          .replaceAll(RegExp(r'\D'), '');
    }
    return _manualPhone.replaceAll(RegExp(r'\D'), '');
  }

  String get effectiveAmount {
    if (_useCustomAmount) return _customAmount;
    return _selectedPlan?.amount ?? '';
  }

  bool get canSend {
    return effectivePhone.isNotEmpty &&
        effectiveAmount.isNotEmpty &&
        _selectedOperator != null;
  }

  // ──────────────────────────────────────────────
  // SEND AIRTIME
  // ──────────────────────────────────────────────

  Future<void> sendAirtime() async {
    if (!canSend) return;

    double amountDouble = double.tryParse(effectiveAmount) ?? 0.0;
    double walletBalance =
        Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0.0;

    if (amountDouble > walletBalance) {
      showCustomSnackBar('Insufficient wallet balance to perform this topup.');
      return;
    }

    _isLoading = true;
    _transactionSuccess = false;
    _lastTransaction = null;
    update();

    try {
      final result = await _repository.sendAirtime(
        montant: effectiveAmount,
        telephone: effectivePhone,
        operateur: _selectedOperator!.code,
      );

      if (result != null) {
        _lastTransaction = result;
        final status = result.status?.toLowerCase() ?? '';

        // Considering "pending" as success because Airtime requests are asynchronous
        _transactionSuccess = status == 'success' ||
            status == 'completed' ||
            status == 'sent' ||
            status == 'pending';

        if (_transactionSuccess) {
          // Temporarily deduct balance visually. For real production,
          // ensure your backend natively deducts this from the DB.
          if (Get.find<ProfileController>().userInfoModel != null) {
            Get.find<ProfileController>().userInfoModel!.walletBalance =
                (Get.find<ProfileController>().userInfoModel!.walletBalance ??
                        0.0) -
                    amountDouble;
            Get.find<ProfileController>().update();
          }
        } else {
          if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
            showCustomSnackBar(result.errorMessage);
          } else {
            showCustomSnackBar(
                'Transaction failed: ${result.status ?? "Unknown Error"}');
          }
        }
      } else {
        showCustomSnackBar('No response from server. Please try again.');
      }
    } catch (e) {
      showCustomSnackBar('Error: $e');
    }

    _isLoading = false;
    update();
  }

  void resetState() {
    _lastTransaction = null;
    _transactionSuccess = false;
    _selectedPlan = null;
    _customAmount = '';
    _useCustomAmount = false;
    update();
  }
}
