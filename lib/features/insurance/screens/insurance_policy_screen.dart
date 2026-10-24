import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/insurance/controllers/insurance_controller.dart';
import 'package:sixam_mart/features/insurance/domain/models/insurance_models.dart';
import 'package:sixam_mart/features/insurance/screens/insurance_screen.dart';
import 'package:sixam_mart/features/insurance/widgets/insurance_format.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// One policy: status, period, amount, and the attestation and carte brune links.
class InsurancePolicyScreen extends StatefulWidget {
  final int policyId;
  final bool fromPayment;
  const InsurancePolicyScreen({super.key, required this.policyId, this.fromPayment = false});

  @override
  State<InsurancePolicyScreen> createState() => _InsurancePolicyScreenState();
}

class _InsurancePolicyScreenState extends State<InsurancePolicyScreen> {
  InsurancePolicy? _policy;
  bool _loading = true;
  Timer? _poll;
  int _polls = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final policy = await Get.find<InsuranceController>().loadPolicy(widget.policyId);
    if (!mounted) return;
    setState(() {
      _policy = policy ?? _policy;
      _loading = false;
    });
    // PayDunya's confirmation and the attestation can arrive a few seconds
    // after the customer is sent back: keep checking for a short while.
    final waiting = policy != null && (policy.isWaitingForPayment || policy.status == InsurancePolicy.awaitingIssuance);
    if (widget.fromPayment && waiting && _polls < 10) {
      _polls++;
      _poll = Timer(const Duration(seconds: 3), _load);
    }
  }

  Future<void> _open(String? url) async {
    if (url == null || url.isEmpty) return;
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      showCustomSnackBar('ins_cannot_open_link'.tr);
    }
  }

  void _back() {
    if (widget.fromPayment) {
      Get.find<InsuranceController>().loadPolicies(reload: true);
      Get.off(() => const InsuranceScreen(initialTab: 1));
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final policy = _policy;
    return PopScope(
      canPop: !widget.fromPayment,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'ins_my_policy'.tr, onBackPressed: _back),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : policy == null
                ? Center(child: TextButton(onPressed: _load, child: Text('ins_retry'.tr)))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), children: [
                      _header(context, policy),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      _statusMessage(context, policy),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      _details(context, policy),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      if (policy.certificateUrl != null)
                        CustomButton(buttonText: 'ins_view_attestation'.tr, icon: Icons.verified_outlined, onPressed: () => _open(policy.certificateUrl)),
                      if (policy.carteBruneUrl != null) ...[
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        CustomButton(
                          buttonText: 'ins_view_carte_brune'.tr,
                          icon: Icons.description_outlined,
                          transparent: true,
                          isBorder: true,
                          onPressed: () => _open(policy.carteBruneUrl),
                        ),
                      ],
                    ]),
                  ),
      ),
    );
  }

  Widget _header(BuildContext context, InsurancePolicy policy) {
    return Row(children: [
      Icon(Icons.shield_outlined, size: 40, color: Theme.of(context).primaryColor),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(policy.providerName ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          if (policy.productName != null) Text(policy.productName!, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
        ]),
      ),
      PolicyStatusChip(status: policy.status),
    ]);
  }

  Widget _statusMessage(BuildContext context, InsurancePolicy policy) {
    final message = 'ins_status_hint_${policy.status}'.tr;
    final color = policyStatusColor(policy.status);
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      child: Row(children: [
        if (policy.isWaitingForPayment || policy.status == InsurancePolicy.awaitingIssuance)
          const Padding(padding: EdgeInsets.only(right: 8), child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))),
        Expanded(child: Text(message, style: robotoRegular.copyWith(color: color))),
      ]),
    );
  }

  Widget _details(BuildContext context, InsurancePolicy policy) {
    final vehicle = policy.vehicle ?? {};
    final rows = <MapEntry<String, String>>[
      if (policy.policyNumber != null) MapEntry('ins_attestation_number'.tr, policy.policyNumber!),
      MapEntry('ins_period'.tr, '${insuranceDate(policy.startDate)} → ${insuranceDate(policy.endDate)}'),
      MapEntry('ins_amount_paid'.tr, fcfa(policy.amount)),
      if (vehicle.isNotEmpty)
        MapEntry('ins_vehicle'.tr, [vehicle['brand'], vehicle['model'], vehicle['registration_number'] ?? vehicle['chassis_number']].whereType<Object>().join(' · ')),
    ];
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(row.key, style: robotoRegular.copyWith(color: Theme.of(context).hintColor))),
              Expanded(child: Text(row.value, textAlign: TextAlign.end, style: robotoMedium)),
            ]),
          ),
      ]),
    );
  }
}
