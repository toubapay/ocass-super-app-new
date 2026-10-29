import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Form building blocks shared by the insurance wizard steps.
class InsuranceSection extends StatelessWidget {
  final String title;
  final String? hint;
  const InsuranceSection({super.key, required this.title, this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(hint!, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
        ],
      ]),
    );
  }
}

class InsuranceTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final bool caps;
  final bool numeric;
  final TextInputType? keyboard;
  final String? helper;
  final String? Function(String?)? validator;

  const InsuranceTextField({
    super.key,
    required this.controller,
    required this.label,
    this.required = false,
    this.caps = false,
    this.numeric = false,
    this.keyboard,
    this.helper,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: TextFormField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : keyboard,
        inputFormatters: numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
        textCapitalization: caps ? TextCapitalization.characters : TextCapitalization.words,
        decoration: InputDecoration(labelText: label, helperText: helper, helperMaxLines: 2, border: const OutlineInputBorder(), isDense: true),
        validator: validator ?? (required ? (v) => (v ?? '').trim().isEmpty ? 'ins_required'.tr : null : null),
      ),
    );
  }
}

/// DropdownButton inside a decorator rather than DropdownButtonFormField,
/// whose value/initialValue parameter differs between Flutter versions.
class InsuranceDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  const InsuranceDropdown({super.key, required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: items.containsKey(value) ? value : items.keys.first,
            isExpanded: true,
            isDense: true,
            items: [for (final e in items.entries) DropdownMenuItem(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis))],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class InsuranceDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final bool showRequiredError;
  const InsuranceDateField({super.key, required this.label, required this.value, required this.onTap, this.showRequiredError = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
            errorText: showRequiredError && value == null ? 'ins_required'.tr : null,
          ),
          child: Text(value == null ? 'ins_choose_date'.tr : DateFormat('dd/MM/yyyy').format(value!)),
        ),
      ),
    );
  }
}

/// Bottom bar with the step's main button, kept above the keyboard and safe area.
class InsuranceStepBar extends StatelessWidget {
  final Widget child;
  const InsuranceStepBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      // CustomButton centres itself, which would fill the whole bottom bar slot.
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(mainAxisSize: MainAxisSize.min, children: [child]),
      ),
    );
  }
}
