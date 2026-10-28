import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/features/insurance/controllers/insurance_controller.dart';
import 'package:sixam_mart/features/insurance/screens/insurance_quotes_screen.dart';
import 'package:sixam_mart/features/insurance/widgets/insurance_policies_view.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Motor insurance: a quote form compared across every insurer, and the
/// customer's policies ("Mes polices").
class InsuranceScreen extends StatefulWidget {
  final int initialTab;
  const InsuranceScreen({super.key, this.initialTab = 0});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    if (AuthHelper.isLoggedIn()) {
      Get.find<InsuranceController>().loadOptions();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthHelper.isLoggedIn()) {
      return Scaffold(
        appBar: CustomAppBar(title: 'ins_insurance'.tr),
        body: NotLoggedInScreen(callBack: (_) {
          Get.find<InsuranceController>().loadOptions();
          setState(() {});
        }),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'ins_insurance'.tr),
      body: Column(children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          indicatorColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Theme.of(context).disabledColor,
          tabs: [Tab(text: 'ins_new_quote'.tr), Tab(text: 'ins_my_policies'.tr)],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [_QuoteForm(), InsurancePoliciesView()],
          ),
        ),
      ]),
    );
  }
}

class _QuoteForm extends StatefulWidget {
  const _QuoteForm();

  @override
  State<_QuoteForm> createState() => _QuoteFormState();
}

class _QuoteFormState extends State<_QuoteForm> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _plate = TextEditingController();
  final _chassis = TextEditingController();
  final _fiscalPower = TextEditingController();
  final _cylinder = TextEditingController();
  final _seats = TextEditingController();
  final _value = TextEditingController();
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  String _usage = 'private';
  String _fuel = 'petrol';
  int _duration = 12;
  String? _coverageLevel;
  DateTime? _firstRegistration;
  DateTime _startDate = DateTime.now();

  bool get _isMoto => _usage == 'motorcycle';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final profile = Get.find<ProfileController>();
    _prefillPolicyholder();
    // Opened before the profile loaded (e.g. straight from a link or a cold
    // start): fetch it, then fill whatever the customer has not typed yet.
    if (profile.userInfoModel == null) {
      profile.getUserInfo().then((_) {
        if (mounted) setState(_prefillPolicyholder);
      });
    }
  }

  /// Fills empty policyholder fields from the profile; never overwrites typing.
  void _prefillPolicyholder() {
    final user = Get.find<ProfileController>().userInfoModel;
    if (user == null) return;
    void fill(TextEditingController controller, String? value) {
      if (controller.text.trim().isEmpty && (value ?? '').isNotEmpty) controller.text = value!;
    }
    fill(_lastName, user.lName);
    fill(_firstName, user.fName);
    fill(_phone, user.phone);
    fill(_email, user.email);
  }

  @override
  void dispose() {
    for (final c in [_brand, _model, _plate, _chassis, _fiscalPower, _cylinder, _seats, _value, _lastName, _firstName, _phone, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate({required bool firstRegistration}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: firstRegistration ? (_firstRegistration ?? DateTime(now.year - 5)) : _startDate,
      firstDate: firstRegistration ? DateTime(1950) : DateTime(now.year, now.month, now.day),
      lastDate: firstRegistration ? now : now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => firstRegistration ? _firstRegistration = picked : _startDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_firstRegistration == null) {
      showCustomSnackBar('ins_first_registration_required'.tr);
      return;
    }
    final day = DateFormat('yyyy-MM-dd');
    String? text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    int? number(TextEditingController c) => int.tryParse(c.text.replaceAll(RegExp(r'\D'), ''));

    final vehicle = <String, dynamic>{
      'usage': _usage,
      'brand': text(_brand),
      'model': text(_model),
      'registration_number': text(_plate),
      'chassis_number': text(_chassis),
      'fiscal_power': _isMoto ? null : number(_fiscalPower),
      'cylinder': _isMoto ? number(_cylinder) : null,
      'seats': number(_seats),
      'value': number(_value),
      'fuel': _fuel,
      'first_registration_date': day.format(_firstRegistration!),
    }..removeWhere((_, v) => v == null);
    final owner = <String, dynamic>{
      'last_name': text(_lastName),
      'first_name': text(_firstName),
      'phone': text(_phone),
      'email': text(_email),
    }..removeWhere((_, v) => v == null);

    final ok = await Get.find<InsuranceController>().requestQuotes({
      'vehicle': vehicle,
      'owner': owner,
      'duration_months': _duration,
      'start_date': day.format(_startDate),
      'coverage_level': _coverageLevel,
    });
    if (ok) Get.to(() => const InsuranceQuotesScreen());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<InsuranceController>(builder: (controller) {
      final options = controller.options;
      if (options == null) return const Center(child: CircularProgressIndicator());
      final digits = [FilteringTextInputFormatter.digitsOnly];

      return Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), children: [
          Text('ins_form_intro'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          _Section(title: 'ins_vehicle'.tr),
          _dropdown(
            label: 'ins_usage'.tr,
            value: _usage,
            items: {for (final u in options.usages) u.code: u.label},
            onChanged: (v) => setState(() => _usage = v!),
          ),
          Row(children: [
            Expanded(child: _field(_brand, 'ins_brand'.tr, required: true)),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: _field(_model, 'ins_model'.tr, required: true)),
          ]),
          Row(children: [
            Expanded(
              child: _isMoto
                  ? _field(_cylinder, 'ins_cylinder'.tr, required: true, keyboard: TextInputType.number, formatters: digits)
                  : _field(_fiscalPower, 'ins_fiscal_power'.tr, required: true, keyboard: TextInputType.number, formatters: digits),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: _field(_seats, 'ins_seats'.tr, keyboard: TextInputType.number, formatters: digits)),
          ]),
          _field(_plate, 'ins_registration_number'.tr, caps: true, validator: (v) {
            if ((v ?? '').trim().isEmpty && (_isMoto || _chassis.text.trim().isEmpty)) {
              return _isMoto ? 'ins_required'.tr : 'ins_plate_or_chassis_required'.tr;
            }
            return null;
          }),
          if (!_isMoto) _field(_chassis, 'ins_chassis_number'.tr, caps: true),
          _dropdown(
            label: 'ins_fuel'.tr,
            value: _fuel,
            items: {for (final f in options.fuels) f.code: f.label},
            onChanged: (v) => setState(() => _fuel = v!),
          ),
          _dateTile(
            label: 'ins_first_registration_date'.tr,
            value: _firstRegistration,
            onTap: () => _pickDate(firstRegistration: true),
          ),
          _field(_value, 'ins_vehicle_value'.tr, keyboard: TextInputType.number, formatters: digits, helper: 'ins_vehicle_value_hint'.tr),

          _Section(title: 'ins_cover'.tr),
          Text('ins_duration'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Wrap(spacing: 8, children: [
            for (final months in options.durations)
              ChoiceChip(
                label: Text('$months ${'ins_months'.tr}'),
                selected: _duration == months,
                onSelected: (_) => setState(() => _duration = months),
              ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _dateTile(label: 'ins_start_date'.tr, value: _startDate, onTap: () => _pickDate(firstRegistration: false)),
          _dropdown(
            label: 'ins_coverage_level'.tr,
            value: _coverageLevel,
            items: {null: 'ins_all_levels'.tr, for (final l in options.coverageLevels) l.code: l.label},
            onChanged: (v) => setState(() => _coverageLevel = v),
          ),

          _Section(title: 'ins_policyholder'.tr),
          Row(children: [
            Expanded(child: _field(_lastName, 'ins_last_name'.tr, required: true, caps: true)),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: _field(_firstName, 'ins_first_name'.tr, required: true)),
          ]),
          _field(_phone, 'ins_phone'.tr, keyboard: TextInputType.phone),
          _field(_email, 'ins_email'.tr, keyboard: TextInputType.emailAddress),

          const SizedBox(height: Dimensions.paddingSizeLarge),
          CustomButton(
            buttonText: 'ins_compare_offers'.tr,
            isLoading: controller.isLoading,
            onPressed: controller.isLoading ? null : _submit,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ]),
      );
    });
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool caps = false,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    String? helper,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: formatters,
        textCapitalization: caps ? TextCapitalization.characters : TextCapitalization.words,
        decoration: InputDecoration(labelText: label, helperText: helper, helperMaxLines: 2, border: const OutlineInputBorder(), isDense: true),
        validator: validator ?? (required ? (v) => (v ?? '').trim().isEmpty ? 'ins_required'.tr : null : null),
      ),
    );
  }

  Widget _dropdown({required String label, required String? value, required Map<String?, String> items, required ValueChanged<String?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      // DropdownButton inside a decorator rather than DropdownButtonFormField,
      // whose value/initialValue parameter differs between Flutter versions.
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
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

  Widget _dateTile({required String label, required DateTime? value, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true, suffixIcon: const Icon(Icons.calendar_today, size: 18)),
          child: Text(value == null ? 'ins_choose_date'.tr : DateFormat('dd/MM/yyyy').format(value)),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
      child: Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
    );
  }
}
