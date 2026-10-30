import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/mobile_money/controllers/mobile_money_controller.dart';
import 'package:sixam_mart/features/mobile_money/widgets/money_widgets.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Creates or changes the 4-digit secret code that confirms every transfer.
class MobileMoneyPinScreen extends StatefulWidget {
  final bool change;
  const MobileMoneyPinScreen({super.key, this.change = false});

  @override
  State<MobileMoneyPinScreen> createState() => _MobileMoneyPinScreenState();
}

class _MobileMoneyPinScreenState extends State<MobileMoneyPinScreen> {
  final _current = TextEditingController();
  final _pin = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_pin.text.length != 4 || (widget.change && _current.text.length != 4)) {
      showCustomSnackBar('mm_pin_four_digits'.tr);
      return;
    }
    if (_pin.text != _confirm.text) {
      showCustomSnackBar('mm_pin_mismatch'.tr);
      return;
    }
    final ok = await Get.find<MobileMoneyController>().setPin(_pin.text, currentPin: widget.change ? _current.text : null);
    if (ok) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.change ? 'mm_change_pin'.tr : 'mm_create_pin'.tr),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(Dimensions.paddingSizeLarge), children: [
          Icon(Icons.lock_outline, size: 56, color: Theme.of(context).primaryColor),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text('mm_pin_explainer'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          if (widget.change) PinField(controller: _current, label: 'mm_current_pin'.tr, autofocus: true),
          PinField(controller: _pin, label: 'mm_new_pin'.tr, autofocus: !widget.change),
          PinField(controller: _confirm, label: 'mm_confirm_pin'.tr),
          GetBuilder<MobileMoneyController>(
            builder: (c) => CustomButton(buttonText: 'mm_save'.tr, isLoading: c.isLoading, onPressed: _save),
          ),
        ]),
      ),
    );
  }
}
