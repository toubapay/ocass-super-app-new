import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class VerificationScreen extends StatefulWidget {
  final String? identity;
  final String fromPage;
  final String identityType;
  final String? firebaseSession;
  final String? redirectRoute;
  const VerificationScreen({
    super.key,
    this.identity,
    required this.fromPage,
    required this.identityType,
    this.firebaseSession,
    this.redirectRoute,
  });

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _identity;
  Timer? _timer;
  int? _seconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.identityType == "phone" && !widget.identity!.startsWith('+')) {
      _identity = '+${widget.identity!.substring(1, widget.identity!.length)}';
    } else {
      _identity = widget.identity;
    }

    // Reset wrong OTP status when screen initializes
    Get.find<ServiceAuthController>().setWrongOtpSubmitted(false);

    _startTimer();
  }

  void _startTimer() {
    _seconds =
        Get.find<ServiceSplashController>()
            .configModel
            .content
            ?.resentOtpTime ??
        60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(title: 'otp_verification'.tr),
        body: SafeArea(
          child: FooterBaseView(
            isCenter: true,
            child: WebShadowWrap(
              child: Scrollbar(
                child: SizedBox(
                  height: ResponsiveHelper.isDesktop(context)
                      ? MediaQuery.of(context).size.height * 0.7
                      : MediaQuery.of(context).size.height - 130,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                      ),
                      child: GetBuilder<ServiceAuthController>(
                        builder: (authController) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.webMaxWidth / 3.5
                                  : ResponsiveHelper.isTab(context)
                                  ? Dimensions.webMaxWidth / 5.5
                                  : 0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(Images.otp, width: 140),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),

                                Get.find<ServiceSplashController>()
                                            .configModel
                                            .content
                                            ?.appEnvironment ==
                                        "demo"
                                    ? Text(
                                        'for_demo_purpose'.tr,
                                        style: robotoRegular,
                                      )
                                    : RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: DefaultTextStyle.of(
                                            context,
                                          ).style,
                                          children: [
                                            TextSpan(
                                              text:
                                                  'we_have_sent_a_verification_code_to'
                                                      .tr,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color
                                                    ?.withValues(alpha: 0.5),
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  StringParser.obfuscateMiddle(
                                                    _identity ?? "",
                                                  ),
                                              style: robotoMedium.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge!.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraMoreLarge,
                                ),

                                PinCodeTextField(
                                  length: 6,
                                  appContext: context,
                                  keyboardType: TextInputType.number,
                                  animationType: AnimationType.slide,
                                  pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    fieldHeight:
                                        ResponsiveHelper.isMobile(context)
                                        ? width / 9
                                        : 60,
                                    fieldWidth:
                                        ResponsiveHelper.isMobile(context)
                                        ? width / 9
                                        : 60,
                                    borderWidth: 0.5,
                                    activeBorderWidth: 0.5,
                                    inactiveBorderWidth: 0.5,
                                    errorBorderWidth: 0.5,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                    selectedColor:
                                        authController.isWrongOtpSubmitted
                                        ? Theme.of(context).colorScheme.error
                                              .withValues(alpha: 0.5)
                                        : Theme.of(context).colorScheme.primary
                                              .withValues(alpha: 0.2),
                                    selectedFillColor: Get.isDarkMode
                                        ? Colors.grey.withValues(alpha: 0.6)
                                        : Colors.white,
                                    inactiveFillColor: Get.isDarkMode
                                        ? Theme.of(context).disabledColor
                                              .withValues(alpha: 0.50)
                                        : Theme.of(context).cardColor,
                                    inactiveColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(
                                          alpha: Get.isDarkMode ? 0.7 : 0.2,
                                        ),
                                    activeColor:
                                        authController.isWrongOtpSubmitted
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.primary
                                              .withValues(alpha: 0.4),
                                    activeFillColor: Get.isDarkMode
                                        ? Theme.of(context).disabledColor
                                              .withValues(alpha: 0.50)
                                        : Theme.of(context).cardColor,
                                  ),
                                  animationDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  backgroundColor: Colors.transparent,
                                  enableActiveFill: true,
                                  onChanged:
                                      authController.updateVerificationCode,
                                  beforeTextPaste: (text) => true,
                                  pastedTextStyle: robotoRegular.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.color,
                                  ),
                                  textStyle: robotoMedium,
                                ),

                                authController.isWrongOtpSubmitted
                                    ? Text(
                                        'incorrect_otp'.tr,
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                    : const Text(" "),

                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                CustomButton(
                                  buttonText: "verify".tr,
                                  isLoading: authController.isLoading,
                                  onPressed:
                                      (authController.verificationCode.length ==
                                              6 &&
                                          !authController.isResendLoading)
                                      ? () {
                                          _otpVerify(
                                            _identity!,
                                            widget.identityType,
                                            authController.verificationCode,
                                            authController,
                                          );
                                        }
                                      : null,
                                ),

                                const SizedBox(
                                  height: Dimensions.paddingSizeEight,
                                ),

                                (widget.identity != null &&
                                        widget.identity!.isNotEmpty)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'did_not_receive_the_code'.tr,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color!
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: Dimensions.paddingSizeSmall,
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              minimumSize: const Size(1, 40),
                                              backgroundColor: Theme.of(
                                                context,
                                              ).cardColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeSmall,
                                                  ),
                                            ),
                                            onPressed:
                                                (_seconds! < 1 &&
                                                    !authController
                                                        .isResendLoading)
                                                ? () {
                                                    var config =
                                                        Get.find<
                                                              ServiceSplashController
                                                            >()
                                                            .configModel
                                                            .content;
                                                    SendOtpType type =
                                                        config?.firebaseOtpVerification ==
                                                                1 &&
                                                            widget.identityType ==
                                                                "phone"
                                                        ? SendOtpType.firebase
                                                        : widget.fromPage ==
                                                              "verification"
                                                        ? SendOtpType
                                                              .verification
                                                        : SendOtpType
                                                              .forgetPassword;

                                                    authController
                                                        .sendVerificationCode(
                                                          identity: _identity!,
                                                          identityType: widget
                                                              .identityType,
                                                          type: type,
                                                          isResend: true,
                                                        )
                                                        .then((status) {
                                                          if (status != null) {
                                                            if (status
                                                                .isSuccess!) {
                                                              _startTimer();
                                                              customSnackBar(
                                                                'resend_code_successful'
                                                                    .tr,
                                                                type:
                                                                    ToasterMessageType
                                                                        .success,
                                                              );
                                                            } else {
                                                              customSnackBar(
                                                                status.message,
                                                              );
                                                            }
                                                          }
                                                        });
                                                  }
                                                : null,
                                            child:
                                                authController.isResendLoading
                                                ? Row(
                                                    children: [
                                                      Text(
                                                        'resending'.tr,
                                                        style: robotoRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                    alpha: 0.8,
                                                                  ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall,
                                                      ),

                                                      SizedBox(
                                                        height: Dimensions
                                                            .fontSizeDefault,
                                                        width: Dimensions
                                                            .fontSizeDefault,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                    alpha: 0.8,
                                                                  ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    '${'resend'.tr}${_seconds! > 0 ? ' ($_seconds)' : ''}',
                                                    style: robotoRegular
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                    alpha: 0.9,
                                                                  ),
                                                        ),
                                                  ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraMoreLarge,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _otpVerify(
    String identity,
    String identityType,
    String otp,
    ServiceAuthController authController,
  ) async {
    if (widget.fromPage == "verification" || widget.fromPage == "profile") {
      authController.verifyOtpForVerificationScreen(
        identity: identity,
        identityType: identityType,
        otp: otp,
        fromPage: widget.fromPage,
        redirectUrl: widget.redirectRoute,
      );
    } else if (widget.fromPage == "otp-login") {
      authController.verifyOtpForPhoneOtpLogin(
        phone: identity,
        otp: otp,
        redirectUrl: widget.redirectRoute,
      );
    } else if (widget.fromPage == "firebase-otp" ||
        (widget.fromPage == "forget-password" && identityType == "phone") &&
            (widget.firebaseSession ?? '').isNotEmpty) {
      authController.verifyOtpForFirebaseOtp(
        session: widget.firebaseSession,
        phone: identity,
        code: otp,
        fromPage: widget.fromPage,
        redirectUrl: widget.redirectRoute,
      );
    } else {
      authController.updateForgetPasswordUrlSessionExpiredStatus(status: false);
      authController
          .verifyOtpForForgetPasswordScreen(identity, identityType, otp)
          .then((status) async {
            if (status.isSuccess!) {
              Get.offNamed(
                ServiceRouteHelper.getChangePasswordRoute(
                  body: ForgetPasswordBody(
                    identity: identity,
                    identityType: identityType,
                    otp: otp,
                    fromUrl: 0,
                  ),
                  redirectUrl: widget.redirectRoute,
                ),
              );
            } else {
              customSnackBar(status.message.toString().capitalizeFirst);
            }
          });
    }
  }
}
