import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/insurance/controllers/insurance_controller.dart';
import 'package:sixam_mart/features/insurance/screens/wizard/vehicle_duration_screen.dart';
import 'package:sixam_mart/features/insurance/widgets/insurance_fields.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// The vehicle's new and current value. Optional: third-party cover doesn't
/// need it, but theft, fire and all-risks offers are only priced with it.
class VehicleValueScreen extends StatefulWidget {
  const VehicleValueScreen({super.key});

  @override
  State<VehicleValueScreen> createState() => _VehicleValueScreenState();
}

class _VehicleValueScreenState extends State<VehicleValueScreen> {
  final _newValue = TextEditingController();
  final _value = TextEditingController();

  @override
  void initState() {
    super.initState();
    final draft = Get.find<InsuranceController>().draft;
    _newValue.text = draft?.newValue?.toString() ?? '';
    _value.text = draft?.value?.toString() ?? '';
  }

  @override
  void dispose() {
    _newValue.dispose();
    _value.dispose();
    super.dispose();
  }

  void _next() {
    final draft = Get.find<InsuranceController>().draft;
    if (draft != null) {
      draft.newValue = int.tryParse(_newValue.text.trim());
      draft.value = int.tryParse(_value.text.trim()) ?? draft.newValue;
    }
    Get.to(() => const VehicleDurationScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'ins_vehicle_value_title'.tr),
      body: ListView(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), children: [
        Text('ins_vehicle_value_intro'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        InsuranceTextField(controller: _newValue, label: 'ins_new_value'.tr, numeric: true, helper: 'ins_new_value_hint'.tr),
        InsuranceTextField(controller: _value, label: 'ins_vehicle_value'.tr, numeric: true, helper: 'ins_vehicle_value_hint'.tr),
      ]),
      bottomNavigationBar: InsuranceStepBar(child: CustomButton(buttonText: 'ins_next'.tr, onPressed: _next)),
    );
  }
}
