import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/mobile_money/controllers/mobile_money_controller.dart';
import 'package:sixam_mart/features/mobile_money/domain/models/mobile_money_models.dart';
import 'package:sixam_mart/features/mobile_money/screens/mobile_money_success_screen.dart';
import 'package:sixam_mart/features/mobile_money/widgets/money_widgets.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/util/styles.dart';

String _group(num n) => n <= 0 ? '' : NumberFormat('#,##0', 'en_US').format(n.round()).replaceAll(',', ' ');

/// Step 2 as in Wave: "Montant envoyé" and "Montant reçu" are linked (either
/// one can be typed), the fee rule is spelled out, then Envoyer opens the
/// confirmation sheet and the secret code.
class MoneyAmountScreen extends StatefulWidget {
  final MoneyContact person;
  const MoneyAmountScreen({super.key, required this.person});

  @override
  State<MoneyAmountScreen> createState() => _MoneyAmountScreenState();
}

class _MoneyAmountScreenState extends State<MoneyAmountScreen> {
  final _sent = TextEditingController();
  final _received = TextEditingController();
  final _note = TextEditingController();
  double _amount = 0;

  MobileMoneyController get _c => Get.find<MobileMoneyController>();

  @override
  void dispose() {
    _sent.dispose();
    _received.dispose();
    _note.dispose();
    super.dispose();
  }

  void _typed(bool sentField, String text) {
    final n = double.tryParse(text.replaceAll(RegExp(r'\D'), '')) ?? 0;
    final other = sentField ? _received : _sent;
    final self = sentField ? _sent : _received;
    setState(() {
      _amount = n <= 0 ? 0 : (sentField ? _c.amountFromSent(n) : _c.amountFromReceived(n));
      final q = _amount > 0 ? _c.quote(_amount) : null;
      other.text = _group(q == null ? 0 : (sentField ? q.received : q.sent));
      final grouped = _group(n);
      self.value = TextEditingValue(text: grouped, selection: TextSelection.collapsed(offset: grouped.length));
    });
  }

  Future<void> _review() async {
    final preview = await _c.preview(localDigits(widget.person.phone), _amount);
    if (preview == null || !mounted) return;
    final confirmed = await Get.bottomSheet<bool>(_ConfirmSheet(preview: preview, note: _note.text.trim()), isScrollControlled: true, backgroundColor: Colors.transparent);
    if (confirmed != true) return;
    final transfer = await Get.bottomSheet<MoneyTransfer>(
      _PinSheet(preview: preview, phone: localDigits(widget.person.phone), note: _note.text.trim()),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    if (transfer != null) {
      _c.rememberRecipient(widget.person);
      Get.off(() => MobileMoneySuccessScreen(transfer: transfer));
    }
  }

  Widget _moneyField(String label, TextEditingController controller, bool sentField, {bool autofocus = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
        TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d ]'))],
          onChanged: (v) => _typed(sentField, v),
          style: robotoBold.copyWith(fontSize: 30),
          decoration: InputDecoration(
            hintText: '0',
            suffixText: 'F',
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _c.config!;
    final q = _amount > 0 ? _c.quote(_amount) : null;
    final balance = Get.find<ProfileController>().userInfoModel?.walletBalance ?? cfg.walletBalance;
    final tooLow = _amount > 0 && _amount < cfg.minAmount;
    final tooHigh = cfg.maxAmount > 0 && _amount > cfg.maxAmount;
    final short = q != null && q.sent > balance;
    final pct = cfg.feePercent;
    final rule = [
      if (pct > 0) '${pct.toStringAsFixed(pct.truncateToDouble() == pct ? 0 : 1).replaceAll('.', ',')} %',
      if (cfg.feeFixed > 0) '${_group(cfg.feeFixed)} F',
    ].join(' + ');
    final gold = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: CustomAppBar(title: 'mm_title'.tr),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 12), children: [
              Text('mm_to'.tr, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
              MoneyPersonRow(name: widget.person.name, phone: widget.person.phone, imageUrl: widget.person.imageFullUrl, onTap: () => Get.back()),
              const Divider(),
              _moneyField('mm_amount_sent'.tr, _sent, true, autofocus: true),
              _moneyField('mm_amount_received'.tr, _received, false),
              const SizedBox(height: 14),
              Text(
                rule.isEmpty ? 'mm_free_transfer'.tr : '${'mm_fee_rule'.tr} = $rule${cfg.maxFee > 0 ? '\n${'mm_max_fee'.tr} : ${_group(cfg.maxFee)} F' : ''}',
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(color: gold, fontSize: 18, height: 1.4),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _note,
                maxLength: 140,
                decoration: InputDecoration(labelText: 'mm_note_optional'.tr),
              ),
              if (tooLow) _notice('${'mm_minimum'.tr} ${fcfa(cfg.minAmount)}'),
              if (tooHigh) _notice('${'mm_maximum'.tr} ${fcfa(cfg.maxAmount)}'),
              if (short) _notice('mm_insufficient'.tr),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: GetBuilder<MobileMoneyController>(
              builder: (c) => CustomButton(
                buttonText: 'mm_send'.tr,
                isLoading: c.isLoading,
                onPressed: _amount > 0 && !tooLow && !tooHigh && !short ? _review : null,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _notice(String text) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFFFF7E6), borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: robotoRegular),
      );
}

class _SheetFrame extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SheetFrame({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22, 16, 22, 20 + MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(title, style: robotoBold.copyWith(fontSize: 21))),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
        ]),
        ...children,
      ]),
    );
  }
}

Widget _row(BuildContext context, String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Text(label, style: robotoRegular.copyWith(fontSize: 17, color: Theme.of(context).hintColor)),
        const SizedBox(width: 16),
        Expanded(child: Align(alignment: Alignment.centerRight, child: value)),
      ]),
    );

/// Wave's "Confirm Transaction" sheet: À, Envoyé, Frais, Reçu, Confirmer.
class _ConfirmSheet extends StatelessWidget {
  final MoneyPreview preview;
  final String note;
  const _ConfirmSheet({required this.preview, required this.note});

  @override
  Widget build(BuildContext context) {
    final p = preview;
    final value = robotoRegular.copyWith(fontSize: 17);
    return _SheetFrame(title: 'mm_confirm_title'.tr, children: [
      _row(
        context,
        'mm_to'.tr,
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(p.receiver.name, style: robotoBold.copyWith(fontSize: 17)),
          Text(formatLocal(localDigits(p.receiver.phone)), style: value),
        ]),
      ),
      _row(context, 'mm_sent'.tr, Text(fcfa(p.senderDebit), style: value)),
      _row(context, 'mm_fee'.tr, Text(p.fee > 0 ? fcfa(p.fee) : 'mm_free'.tr, style: value)),
      _row(context, 'mm_received'.tr, Text(fcfa(p.receiverCredit), style: value)),
      if (note.isNotEmpty) _row(context, 'mm_note'.tr, Text(note, style: value)),
      const SizedBox(height: 16),
      CustomButton(buttonText: 'mm_confirm'.tr, onPressed: () => Get.back(result: true)),
    ]);
  }
}

/// The 4-digit secret code, then the transfer itself.
class _PinSheet extends StatefulWidget {
  final MoneyPreview preview;
  final String phone;
  final String note;
  const _PinSheet({required this.preview, required this.phone, required this.note});

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  final _pin = TextEditingController();
  late final String _requestId = Get.find<MobileMoneyController>().newRequestId();

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final transfer = await Get.find<MobileMoneyController>().send(
      phone: widget.phone,
      amount: widget.preview.amount,
      pin: _pin.text,
      note: widget.note.isEmpty ? null : widget.note,
      requestId: _requestId,
    );
    if (transfer != null) {
      Get.back(result: transfer);
    } else {
      _pin.clear();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.preview;
    return _SheetFrame(title: 'mm_your_pin'.tr, children: [
      Text(
        '${'mm_pin_to_send'.tr} ${fcfa(p.receiverCredit)} → ${p.receiver.name}',
        textAlign: TextAlign.center,
        style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
      ),
      const SizedBox(height: 12),
      PinField(controller: _pin, label: '', autofocus: true, onChanged: (_) => setState(() {})),
      GetBuilder<MobileMoneyController>(
        builder: (c) => CustomButton(buttonText: 'mm_send'.tr, isLoading: c.isLoading, onPressed: _pin.text.length == 4 ? _send : null),
      ),
    ]);
  }
}
