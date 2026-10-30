import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/mobile_money/controllers/mobile_money_controller.dart';
import 'package:sixam_mart/features/mobile_money/domain/models/mobile_money_models.dart';
import 'package:sixam_mart/features/mobile_money/screens/mobile_money_success_screen.dart';
import 'package:sixam_mart/features/mobile_money/widgets/money_widgets.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Shows who receives what and what it costs, then confirms with the PIN.
class MobileMoneyConfirmScreen extends StatefulWidget {
  final MoneyPreview preview;
  final String phone;
  final String? note;
  const MobileMoneyConfirmScreen({super.key, required this.preview, required this.phone, this.note});

  @override
  State<MobileMoneyConfirmScreen> createState() => _MobileMoneyConfirmScreenState();
}

class _MobileMoneyConfirmScreenState extends State<MobileMoneyConfirmScreen> {
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
      note: widget.note,
      requestId: _requestId,
    );
    if (transfer != null) {
      Get.off(() => MobileMoneySuccessScreen(transfer: transfer));
    } else {
      _pin.clear();
      setState(() {});
    }
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Expanded(child: Text(label, style: bold ? robotoBold : robotoRegular)),
          Text(value, style: bold ? robotoBold : robotoRegular),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final p = widget.preview;
    final firstName = p.receiver.name.split(' ').first;
    return Scaffold(
      appBar: CustomAppBar(title: 'mm_confirm_title'.tr),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
            child: Column(children: [
              Row(children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(p.receiver.name.isNotEmpty ? p.receiver.name[0] : '?', style: robotoBold.copyWith(color: Colors.white, fontSize: 20)),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.receiver.name, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    Text(p.receiver.phone, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                  ]),
                ),
              ]),
              const Divider(height: 24),
              _row('mm_amount_sent'.tr, fcfa(p.amount)),
              _row('mm_fee'.tr, p.fee > 0 ? fcfa(p.fee) : 'mm_free'.tr),
              _row('${'mm_received_by'.tr} $firstName', fcfa(p.receiverCredit)),
              const Divider(height: 16),
              _row('mm_debited'.tr, fcfa(p.senderDebit), bold: true),
              if (widget.note != null && widget.note!.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${'mm_note'.tr} : ${widget.note}', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                ),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          if (!p.sufficientBalance)
            Text('mm_insufficient'.tr, textAlign: TextAlign.center, style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error))
          else
            PinField(controller: _pin, label: 'mm_your_pin'.tr, autofocus: true, onChanged: (_) => setState(() {})),
          GetBuilder<MobileMoneyController>(
            builder: (c) => CustomButton(
              buttonText: '${'mm_send'.tr} ${fcfa(p.amount)}',
              isLoading: c.isLoading,
              onPressed: p.sufficientBalance && _pin.text.length == 4 ? _send : null,
            ),
          ),
        ]),
      ),
    );
  }
}
