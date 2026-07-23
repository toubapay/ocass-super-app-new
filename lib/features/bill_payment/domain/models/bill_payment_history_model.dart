class BillPaymentHistoryModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<BillPaymentRecord>? data;

  BillPaymentHistoryModel({this.totalSize, this.limit, this.offset, this.data});

  BillPaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit']?.toString();
    offset = json['offset']?.toString();
    if (json['data'] != null) {
      data = [];
      for (var v in json['data']) {
        data!.add(BillPaymentRecord.fromJson(v));
      }
    }
  }
}

class BillPaymentRecord {
  int? id;
  int? userId;
  String? lamTransactionId;
  String? provider;
  String? accountNumber;
  String? countryCode;
  double? amount;
  // Dedicated DB columns (available after migration)
  double? lamFees;           // LAM provider fee (e.g. 7)
  double? serviceCommission; // our platform commission (e.g. 3)
  double? totalDeducted;     // total charged to wallet (e.g. 1010)
  String? currency;
  String? status;
  String? reference;
  Map<String, dynamic>? paymentResponse;
  Map<String, dynamic>? callbackData;
  DateTime? createdAt;
  DateTime? updatedAt;

  BillPaymentRecord({
    this.id,
    this.userId,
    this.lamTransactionId,
    this.provider,
    this.accountNumber,
    this.countryCode,
    this.amount,
    this.lamFees,
    this.serviceCommission,
    this.totalDeducted,
    this.currency,
    this.status,
    this.reference,
    this.paymentResponse,
    this.callbackData,
    this.createdAt,
    this.updatedAt,
  });

  BillPaymentRecord.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    lamTransactionId = json['lam_transaction_id'];
    provider = json['provider'];
    accountNumber = json['account_number'];
    countryCode = json['country_code'];
    amount = json['amount'] != null ? (json['amount'] as num).toDouble() : null;
    currency = json['currency'];
    status = json['status'];
    reference = json['reference'];

    paymentResponse = json['payment_response'] != null
        ? Map<String, dynamic>.from(json['payment_response'] as Map)
        : null;
    callbackData = json['callback_data'] != null
        ? Map<String, dynamic>.from(json['callback_data'] as Map)
        : null;

    // Primary: dedicated DB columns. Fallback: embedded in payment_response (old records).
    final pr = paymentResponse;
    lamFees = _parseDouble(json['lam_fees'])
        ?? _parseDouble(pr?['_lam_fees'])
        ?? _parseDouble(pr?['fees']);
    serviceCommission = _parseDouble(json['service_commission'])
        ?? _parseDouble(pr?['_service_commission']);
    totalDeducted = _parseDouble(json['total_deducted'])
        ?? _parseDouble(pr?['_total_deducted']);

    createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null;
    updatedAt = json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString())
        : null;
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  bool get isSuccess => status == 'success';
  bool get isFailed  => status == 'failed';
  bool get isPending => status == 'pending';

  // ── LAM response field helpers (read from payment_response or callbackData) ──

  String? get lamStatus        => _responseField('status')?.toString();
  String? get lamCode          => _responseField('code')?.toString();
  String? get lamMessage       => _responseField('message')?.toString();
  String? get lamOperatorRef   => _responseField('operator_ref')?.toString()
                               ?? _responseField('operator_transaction_id')?.toString();
  String? get lamCustomerName  => _responseField('customer_name')?.toString();
  String? get lamInvoiceNumber => _responseField('invoice_number')?.toString();
  String? get lamPhone         => _responseField('phone')?.toString();

  // Prepaid/electricity specific fields
  String? get lamToken   => _responseField('token')?.toString();
  String? get lamReceipt => _responseField('receipt')?.toString();
  String? get lamKwh     => _responseField('khw')?.toString()
                         ?? _responseField('kwh')?.toString();
  String? get lamTotal     => _responseField('total')?.toString();
  String? get lamMontant   => _responseField('montant')?.toString();
  String? get lamReference => _responseField('reference')?.toString();

  // ── Check-status fields (nested in payment_response.check_status) ──

  Map<String, dynamic>? get _checkStatus =>
      paymentResponse?['check_status'] as Map<String, dynamic>?;

  String? get csStatus        => _checkStatus?['status']?.toString();
  String? get csMessage       => _checkStatus?['message']?.toString();
  String? get csTransactionId => _checkStatus?['transaction_id']?.toString();
  String? get csAccountNumber => _checkStatus?['account_number']?.toString();
  String? get csInvoiceNumber => _checkStatus?['invoice_number']?.toString();
  String? get csAmount        => _checkStatus?['amount']?.toString()
                               ?? _checkStatus?['montant']?.toString();
  String? get csFees          => _checkStatus?['fees']?.toString();
  String? get csTotal         => _checkStatus?['total']?.toString();
  String? get csCreatedAt     => _checkStatus?['created_at']?.toString();
  String? get csReference     => _checkStatus?['reference']?.toString();

  dynamic _responseField(String key) =>
      paymentResponse?[key] ?? callbackData?[key];
}
