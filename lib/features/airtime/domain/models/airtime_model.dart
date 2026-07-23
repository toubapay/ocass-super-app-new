// LAM AirTime API documentation:
// https://developers.lafricamobile.com/docs/airtime/introduction

class AirtimeSendRequest {
  final String login;
  final String password;
  final String montant; // amount
  final String telephone; // recipient phone
  final String operateur; // operator code e.g. ORANGESN
  final String? callback;
  final String? offer; // bundle offer ID (optional, for data bundles)

  AirtimeSendRequest({
    required this.login,
    required this.password,
    required this.montant,
    required this.telephone,
    required this.operateur,
    this.callback,
    this.offer,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'login': login,
      'password': password,
      'montant': montant,
      'telephone': telephone,
      'operateur': operateur,
    };
    if (callback != null) map['callback'] = callback;
    if (offer != null) map['offer'] = offer;
    return map;
  }
}

class AirtimeTransactionResponse {
  final String? productId;
  final String? transactionId;
  final String? status;
  final String? dateTime;
  final String? telephone;
  final String? montant;
  final String? partnerTransactionId;
  final String? errorMessage;

  AirtimeTransactionResponse({
    this.productId,
    this.transactionId,
    this.status,
    this.dateTime,
    this.telephone,
    this.montant,
    this.partnerTransactionId,
    this.errorMessage,
  });

  factory AirtimeTransactionResponse.fromJson(Map<String, dynamic> json) {
    return AirtimeTransactionResponse(
      productId:
          json['service_id']?.toString() ?? json['product_id']?.toString(),
      transactionId: json['gu_transaction_id']?.toString() ??
          json['transaction_id']?.toString(),
      status: json['status']?.toString(),
      dateTime: json['transaction_date']?.toString() ??
          json['datetime']?.toString() ??
          json['date_time']?.toString(),
      telephone: json['recipient_phone_number']?.toString() ??
          json['telephone']?.toString(),
      montant: json['amount']?.toString() ?? json['montant']?.toString(),
      partnerTransactionId: json['partner_transaction_id']?.toString(),
      errorMessage: json['message']?.toString() ??
          json['errorMessage']?.toString() ??
          json['error']?.toString(),
    );
  }
}

/// Predefined operators supported by LAM
class AirtimeOperator {
  final String code;
  final String name;
  final String country;
  final String flag;
  final String color;
  final String logo;

  const AirtimeOperator({
    required this.code,
    required this.name,
    required this.country,
    required this.flag,
    required this.color,
    required this.logo,
  });
}

/// A predefined airtime plan amount
class AirtimePlan {
  final String amount;
  final String label;
  final String? description;

  const AirtimePlan({
    required this.amount,
    required this.label,
    this.description,
  });
}

/// Predefined operators
const List<AirtimeOperator> kAirtimeOperators = [
  AirtimeOperator(
    code: 'ORANGESN',
    name: 'Orange',
    country: 'Senegal',
    flag: '🇸🇳',
    color: '#FF6600',
    logo: 'orange.png',
  ),
  AirtimeOperator(
    code: 'FREESN',
    name: 'Free Mobile',
    country: 'Senegal',
    flag: '🇸🇳',
    color: '#CC0000',
    logo: 'yas.png', // User mentioned yas.png as one of the logos, using it for Free/Yas
  ),
  AirtimeOperator(
    code: 'EXPSN',
    name: 'Expresso',
    country: 'Senegal',
    flag: '🇸🇳',
    color: '#006633',
    logo: 'expresso.png',
  ),
];

/// Predefined plans
const List<AirtimePlan> kAirtimePlans = [
  AirtimePlan(amount: '100', label: '100', description: 'Quick top-up'),
  AirtimePlan(amount: '200', label: '200', description: 'Standard'),
  AirtimePlan(amount: '500', label: '500', description: 'Popular'),
  AirtimePlan(amount: '1000', label: '1,000', description: 'Value pack'),
  AirtimePlan(amount: '2000', label: '2,000', description: 'Large pack'),
  AirtimePlan(amount: '5000', label: '5,000', description: 'Super pack'),
];
