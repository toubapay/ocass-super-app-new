import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/insurance/controllers/insurance_controller.dart';
import 'package:sixam_mart/features/insurance/domain/models/insurance_models.dart';
import 'package:sixam_mart/features/insurance/screens/wizard/vehicle_value_screen.dart';
import 'package:sixam_mart/features/insurance/widgets/insurance_fields.dart';
import 'package:sixam_mart/util/dimensions.dart';

/// Identification: the policyholder (prefilled from the driving licence
/// reading) and what identifies the vehicle on the attestation. Rating
/// details (power, seats, age, usage) are on the previous step.
class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final InsuranceDraft _draft;
  late final TextEditingController _plate, _chassis, _brand, _model, _last, _first, _phone, _email, _license;

  @override
  void initState() {
    super.initState();
    _draft = Get.find<InsuranceController>().draft ?? InsuranceDraft(isMoto: false);
    String text(Object? v) => v?.toString() ?? '';
    _plate = TextEditingController(text: text(_draft.registrationNumber));
    _chassis = TextEditingController(text: text(_draft.chassisNumber));
    _brand = TextEditingController(text: text(_draft.brand));
    _model = TextEditingController(text: text(_draft.model));
    _last = TextEditingController(text: text(_draft.lastName));
    _first = TextEditingController(text: text(_draft.firstName));
    _phone = TextEditingController(text: text(_draft.phone));
    _email = TextEditingController(text: text(_draft.email));
    _license = TextEditingController(text: text(_draft.licenseNumber));
  }

  @override
  void dispose() {
    for (final c in [_plate, _chassis, _brand, _model, _last, _first, _phone, _email, _license]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFirstRegistration() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.firstRegistration ??
          DateTime(now.year - (VehicleAge.byCode(_draft.ageCode)?.yearsAgo ?? 5)),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) setState(() => _draft.firstRegistration = picked);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.birthDate ?? DateTime(now.year - 30),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 16, now.month, now.day),
    );
    if (picked != null) setState(() => _draft.birthDate = picked);
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    String? text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    _draft
      ..licenseNumber = text(_license)?.toUpperCase()
      ..registrationNumber = text(_plate)?.toUpperCase()
      ..chassisNumber = text(_chassis)?.toUpperCase()
      ..brand = text(_brand)
      ..model = text(_model)
      ..lastName = text(_last)
      ..firstName = text(_first)
      ..phone = text(_phone)
      ..email = text(_email);
    Get.to(() => const VehicleValueScreen());
  }

  @override
  Widget build(BuildContext context) {
    final moto = _draft.isMoto;
    final options = Get.find<InsuranceController>().options;
    return Scaffold(
      appBar: CustomAppBar(title: 'ins_identification'.tr),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), children: [
          InsuranceSection(title: 'ins_policyholder'.tr, hint: 'ins_policyholder_hint'.tr),
          Row(children: [
            Expanded(child: InsuranceTextField(controller: _last, label: 'ins_last_name'.tr, required: true, caps: true)),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: InsuranceTextField(controller: _first, label: 'ins_first_name'.tr, required: true)),
          ]),
          InsuranceTextField(controller: _license, label: 'ins_license_number'.tr, caps: true),
          InsuranceDateField(label: 'ins_birth_date'.tr, value: _draft.birthDate, onTap: _pickBirthDate),
          InsuranceTextField(controller: _phone, label: 'ins_phone'.tr, keyboard: TextInputType.phone),
          InsuranceTextField(controller: _email, label: 'ins_email'.tr, keyboard: TextInputType.emailAddress),
          InsuranceSection(title: 'ins_identification'.tr, hint: 'ins_identification_hint'.tr),
          InsuranceTextField(
            controller: _plate,
            label: 'ins_registration_number'.tr,
            caps: true,
            validator: (v) {
              if ((v ?? '').trim().isEmpty && (moto || _chassis.text.trim().isEmpty)) {
                return moto ? 'ins_required'.tr : 'ins_plate_or_chassis_required'.tr;
              }
              return null;
            },
          ),
          if (!moto) InsuranceTextField(controller: _chassis, label: 'ins_chassis_vin'.tr, caps: true, helper: 'ins_chassis_hint'.tr),
          Row(children: [
            Expanded(child: InsuranceTextField(controller: _brand, label: 'ins_brand'.tr, required: true, caps: true)),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: InsuranceTextField(controller: _model, label: 'ins_model'.tr, required: true, caps: true)),
          ]),
          InsuranceDateField(
            label: 'ins_first_registration_optional'.tr,
            value: _draft.firstRegistration,
            onTap: _pickFirstRegistration,
          ),
          InsuranceDropdown<String>(
            label: 'ins_fuel'.tr,
            value: _draft.fuel,
            items: {for (final f in options?.fuels ?? <InsuranceChoice>[]) f.code: f.label}..putIfAbsent('petrol', () => 'Essence'),
            onChanged: (v) => setState(() => _draft.fuel = v ?? 'petrol'),
          ),
        ]),
      ),
      bottomNavigationBar: InsuranceStepBar(child: CustomButton(buttonText: 'ins_next'.tr, onPressed: _next)),
    );
  }
}
