double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

/// Rules of the mobile money module, as set by the admin, plus this customer's state.
class MobileMoneyConfig {
  final bool enabled;
  final String? moduleName;
  final double feePercent;
  final double feeFixed;
  final double maxFee;
  final String feeBearer;
  final double minAmount;
  final double maxAmount;
  final bool hasPin;
  final double walletBalance;

  MobileMoneyConfig({
    required this.enabled,
    this.moduleName,
    required this.feePercent,
    required this.feeFixed,
    required this.maxFee,
    required this.feeBearer,
    required this.minAmount,
    required this.maxAmount,
    required this.hasPin,
    required this.walletBalance,
  });

  factory MobileMoneyConfig.fromJson(Map<String, dynamic> json) => MobileMoneyConfig(
        enabled: json['enabled'] == true,
        moduleName: json['module_name'],
        feePercent: _d(json['fee_percent']),
        feeFixed: _d(json['fee_fixed']),
        maxFee: _d(json['max_fee']),
        feeBearer: json['fee_bearer'] ?? 'sender',
        minAmount: _d(json['min_amount']),
        maxAmount: _d(json['max_amount']),
        hasPin: json['has_pin'] == true,
        walletBalance: _d(json['wallet_balance']),
      );

  MobileMoneyConfig withPin() => MobileMoneyConfig(
        enabled: enabled,
        moduleName: moduleName,
        feePercent: feePercent,
        feeFixed: feeFixed,
        maxFee: maxFee,
        feeBearer: feeBearer,
        minAmount: minAmount,
        maxAmount: maxAmount,
        hasPin: true,
        walletBalance: walletBalance,
      );
}

/// The other customer of a transfer, as much as the backend shows ("Moussa N.").
class MoneyContact {
  final int? id;
  final String name;
  final String phone;
  final String? imageFullUrl;

  MoneyContact({this.id, required this.name, required this.phone, this.imageFullUrl});

  factory MoneyContact.fromJson(Map<String, dynamic> json) =>
      MoneyContact(id: json['id'], name: json['name'] ?? '', phone: json['phone'] ?? '', imageFullUrl: json['image_full_url']);
}

class MoneyPreview {
  final MoneyContact receiver;
  final double amount;
  final double fee;
  final double senderDebit;
  final double receiverCredit;
  final double walletBalance;

  MoneyPreview({
    required this.receiver,
    required this.amount,
    required this.fee,
    required this.senderDebit,
    required this.receiverCredit,
    required this.walletBalance,
  });

  bool get sufficientBalance => walletBalance >= senderDebit;

  factory MoneyPreview.fromJson(Map<String, dynamic> json) => MoneyPreview(
        receiver: MoneyContact.fromJson(Map<String, dynamic>.from(json['receiver'])),
        amount: _d(json['amount']),
        fee: _d(json['fee']),
        senderDebit: _d(json['sender_debit']),
        receiverCredit: _d(json['receiver_credit']),
        walletBalance: _d(json['wallet_balance']),
      );
}

class MoneyTransfer {
  final String reference;
  final bool sent;
  final MoneyContact? counterpart;
  final double amount;
  final double fee;
  // Signed change on this customer's balance.
  final double walletAmount;
  final String? note;
  final String status;
  final DateTime? createdAt;

  MoneyTransfer({
    required this.reference,
    required this.sent,
    this.counterpart,
    required this.amount,
    required this.fee,
    required this.walletAmount,
    this.note,
    required this.status,
    this.createdAt,
  });

  factory MoneyTransfer.fromJson(Map<String, dynamic> json) => MoneyTransfer(
        reference: json['reference'] ?? '',
        sent: json['direction'] == 'sent',
        counterpart: json['counterpart'] is Map ? MoneyContact.fromJson(Map<String, dynamic>.from(json['counterpart'])) : null,
        amount: _d(json['amount']),
        fee: _d(json['fee']),
        walletAmount: _d(json['wallet_amount']),
        note: json['note'],
        status: json['status'] ?? 'completed',
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'])?.toLocal() : null,
      );
}
