import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sixam_mart/features/auth/pin_auth.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/widgets/social_login_widget.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/validate_check.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Phone sign-in. Noor: "Code PIN" (number + 4-digit PIN, no SMS to wait
/// for) by default, "Code SMS" for the first sign-up and a forgotten PIN.
class OtpLoginWidget extends StatefulWidget {
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final Function() onClickLoginButton;
  final Function(String pin)? onPinLogin;
  final bool socialEnable;
  final bool backFromThis;
  const OtpLoginWidget({super.key, required this.phoneController, required this.phoneFocus, required this.onCountryChanged, required this.countryDialCode,
    required this.onClickLoginButton, this.onPinLogin, this.socialEnable = false, required this.backFromThis});

  @override
  State<OtpLoginWidget> createState() => OtpLoginWidgetState();
}

class OtpLoginWidgetState extends State<OtpLoginWidget> {
  bool _pinMode = true;
  final TextEditingController _pin = TextEditingController();

  /// Switch to the SMS code (no PIN on this number, or PIN forgotten).
  void useSms() => setState(() => _pinMode = false);

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Widget _modeButton(String label, bool active, VoidCallback onTap) => Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? Theme.of(context).cardColor : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)] : null,
            ),
            child: Text(label, style: robotoBold.copyWith(color: active ? Theme.of(context).primaryColor : Theme.of(context).hintColor)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final phoneController = widget.phoneController;
    final phoneFocus = widget.phoneFocus;
    final countryDialCode = widget.countryDialCode;
    final onCountryChanged = widget.onCountryChanged;
    final onClickLoginButton = widget.onClickLoginButton;
    final socialEnable = widget.socialEnable;
    final backFromThis = widget.backFromThis;
    final pinEnabled = widget.onPinLogin != null;
    final pinMode = pinEnabled && _pinMode;
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<AuthController>(builder: (authController) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : 0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('hey_there_welcome_back'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          if (pinEnabled) ...[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                _modeButton('Code PIN', _pinMode, () => setState(() => _pinMode = true)),
                _modeButton('Code SMS', !_pinMode, () => setState(() => _pinMode = false)),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(_pinMode ? 'Ton numéro et ton code PIN à 4 chiffres.' : 'Nous t’envoyons un code par SMS (inscription ou code PIN oublié).',
                style: robotoRegular.copyWith(color: Theme.of(context).hintColor), textAlign: TextAlign.center),
          ],
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          CustomTextField(
            titleText: 'xxx-xxx-xxxxx'.tr,
            controller: phoneController,
            focusNode: phoneFocus,
            inputAction: TextInputAction.done,
            inputType: TextInputType.phone,
            isPhone: true,
            onCountryChanged: onCountryChanged,
            countryDialCode: countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
            labelText: 'phone'.tr,
            required: true,
            validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_phone_number".tr),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          if (pinMode) ...[
            TextField(
              controller: _pin,
              obscureText: true,
              obscuringCharacter: '●',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
              onChanged: (v) {
                setState(() {});
                if (v.length == 4 && !authController.isLoading) widget.onPinLogin!(v);
              },
              style: robotoBold.copyWith(fontSize: 24, letterSpacing: 14),
              decoration: InputDecoration(
                labelText: 'Code PIN',
                hintText: '••••',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],

          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => authController.toggleRememberMe(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 24, width: 24,
                    child: Checkbox(
                      side: BorderSide(color: Theme.of(context).hintColor),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: Theme.of(context).primaryColor,
                      value: authController.isActiveRememberMe,
                      onChanged: (bool? isChecked) => authController.toggleRememberMe(),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Text('remember_me'.tr, style: robotoRegular),
                ],
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // const ConditionCheckBoxWidget(forSignUp: true),
          // const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomButton(
            buttonText: pinMode ? 'login'.tr : (pinEnabled ? 'Recevoir le code' : 'login'.tr),
            radius: Dimensions.radiusDefault,
            isBold: isDesktop ? false : true,
            isLoading: authController.isLoading,
            onPressed: pinMode ? (_pin.text.length == 4 ? () => widget.onPinLogin!(_pin.text) : null) : onClickLoginButton,
            fontSize: isDesktop ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
          ),
          if (pinMode)
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(
                onPressed: () {
                  PinAuth.markReset();
                  setState(() => _pinMode = false);
                },
                child: const Text('Code PIN oublié ?'),
              ),
              TextButton(onPressed: () => setState(() => _pinMode = false), child: const Text('Créer un compte')),
            ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          socialEnable ? SocialLoginWidget(onlySocialLogin: false, backFromThis: backFromThis) : const SizedBox(),

          socialEnable && isDesktop ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

          !socialEnable ? const SizedBox(height: 100) : const SizedBox(),

        ]),
      );
    });
  }
}
