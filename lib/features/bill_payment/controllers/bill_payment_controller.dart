import 'package:get/get.dart';
import 'package:sixam_mart/features/bill_payment/domain/models/bill_payment_model.dart';
import 'package:sixam_mart/features/bill_payment/domain/models/bill_payment_history_model.dart';
import 'package:sixam_mart/features/bill_payment/domain/repositories/bill_payment_repository.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

enum BillPaymentStep {
  selection,
  verification,
  payment,
  result
}

class BillPaymentController extends GetxController {
  // ── Fee config from admin (via /api/v1/config) ──
  double get _commissionValue =>
      Get.find<SplashController>().configModel?.billPaymentPlatformCommissionValue ?? 0.3;
  String get _commissionType =>
      Get.find<SplashController>().configModel?.billPaymentPlatformCommissionType ?? 'percent';
  double get _providerFeeValue =>
      Get.find<SplashController>().configModel?.billPaymentProviderFeeValue ?? 7.0;
  String get _providerFeeType =>
      Get.find<SplashController>().configModel?.billPaymentProviderFeeType ?? 'fixed';

  // Computed fee for a given bill amount
  double calcCommission(double billAmount) => _commissionType == 'percent'
      ? (_commissionValue * billAmount / 100).roundToDouble()
      : _commissionValue;

  double calcProviderFee(double billAmount) => _providerFeeType == 'percent'
      ? (_providerFeeValue * billAmount / 100).roundToDouble()
      : _providerFeeValue;

  // Label helpers used by the UI
  String get commissionLabel => _commissionType == 'percent'
      ? '${_commissionValue.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}%'
      : '${_commissionValue.toStringAsFixed(0)} XOF';
  String get providerFeeLabel => _providerFeeType == 'percent'
      ? '${_providerFeeValue.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}%'
      : '${_providerFeeValue.toStringAsFixed(0)} XOF';

  final BillPaymentRepository _repository = BillPaymentRepository();

  // — State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCheckingInvoice = false;
  bool get isCheckingInvoice => _isCheckingInvoice;

  BillPaymentStep _currentStep = BillPaymentStep.selection;
  BillPaymentStep get currentStep => _currentStep;

  int _selectedTabIndex = 0; // 0: Pay, 1: Check
  int get selectedTabIndex => _selectedTabIndex;

  // Countries & Providers List
  List<BillCountry> _countries = [];
  List<BillCountry> get countries => _countries;

  List<BillProvider> _providers = [];
  List<BillProvider> get providers => _providers;

  // Selections
  BillCountry? _selectedCountry;
  BillCountry? get selectedCountry => _selectedCountry;

  BillProvider? _selectedProvider;
  BillProvider? get selectedProvider => _selectedProvider;

  // Account / Meter Number
  String _accountNumber = '';
  String get accountNumber => _accountNumber;

  // Custom Amount
  String _customAmount = '';
  String get customAmount => _customAmount;

  // Invoice Details from verification
  BillTransactionResponse? _verifiedInvoice;
  BillTransactionResponse? get verifiedInvoice => _verifiedInvoice;

  // Final Result
  BillTransactionResponse? _lastTransaction;
  BillTransactionResponse? get lastTransaction => _lastTransaction;

  bool _transactionSuccess = false;
  bool get transactionSuccess => _transactionSuccess;

  // History
  List<BillPaymentRecord>? _historyList;
  List<BillPaymentRecord>? get historyList => _historyList;

  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;

  int _historyOffset = 1;
  int? _historyTotalSize;
  bool get hasMoreHistory =>
      _historyList == null || _historyList!.length < (_historyTotalSize ?? 0);

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
      
      // Handle the data wrapper from the backend or direct LAM response
      dynamic data = rawData;
      if (rawData is Map && rawData.containsKey('data')) {
        data = rawData['data'];
      }

      if (data is Map && data.containsKey('billing_countries')) {
        var countriesList = data['billing_countries'] as List;
        for (var c in countriesList) {
          tempCountries.add(BillCountry.fromJson(Map<String, dynamic>.from(c)));
        }
      } else if (data is List) {
        for (var item in data) {
          if (item is Map) {
            tempCountries.add(BillCountry.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      _countries = tempCountries;
      if (_countries.isNotEmpty) {
        // Find Senegal (SN) specifically as requested by the user
        _selectedCountry = _countries.firstWhere(
          (c) => c.code.toUpperCase() == 'SN',
          orElse: () => _countries.first,
        );
        _providers = _selectedCountry!.billers;
        _selectedProvider = null; // Let user select from grid
      } else {
        // Use static defaults if API fails or returns no countries
        _providers = List.from(kDefaultBillProviders);
        _selectedCountry = BillCountry(code: 'SN', name: 'Sénégal', billers: _providers);
      }
    } catch (e) {
      if (_providers.isEmpty) {
        _providers = List.from(kDefaultBillProviders);
        _selectedCountry = BillCountry(code: 'SN', name: 'Sénégal', billers: _providers);
      }
    }

    _isLoading = false;
    update();
  }

  // ──────────────────────────────────────────────
  // NAVIGATION & SELECTION
  // ──────────────────────────────────────────────

  void setStep(BillPaymentStep step) {
    _currentStep = step;
    update();
  }

  void selectCountry(BillCountry country) {
    _selectedCountry = country;
    _providers = country.billers;
    _verifiedInvoice = null;
    update();
  }

  void selectProvider(BillProvider provider) {
    _selectedProvider = provider;
    _verifiedInvoice = null;
    _currentStep = BillPaymentStep.verification; // Auto-advance
    update();
  }

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    // Clear invoice data when switching tabs to avoid stale data
    _verifiedInvoice = null;
    update();
  }

  void setAccountNumber(String acc) {
    _accountNumber = acc;
    update();
  }

  void setAmount(String amount) {
    _customAmount = amount;
    update();
  }

  bool get canCheckInvoice {
    return _accountNumber.isNotEmpty && _selectedProvider != null && !_isCheckingInvoice;
  }

  bool get canSend {
    return _accountNumber.isNotEmpty && _customAmount.isNotEmpty && _selectedProvider != null && !_isLoading;
  }

  // ──────────────────────────────────────────────
  // CHECK INVOICE
  // ──────────────────────────────────────────────

  Future<void> checkInvoice() async {
    if (!canCheckInvoice) return;

    _isCheckingInvoice = true;
    _verifiedInvoice = null;
    update();

    try {
      final result = await _repository.checkInvoice(
        accountNumber: _accountNumber.trim(),
        billerCode: _selectedProvider!.code,
        countryCode: _selectedCountry?.code ?? _selectedProvider!.countryCode,
      );

      if (result != null) {
        if (result.status != 'failed' && result.status != 'ERROR') {
          _verifiedInvoice = result;
          if (result.total != null && result.total!.isNotEmpty && result.total != "0") {
            _customAmount = result.total!;
          } else if (result.amount != null && result.amount!.isNotEmpty && result.amount != "0") {
            _customAmount = result.amount!;
          }
          // Stay on current step (verification) but with invoice data
          showCustomSnackBar('Invoice verified successfully', isError: false);
        } else {
          showCustomSnackBar(result.errorMessage ?? 'Verification failed');
        }
      } else {
        showCustomSnackBar('No response from server. Please try again.');
      }
    } catch (e) {
      showCustomSnackBar('Error verifying account: $e');
    } finally {
      _isCheckingInvoice = false;
      update();
    }
  }

  // ──────────────────────────────────────────────
  // PROCESS PAYMENT
  // ──────────────────────────────────────────────

  Future<void> processPayment() async {
    if (!canSend) return;

    double amountDouble = double.tryParse(_customAmount) ?? 0.0;
    final double myCommission = calcCommission(amountDouble);
    final double myProviderFee = calcProviderFee(amountDouble);
    double walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0.0;

    if ((amountDouble + myCommission + myProviderFee) > walletBalance) {
      showCustomSnackBar('Insufficient wallet balance to pay this bill.');
      return;
    }

    // Min/Max Validation
    if (_verifiedInvoice != null) {
      if (_verifiedInvoice!.minAmount != null) {
        double min = double.tryParse(_verifiedInvoice!.minAmount!) ?? 0;
        if (amountDouble < min && min > 0) {
          showCustomSnackBar('Minimum payment allowed is $min ${_verifiedInvoice!.currency ?? 'XOF'}');
          return;
        }
      }
      if (_verifiedInvoice!.maxAmount != null) {
        double max = double.tryParse(_verifiedInvoice!.maxAmount!) ?? double.infinity;
        if (amountDouble > max) {
          showCustomSnackBar('Maximum payment allowed is $max ${_verifiedInvoice!.currency ?? 'XOF'}');
          return;
        }
      }
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
        countryCode: _selectedCountry?.code ?? _selectedProvider!.countryCode,
        invoiceNumber: _verifiedInvoice?.invoiceNumber,
      );

      if (result != null) {
        _lastTransaction = result;
        final status = result.status?.toLowerCase() ?? '';
        
        _transactionSuccess =
            status == 'success' || status == 'completed' || status == 'pending' || status == 'processed';
            
        if (_transactionSuccess) {
          if (Get.find<ProfileController>().userInfoModel != null) {
            // Deduct the full amount: bill + LAM fees + platform commission
            final double actualDeduction =
                double.tryParse(result.totalDeducted ?? '') ?? amountDouble;
            Get.find<ProfileController>().userInfoModel!.walletBalance =
                (Get.find<ProfileController>().userInfoModel!.walletBalance ?? 0.0) -
                actualDeduction;
            Get.find<ProfileController>().update();
          }
           _currentStep = BillPaymentStep.result;
        } else {
          // If it failed due to bounds (from server)
          if (result.minAmount != null || result.maxAmount != null) {
             _verifiedInvoice = result; // Update bounds info
          }
          _currentStep = BillPaymentStep.result;
        }
      } else {
        showCustomSnackBar('No response from server.');
      }
    } catch (e) {
      showCustomSnackBar('Error processing payment: $e');
    }

    _isLoading = false;
    update();
  }

  // ──────────────────────────────────────────────
  // CHECK STATUS
  // ──────────────────────────────────────────────

  Future<void> checkStatus() async {
    if (_lastTransaction?.transactionId == null) return;

    _isLoading = true;
    update();

    try {
      final result = await _repository.checkPaymentStatus(
        transactionId: _lastTransaction!.transactionId!,
      );

      if (result != null && result.status != 'ERROR') {
        _lastTransaction = result;
        final status = result.status?.toLowerCase() ?? '';
        _transactionSuccess = 
            status == 'success' || status == 'completed' || status == 'pending' || status == 'processed';
        showCustomSnackBar('Status updated successfully', isError: false);
      } else {
        showCustomSnackBar(result?.errorMessage ?? 'Failed to check status');
      }
    } catch (e) {
      showCustomSnackBar('Error checking status: $e');
    }

    _isLoading = false;
    update();
  }

  // ──────────────────────────────────────────────
  // BILL PAYMENT HISTORY
  // ──────────────────────────────────────────────

  Future<void> loadHistory({bool reload = false}) async {
    if (reload) {
      _historyOffset = 1;
      _historyList = null;
      _historyTotalSize = null;
    }

    if (_isHistoryLoading) return;
    _isHistoryLoading = true;
    update();

    try {
      final result = await _repository.getBillPaymentHistory(
        offset: _historyOffset,
        limit: 10,
      );

      if (result != null) {
        _historyTotalSize = result.totalSize;
        if (_historyOffset == 1) {
          _historyList = result.data ?? [];
        } else {
          _historyList ??= [];
          _historyList!.addAll(result.data ?? []);
        }
        _historyOffset++;
      }
    } catch (_) {}

    _isHistoryLoading = false;
    update();
  }

  void resetState() {
    _currentStep = BillPaymentStep.selection;
    _selectedProvider = null;
    _verifiedInvoice = null;
    _lastTransaction = null;
    _transactionSuccess = false;
    _customAmount = '';
    _accountNumber = '';
    update();
  }
}
