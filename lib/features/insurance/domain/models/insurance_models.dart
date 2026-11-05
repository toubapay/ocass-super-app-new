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

/// What the carte grise reading returned. Every field may be null: an
/// unreadable value is left for the customer to type, never guessed.
class VehicleExtraction {
  final String? vehicleType;
  final int? fiscalPower;
  final int? seats;
  final String? registrationNumber;
  final String? chassisNumber;
  final String? brand;
  final String? model;
  final String? firstRegistrationDate;
  final String? fuel;
  final int? cylinder;

  VehicleExtraction({
    this.vehicleType,
    this.fiscalPower,
    this.seats,
    this.registrationNumber,
    this.chassisNumber,
    this.brand,
    this.model,
    this.firstRegistrationDate,
    this.fuel,
    this.cylinder,
  });

  factory VehicleExtraction.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());
    String? toStr(dynamic v) => (v == null || v.toString().trim().isEmpty) ? null : v.toString();
    return VehicleExtraction(
      vehicleType: toStr(json['vehicle_type']),
      fiscalPower: toInt(json['fiscal_power']),
      seats: toInt(json['seats']),
      registrationNumber: toStr(json['registration_number']),
      chassisNumber: toStr(json['chassis_number']),
      brand: toStr(json['brand']),
      model: toStr(json['model']),
      firstRegistrationDate: toStr(json['first_registration_date']),
      fuel: toStr(json['fuel']),
      cylinder: toInt(json['cylinder']),
    );
  }

  /// How many fields the reading filled, to tell the customer what to check.
  int get filledCount => [vehicleType, fiscalPower, seats, registrationNumber, chassisNumber, brand, model, firstRegistrationDate, fuel, cylinder]
      .where((v) => v != null)
      .length;
}

/// The quote request being built across the wizard steps.
/// What the AI read on the driving licence (null where unreadable).
class LicenseExtraction {
  final String? lastName;
  final String? firstName;
  final String? birthDate;
  final String? licenseNumber;
  final String? categories;
  final String? issueDate;
  final String? expiryDate;

  LicenseExtraction({this.lastName, this.firstName, this.birthDate, this.licenseNumber, this.categories, this.issueDate, this.expiryDate});

  factory LicenseExtraction.fromJson(Map<String, dynamic> json) {
    String? s(dynamic v) => (v == null || v.toString().trim().isEmpty) ? null : v.toString();
    return LicenseExtraction(
      lastName: s(json['last_name']),
      firstName: s(json['first_name']),
      birthDate: s(json['birth_date']),
      licenseNumber: s(json['license_number']),
      categories: s(json['categories']),
      issueDate: s(json['issue_date']),
      expiryDate: s(json['expiry_date']),
    );
  }

  int get filledCount => [lastName, firstName, birthDate, licenseNumber, categories, issueDate, expiryDate].where((v) => v != null).length;

  bool get expired {
    final d = DateTime.tryParse(expiryDate ?? '');
    return d != null && d.isBefore(DateTime.now());
  }
}

/// Vehicle age bands, as in Wave, with the first-registration year sent for rating.
class VehicleAge {
  final String code;
  final String labelKey;
  final int yearsAgo;
  const VehicleAge(this.code, this.labelKey, this.yearsAgo);

  static const all = [
    VehicleAge('lt3', 'ins_age_lt3', 1),
    VehicleAge('3to5', 'ins_age_3to5', 4),
    VehicleAge('5to10', 'ins_age_5to10', 7),
    VehicleAge('gt10', 'ins_age_gt10', 12),
  ];

  static VehicleAge? byCode(String? code) => all.where((a) => a.code == code).firstOrNull;

  static String codeFor(DateTime firstRegistration) {
    final years = DateTime.now().year - firstRegistration.year;
    return years < 3 ? 'lt3' : years <= 5 ? '3to5' : years <= 10 ? '5to10' : 'gt10';
  }
}

class InsuranceDraft {
  bool isMoto;
  String usage = 'private';
  bool commercialUse = false;
  String? brand;
  String? model;
  String? registrationNumber;
  String? chassisNumber;
  int? fiscalPower;
  int? cylinder;
  int? seats;
  String fuel = 'petrol';
  DateTime? firstRegistration;
  int? newValue;
  int? value;
  int durationMonths = 12;
  DateTime startDate = DateTime.now();
  String? coverageLevel;
  String? lastName;
  String? firstName;
  String? phone;
  String? email;
  // Wave's two usages: 'personal' (private tariff) or 'professional' (commercial).
  String? usageChoice;
  String? ageCode;
  String? licenseNumber;
  DateTime? birthDate;
  String? licenseCategories;
  String? licenseIssueDate;
  String? licenseExpiryDate;

  InsuranceDraft({required this.isMoto}) {
    if (isMoto) usage = 'motorcycle';
  }

  /// Fills from the carte grise reading; only what was readable.
  void apply(VehicleExtraction e) {
    if (e.vehicleType != null) {
      isMoto = e.vehicleType == 'motorcycle';
      usage = isMoto ? 'motorcycle' : (usage == 'motorcycle' ? 'private' : usage);
    }
    brand = e.brand ?? brand;
    model = e.model ?? model;
    registrationNumber = e.registrationNumber ?? registrationNumber;
    chassisNumber = e.chassisNumber ?? chassisNumber;
    fiscalPower = e.fiscalPower ?? fiscalPower;
    cylinder = e.cylinder ?? cylinder;
    seats = e.seats ?? seats;
    fuel = e.fuel ?? fuel;
    firstRegistration = DateTime.tryParse(e.firstRegistrationDate ?? '') ?? firstRegistration;
  }

  /// Fills the policyholder from the driving licence reading; only what was readable.
  void applyLicense(LicenseExtraction e) {
    lastName = e.lastName ?? lastName;
    firstName = e.firstName ?? firstName;
    licenseNumber = e.licenseNumber ?? licenseNumber;
    birthDate = DateTime.tryParse(e.birthDate ?? '') ?? birthDate;
    licenseCategories = e.categories ?? licenseCategories;
    licenseIssueDate = e.issueDate ?? licenseIssueDate;
    licenseExpiryDate = e.expiryDate ?? licenseExpiryDate;
  }

  /// Personnel / Professionnel to the tariff usage (a moto keeps its own, with commercial use).
  void setUsageChoice(String choice) {
    usageChoice = choice;
    if (isMoto) {
      usage = 'motorcycle';
      commercialUse = choice == 'professional';
    } else {
      usage = choice == 'professional' ? 'commercial' : 'private';
    }
  }

  Map<String, dynamic> toRequest() {
    String day(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final vehicle = <String, dynamic>{
      'usage': usage,
      'brand': brand,
      'model': model,
      'registration_number': registrationNumber,
      'chassis_number': chassisNumber,
      'fiscal_power': isMoto ? null : fiscalPower,
      'cylinder': isMoto ? cylinder : null,
      'seats': seats,
      'fuel': fuel,
      'value': value,
      'new_value': newValue,
      'commercial_use': isMoto && commercialUse ? true : null,
      'first_registration_date': firstRegistration == null ? null : day(firstRegistration!),
      'first_registration_year': firstRegistration?.year ??
          (VehicleAge.byCode(ageCode) == null ? null : DateTime.now().year - VehicleAge.byCode(ageCode)!.yearsAgo),
    }..removeWhere((_, v) => v == null || (v is String && v.trim().isEmpty));
    final owner = <String, dynamic>{
      'name': [firstName, lastName].where((s) => s != null && s.trim().isNotEmpty).join(' '),
      'last_name': lastName,
      'first_name': firstName,
      'phone': phone,
      'email': email,
      'license_number': licenseNumber?.toUpperCase(),
      'birth_date': birthDate == null ? null : day(birthDate!),
      'license_categories': licenseCategories,
      'license_issue_date': licenseIssueDate,
      'license_expiry_date': licenseExpiryDate,
    }..removeWhere((_, v) => v == null || v.trim().isEmpty);
    return {
      'vehicle': vehicle,
      'owner': owner,
      'duration_months': durationMonths,
      'start_date': day(startDate),
      'coverage_level': coverageLevel,
    };
  }
}
