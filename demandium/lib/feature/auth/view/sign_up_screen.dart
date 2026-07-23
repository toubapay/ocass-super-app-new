import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class SignUpScreen extends StatefulWidget {
  final String? referralCode;
  final String? redirectRoute;

  const SignUpScreen({super.key, this.referralCode, this.redirectRoute});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var referCodeController = TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();

  late final GlobalKey<FormState> customerSignUpKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Get.find<ServiceAuthController>().initCountryCode();
    Get.find<ServiceAuthController>().toggleTerms(
      value: false,
      shouldUpdate: false,
    );
    final ConfigModel config = Get.find<ServiceSplashController>().configModel;

    if (config.content?.referEarnStatus == 1 &&
        (widget.referralCode?.isNotEmpty ?? false)) {
      referCodeController.text = widget.referralCode ?? '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _clearControllerValue();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      onPopInvoked: () {
        ServiceAuthController authController = Get.find();
        authController.acceptTerms == true
            ? authController.toggleTerms()
            : authController.acceptTerms;
      },
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: const CustomAppBar(title: "", isBackgroundTransparent: true),
        body: SafeArea(
          child: GetBuilder<ServiceAuthController>(
            builder: (authController) {
              var config =
                  Get.find<ServiceSplashController>().configModel.content;
              var socialLogin =
                  config?.customerLogin?.loginOption?.socialMediaLogin;

              return FooterBaseView(
                child: WebShadowWrap(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeExtraLarge,
                    ),
                    child: Column(
                      children: [
                        Form(
                          key: customerSignUpKey,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraMoreLarge,
                              ),

                              Hero(
                                tag: Images.logo,
                                child: Image.asset(
                                  Images.logo,
                                  width: Dimensions.logoSize,
                                ),
                              ),

                              const SizedBox(
                                height: Dimensions.paddingSizeExtraMoreLarge,
                              ),
                              if (ResponsiveHelper.isMobile(context))
                                _firstList(authController),
                              if (ResponsiveHelper.isMobile(context))
                                _secondList(authController),
                              if (!ResponsiveHelper.isMobile(context))
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _firstList(authController)),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeLarge,
                                    ),
                                    Expanded(
                                      child: _secondList(authController),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        ConditionCheckBox(
                          checkBoxValue: authController.acceptTerms,
                          onTap: (bool? value) {
                            if (customerSignUpKey.currentState?.validate() ==
                                true) {
                              authController.toggleTerms(value: true);
                            } else {
                              authController.toggleTerms(value: false);
                            }
                          },
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraLarge,
                        ),
                        CustomButton(
                          buttonText: 'sign_up'.tr,
                          isLoading: authController.isLoading,
                          onPressed:
                              authController.acceptTerms &&
                                  customerSignUpKey.currentState?.validate() ==
                                      true
                              ? () => _register(authController)
                              : null,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        socialLogin == 1
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.webMaxWidth / 3.5
                                      : ResponsiveHelper.isTab(context)
                                      ? Dimensions.webMaxWidth / 5.5
                                      : 0,
                                ),
                                child: SocialLoginWidget(
                                  redirectUrl: widget.redirectRoute,
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${'already_have_an_account'.tr} ',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.toNamed(
                                  ServiceRouteHelper.getSignInRoute(),
                                );
                              },
                              child: Text(
                                'sign_in_here'.tr,
                                style: robotoRegular.copyWith(
                                  decoration: TextDecoration.underline,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        const SizedBox(
                          height: Dimensions.paddingSizeExtraMoreLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _firstList(ServiceAuthController authController) {
    return Column(
      children: [
        CustomTextField(
          title: 'first_name'.tr,
          hintText: 'enter_your_first_name'.tr,
          controller: firstNameController,
          isAutoFocus: false,
          focusNode: _firstNameFocus,
          nextFocus: _lastNameFocus,
          inputType: TextInputType.name,
          capitalization: TextCapitalization.words,
          onValidate: (String? value) {
            return FormValidation().isValidFirstName(value!);
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

        CustomTextField(
          title: 'last_name'.tr,
          hintText: 'enter_your_last_name'.tr,
          controller: lastNameController,
          focusNode: _lastNameFocus,
          nextFocus: _emailFocus,
          inputType: TextInputType.name,
          capitalization: TextCapitalization.words,
          onValidate: (String? value) {
            return FormValidation().isValidLastName(value!);
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

        CustomTextField(
          title: 'email_address'.tr,
          hintText: 'enter_email_address'.tr,
          controller: emailController,
          focusNode: _emailFocus,
          nextFocus: _phoneFocus,
          inputType: TextInputType.emailAddress,
          onValidate: (String? value) {
            return FormValidation().isValidEmail(value);
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

        CustomTextField(
          onCountryChanged: (CountryCode countryCode) {
            authController.countryDialCode = countryCode.dialCode!;
          },
          countryDialCode: authController.countryDialCode,
          hintText: 'enter_phone_number'.tr,
          controller: phoneController,
          focusNode: _phoneFocus,
          nextFocus: _passwordFocus,
          inputType: TextInputType.phone,
          isRequired: false,
          onValidate: (String? value) {
            if (value == null || value.isEmpty) {
              return 'enter_phone_number'.tr;
            } else {
              return FormValidation().isValidPhone(
                authController.countryDialCode + (value),
                fromAuthPage: true,
              );
            }
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),
      ],
    );
  }

  Widget _secondList(ServiceAuthController authController) {
    return Column(
      children: [
        CustomTextField(
          title: 'password'.tr,
          hintText: '****************'.tr,
          controller: passwordController,
          focusNode: _passwordFocus,
          nextFocus: _confirmPasswordFocus,
          inputType: TextInputType.visiblePassword,
          onValidate: (String? value) {
            return FormValidation().isValidPassword(value!);
          },
          isPassword: true,
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

        CustomTextField(
          title: 'confirm_password'.tr,
          hintText: '****************'.tr,
          controller: confirmPasswordController,
          focusNode: _confirmPasswordFocus,
          nextFocus: _referCodeFocus,
          inputType: TextInputType.visiblePassword,
          isPassword: true,
          onValidate: (String? value) {
            if (value == null || value.isEmpty) {
              return 'this_field_can_not_empty'.tr;
            } else {
              return FormValidation().isValidConfirmPassword(
                passwordController.text,
                confirmPasswordController.text,
              );
            }
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),
        CustomTextField(
          title: 'referral_code'.tr,
          hintText: 'optional'.tr,
          controller: referCodeController,
          focusNode: _referCodeFocus,
          inputType: TextInputType.text,
          inputAction: TextInputAction.done,
          isRequired: false,
        ),
        const SizedBox(height: Dimensions.paddingSizeTextFieldGap),
      ],
    );
  }

  void _register(ServiceAuthController authController) async {
    if (customerSignUpKey.currentState!.validate()) {
      SignUpBody signUpBody;
      String numberWithCountryCode =
          PhoneVerificationHelper.getValidPhoneNumber(
            authController.countryDialCode + phoneController.value.text,
            withCountryCode: true,
          );

      if (referCodeController.text != "") {
        signUpBody = SignUpBody(
          fName: firstNameController.value.text.trim(),
          lName: lastNameController.value.text.trim(),
          email: emailController.value.text.trim(),
          phone: numberWithCountryCode.trim(),
          password: passwordController.value.text.trim(),
          confirmPassword: confirmPasswordController.value.text.trim(),
          referCode: referCodeController.text.trim(),
        );
      } else {
        signUpBody = SignUpBody(
          fName: firstNameController.value.text.trim(),
          lName: lastNameController.value.text.trim(),
          email: emailController.value.text.trim(),
          phone: numberWithCountryCode.trim(),
          password: passwordController.value.text.trim(),
          confirmPassword: confirmPasswordController.value.text.trim(),
        );
      }
      authController.registration(
        signUpBody: signUpBody,
        redirectUrl: widget.redirectRoute,
      );
    }
  }

  void _clearControllerValue() {
    firstNameController.text = "";
    lastNameController.text = "";
    emailController.text = "";
    phoneController.text = "";
    passwordController.text = "";
    confirmPasswordController.text = "";
    referCodeController.text = "";
  }
}
