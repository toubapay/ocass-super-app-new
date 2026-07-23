import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/bill_payment/domain/models/bill_payment_history_model.dart';
import 'package:sixam_mart/features/bill_payment/domain/repositories/bill_payment_repository.dart';

class BillPaymentDetailScreen extends StatefulWidget {
  final BillPaymentRecord initialRecord;
  const BillPaymentDetailScreen({super.key, required this.initialRecord});

  @override
  State<BillPaymentDetailScreen> createState() =>
      _BillPaymentDetailScreenState();
}

class _BillPaymentDetailScreenState extends State<BillPaymentDetailScreen> {
  late BillPaymentRecord _record;
  bool _refreshing = false;
  String? _refreshError;

  final _repo = BillPaymentRepository();

  // ── Colours ──────────────────────────────────────────────────────
  static const _blue    = Color(0xFF00AA13);
  static const _dark    = Color(0xFF1E1B4B);
  static const _grey    = Color(0xFF8A9BB5);
  static const _surface = Color(0xFFF3F7FF);

  @override
  void initState() {
    super.initState();
    _record = widget.initialRecord;
  }

  Color get _statusColor {
    if (_record.isSuccess) return const Color(0xFF00AA13);
    if (_record.isFailed)  return Colors.red;
    return Colors.orange;
  }

  IconData get _statusIcon {
    if (_record.isSuccess) return Icons.verified_rounded;
    if (_record.isFailed)  return Icons.cancel_rounded;
    return Icons.hourglass_top_rounded;
  }

  String get _statusLabel {
    if (_record.isSuccess) return 'Payment Successful';
    if (_record.isFailed)  return 'Payment Failed';
    return 'Processing…';
  }

  // Helpers for check-status section — derived from csStatus string
  bool get _csIsSuccess {
    final s = _record.csStatus?.toLowerCase() ?? '';
    return s == 'true' || s == 'success' || s == 'completed' || s == 'processed';
  }

  bool get _csIsFailed {
    final s = _record.csStatus?.toLowerCase() ?? '';
    return s == 'false' || s == 'failed';
  }

  Color get _csStatusColor {
    if (_csIsSuccess) return const Color(0xFF00AA13);
    if (_csIsFailed)  return Colors.red;
    return Colors.orange;
  }

  IconData get _csStatusIcon {
    if (_csIsSuccess) return Icons.check_circle_rounded;
    if (_csIsFailed)  return Icons.cancel_rounded;
    return Icons.hourglass_top_rounded;
  }

  String get _csStatusLabel {
    if (_csIsSuccess) return 'Success';
    if (_csIsFailed)  return 'Failed';
    return _record.csStatus ?? 'Pending';
  }

  // ── Refresh ──────────────────────────────────────────────────────

  Future<void> _refreshStatus() async {
    final txId = _record.lamTransactionId;
    if (txId == null || txId.isEmpty) return;

    setState(() {
      _refreshing = true;
      _refreshError = null;
    });

    final result = await _repo.refreshBillPaymentStatus(
      lamTransactionId: txId,
    );

    if (!mounted) return;

    if (result.error != null) {
      setState(() {
        _refreshing = false;
        _refreshError = result.error;
      });
      Get.snackbar(
        'Refresh Failed',
        result.error!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (result.record != null) {
      setState(() {
        _record = result.record!;
        _refreshing = false;
      });
      Get.snackbar(
        'Status Updated',
        'Latest status: $_statusLabel',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _statusColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    } else {
      // No DB record returned (rare) — just stop spinner
      setState(() => _refreshing = false);
      Get.snackbar(
        'Up to Date',
        'No status change received from provider.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          _header(),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────

  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF06402B), _blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(children: [
            // Back + Refresh bar
            Row(children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.15)),
              ),
              Expanded(child: Text('transaction_details'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ),
              // Refresh button
              _refreshing
                  ? Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : IconButton(
                      onPressed: _record.isPending ? _refreshStatus : null,
                      tooltip: 'Refresh status from provider',
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: _record.isPending
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                        size: 22,
                      ),
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15)),
                    ),
            ]),
            const SizedBox(height: 24),
            // Status icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Container(
                key: ValueKey(_record.status),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3), width: 2),
                ),
                child: Icon(_statusIcon, color: Colors.white, size: 48),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(_statusLabel,
                  key: ValueKey(_statusLabel),
                  style: const TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 6),
            Text(
              '${((_record.totalDeducted ?? 0) > 0 ? _record.totalDeducted : _record.amount)?.toStringAsFixed(0) ?? '—'} ${_record.currency ?? 'XOF'}',
              style: const TextStyle(color: Colors.white, fontSize: 32,
                  fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(_record.status),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _statusColor.withValues(alpha: 0.5), width: 1),
                ),
                child: Text(_statusLabel,
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────

  Widget _body() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Pending hint + inline refresh
        if (_record.isPending) ...[
          _pendingBanner(),
          const SizedBox(height: 16),
        ],

        // 1 ── Payment Details
        _card('Payment Details', [
          _row('Provider',       _record.provider ?? '—',      Icons.electrical_services_rounded),
          _row('Account Number', _record.accountNumber ?? '—', Icons.numbers_rounded),
          _row('Country',        _record.countryCode ?? '—',   Icons.flag_rounded),
          _row('Bill Amount',
              '${_record.amount?.toStringAsFixed(0) ?? '—'} ${_record.currency ?? 'XOF'}',
              Icons.attach_money_rounded),
          if ((_record.lamFees ?? 0) > 0)
            _row('Provider Fee',
                '+ ${_record.lamFees!.toStringAsFixed(0)} ${_record.currency ?? 'XOF'}',
                Icons.payments_outlined,
                valueColor: Colors.orange.shade700),
          if ((_record.serviceCommission ?? 0) > 0)
            _row('Service Fee',
                '+ ${_record.serviceCommission!.toStringAsFixed(0)} ${_record.currency ?? 'XOF'}',
                Icons.miscellaneous_services_rounded,
                valueColor: Colors.deepPurple),
          if ((_record.totalDeducted ?? 0) > 0)
            _totalDeductedRow(_record.totalDeducted!, _record.currency ?? 'XOF'),
        ]),
        const SizedBox(height: 16),

        // 2 ── Transaction Info
        _card('Transaction Info', [
          _row('Transaction ID', _record.lamTransactionId ?? '—',
              Icons.tag_rounded, copyable: true),
          if (_record.lamToken != null)
            _row('Token / Vend Code', _record.lamToken!,
                Icons.key_rounded, copyable: true),
          if (_record.lamReceipt != null)
            _row('Receipt Number', _record.lamReceipt!,
                Icons.receipt_rounded, copyable: true),
          _row('Reference', _record.reference ?? '—',
              Icons.description_rounded),
          _row('Status', _statusLabel, _statusIcon, valueColor: _statusColor),
        ]),
        const SizedBox(height: 16),

        // 3 ── Provider Response (from POST /api/payment)
        if (_record.paymentResponse != null) ...[
          _card('Provider Response', [
            if (_record.lamCode != null)
              _row('Response Code',    _record.lamCode!,          Icons.code_rounded),
            if (_record.lamMessage != null)
              _row('Message',          _record.lamMessage!,       Icons.message_outlined),
            if (_record.lamCustomerName != null)
              _row('Customer Name',    _record.lamCustomerName!,  Icons.person_rounded),
            if (_record.lamKwh != null)
              _row('Energy Allocated', _record.lamKwh!,           Icons.bolt_rounded),
            if (_record.lamFees != null)
              _row('Fees',
                  '${_record.lamFees!.toStringAsFixed(0)} ${_record.currency ?? 'XOF'}',
                  Icons.payments_outlined),
            if (_record.lamTotal != null)
              _row('Total Charged',
                  '${_record.lamTotal} ${_record.currency ?? 'XOF'}',
                  Icons.price_check_rounded),
            if (_record.lamInvoiceNumber != null)
              _row('Invoice Number',   _record.lamInvoiceNumber!, Icons.receipt_long_rounded, copyable: true),
            if (_record.lamOperatorRef != null)
              _row('Operator Ref',     _record.lamOperatorRef!,   Icons.receipt_rounded, copyable: true),
            if (_record.lamPhone != null)
              _row('Phone',            _record.lamPhone!,         Icons.phone_rounded),
            if (_record.lamReference != null)
              _row('Reference',        _record.lamReference!,     Icons.fingerprint_rounded, copyable: true),
            if (_record.lamMontant != null)
              _row('Montant',
                  '${_record.lamMontant} ${_record.currency ?? 'XOF'}',
                  Icons.attach_money_rounded),
            // any extra unknown keys the provider may add
            ..._rawRows(_record.paymentResponse!, skip: {
              'status','code','message','operator_ref','operator_transaction_id',
              'customer_name','invoice_number','phone',
              'token','receipt','khw','kwh','fees','total',
              'transaction_id','account_number','amount',
              'reference','montant','callback','check_status',
            }),
          ]),
          const SizedBox(height: 16),
        ],

        // 4 ── Last Status Check (from POST /api/checkstatus)
        if (_record.csTransactionId != null || _record.csStatus != null) ...[
          _card('Last Status Check', [
            if (_record.csStatus != null)
              _row('Provider Status',  _csStatusLabel,  _csStatusIcon,
                  valueColor: _csStatusColor),
            if (_record.csMessage != null)
              _row('Message',          _record.csMessage!,        Icons.message_outlined),
            if (_record.csTransactionId != null)
              _row('Transaction ID',   _record.csTransactionId!,  Icons.tag_rounded, copyable: true),
            if (_record.csAccountNumber != null)
              _row('Account Number',   _record.csAccountNumber!,  Icons.numbers_rounded),
            if (_record.csInvoiceNumber != null)
              _row('Invoice Number',   _record.csInvoiceNumber!,  Icons.receipt_long_rounded, copyable: true),
            if (_record.csAmount != null)
              _row('Amount',
                  '${_record.csAmount} ${_record.currency ?? 'XOF'}',
                  Icons.attach_money_rounded),
            if (_record.csFees != null)
              _row('Fees',
                  '${_record.csFees} ${_record.currency ?? 'XOF'}',
                  Icons.payments_outlined),
            if (_record.csTotal != null)
              _row('Total',
                  '${_record.csTotal} ${_record.currency ?? 'XOF'}',
                  Icons.price_check_rounded),
            if (_record.csReference != null)
              _row('Reference',        _record.csReference!,      Icons.fingerprint_rounded, copyable: true),
            if (_record.csCreatedAt != null)
              _row('Provider Date',    _record.csCreatedAt!,      Icons.calendar_today_rounded),
            // any extra unknown keys
            ..._rawRows(_latestCheckStatus ?? {}, skip: {
              'status','message','transaction_id','account_number',
              'invoice_number','amount','montant','fees','total',
              'created_at','reference',
            }),
          ]),
          const SizedBox(height: 16),
        ],

        // 5 ── Callback (if received from LAM)
        if (_record.callbackData != null) ...[
          _card('Callback Response', [
            ..._rawRows(_record.callbackData!, skip: {}),
          ]),
          const SizedBox(height: 16),
        ],

        // 6 ── Date & Time
        _card('Date & Time', [
          _row('Initiated',
              _record.createdAt != null ? _fmt(_record.createdAt!) : '—',
              Icons.calendar_today_rounded),
          if (_record.updatedAt != null && _record.updatedAt != _record.createdAt)
            _row('Last Updated', _fmt(_record.updatedAt!), Icons.update_rounded),
        ]),
        const SizedBox(height: 24),

        // Copy TX ID
        if (_record.lamTransactionId != null)
          _copyButton('Copy Transaction ID', _record.lamTransactionId!),

        // Refresh button (always visible at bottom for pending)
        if (_record.isPending) ...[
          const SizedBox(height: 12),
          _refreshButton(),
        ],
      ]),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────

  Widget _pendingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 1.2),
      ),
      child: Row(children: [
        Icon(Icons.hourglass_top_rounded,
            color: Colors.orange.shade700, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'payment_is_being_processed_by_the_provider_tap_refresh_to_check_for_updates'.tr,
            style: TextStyle(color: Colors.orange.shade800,
                fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
          ),
        ),
      ]),
    );
  }

  Widget _refreshButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _refreshing ? null : _refreshStatus,
        icon: _refreshing
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Icon(Icons.refresh_rounded, size: 20),
        label: Text(
          _refreshing ? 'Checking…' : 'Refresh Status',
          style: const TextStyle(
              fontWeight: FontWeight.w800, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: _refreshing ? 0 : 4,
          shadowColor: _blue.withValues(alpha: 0.35),
        ),
      ),
    );
  }

  Map<String, dynamic>? get _latestCheckStatus =>
      _record.paymentResponse?['check_status'] as Map<String, dynamic>?;

  Widget _card(String title, List<Widget> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: _grey, letterSpacing: 0.8)),
        const SizedBox(height: 16),
        ...rows,
      ]),
    );
  }

  Widget _row(String label, String value, IconData icon,
      {bool copyable = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: _surface, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: _blue, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(label,
                style: const TextStyle(color: _grey, fontSize: 11,
                    fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    color: valueColor ?? _dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.4)),
          ]),
        ),
        if (copyable)
          GestureDetector(
            onTap: () => _copy(value),
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.copy_rounded, size: 16, color: _blue),
            ),
          ),
      ]),
    );
  }

  Widget _totalDeductedRow(double total, String currency) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _blue.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _blue.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: _blue, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('total_deducted'.tr,
                  style: TextStyle(color: _grey, fontSize: 11,
                      fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text('${total.toStringAsFixed(0)} $currency',
                  style: const TextStyle(color: _blue, fontSize: 15,
                      fontWeight: FontWeight.w900)),
            ]),
          ),
        ]),
      ),
    );
  }

  List<Widget> _rawRows(Map<String, dynamic> map,
      {required Set<String> skip}) {
    final rows = <Widget>[];
    map.forEach((key, value) {
      if (skip.contains(key) || value == null) return;
      final label = key
          .replaceAll('_', ' ')
          .split(' ')
          .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
      final strVal = (value is Map || value is List)
          ? _prettyJson(value)
          : value.toString();
      rows.add(_row(label, strVal, Icons.data_object_rounded));
    });
    return rows;
  }

  String _prettyJson(dynamic v) {
    if (v is Map) {
      return v.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    }
    if (v is List) return v.map((e) => '• $e').join('\n');
    return v.toString();
  }

  Widget _copyButton(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _copy(value),
        icon: const Icon(Icons.copy_rounded, size: 18),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        style: OutlinedButton.styleFrom(
          foregroundColor: _blue,
          side: const BorderSide(color: _blue, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    Get.snackbar('Copied', 'Copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _blue,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2));
  }

  String _fmt(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $h:$m';
  }
}
