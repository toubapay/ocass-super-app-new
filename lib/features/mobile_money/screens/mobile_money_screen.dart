import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/mobile_money/controllers/mobile_money_controller.dart';
import 'package:sixam_mart/features/mobile_money/screens/mobile_money_confirm_screen.dart';
import 'package:sixam_mart/features/mobile_money/screens/mobile_money_pin_screen.dart';
import 'package:sixam_mart/features/mobile_money/widgets/money_widgets.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Ocass Money: send money from the wallet to another customer's wallet.
class MobileMoneyScreen extends StatefulWidget {
  const MobileMoneyScreen({super.key});

  @override
  State<MobileMoneyScreen> createState() => _MobileMoneyScreenState();
}

class _MobileMoneyScreenState extends State<MobileMoneyScreen> {
  static const _amounts = [1000, 2000, 5000, 10000, 25000];
  final _phone = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<MobileMoneyController>().load();
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  String get _digits => _phone.text.replaceAll(RegExp(r'\D'), '');
  double get _value => double.tryParse(_amount.text) ?? 0;

  Future<void> _continue(MobileMoneyController c) async {
    if (_digits.length < 9 || _value <= 0) {
      showCustomSnackBar('mm_fill_form'.tr);
      return;
    }
    if (!(c.config?.hasPin ?? false)) {
      final created = await Get.to(() => const MobileMoneyPinScreen());
      if (created != true) return;
    }
    final preview = await c.preview(_digits, _value);
    if (preview == null) return;
    await Get.to(() => MobileMoneyConfirmScreen(preview: preview, phone: _digits, note: _note.text.trim()));
    if (mounted) setState(() {});
  }

  String _feeHint(MobileMoneyController c) {
    final cfg = c.config!;
    final parts = [if (cfg.feePercent > 0) '${cfg.feePercent} %', if (cfg.feeFixed > 0) fcfa(cfg.feeFixed)];
    if (parts.isEmpty) return 'mm_free_transfer'.tr;
    var hint = '${'mm_fee'.tr} : ${parts.join(' + ')}';
    if (cfg.maxFee > 0) hint += ', ${'mm_capped_at'.tr} ${fcfa(cfg.maxFee)}';
    if (cfg.feeBearer == 'receiver') hint += ', ${'mm_deducted'.tr}';
    return hint;
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.find<AuthController>().isLoggedIn()) {
      return Scaffold(
        appBar: CustomAppBar(title: 'mm_title'.tr),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('mm_login_required'.tr, textAlign: TextAlign.center),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomButton(buttonText: 'sign_in'.tr, onPressed: () => Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.mobileMoney))),
            ]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'mm_title'.tr),
      body: SafeArea(
        child: GetBuilder<MobileMoneyController>(builder: (c) {
          if (c.config == null) return const Center(child: CircularProgressIndicator());
          if (!c.config!.enabled) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('mm_unavailable'.tr, textAlign: TextAlign.center)));
          }
          final balance = Get.find<ProfileController>().userInfoModel?.walletBalance ?? c.config!.walletBalance;
          return RefreshIndicator(
            onRefresh: c.load,
            child: ListView(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), children: [
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                  gradient: const LinearGradient(colors: [Color(0xFF6B4F05), Color(0xFF9A7209), Color(0xFFD4AF37)]),
                ),
                child: Row(children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 32),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('mm_balance'.tr, style: robotoRegular.copyWith(color: Colors.white70)),
                      Text(fcfa(balance), style: robotoBold.copyWith(color: Colors.white, fontSize: 24)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'mm_recipient_phone'.tr, prefixText: '+221 ', border: const OutlineInputBorder(), hintText: '77 123 45 67'),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: 'mm_amount'.tr, suffixText: 'F CFA', border: const OutlineInputBorder(), hintText: '${'mm_minimum'.tr} ${fcfa(c.config!.minAmount)}'),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _amounts
                    .where((a) => a >= c.config!.minAmount && (c.config!.maxAmount <= 0 || a <= c.config!.maxAmount))
                    .map((a) => ChoiceChip(
                          label: Text(fcfa(a)),
                          selected: _value == a,
                          onSelected: (_) => setState(() => _amount.text = '$a'),
                        ))
                    .toList(),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              TextField(
                controller: _note,
                maxLength: 140,
                decoration: InputDecoration(labelText: 'mm_note_optional'.tr, border: const OutlineInputBorder()),
              ),
              Text(_feeHint(c), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomButton(buttonText: 'mm_continue'.tr, isLoading: c.isLoading, onPressed: () => _continue(c)),
              if (c.config!.hasPin)
                TextButton(onPressed: () => Get.to(() => const MobileMoneyPinScreen(change: true)), child: Text('mm_change_pin'.tr)),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text('mm_my_transfers'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              if (c.transfers == null)
                const Center(child: CircularProgressIndicator())
              else if (c.transfers!.isEmpty)
                Padding(padding: const EdgeInsets.all(16), child: Text('mm_no_transfers'.tr, textAlign: TextAlign.center))
              else
                ...c.transfers!.map((t) => TransferTile(transfer: t)),
            ]),
          );
        }),
      ),
    );
  }
}
