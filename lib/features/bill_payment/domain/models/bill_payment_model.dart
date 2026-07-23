class BillTransactionResponse {
  final String? serviceId;
  final String? transactionId;
  final String? status;
  final String? dateTime;
  final String? accountNumber;
  final String? invoiceNumber;
  final String? dueDate;
  final String? amount;
  final String? errorMessage;
  final String? fees;
  final String? total;
  final String? currency;
  final String? message;
  final String? customerName;
  final String? minAmount;
  final String? maxAmount;
  final String? token;
  // Commission & deduction breakdown (added by our backend)
  final String? serviceCommission;
  final String? totalDeducted;
  final String? lamFeesAmount;

  BillTransactionResponse({
    this.serviceId,
    this.transactionId,
    this.status,
    this.dateTime,
    this.accountNumber,
    this.invoiceNumber,
    this.dueDate,
    this.amount,
    this.errorMessage,
    this.fees,
    this.total,
    this.currency,
    this.message,
    this.customerName,
    this.minAmount,
    this.maxAmount,
    this.token,
    this.serviceCommission,
    this.totalDeducted,
    this.lamFeesAmount,
  });

  factory BillTransactionResponse.fromJson(Map<String, dynamic> json) {
    // If the backend returned a BillPayment DB record (has lam_transaction_id),
    // the LAM-level fields are nested inside payment_response.
    final bool isDbRecord = json.containsKey('lam_transaction_id');
    final Map<String, dynamic> raw = isDbRecord && json['payment_response'] is Map
        ? Map<String, dynamic>.from(json['payment_response'] as Map)
        : json;

    dynamic statusVal = json['status'] ?? raw['status'];
    String? statusString;
    if (statusVal is bool) {
      statusString = statusVal ? 'success' : 'failed';
    } else {
      statusString = statusVal?.toString();
    }

    return BillTransactionResponse(
      serviceId: json['provider']?.toString() ?? raw['product']?.toString() ?? raw['service_id']?.toString(),
      transactionId: json['lam_transaction_id']?.toString() ?? raw['transaction_id']?.toString() ?? raw['gu_transaction_id']?.toString(),
      status: statusString,
      dateTime: json['created_at']?.toString() ?? raw['created_at']?.toString() ?? raw['transaction_date']?.toString(),
      accountNumber: json['account_number']?.toString() ?? raw['account_number']?.toString() ?? raw['customer_account']?.toString(),
      invoiceNumber: raw['invoice_number']?.toString(),
      dueDate: raw['due_date']?.toString(),
      amount: json['amount']?.toString() ?? raw['amount']?.toString() ?? raw['montant']?.toString(),
      errorMessage: raw['message']?.toString() ?? raw['errorMessage']?.toString() ?? raw['error']?.toString(),
      fees: json['lam_fees']?.toString() ?? raw['fees']?.toString(),
      total: raw['total']?.toString(),
      currency: json['currency']?.toString() ?? raw['currency']?.toString() ?? 'XOF',
      message: raw['message']?.toString(),
      customerName: raw['customer_name']?.toString(),
      minAmount: raw['meta']?['amount_bound_min']?.toString() ?? raw['min_amount']?.toString(),
      maxAmount: raw['meta']?['amount_bound_max']?.toString() ?? raw['max_amount']?.toString(),
      token: raw['token']?.toString(),
      serviceCommission: json['service_commission']?.toString(),
      totalDeducted: json['total_deducted']?.toString(),
      lamFeesAmount: json['lam_fees']?.toString() ?? raw['fees']?.toString(),
    );
  }
}

class BillCountry {
  final String code;
  final String name;
  final List<BillProvider> billers;

  BillCountry({required this.code, required this.name, required this.billers});

  factory BillCountry.fromJson(Map<String, dynamic> json) {
    var billersList = json['billers'] as List? ?? [];
    String countryCode = json['code']?.toString() ?? '';
    String countryName = json['name']?.toString() ?? '';
    
    return BillCountry(
      code: countryCode,
      name: countryName,
      billers: billersList.map((b) {
        Map<String, dynamic> bMap = Map<String, dynamic>.from(b);
        bMap['country'] = countryName;
        bMap['country_code'] = countryCode;
        return BillProvider.fromJson(bMap);
      }).toList(),
    );
  }
}

class BillProvider {
  final String code;
  final String name;
  final String country;
  final String countryCode;
  final String flag;
  final String color;
  final String? description;

  const BillProvider({
    required this.code,
    required this.name,
    required this.country,
    required this.countryCode,
    required this.flag,
    required this.color,
    this.description,
  });

  String? get imageAsset {
    final nameLower = name.toLowerCase();
    final codeLower = code.toLowerCase();
    if (nameLower.contains('senelec') || codeLower.contains('senelec')) {
      return 'assets/image/billpayment/senelec.jpeg';
    }
    if (nameLower.contains('seneau') || codeLower.contains('seneau')) {
      return 'assets/image/billpayment/seneau.png';
    }
    if (nameLower.contains('woyofal') || codeLower.contains('woyofal')) {
      return 'assets/image/billpayment/woyofal.jpeg';
    }
    if (nameLower.contains('rapido') || codeLower.contains('rapido')) {
      return 'assets/image/billpayment/rapido.png';
    }
    if (nameLower.contains('startimes') || codeLower.contains('startimes')) {
      return 'assets/image/billpayment/startimes.jpeg';
    }
    if (nameLower.contains('cmacgm') || codeLower.contains('cmacgm')) {
      return 'assets/image/billpayment/cmacgm.png';
    }
    return null;
  }

  factory BillProvider.fromJson(Map<String, dynamic> json) {
    String cCode = json['country_code']?.toString() ?? '';
    return BillProvider(
      code: json['code']?.toString() ?? json['id']?.toString() ?? json['name']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      countryCode: cCode,
      flag: _getFlagFromCountryCode(cCode),
      color: '#0066CC',
      description: json['description']?.toString(),
    );
  }

  static String _getFlagFromCountryCode(String code) {
    switch (code.toUpperCase()) {
      case 'SN': return '🇸🇳';
      case 'CI': return '🇨🇮';
      case 'ML': return '🇲🇱';
      case 'GN': return '🇬🇳';
      case 'CD': return '🇨🇩';
      case 'CG': return '🇨🇬';
      case 'GM': return '🇬🇲';
      case 'BJ': return '🇧🇯';
      case 'CF': return '🇨🇫';
      case 'BF': return '🇧🇫';
      case 'TG': return '🇹🇬';
      case 'NE': return '🇳🇪';
      default: return '🌍';
    }
  }
}

const List<BillProvider> kDefaultBillProviders = [
  BillProvider(code: 'SENELEC', name: 'Senelec', country: 'Senegal', countryCode: 'SN', flag: '🇸🇳', color: '#0066CC'),
  BillProvider(code: 'SENEAU', name: 'Seneau', country: 'Senegal', countryCode: 'SN', flag: '🇸🇳', color: '#0066CC'),
  BillProvider(code: 'WOYOFAL', name: 'Woyofal', country: 'Senegal', countryCode: 'SN', flag: '🇸🇳', color: '#0066CC'),
];
