import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class NewPassScreen extends StatefulWidget {
  final ForgetPasswordBody? forgetPasswordBody;
  final String? redirectUrl;
  const NewPassScreen({super.key, this.forgetPasswordBody, this.redirectUrl});

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  final GlobalKey<FormState> newPassKey = GlobalKey<FormState>();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  String _identity = '';

  @override
  void initState() {
    ServiceAuthController authController = Get.find();

    authController.newPasswordController.clear();
    authController.confirmNewPasswordController.clear();

    super.initState();
    _identity = widget.forgetPasswordBody?.identity ?? "";

    if (widget.forgetPasswordBody?.fromUrl == 1) {
      authController
          .verifyOtpForForgetPasswordScreen(
            widget.forgetPasswordBody?.identity ?? "",
            widget.forgetPasswordBody?.identityType ?? "",
            widget.forgetPasswordBody?.otp ?? "",
            fromOutsideUrl: true,
            shouldUpdate: false,
          )
          .then((status) async {
            if (status.isSuccess!) {
              if (kDebugMode) {
                print("Session Available");
              }
            } else {
              if (kDebugMode) {
                print("Session Expired");
              }
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(
          title: 'change_password'.tr,
          onBackPressed: () {
            Get.find<ServiceAuthController>().updateVerificationCode('');
            Get.back();
          },
        ),
        body: GetBuilder<ServiceAuthController>(
          builder: (controller) {
            return SafeArea(
              child: FooterBaseView(
                isCenter: true,
                child: WebShadowWrap(
                  child: Center(
                    child:
                        controller.forgetPasswordUrlSessionExpired &&
                            controller.isLoading
                        ? const CircularProgressIndicator()
                        : controller.forgetPasswordUrlSessionExpired &&
                              !controller.isLoading
                        ? Column(
                            children: [
                              Text("url_session_expired".tr),
                              const SizedBox(
                                height: Dimensions.paddingSizeLarge,
                              ),
                              CustomButton(
                                width: 200,
                                buttonText: "go_back".tr,
                                onPressed: () {
                                  Get.offAllNamed(
                                    ServiceRouteHelper.getSignInRoute(),
                                  );
                                },
                              ),
                            ],
                          )
                        : Form(
                            key: newPassKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        ResponsiveHelper.isDesktop(context)
                                        ? Dimensions.webMaxWidth / 3.5
                                        : ResponsiveHelper.isTab(context)
                                        ? Dimensions.webMaxWidth / 5.5
                                        : Dimensions.paddingSizeLarge,
                                  ),
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        title: 'new_password'.tr,
                                        hintText: '**************',
                                        controller:
                                            controller.newPasswordController,
                                        focusNode: _passwordFocus,
                                        nextFocus: _confirmPasswordFocus,
                                        inputType:
                                            TextInputType.visiblePassword,
                                        isPassword: true,
                                        onValidate: (String? value) {
                                          return FormValidation()
                                              .isValidPassword(value!);
                                        },
                                      ),
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeTextFieldGap,
                                      ),

                                      CustomTextField(
                                        title: 'confirm_new_password'.tr,
                                        hintText: '**************',
                                        controller: controller
                                            .confirmNewPasswordController,
                                        inputAction: TextInputAction.done,
                                        focusNode: _confirmPasswordFocus,
                                        inputType:
                                            TextInputType.visiblePassword,
                                        isPassword: true,
                                        onValidate: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'this_field_can_not_empty'
                                                .tr;
                                          } else {
                                            return FormValidation()
                                                .isValidConfirmPassword(
                                                  controller
                                                      .newPasswordController
                                                      .text,
                                                  value,
                                                );
                                          }
                                        },
                                        onSubmit: (text) => GetPlatform.isWeb
                                            ? _resetPassword(
                                                confirmNewPassword: controller
                                                    .confirmNewPasswordController
                                                    .text,
                                                newPassword: controller
                                                    .confirmNewPasswordController
                                                    .text,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeTextFieldGap,
                                      ),

                                      GetBuilder<UserController>(
                                        builder: (userController) {
                                          return GetBuilder<
                                            ServiceAuthController
                                          >(
                                            builder: (authBuilder) {
                                              return CustomButton(
                                                buttonText:
                                                    'change_password'.tr,
                                                isLoading:
                                                    authBuilder.isLoading,
                                                onPressed: () {
                                                  if (isRedundentClick(
                                                    DateTime.now(),
                                                  )) {
                                                    return;
                                                  } else {
                                                    _resetPassword(
                                                      newPassword: controller
                                                          .newPasswordController
                                                          .value
                                                          .text,
                                                      confirmNewPassword: controller
                                                          .confirmNewPasswordController
                                                          .value
                                                          .text,
                                                    );
                                                  }
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _resetPassword({
    required String newPassword,
    required String confirmNewPassword,
  }) {
    if (newPassKey.currentState!.validate()) {
      if (newPassword != confirmNewPassword) {
        customSnackBar('confirm_password_not_matched'.tr);
      } else {
        Get.find<ServiceAuthController>().resetPassword(
          identity: _identity,
          identityType: widget.forgetPasswordBody?.identityType ?? "",
          otp: widget.forgetPasswordBody?.otp ?? "",
          password: newPassword,
          confirmPassword: confirmNewPassword,
          isFirebaseOtp: widget.forgetPasswordBody?.isFirebaseOtp ?? 0,
          redirectUrl: widget.redirectUrl,
        );
      }
    }
  }
}
