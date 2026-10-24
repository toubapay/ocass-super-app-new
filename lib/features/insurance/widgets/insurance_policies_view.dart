import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/insurance/controllers/insurance_controller.dart';
import 'package:sixam_mart/features/insurance/domain/models/insurance_models.dart';
import 'package:sixam_mart/features/insurance/screens/insurance_policy_screen.dart';
import 'package:sixam_mart/features/insurance/widgets/insurance_format.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// "Mes polices": the customer's policies, newest first.
class InsurancePoliciesView extends StatefulWidget {
  const InsurancePoliciesView({super.key});

  @override
  State<InsurancePoliciesView> createState() => _InsurancePoliciesViewState();
}

class _InsurancePoliciesViewState extends State<InsurancePoliciesView> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<InsuranceController>();
    if (controller.policies == null) controller.loadPolicies();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InsuranceController>(builder: (controller) {
      final policies = controller.policies;
      if (policies == null) return const Center(child: CircularProgressIndicator());
      return RefreshIndicator(
        onRefresh: controller.loadPolicies,
        child: policies.isEmpty
            ? ListView(children: [
                const SizedBox(height: 120),
                Icon(Icons.shield_outlined, size: 64, color: Theme.of(context).disabledColor),
                const SizedBox(height: 12),
                Text('ins_no_policies'.tr, textAlign: TextAlign.center, style: robotoMedium),
              ])
            : ListView.separated(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                itemCount: policies.length,
                separatorBuilder: (_, __) => const SizedBox(height: Dimensions.paddingSizeSmall),
                itemBuilder: (_, i) => _PolicyTile(policy: policies[i]),
              ),
      );
    });
  }
}

class _PolicyTile extends StatelessWidget {
  final InsurancePolicy policy;
  const _PolicyTile({required this.policy});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      onTap: () async {
        await Get.to(() => InsurancePolicyScreen(policyId: policy.id));
        Get.find<InsuranceController>().loadPolicies();
      },
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(policy.providerName ?? '', style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis)),
            PolicyStatusChip(status: policy.status),
          ]),
          const SizedBox(height: 6),
          if (policy.policyNumber != null)
            Text('${'ins_attestation_number'.tr}: ${policy.policyNumber}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
          Text('${insuranceDate(policy.startDate)} → ${insuranceDate(policy.endDate)}',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
          const SizedBox(height: 6),
          Text(fcfa(policy.amount), style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
        ]),
      ),
    );
  }
}
