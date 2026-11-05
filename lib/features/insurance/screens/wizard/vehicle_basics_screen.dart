import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/insurance/controllers/insurance_controller.dart';
import 'package:sixam_mart/features/insurance/domain/models/insurance_models.dart';
import 'package:sixam_mart/features/insurance/screens/wizard/vehicle_info_screen.dart';
import 'package:sixam_mart/features/insurance/widgets/insurance_fields.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// "Informations du véhicule" as in Wave: what the price depends on, in big
/// grey boxes. Power and seats (cylinder for a moto), the vehicle's age and
/// its usage, both picked in a sheet. Usage is Personnel or Professionnel.
class VehicleBasicsScreen extends StatefulWidget {
  final LicenseExtraction? license;
  final bool readingAttempted;
  const VehicleBasicsScreen({super.key, this.license, this.readingAttempted = false});

  @override
  State<VehicleBasicsScreen> createState() => _VehicleBasicsScreenState();
}

class _VehicleBasicsScreenState extends State<VehicleBasicsScreen> {
  late final InsuranceDraft _draft = Get.find<InsuranceController>().draft ?? InsuranceDraft(isMoto: false);
  late final _power = TextEditingController(text: _draft.fiscalPower?.toString() ?? '');
  late final _cylinder = TextEditingController(text: _draft.cylinder?.toString() ?? '');
  late final _seats = TextEditingController(text: _draft.seats?.toString() ?? '');

  @override
  void dispose() {
    _power.dispose();
    _cylinder.dispose();
    _seats.dispose();
    super.dispose();
  }

  bool get _valid =>
      (_draft.isMoto ? int.tryParse(_cylinder.text) != null : int.tryParse(_power.text) != null) && _draft.ageCode != null && _draft.usageChoice != null;

  void _next() {
    _draft
      ..fiscalPower = int.tryParse(_power.text)
      ..cylinder = int.tryParse(_cylinder.text)
      ..seats = int.tryParse(_seats.text);
    Get.to(() => const VehicleInfoScreen());
  }

  Future<void> _pickAge() async {
    final code = await Get.bottomSheet<String>(
      _Sheet(
        title: 'ins_vehicle_age'.tr,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final a in VehicleAge.all)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(a.labelKey.tr, style: robotoRegular.copyWith(fontSize: 18)),
              trailing: _draft.ageCode == a.code ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
              onTap: () => Get.back(result: a.code),
            ),
        ]),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    if (code != null) setState(() => _draft.ageCode = code);
  }

  Future<void> _pickUsage() async {
    final choice = await Get.bottomSheet<String>(
      _Sheet(
        title: 'ins_usage'.tr,
        child: Row(children: [
          Expanded(
            child: _UsageChoice(
              label: 'ins_usage_personal'.tr,
              icon: _draft.isMoto ? Icons.two_wheeler : Icons.directions_car_filled,
              background: const Color(0xFFE3F2FD),
              color: const Color(0xFF1E5EFF),
              onTap: () => Get.back(result: 'personal'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _UsageChoice(
              label: 'ins_usage_professional'.tr,
              icon: Icons.local_shipping,
              background: const Color(0xFFFDE3B3),
              color: const Color(0xFF8A5A12),
              onTap: () => Get.back(result: 'professional'),
            ),
          ),
        ]),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    if (choice != null) setState(() => _draft.setUsageChoice(choice));
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.license;
    final readOk = l != null && l.filledCount > 0;
    return Scaffold(
      appBar: AppBar(title: Text('ins_vehicle_info'.tr), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), children: [
        if (widget.readingAttempted)
          _Banner(
            ok: readOk,
            text: !readOk
                ? 'ins_license_read_none'.tr
                : [
                    '${'ins_license_read'.tr} ${[l.firstName, l.lastName].whereType<String>().join(' ')}'.trim(),
                    if (l.licenseNumber != null) 'n° ${l.licenseNumber}',
                  ].join(' · '),
          ),
        if (l != null && l.expired) _Banner(ok: false, text: 'ins_license_expired'.tr),
        if (_draft.isMoto)
          _Box(label: 'ins_cylinder'.tr, child: _number(_cylinder))
        else ...[
          _Box(label: 'ins_fiscal_power'.tr, child: _number(_power)),
          _Box(label: 'ins_seats'.tr, child: _number(_seats)),
        ],
        _Box(
          label: 'ins_vehicle_age'.tr,
          value: VehicleAge.byCode(_draft.ageCode)?.labelKey.tr,
          onTap: _pickAge,
        ),
        _Box(
          label: 'ins_usage'.tr,
          value: _draft.usageChoice == null ? null : (_draft.usageChoice == 'professional' ? 'ins_usage_professional'.tr : 'ins_usage_personal'.tr),
          onTap: _pickUsage,
        ),
      ]),
      bottomNavigationBar: InsuranceStepBar(child: CustomButton(buttonText: 'ins_next'.tr, onPressed: _valid ? _next : null)),
    );
  }

  Widget _number(TextEditingController c) => TextField(
        controller: c,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (_) => setState(() {}),
        style: robotoRegular.copyWith(fontSize: 19),
        decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.only(top: 4)),
      );
}

/// Wave's grey box with a small label; tappable ones open a sheet.
class _Box extends StatelessWidget {
  final String label;
  final Widget? child;
  final String? value;
  final VoidCallback? onTap;
  const _Box({required this.label, this.child, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).hintColor;
    final empty = onTap != null && value == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: const Color(0xFFECECEF),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.fromLTRB(18, 10, 14, 10),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (!empty) Text(label, style: robotoRegular.copyWith(fontSize: 14, color: hint)),
                  if (child != null) child! else Text(value ?? label, style: robotoRegular.copyWith(fontSize: 19, color: empty ? hint : null)),
                ]),
              ),
              if (onTap != null) Icon(Icons.keyboard_arrow_down, color: hint, size: 28),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final bool ok;
  final String text;
  const _Banner({required this.ok, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = ok ? const Color(0xFF136C34) : Colors.orange.shade800;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icon(ok ? Icons.auto_awesome : Icons.edit_note, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: robotoMedium.copyWith(color: color))),
      ]),
    );
  }
}

class _Sheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _Sheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22, 16, 22, 28 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(child: Text(title, style: robotoBold.copyWith(fontSize: 21))),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
        ]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

class _UsageChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color color;
  final VoidCallback onTap;
  const _UsageChoice({required this.label, required this.icon, required this.background, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(children: [
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(18)),
          child: Icon(icon, size: 52, color: color),
        ),
        const SizedBox(height: 12),
        Text(label, style: robotoMedium.copyWith(fontSize: 18)),
      ]),
    );
  }
}
