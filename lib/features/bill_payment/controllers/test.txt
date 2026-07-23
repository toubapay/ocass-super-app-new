import 'package:get/get.dart';
import 'package:sixam_mart/features/bill_payment/domain/models/bill_payment_model.dart';
import 'package:sixam_mart/features/bill_payment/domain/repositories/bill_payment_repository.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class BillPaymentController extends GetxController {
  final BillPaymentRepository _repository = BillPaymentRepository();

  // — State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCheckingInvoice = false;
  bool get isCheckingInvoice => _isCheckingInvoice;  // Countries List
  List<BillCountry> _countries = [];
  List<BillCountry> get countries => _countries;

  // Selected Country
  BillCountry? _selectedCountry;
  BillCountry? get selectedCountry => _selectedCountry;

  // Selected Provider
  BillProvider? _selectedProvider;
  BillProvider? get selectedProvider => _selectedProvider;

  // Account / Meter Number
  String _accountNumber = '';
  String get accountNumber => _accountNumber;

  // Custom Amount
  String _customAmount = '';
  String get customAmount => _customAmount;

  // Invoice Number (optional, retrieved from checking invoice)
  String? _invoiceNumber;

  // Result
  BillTransactionResponse? _lastTransaction;
  BillTransactionResponse? get lastTransaction => _lastTransaction;
  bool _transactionSuccess = false;
  bool get transactionSuccess => _transactionSuccess;

  @override
  void onInit() {
    super.onInit();
    getProviders();
  }

  // ──────────────────────────────────────────────
  // FETCH PROVIDERS
  // ──────────────────────────────────────────────

  Future<void> getProviders() async {
    _isLoading = true;
    update();

    try {
      final dynamic rawData = await _repository.getProviders();
      List<BillCountry> tempCountries = [];

      if (rawData is Map && rawData.containsKey('billing_countries')) {
          var countriesList = rawData['billing_countries'] as List;
          for (var c in countriesList) {
             tempCountries.add(BillCountry.fromJson(Map<String, dynamic>.from(c)));
          }
      } else if (rawData is List) {
        // Fallback or legacy structure
        for (var item in rawData) {
          if (item is Map && (item.containsKey('billers') || item.containsKey('services'))) {
             tempCountries.add(BillCountry.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      _countries = tempCountries;
      if (_countries.isNotEmpty) {
        _selectedCountry = _countries.first;
        _providers = _selectedCountry!.billers;
        if (_providers.isNotEmpty) {
           _selectedProvider = _providers.first;
        }
      } else {
         // Fallback to static defaults if needed
         _providers = List.from(kDefaultBillProviders);
         _selectedProvider = _providers.first;
      }
    } catch (e) {
      if (_providers.isEmpty) {
        _providers = List.from(kDefaultBillProviders);
        _selectedProvider = _providers.first;
      }
    }

    _isLoading = false;
    update();
  }

  // ──────────────────────────────────────────────
  // INPUT HANDLING
  // ──────────────────────────────────────────────

  void selectCountry(BillCountry country) {
    _selectedCountry = country;
    _providers = country.billers;
    if (_providers.isNotEmpty) {
      _selectedProvider = _providers.first;
    } else {
      _selectedProvider = null;
    }
    _invoiceNumber = null;
    update();
  }
��──────────
  // INPUT HANDLING
  // ──────────────────────────────────────────────

  void selectProvider(BillProvider provider) {
    _selectedProvider = provider;
    _invoiceNumber = null; // reset invoice number when provider changes
    update();
  }

  void setAccountNumber(String acc) {
    _accountNumber = acc;
    update();
  }

  void setCustomAmount(String amount) {
    _customAmount = amount;
    update();
  }

  bool get canCheckInvoice {
    return _accountNumber.isNotEmpty && _selectedProvider != null;
  }

  bool get canSend {
    return _accountNumber.isNotEmpty && _customAmount.isNotEmpty && _selectedProvider != null;
  }

  // ──────────────────────────────────────────────
  // CHECK INVOICE
  // ──────────────────────────────────────────────

  Future<void> checkInvoice() async {
    if (!canCheckInvoice) return;

    _isCheckingInvoice = true;
    _invoiceNumber = null;
    update();

    try {
      final result = await _repository.checkInvoice(
        accountNumber: _accountNumber.trim(),
        billerCode: _selectedProvider!.code,
      );

      if (result != null) {
        // Our backend now returns success if invoice_number or amount is present
        if (result.status != 'ERROR') {
          if (result.total != null && result.total!.isNotEmpty) {
            _customAmount = result.total!;
          } else if (result.amount != null && result.amount!.isNotEmpty) {
            _customAmount = result.amount!;
          }
          
          _lastTransaction = result; // Store to access fees/total
          _invoiceNumber = result.transactionId ?? result.accountNumber; 
          showCustomSnackBar('Invoice details fetched successfully', isError: false);
        } else {
          showCustomSnackBar(result.errorMessage ?? 'Failed to check invoice');
        }
      } else {
        showCustomSnackBar('No response from server. Please try again.');
      }
    } catch (e) {
      showCustomSnackBar('Error: $e');
    }

    _isCheckingInvoice = false;
    update();
  }

  // ──────────────────────────────────────────────
  // PROCESS PAYMENT
  // ──────────────────────────────────────────────

  Future<void> processPayment() async {
    if (!canSend) return;

    double amountDouble = double.tryParse(_customAmount) ?? 0.0;
    double walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0.0;

    if (amountDouble > walletBalance) {
      showCustomSnackBar('Insufficient wallet balance to pay this bill.');
      return;
    }

    _isLoading = true;
    _transactionSuccess = false;
    _lastTransaction = null;
    update();

    try {
      final result = await _repository.processPayment(
        amount: _customAmount,
        accountNumber: _accountNumber.trim(),
        billerCode: _selectedProvider!.code,
        invoiceNumber: _invoiceNumber,
      );

      if (result != null) {
        _lastTransaction = result;
        final status = result.status?.toLowerCase() ?? '';
        
        _transactionSuccess =
            status == 'success' || status == 'completed' || status == 'pending';
            
        if (_transactionSuccess) {
           if (Get.find<ProfileController>().userInfoModel != null) {
              Get.find<ProfileController>().userInfoModel!.walletBalance = 
                  (Get.find<ProfileController>().userInfoModel!.walletBalance ?? 0.0) - amountDouble;
              Get.find<ProfileController>().update();
           }
        } else {
          if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
            showCustomSnackBar(result.errorMessage);
          } else {
            showCustomSnackBar('Transaction failed: ${result.status ?? "Unknown Error"}');
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

  Future<void> checkPaymentStatus(String transactionId) async {
    _isLoading = true;
    update();

    try {
      final result = await _repository.checkPaymentStatus(transactionId: transactionId);
      if (result != null && result.status != 'ERROR') {
        _lastTransaction = result;
        showCustomSnackBar('Payment status updated', isError: false);
      } else {
        showCustomSnackBar(result?.errorMessage ?? 'Failed to check payment status');
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
    _customAmount = '';
    _accountNumber = '';
    _invoiceNumber = null;
    update();
  }
}
