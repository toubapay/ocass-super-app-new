import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class CreateAccountWidget extends StatelessWidget {
  const CreateAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckOutController>(builder: (checkoutController){

      return checkoutController.isCheckedCreateAccount ? _CreateAccountInputWidget(checkoutController) : Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.3), width: 0.5),
          borderRadius: BorderRadius.circular(Dimensions.radiusSeven),
          color: Theme.of(context).cardColor
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: kIsWeb ? 8 : 2),
        child: CustomCheckBox(
          title: "create_account_with_existing_info".tr,
          value: checkoutController.isCheckedCreateAccount,
          onTap: () {
           checkoutController.toggleIsCheckedCreateAccount();
          },
        ),
      );
    });
  }
}

class _CreateAccountInputWidget extends StatefulWidget {
  final CheckOutController checkoutController;
  const _CreateAccountInputWidget(this.checkoutController);

  @override
  State<_CreateAccountInputWidget> createState() => _CreateAccountInputWidgetState();
}

class _CreateAccountInputWidgetState extends State<_CreateAccountInputWidget> {

  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).cardColor : Theme.of(context).hintColor.withValues(alpha: 0.05),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CustomCheckBox(
            title: "create_account_with_existing_info".tr,
            value: widget.checkoutController.isCheckedCreateAccount,
            onTap: () {
              widget.checkoutController.toggleIsCheckedCreateAccount();
            },
          ),

          Text("your_provided_contact_info_user_as".tr, style: robotoLight),
          const SizedBox(height: Dimensions.paddingSizeDefault,),
          CustomTextField(
            title: 'password'.tr,
            hintText: '****************'.tr,
            focusNode: passwordFocus,
            nextFocus: confirmPasswordFocus,
            controller: widget.checkoutController.passwordController,
            inputType: TextInputType.visiblePassword,
            onValidate: (String? value) {
              return FormValidation().isValidPassword(value!);
            },
            isPassword: true,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomTextField(
            title: 'confirm_password'.tr,
            hintText: '****************'.tr,
            controller: widget.checkoutController.confirmPasswordController,
            inputType: TextInputType.visiblePassword,
            focusNode: confirmPasswordFocus,
            inputAction: TextInputAction.done,
            isPassword: true,
            onValidate: (String? value) {
              if(value == null || value.isEmpty){
                return 'this_field_can_not_empty'.tr;
              }else{
                return FormValidation().isValidConfirmPassword(
                  widget.checkoutController.passwordController.text,
                  widget.checkoutController.confirmPasswordController.text,
                );
              }
            },
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

        ]),
      ),
    );
  }
}

