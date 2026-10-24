import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/features/insurance/domain/models/insurance_models.dart';

/// XOF has no minor unit: whole francs with a space as thousands separator.
String fcfa(num amount) => '${NumberFormat('#,##0', 'en_US').format(amount.round()).replaceAll(',', ' ')} F CFA';

/// "2026-10-25" -> "25/10/2026".
String insuranceDate(String? isoDate) {
  final date = DateTime.tryParse(isoDate ?? '');
  return date == null ? '-' : DateFormat('dd/MM/yyyy').format(date);
}

String policyStatusLabel(String status) => 'ins_status_$status'.tr;

Color policyStatusColor(String status) {
  switch (status) {
    case InsurancePolicy.active:
      return const Color(0xFF1E8E3E);
    case InsurancePolicy.awaitingIssuance:
    case InsurancePolicy.pendingPayment:
      return const Color(0xFFE37400);
    case InsurancePolicy.paymentFailed:
    case InsurancePolicy.issuanceFailed:
      return const Color(0xFFD93025);
    default:
      return Colors.grey;
  }
}

class PolicyStatusChip extends StatelessWidget {
  final String status;
  const PolicyStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = policyStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(policyStatusLabel(status), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
