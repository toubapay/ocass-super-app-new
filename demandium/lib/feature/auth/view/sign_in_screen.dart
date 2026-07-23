import 'dart:developer';

import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final String? redirectRoute;
  const SignInScreen({
    super.key,
    required this.exitFromApp,
    this.redirectRoute,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var signInPhoneController = TextEditingController();
  var signInPasswordController = TextEditingController();

  final _passwordFocus = FocusNode();
  final _phoneFocus = FocusNode();

  final GlobalKey<FormState> customerSignInKey = GlobalKey<FormState>();

  @override
  void initState() {
    _initializeController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const WebMenuBar()
            : !widget.exitFromApp
            ? AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  hoverColor: Colors.transparent,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : null,

        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,

        body: SafeArea(
          child: FooterBaseView(
            isCenter: true,
            child: WebShadowWrap(
              child: Center(
                child: GetBuilder<ServiceSplashController>(
                  builder: (splashController) {
                    return GetBuilder<ServiceAuthController>(
                      builder: (authController) {
                        var config = splashController.configModel.content;
                        var otpLogin =
                            config?.customerLogin?.loginOption?.otpLogin;
                        var manualLogin =
                            config?.customerLogin?.loginOption?.manualLogin ??
                            1;
                        var socialLogin = config
                            ?.customerLogin
                            ?.loginOption
                            ?.socialMediaLogin;

                        return Form(
                          autovalidateMode: ResponsiveHelper.isDesktop(context)
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          key: customerSignInKey,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.webMaxWidth / 3.5
                                  : ResponsiveHelper.isTab(context)
                                  ? Dimensions.webMaxWidth / 5.5
                                  : Dimensions.paddingSizeLarge,
                            ),
                            child: Column(
                              children: [
                                Hero(
                                  tag: Images.logo,
                                  child: Image.asset(
                                    Images.logo,
                                    width: Dimensions.logoSize,
                                  ),
                                ),
                                SizedBox(
                                  height: manualLogin == 1 || otpLogin == 1
                                      ? Dimensions.paddingSizeExtraMoreLarge
                                      : Dimensions.paddingSizeDefault,
                                ),

                                manualLogin == 1 || otpLogin == 1
                                    ? CustomTextField(
                                        onCountryChanged: (countryCode) =>
                                            authController.countryDialCode =
                                                countryCode.dialCode!,
                                        countryDialCode:
                                            authController.isNumberLogin ||
                                                (manualLogin == 0 &&
                                                    otpLogin == 1)
                                            ? authController.countryDialCode
                                            : null,
                                        title: 'email_phone'.tr,
                                        hintText:
                                            authController
                                                        .selectedLoginMedium ==
                                                    LoginMedium.otp ||
                                                (manualLogin == 0 &&
                                                    otpLogin == 1)
                                            ? "please_enter_phone_number".tr
                                            : 'enter_email_or_phone'.tr,
                                        controller: signInPhoneController,
                                        focusNode: _phoneFocus,
                                        nextFocus: _passwordFocus,
                                        capitalization:
                                            TextCapitalization.words,
                                        onChanged: (String text) {
                                          if (authController
                                                  .selectedLoginMedium !=
                                              LoginMedium.otp) {
                                            final numberRegExp = RegExp(
                                              r'^[+]?[0-9]+$',
                                            );

                                            if (text.isEmpty &&
                                                authController.isNumberLogin) {
                                              authController
                                                  .toggleIsNumberLogin();
                                            }
                                            if (text.startsWith(numberRegExp) &&
                                                !authController.isNumberLogin &&
                                                manualLogin == 1) {
                                              authController
                                                  .toggleIsNumberLogin();
                                              final cursorPosition =
                                                  signInPhoneController
                                                      .selection
                                                      .baseOffset;
                                              signInPhoneController.text = text
                                                  .replaceAll("+", "");
                                              signInPhoneController.selection =
                                                  TextSelection.fromPosition(
                                                    TextPosition(
                                                      offset: cursorPosition,
                                                    ),
                                                  );
                                            }
                                            final emailRegExp = RegExp(r'@');
                                            if (text.contains(emailRegExp) &&
                                                authController.isNumberLogin &&
                                                manualLogin == 1) {
                                              authController
                                                  .toggleIsNumberLogin();
                                            }

                                            _phoneFocus.requestFocus();
                                          }
                                        },
                                        onValidate: (String? value) {
                                          if (otpLogin == 1 &&
                                              manualLogin == 0 &&
                                              PhoneVerificationHelper.getValidPhoneNumber(
                                                    authController
                                                            .countryDialCode +
                                                        signInPhoneController
                                                            .text
                                                            .trim(),
                                                    withCountryCode: true,
                                                  ) ==
                                                  "") {
                                            return "enter_valid_phone_number"
                                                .tr;
                                          }
                                          if (authController.isNumberLogin &&
                                              PhoneVerificationHelper.getValidPhoneNumber(
                                                    authController
                                                            .countryDialCode +
                                                        signInPhoneController
                                                            .text
                                                            .trim(),
                                                    withCountryCode: true,
                                                  ) ==
                                                  "") {
                                            return "enter_valid_phone_number"
                                                .tr;
                                          }
                                          return (PhoneVerificationHelper.getValidPhoneNumber(
                                                        authController
                                                                .countryDialCode +
                                                            signInPhoneController
                                                                .text
                                                                .trim(),
                                                        withCountryCode: true,
                                                      ) !=
                                                      "" ||
                                                  GetUtils.isEmail(value ?? ""))
                                              ? null
                                              : 'enter_email_or_phone'.tr;
                                        },
                                      )
                                    : const SizedBox.shrink(),

                                SizedBox(
                                  height:
                                      manualLogin == 1 &&
                                          authController.selectedLoginMedium ==
                                              LoginMedium.manual
                                      ? Dimensions.paddingSizeTextFieldGap
                                      : 0,
                                ),

                                manualLogin == 1 &&
                                        authController.selectedLoginMedium ==
                                            LoginMedium.manual
                                    ? CustomTextField(
                                        title: 'password'.tr,
                                        hintText: '************'.tr,
                                        controller: signInPasswordController,
                                        focusNode: _passwordFocus,
                                        inputType:
                                            TextInputType.visiblePassword,
                                        isPassword: true,
                                        inputAction: TextInputAction.done,
                                        onValidate: (String? value) {
                                          return FormValidation()
                                              .isValidPassword(value!.tr);
                                        },
                                      )
                                    : const SizedBox.shrink(),
                                SizedBox(
                                  height:
                                      authController.selectedLoginMedium ==
                                          LoginMedium.manual
                                      ? Dimensions.paddingSizeDefault
                                      : 0,
                                ),

                                manualLogin == 1 || otpLogin == 1
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () => authController
                                                .toggleRememberMe(),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 20.0,
                                                  child: Checkbox(
                                                    activeColor: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                    value: authController
                                                        .isActiveRememberMe,
                                                    onChanged:
                                                        (
                                                          bool? isChecked,
                                                        ) => authController
                                                            .toggleRememberMe(),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall,
                                                ),
                                                Text(
                                                  'remember_me'.tr,
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          manualLogin == 1 &&
                                                  authController
                                                          .selectedLoginMedium ==
                                                      LoginMedium.manual
                                              ? TextButton(
                                                  onPressed: () {
                                                    Get.toNamed(
                                                      ServiceRouteHelper.getSendOtpScreen(
                                                        redirectUrl: widget
                                                            .redirectRoute,
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    'forgot_password'.tr,
                                                    style: robotoRegular
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .tertiary,
                                                        ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      )
                                    : const SizedBox.shrink(),

                                SizedBox(
                                  height: manualLogin == 1 || otpLogin == 1
                                      ? Dimensions.paddingSizeLarge
                                      : 0,
                                ),

                                manualLogin == 1 || otpLogin == 1
                                    ? CustomButton(
                                        buttonText:
                                            (authController
                                                        .selectedLoginMedium ==
                                                    LoginMedium.otp) ||
                                                (manualLogin == 0 &&
                                                    otpLogin == 1)
                                            ? "get_otp".tr
                                            : 'sign_in'.tr,
                                        onPressed: () {
                                          if (customerSignInKey.currentState!
                                              .validate()) {
                                            _login(
                                              authController,
                                              manualLogin,
                                              otpLogin,
                                            );
                                          }
                                        },
                                        isLoading: authController.isLoading,
                                      )
                                    : const SizedBox.shrink(),
                                SizedBox(
                                  height: manualLogin == 1 || otpLogin == 1
                                      ? Dimensions.paddingSizeDefault
                                      : 0,
                                ),

                                (manualLogin == 1 || otpLogin == 1) &&
                                        socialLogin == 1
                                    ? Center(
                                        child: Text(
                                          'or'.tr,
                                          style: robotoRegular.copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color!
                                                .withValues(alpha: 0.6),
                                            fontSize: Dimensions.fontSizeSmall,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),

                                manualLogin == 1 &&
                                        (otpLogin == 1 || socialLogin == 1)
                                    ? Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'sign_in_with'.tr,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color!
                                                    .withValues(alpha: 0.6),
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                              ),
                                            ),
                                            otpLogin == 1 && manualLogin == 1
                                                ? TextButton(
                                                    onPressed: () {
                                                      String
                                                      phoneWithoutCountryCode =
                                                          PhoneVerificationHelper.getValidPhoneNumber(
                                                            Get.find<
                                                                  ServiceAuthController
                                                                >()
                                                                .getUserNumber(),
                                                          );
                                                      String countryCode =
                                                          PhoneVerificationHelper.getCountryCode(
                                                            Get.find<
                                                                  ServiceAuthController
                                                                >()
                                                                .getUserNumber(),
                                                          );

                                                      if (authController
                                                              .selectedLoginMedium ==
                                                          LoginMedium.otp) {
                                                        authController
                                                            .toggleSelectedLoginMedium(
                                                              loginMedium:
                                                                  LoginMedium
                                                                      .manual,
                                                            );
                                                        signInPhoneController
                                                                .text =
                                                            phoneWithoutCountryCode !=
                                                                ""
                                                            ? phoneWithoutCountryCode
                                                            : authController
                                                                  .getUserNumber();
                                                        if (countryCode != "") {
                                                          authController
                                                              .toggleIsNumberLogin(
                                                                value: true,
                                                              );
                                                        } else {
                                                          authController
                                                              .toggleIsNumberLogin(
                                                                value: false,
                                                              );
                                                        }
                                                        authController
                                                            .initCountryCode(
                                                              countryCode:
                                                                  countryCode !=
                                                                      ""
                                                                  ? countryCode
                                                                  : null,
                                                            );
                                                        signInPasswordController
                                                            .text = authController
                                                            .getUserPassword();

                                                        if (signInPasswordController
                                                            .text
                                                            .isEmpty) {
                                                          signInPhoneController
                                                                  .text =
                                                              "";
                                                          authController
                                                              .toggleIsNumberLogin(
                                                                value: false,
                                                              );
                                                        }
                                                      } else {
                                                        authController
                                                            .toggleSelectedLoginMedium(
                                                              loginMedium:
                                                                  LoginMedium
                                                                      .otp,
                                                            );
                                                        authController
                                                            .toggleIsNumberLogin(
                                                              value: true,
                                                            );
                                                        signInPasswordController
                                                            .clear();

                                                        signInPhoneController
                                                                .text =
                                                            phoneWithoutCountryCode;
                                                        authController
                                                            .initCountryCode(
                                                              countryCode:
                                                                  countryCode !=
                                                                      ""
                                                                  ? countryCode
                                                                  : null,
                                                            );
                                                      }
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: const Size(
                                                        30,
                                                        30,
                                                      ),
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 5,
                                                          ),
                                                      child: Text(
                                                        authController
                                                                    .selectedLoginMedium ==
                                                                LoginMedium
                                                                    .manual
                                                            ? 'OTP'.tr
                                                            : "email_phone".tr,
                                                        style: robotoRegular.copyWith(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          color: Theme.of(
                                                            context,
                                                          ).colorScheme.primary,
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),

                                socialLogin == 1
                                    ? SocialLoginWidget(
                                        redirectUrl: widget.redirectRoute,
                                      )
                                    : const SizedBox(),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),

                                manualLogin == 1
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${'do_not_have_an_account'.tr} ',
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge!.color,
                                            ),
                                          ),

                                          TextButton(
                                            onPressed: () {
                                              signInPhoneController.clear();
                                              signInPasswordController.clear();

                                              Get.toNamed(
                                                ServiceRouteHelper.getSignUpRoute(
                                                  redirectUrl:
                                                      widget.redirectRoute,
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(50, 30),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              'sign_up_here'.tr,
                                              style: robotoRegular.copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _initializeController() {
    var authController = Get.find<ServiceAuthController>();
    String phoneWithoutCountryCode =
        PhoneVerificationHelper.getValidPhoneNumber(
          Get.find<ServiceAuthController>().getUserNumber(),
        );
    String countryCode = PhoneVerificationHelper.getCountryCode(
      Get.find<ServiceAuthController>().getUserNumber(),
    );

    var config = Get.find<ServiceSplashController>().configModel.content;
    var manualLogin = config?.customerLogin?.loginOption?.manualLogin ?? 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (countryCode != "" && phoneWithoutCountryCode != "") {
        authController.toggleIsNumberLogin(value: true);
      } else {
        authController.toggleIsNumberLogin(value: false);
      }
      authController.toggleSelectedLoginMedium(loginMedium: LoginMedium.manual);
      authController.initCountryCode(
        countryCode: countryCode != "" ? countryCode : null,
      );

      signInPhoneController.text = phoneWithoutCountryCode != ""
          ? phoneWithoutCountryCode
          : authController.isNumberLogin
          ? ""
          : Get.find<ServiceAuthController>().getUserNumber();
      signInPasswordController.text = Get.find<ServiceAuthController>()
          .getUserPassword();

      if (manualLogin == 1 && signInPasswordController.text.isEmpty) {
        signInPhoneController.text = "";
        authController.initCountryCode();
        authController.toggleIsNumberLogin(value: false);
      }
    });
    authController.toggleRememberMe(value: false, shouldUpdate: false);
  }

  void _login(
    ServiceAuthController authController,
    var manualLogin,
    var otpLogin,
  ) async {
    log("Selected Login Medium: ${authController.selectedLoginMedium}");
    if (customerSignInKey.currentState!.validate()) {
      var config = Get.find<ServiceSplashController>().configModel.content;

      SendOtpType type = config?.firebaseOtpVerification == 1
          ? SendOtpType.firebase
          : SendOtpType.verification;

      String phone = PhoneVerificationHelper.getValidPhoneNumber(
        authController.countryDialCode + signInPhoneController.text.trim(),
        withCountryCode: true,
      );

      if ((authController.selectedLoginMedium == LoginMedium.otp) ||
          (manualLogin == 0 && otpLogin == 1)) {
        log("Initiating OTP Login for phone: $phone with type: $type");
        authController
            .sendVerificationCode(
              identity: phone,
              identityType: "phone",
              type: type,
              checkUser: 0,
              redirectUrl: widget.redirectRoute,
            )
            .then((status) {
              if (status != null) {
                if (status.isSuccess!) {
                  Get.toNamed(
                    ServiceRouteHelper.getVerificationRoute(
                      identity: phone,
                      identityType: "phone",
                      fromPage: config?.firebaseOtpVerification == 1
                          ? "firebase-otp"
                          : "otp-login",
                      firebaseSession: type == SendOtpType.firebase
                          ? status.message
                          : null,
                      redirectUrl: widget.redirectRoute,
                    ),
                  );
                } else {
                  customSnackBar(status.message.toString().capitalizeFirst);
                }
              }
            });
      } else {
        log(
          "Initiating Manual Login for email/phone: ${signInPhoneController.text.trim()}",
        );
        authController.login(
          redirectRoute: widget.redirectRoute,
          emailPhone: phone != "" ? phone : signInPhoneController.text.trim(),
          password: signInPasswordController.text.trim(),
          type: phone != "" ? "phone" : "email",
        );
      }
    }
  }
}
