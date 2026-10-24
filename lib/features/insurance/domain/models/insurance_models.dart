/// Models for the motor insurance comparison (backend: /api/v1/customer/insurance).
library;

double _num(dynamic value) => value == null ? 0 : double.tryParse(value.toString()) ?? 0;

class InsuranceChoice {
  final String code;
  final String label;
  InsuranceChoice({required this.code, required this.label});

  factory InsuranceChoice.fromJson(Map<String, dynamic> json) =>
      InsuranceChoice(code: json['code'].toString(), label: json['label']?.toString() ?? json['code'].toString());
}

class InsuranceOptions {
  final List<InsuranceChoice> usages;
  final List<InsuranceChoice> coverageLevels;
  final List<InsuranceChoice> fuels;
  final List<int> durations;
  final String currency;

  InsuranceOptions({required this.usages, required this.coverageLevels, required this.fuels, required this.durations, required this.currency});

  factory InsuranceOptions.fromJson(Map<String, dynamic> json) {
    List<InsuranceChoice> choices(String key) =>
        (json[key] as List? ?? []).map((e) => InsuranceChoice.fromJson(Map<String, dynamic>.from(e))).toList();
    return InsuranceOptions(
      usages: choices('usages'),
      coverageLevels: choices('coverage_levels'),
      fuels: choices('fuels'),
      durations: (json['durations'] as List? ?? [1, 3, 6, 12]).map((e) => int.parse(e.toString())).toList(),
      currency: json['currency']?.toString() ?? 'XOF',
    );
  }
}

class InsuranceProviderInfo {
  final int id;
  final String name;
  final String? logo;
  InsuranceProviderInfo({required this.id, required this.name, this.logo});

  factory InsuranceProviderInfo.fromJson(Map<String, dynamic> json) => InsuranceProviderInfo(
        id: int.parse(json['id'].toString()),
        name: json['name']?.toString() ?? '',
        logo: (json['logo'] ?? json['logo_full_url'])?.toString(),
      );
}

class InsuranceQuote {
  final int id;
  final InsuranceProviderInfo provider;
  final String productName;
  final String coverageLevel;
  final String coverageLevelLabel;
  final List<InsuranceChoice> guarantees;
  final Map<String, double> breakdown;
  final double premiumNet;
  final double fees;
  final double taxes;
  final double totalPremium;
  final String currency;
  final DateTime? validUntil;
  final bool purchasable;
  final bool isCheapest;
  final bool isCheapestInLevel;

  InsuranceQuote({
    required this.id,
    required this.provider,
    required this.productName,
    required this.coverageLevel,
    required this.coverageLevelLabel,
    required this.guarantees,
    required this.breakdown,
    required this.premiumNet,
    required this.fees,
    required this.taxes,
    required this.totalPremium,
    required this.currency,
    this.validUntil,
    required this.purchasable,
    required this.isCheapest,
    required this.isCheapestInLevel,
  });

  factory InsuranceQuote.fromJson(Map<String, dynamic> json) {
    final breakdown = <String, double>{};
    if (json['breakdown'] is Map) {
      (json['breakdown'] as Map).forEach((key, value) => breakdown[key.toString()] = _num(value));
    }
    return InsuranceQuote(
      id: int.parse(json['id'].toString()),
      provider: InsuranceProviderInfo.fromJson(Map<String, dynamic>.from(json['provider'] ?? {'id': 0})),
      productName: json['product_name']?.toString() ?? '',
      coverageLevel: json['coverage_level']?.toString() ?? '',
      coverageLevelLabel: json['coverage_level_label']?.toString() ?? '',
      guarantees: (json['guarantees'] as List? ?? []).map((e) => InsuranceChoice.fromJson(Map<String, dynamic>.from(e))).toList(),
      breakdown: breakdown,
      premiumNet: _num(json['premium_net']),
      fees: _num(json['fees']),
      taxes: _num(json['taxes']),
      totalPremium: _num(json['total_premium']),
      currency: json['currency']?.toString() ?? 'XOF',
      validUntil: DateTime.tryParse(json['valid_until']?.toString() ?? ''),
      purchasable: json['purchasable'] == true,
      isCheapest: json['is_cheapest'] == true,
      isCheapestInLevel: json['is_cheapest_in_level'] == true,
    );
  }
}

class InsuranceQuoteResult {
  final int quoteRequestId;
  final List<InsuranceQuote> quotes;
  final List<String> unavailableProviders;

  InsuranceQuoteResult({required this.quoteRequestId, required this.quotes, required this.unavailableProviders});

  factory InsuranceQuoteResult.fromJson(Map<String, dynamic> json) => InsuranceQuoteResult(
        quoteRequestId: int.parse(json['quote_request_id'].toString()),
        quotes: (json['quotes'] as List? ?? []).map((e) => InsuranceQuote.fromJson(Map<String, dynamic>.from(e))).toList(),
        unavailableProviders: (json['unavailable_providers'] as List? ?? []).map((e) => e.toString()).toList(),
      );
}

class InsurancePolicy {
  static const String pendingPayment = 'pending_payment';
  static const String paymentFailed = 'payment_failed';
  static const String awaitingIssuance = 'awaiting_issuance';
  static const String issuanceFailed = 'issuance_failed';
  static const String active = 'active';
  static const String cancelled = 'cancelled';

  final int id;
  final String status;
  final double amount;
  final String currency;
  final String? policyNumber;
  final String? startDate;
  final String? endDate;
  final String? certificateUrl;
  final String? carteBruneUrl;
  final String? providerName;
  final String? providerLogo;
  final String? productName;
  final String? coverageLevelLabel;
  final Map<String, dynamic>? vehicle;
  final DateTime? createdAt;

  InsurancePolicy({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    this.policyNumber,
    this.startDate,
    this.endDate,
    this.certificateUrl,
    this.carteBruneUrl,
    this.providerName,
    this.providerLogo,
    this.productName,
    this.coverageLevelLabel,
    this.vehicle,
    this.createdAt,
  });

  bool get isWaitingForPayment => status == pendingPayment;
  bool get isBeingIssued => status == awaitingIssuance || status == issuanceFailed;

  factory InsurancePolicy.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] is Map ? Map<String, dynamic>.from(json['provider']) : null;
    final quote = json['quote'] is Map ? Map<String, dynamic>.from(json['quote']) : null;
    final request = quote?['quote_request'] is Map ? Map<String, dynamic>.from(quote!['quote_request']) : null;
    final details = request?['details'] is Map ? Map<String, dynamic>.from(request!['details']) : null;
    return InsurancePolicy(
      id: int.parse(json['id'].toString()),
      status: json['status']?.toString() ?? '',
      amount: _num(json['amount']),
      currency: json['currency']?.toString() ?? 'XOF',
      policyNumber: json['policy_number']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      certificateUrl: json['certificate_full_url']?.toString(),
      carteBruneUrl: json['carte_brune_url']?.toString(),
      providerName: provider?['name']?.toString(),
      providerLogo: provider?['logo_full_url']?.toString(),
      productName: quote?['product_name']?.toString(),
      coverageLevelLabel: quote?['coverage_level']?.toString(),
      vehicle: details?['vehicle'] is Map ? Map<String, dynamic>.from(details!['vehicle']) : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

/// The purchase was refused before payment; [missingFields] lists what the
/// insurer still needs (e.g. `vehicle.first_registration_date`).
class InsurancePurchaseError {
  final String code;
  final String message;
  final List<String> missingFields;
  InsurancePurchaseError({required this.code, required this.message, this.missingFields = const []});
}
