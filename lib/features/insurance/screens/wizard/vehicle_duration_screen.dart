import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/insurance/controllers/insurance_controller.dart';
import 'package:sixam_mart/features/insurance/domain/models/insurance_models.dart';
import 'package:sixam_mart/features/insurance/screens/insurance_quotes_screen.dart';
import 'package:sixam_mart/features/insurance/widgets/insurance_fields.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Duration, start date and (optionally) one coverage level, then every
/// insurer's offer, cheapest first.
class VehicleDurationScreen extends StatefulWidget {
  const VehicleDurationScreen({super.key});

  @override
  State<VehicleDurationScreen> createState() => _VehicleDurationScreenState();
}

class _VehicleDurationScreenState extends State<VehicleDurationScreen> {
  Future<void> _pickStart(InsuranceDraft draft) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.startDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => draft.startDate = picked);
  }

  Future<void> _compare(InsuranceDraft draft) async {
    final ok = await Get.find<InsuranceController>().requestQuotes(draft.toRequest());
    if (ok) Get.to(() => const InsuranceQuotesScreen());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InsuranceController>(builder: (controller) {
      final draft = controller.draft!;
      final durations = controller.options?.durations ?? const [1, 3, 6, 12];
      final primary = Theme.of(context).primaryColor;
      return Scaffold(
        appBar: CustomAppBar(title: 'ins_duration_title'.tr),
        body: ListView(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), children: [
          InsuranceSection(title: 'ins_duration'.tr),
          for (final months in durations)
            Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: InkWell(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                onTap: () => setState(() => draft.durationMonths = months),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: draft.durationMonths == months ? primary : Theme.of(context).disabledColor.withValues(alpha: 0.3), width: draft.durationMonths == months ? 2 : 1),
                  ),
                  child: Row(children: [
                    Icon(draft.durationMonths == months ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: draft.durationMonths == months ? primary : Theme.of(context).disabledColor),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text('$months ${'ins_months'.tr}', style: robotoMedium),
                  ]),
                ),
              ),
            ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          InsuranceDateField(label: 'ins_start_date'.tr, value: draft.startDate, onTap: () => _pickStart(draft)),
          InsuranceDropdown<String?>(
            label: 'ins_coverage_level'.tr,
            value: draft.coverageLevel,
            items: {null: 'ins_all_levels'.tr, for (final l in controller.options?.coverageLevels ?? <InsuranceChoice>[]) l.code: l.label},
            onChanged: (v) => setState(() => draft.coverageLevel = v),
          ),
        ]),
        bottomNavigationBar: InsuranceStepBar(
          child: CustomButton(
            buttonText: 'ins_compare_offers'.tr,
            isLoading: controller.isLoading,
            onPressed: controller.isLoading ? null : () => _compare(draft),
          ),
        ),
      );
    });
  }
}
