import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/insurance/controllers/insurance_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Asks only for what the insurer said is missing (e.g. `vehicle.chassis_number`)
/// and saves it on the quote request, without re-quoting. Pops `true` when saved.
class MissingDetailsSheet extends StatefulWidget {
  final List<String> missingFields;
  const MissingDetailsSheet({super.key, required this.missingFields});

  @override
  State<MissingDetailsSheet> createState() => _MissingDetailsSheetState();
}

class _MissingDetailsSheetState extends State<MissingDetailsSheet> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  DateTime? _firstRegistration;

  static const _dateField = 'vehicle.first_registration_date';

  // A missing last name is reported as owner.last_name; ask for both names.
  List<String> get _fields {
    final fields = [...widget.missingFields];
    if (fields.contains('owner.last_name') && !fields.contains('owner.first_name')) fields.add('owner.first_name');
    return fields;
  }

  @override
  void initState() {
    super.initState();
    for (final field in _fields) {
      if (field != _dateField) _controllers[field] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fields.contains(_dateField) && _firstRegistration == null) return;

    final body = <String, Map<String, dynamic>>{'vehicle': {}, 'owner': {}};
    _controllers.forEach((field, controller) {
      final parts = field.split('.');
      body[parts.first]![parts.last] = controller.text.trim();
    });
    if (_firstRegistration != null) {
      body['vehicle']!['first_registration_date'] = DateFormat('yyyy-MM-dd').format(_firstRegistration!);
    }
    body.removeWhere((_, v) => v.isEmpty);

    if (await Get.find<InsuranceController>().updateDetails(body)) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: Dimensions.paddingSizeLarge,
        right: Dimensions.paddingSizeLarge,
        top: Dimensions.paddingSizeLarge,
        bottom: MediaQuery.of(context).viewInsets.bottom + Dimensions.paddingSizeLarge,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ins_missing_details_title'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: 4),
            Text('ins_missing_details_hint'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            for (final field in _fields)
              Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: field == _dateField ? _datePicker(context) : _textField(field),
              ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            GetBuilder<InsuranceController>(
              builder: (controller) => CustomButton(
                buttonText: 'ins_continue_to_payment'.tr,
                isLoading: controller.isLoading,
                onPressed: controller.isLoading ? null : _save,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _textField(String field) {
    return TextFormField(
      controller: _controllers[field],
      textCapitalization: field.endsWith('number') || field.endsWith('last_name') ? TextCapitalization.characters : TextCapitalization.words,
      decoration: InputDecoration(labelText: 'ins_field_${field.split('.').last}'.tr, border: const OutlineInputBorder(), isDense: true),
      validator: (v) => (v ?? '').trim().isEmpty ? 'ins_required'.tr : null,
    );
  }

  Widget _datePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(context: context, initialDate: DateTime(now.year - 5), firstDate: DateTime(1950), lastDate: now);
        if (picked != null) setState(() => _firstRegistration = picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'ins_first_registration_date'.tr,
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
          errorText: _firstRegistration == null ? 'ins_required'.tr : null,
        ),
        child: Text(_firstRegistration == null ? 'ins_choose_date'.tr : DateFormat('dd/MM/yyyy').format(_firstRegistration!)),
      ),
    );
  }
}
