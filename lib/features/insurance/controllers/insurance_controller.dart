import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/insurance/domain/models/insurance_models.dart';
import 'package:sixam_mart/features/insurance/domain/repositories/insurance_repository.dart';

class InsuranceController extends GetxController {
  final InsuranceRepository _repository = InsuranceRepository();

  InsuranceOptions? _options;
  InsuranceOptions? get options => _options;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // The comparison currently shown.
  InsuranceQuoteResult? _quoteResult;
  InsuranceQuoteResult? get quoteResult => _quoteResult;

  // Coverage filter on the comparison screen (null = all levels).
  String? _levelFilter;
  String? get levelFilter => _levelFilter;

  int? _purchasingQuoteId;
  int? get purchasingQuoteId => _purchasingQuoteId;

  List<InsurancePolicy>? _policies;
  List<InsurancePolicy>? get policies => _policies;

  /// Offers already sorted cheapest first by the backend.
  List<InsuranceQuote> get visibleQuotes {
    final quotes = _quoteResult?.quotes ?? [];
    return _levelFilter == null ? quotes : quotes.where((q) => q.coverageLevel == _levelFilter).toList();
  }

  Future<void> loadOptions() async {
    if (_options != null) return;
    final response = await _repository.getOptions();
    if (response.statusCode == 200 && response.body is Map) {
      _options = InsuranceOptions.fromJson(Map<String, dynamic>.from(response.body));
      update();
    } else {
      showCustomSnackBar(response.statusText);
    }
  }

  /// Returns true when the comparison is ready to show.
  Future<bool> requestQuotes(Map<String, dynamic> body) async {
    _isLoading = true;
    _levelFilter = null;
    update();
    final response = await _repository.requestQuotes(body);
    _isLoading = false;
    if (response.statusCode == 200 && response.body is Map) {
      _quoteResult = InsuranceQuoteResult.fromJson(Map<String, dynamic>.from(response.body));
      update();
      return true;
    }
    update();
    showCustomSnackBar(response.statusText ?? 'ins_something_went_wrong'.tr);
    return false;
  }

  void setLevelFilter(String? level) {
    _levelFilter = level;
    update();
  }

  /// Starts the purchase. Returns the PayDunya link, or an error the screen
  /// acts on (missing details are completed in a sheet, then retried).
  Future<({String? redirectLink, int? policyId, InsurancePurchaseError? error})> purchase(InsuranceQuote quote) async {
    _purchasingQuoteId = quote.id;
    update();
    final response = await _repository.purchase(quote.id);
    _purchasingQuoteId = null;
    update();

    if (response.statusCode == 200 && response.body is Map) {
      final body = Map<String, dynamic>.from(response.body);
      final policy = body['policy'] is Map ? Map<String, dynamic>.from(body['policy']) : null;
      return (redirectLink: body['redirect_link']?.toString(), policyId: int.tryParse('${policy?['id']}'), error: null);
    }

    String code = 'error';
    List<String> missing = [];
    if (response.body is Map) {
      final body = Map<String, dynamic>.from(response.body);
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty && errors.first is Map) {
        code = errors.first['code']?.toString() ?? code;
      }
      missing = (body['missing_fields'] as List? ?? []).map((e) => e.toString()).toList();
    }
    return (
      redirectLink: null,
      policyId: null,
      error: InsurancePurchaseError(code: code, message: response.statusText ?? 'ins_something_went_wrong'.tr, missingFields: missing),
    );
  }

  /// Completes plate, chassis, dates or names on the current quote request.
  Future<bool> updateDetails(Map<String, dynamic> body) async {
    final requestId = _quoteResult?.quoteRequestId;
    if (requestId == null) return false;
    _isLoading = true;
    update();
    final response = await _repository.updateDetails(requestId, body);
    _isLoading = false;
    update();
    if (response.statusCode == 200) return true;
    showCustomSnackBar(response.statusText ?? 'ins_something_went_wrong'.tr);
    return false;
  }

  Future<void> loadPolicies({bool reload = false}) async {
    if (reload) {
      _policies = null;
      update();
    }
    final response = await _repository.getPolicies();
    if (response.statusCode == 200 && response.body is Map) {
      _policies = (response.body['policies'] as List? ?? [])
          .map((e) => InsurancePolicy.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      _policies ??= [];
      showCustomSnackBar(response.statusText);
    }
    update();
  }

  Future<InsurancePolicy?> loadPolicy(int id) async {
    final response = await _repository.getPolicy(id);
    if (response.statusCode == 200 && response.body is Map && response.body['policy'] is Map) {
      return InsurancePolicy.fromJson(Map<String, dynamic>.from(response.body['policy']));
    }
    showCustomSnackBar(response.statusText);
    return null;
  }
}
