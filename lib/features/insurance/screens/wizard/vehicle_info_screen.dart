import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/insurance/controllers/insurance_controller.dart';
import 'package:sixam_mart/features/insurance/domain/models/insurance_models.dart';
import 'package:sixam_mart/features/insurance/screens/wizard/vehicle_value_screen.dart';
import 'package:sixam_mart/features/insurance/widgets/insurance_fields.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// The vehicle and policyholder details, prefilled from the carte grise
/// reading when there was one. Everything stays editable: the customer
/// confirms what the attestation will say.
class VehicleInfoScreen extends StatefulWidget {
  final int readFields;
  final bool readingAttempted;
  const VehicleInfoScreen({super.key, this.readFields = 0, this.readingAttempted = false});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final InsuranceDraft _draft;
  late final TextEditingController _power, _cylinder, _seats, _plate, _chassis, _brand, _model, _last, _first, _phone, _email;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _draft = Get.find<InsuranceController>().draft ?? InsuranceDraft(isMoto: false);
    String text(Object? v) => v?.toString() ?? '';
    _power = TextEditingController(text: text(_draft.fiscalPower));
    _cylinder = TextEditingController(text: text(_draft.cylinder));
    _seats = TextEditingController(text: text(_draft.seats));
    _plate = TextEditingController(text: text(_draft.registrationNumber));
    _chassis = TextEditingController(text: text(_draft.chassisNumber));
    _brand = TextEditingController(text: text(_draft.brand));
    _model = TextEditingController(text: text(_draft.model));
    _last = TextEditingController(text: text(_draft.lastName));
    _first = TextEditingController(text: text(_draft.firstName));
    _phone = TextEditingController(text: text(_draft.phone));
    _email = TextEditingController(text: text(_draft.email));
  }

  @override
  void dispose() {
    for (final c in [_power, _cylinder, _seats, _plate, _chassis, _brand, _model, _last, _first, _phone, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFirstRegistration() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.firstRegistration ?? DateTime(now.year - 5),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) setState(() => _draft.firstRegistration = picked);
  }

  void _next() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate() || _draft.firstRegistration == null) return;
    String? text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    int? number(TextEditingController c) => int.tryParse(c.text.trim());
    _draft
      ..fiscalPower = number(_power)
      ..cylinder = number(_cylinder)
      ..seats = number(_seats)
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
    // Two-wheelers have their own usage; the car list leaves it out.
    final carUsages = {
      for (final u in options?.usages ?? <InsuranceChoice>[])
        if (u.code != 'motorcycle') u.code: u.label,
    };
    if (carUsages.isEmpty) carUsages['private'] = 'Affaires et promenade';

    return Scaffold(
      appBar: CustomAppBar(title: 'ins_vehicle_info'.tr),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), children: [
          if (widget.readingAttempted) _ReadingBanner(readFields: widget.readFields),
          InsuranceSection(title: moto ? 'ins_your_motorbike'.tr : 'ins_your_car'.tr),
          if (moto) ...[
            Row(children: [
              Expanded(child: InsuranceTextField(controller: _cylinder, label: 'ins_cylinder'.tr, required: true, numeric: true)),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(child: InsuranceTextField(controller: _seats, label: 'ins_seats'.tr, numeric: true)),
            ]),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _draft.commercialUse,
              onChanged: (v) => setState(() => _draft.commercialUse = v),
              title: Text('ins_moto_commercial'.tr, style: robotoRegular),
              subtitle: Text('ins_moto_commercial_hint'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            ),
          ] else ...[
            Row(children: [
              Expanded(child: InsuranceTextField(controller: _power, label: 'ins_fiscal_power'.tr, required: true, numeric: true)),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(child: InsuranceTextField(controller: _seats, label: 'ins_seats'.tr, numeric: true)),
            ]),
            InsuranceDropdown<String>(
              label: 'ins_usage'.tr,
              value: _draft.usage,
              items: carUsages,
              onChanged: (v) => setState(() => _draft.usage = v ?? 'private'),
            ),
          ],
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
            label: 'ins_first_registration_date'.tr,
            value: _draft.firstRegistration,
            onTap: _pickFirstRegistration,
            showRequiredError: _submitted,
          ),
          InsuranceDropdown<String>(
            label: 'ins_fuel'.tr,
            value: _draft.fuel,
            items: {for (final f in options?.fuels ?? <InsuranceChoice>[]) f.code: f.label}..putIfAbsent('petrol', () => 'Essence'),
            onChanged: (v) => setState(() => _draft.fuel = v ?? 'petrol'),
          ),
          InsuranceSection(title: 'ins_policyholder'.tr),
          Row(children: [
            Expanded(child: InsuranceTextField(controller: _last, label: 'ins_last_name'.tr, required: true, caps: true)),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: InsuranceTextField(controller: _first, label: 'ins_first_name'.tr, required: true)),
          ]),
          InsuranceTextField(controller: _phone, label: 'ins_phone'.tr, keyboard: TextInputType.phone),
          InsuranceTextField(controller: _email, label: 'ins_email'.tr, keyboard: TextInputType.emailAddress),
        ]),
      ),
      bottomNavigationBar: InsuranceStepBar(child: CustomButton(buttonText: 'ins_next'.tr, onPressed: _next)),
    );
  }
}

class _ReadingBanner extends StatelessWidget {
  final int readFields;
  const _ReadingBanner({required this.readFields});

  @override
  Widget build(BuildContext context) {
    final ok = readFields > 0;
    final color = ok ? Theme.of(context).primaryColor : Colors.orange.shade800;
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      child: Row(children: [
        Icon(ok ? Icons.auto_awesome : Icons.edit_note, color: color),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Text(
            ok ? 'ins_read_ok'.trParams({'count': '$readFields'}) : 'ins_read_none'.tr,
            style: robotoRegular.copyWith(color: color),
          ),
        ),
      ]),
    );
  }
}
