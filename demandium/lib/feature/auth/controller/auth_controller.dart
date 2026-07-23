import 'dart:developer';

import 'package:demandium/feature/auth/controller/facebook_login_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class ServiceAuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;

  bool _isLoading = false;
  bool _isResendLoading = false;
  bool _acceptTerms = false;
  bool _forgetPasswordUrlSessionExpired = false;
  bool savedCookiesData = false;

  ServiceAuthController({required this.authRepo});
  bool get isLoading => _isLoading;
  bool get isResendLoading => _isResendLoading;
  bool get forgetPasswordUrlSessionExpired => _forgetPasswordUrlSessionExpired;
  bool get acceptTerms => _acceptTerms;

  String _verificationCode = '';
  String get verificationCode => _verificationCode;

  bool _isNumberLogin = false;
  bool get isNumberLogin => _isNumberLogin;

  bool _isActiveRememberMe = false;
  bool get isActiveRememberMe => _isActiveRememberMe;

  bool _isWrongOtpSubmitted = false;
  bool get isWrongOtpSubmitted => _isWrongOtpSubmitted;
  void setWrongOtpSubmitted(bool value) {
    _isWrongOtpSubmitted = value;
  }

  LoginMedium _selectedLoginMedium = LoginMedium.manual;
  LoginMedium get selectedLoginMedium => _selectedLoginMedium;

  var countryDialCode = "+880";
  final String _mobileNumber = '';
  String get mobileNumber => _mobileNumber;

  var newPasswordController = TextEditingController();
  var confirmNewPasswordController = TextEditingController();

  final GoogleSignIn signIn = GoogleSignIn.instance;
  GoogleSignInAccount? googleAccount;

  @override
  void onInit() {
    super.onInit();
    countryDialCode = CountryCode.fromCountryCode(
      Get.find<ServiceSplashController>().configModel.content != null
          ? Get.find<ServiceSplashController>()
                .configModel
                .content!
                .countryCode!
          : "BD",
    ).dialCode!;
  }

  Future<void> registration({
    required SignUpBody signUpBody,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();

    Response response = await authRepo.registration(signUpBody);
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'registration_200') {
      var config = Get.find<ServiceSplashController>().configModel.content;
      if (config?.phoneVerification == 1 || config?.emailVerification == 1) {
        String identity = config?.phoneVerification == 1
            ? signUpBody.phone!.trim()
            : signUpBody.email!.trim();
        String identityType = config?.phoneVerification == 1
            ? "phone"
            : "email";
        SendOtpType type =
            config?.phoneVerification == 1 &&
                config?.firebaseOtpVerification == 1
            ? SendOtpType.firebase
            : SendOtpType.verification;
        await sendVerificationCode(
          identity: identity,
          identityType: identityType,
          type: type,
        ).then((status) {
          if (status != null) {
            if (status.isSuccess!) {
              Get.toNamed(
                ServiceRouteHelper.getVerificationRoute(
                  identity: identity,
                  identityType: identityType,
                  fromPage:
                      config?.phoneVerification == 1 &&
                          config?.firebaseOtpVerification == 1
                      ? "firebase-otp"
                      : "verification",
                  firebaseSession: type == SendOtpType.firebase
                      ? status.message
                      : null,
                  redirectUrl: redirectUrl,
                ),
              );
            } else {
              customSnackBar(status.message.toString().capitalizeFirst);
            }
          }
        });
      } else {
        await _saveTokenAndNavigate(
          redirectRoute:
              redirectUrl ??
              (Get.find<ServiceLocationController>().getUserAddress() != null
                  ? ServiceRouteHelper.home
                  : ServiceRouteHelper.pickMap),
          token: response.body['content']['token'],
          emailPhone: "",
          password: "",
        );
      }
      customSnackBar('registration_200'.tr, type: ToasterMessageType.success);
    } else if (response.statusCode == 404 &&
        response.body['response_code'] == "referral_code_400") {
      customSnackBar("invalid_refer_code".tr);
    } else if (response.statusCode == 400 &&
        response.body['response_code'] == "default_400") {
      customSnackBar(response.body['errors'][0]['message']);
    } else {
      customSnackBar(response.statusText);
    }

    _isLoading = false;
    update();
  }

  Future<void> login({
    String? redirectRoute,
    required String emailPhone,
    required String password,
    required String type,
  }) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.login(
      phone: emailPhone,
      password: password,
      type: type,
    );
    if (response!.statusCode == 200 &&
        response.body['response_code'] == "auth_login_200") {
      await _saveTokenAndNavigate(
        redirectRoute: redirectRoute,
        token: response.body['content']['token'],
        emailPhone: emailPhone,
        password: password,
      );
    } else if (response.statusCode == 401 &&
            (response.body["response_code"] == "unverified_phone_401") ||
        response.body["response_code"] == "unverified_email_401") {
      var config = Get.find<ServiceSplashController>().configModel.content;

      SendOtpType sendOtpType =
          type == "phone" && config?.firebaseOtpVerification == 1
          ? SendOtpType.firebase
          : SendOtpType.verification;
      await sendVerificationCode(
        identity: emailPhone,
        identityType: type,
        type: sendOtpType,
      ).then((status) {
        if (status != null) {
          if (status.isSuccess!) {
            Get.toNamed(
              ServiceRouteHelper.getVerificationRoute(
                identity: emailPhone,
                identityType: type,
                fromPage:
                    type == "phone" && config?.firebaseOtpVerification == 1
                    ? "firebase-otp"
                    : "verification",
                firebaseSession: sendOtpType == SendOtpType.firebase
                    ? status.message
                    : null,
                redirectUrl: redirectRoute,
              ),
            );
          } else {
            customSnackBar(status.message.toString().capitalizeFirst);
          }
        }
      });
    } else {
      customSnackBar(
        response.body["message"].toString().capitalizeFirst ??
            response.statusText,
      );
    }
    _isLoading = false;
    update();
  }

  Future<void> logOut() async {
    Response? response = await authRepo.logOut();
    if (response?.statusCode == 200) {
      if (kDebugMode) {
        print("Logout successfully with ${response?.body}");
      }
    } else {
      if (kDebugMode) {
        print("Logout Failed");
      }
    }
  }

  Future<void> _saveTokenAndNavigate({
    String? redirectRoute,
    required String token,
    String? emailPhone,
    String? password,
  }) async {
    authRepo.saveUserToken(token);

    Get.find<ServiceSplashController>().updateLanguage(true);
    Get.find<ServiceLocationController>().getAddressList();

    if (_isActiveRememberMe) {
      saveUserNumberAndPassword(
        number: emailPhone ?? "",
        password: password ?? "",
      );
    } else {
      clearUserNumberAndPassword();
    }

    if (redirectRoute != null) {
      if (Get.find<ServiceLocationController>().getUserAddress() != null) {
        updateSavedLocalAddress();
      }

      final routeData = ServiceRouteHelper.parseRedirectRouteToNavigate(
        redirectRoute,
      );

      Get.offAllNamed(
        routeData.path,
        parameters: (routeData.parameters?.isEmpty ?? true)
            ? null
            : routeData.parameters,
      );
    } else {
      // Get.offAllNamed(ServiceRouteHelper.getMainRoute('home'));
    }
  }

  Future<void> updateSavedLocalAddress({
    bool saveContactPersonInfo = true,
  }) async {
    AddressModel addressModel = Get.find<ServiceLocationController>()
        .getUserAddress()!;

    if (saveContactPersonInfo) {
      if (Get.find<UserController>().userInfoModel == null) {
        Get.find<UserController>().getUserInfo(reload: true);
      } else {
        String? firstName;
        if (Get.find<ServiceAuthController>().isLoggedIn() &&
            Get.find<UserController>().userInfoModel?.phone != null &&
            Get.find<UserController>().userInfoModel?.fName != null) {
          firstName = "${Get.find<UserController>().userInfoModel?.fName} ";
        }

        addressModel.contactPersonNumber = firstName != null
            ? Get.find<UserController>().userInfoModel?.phone ?? ""
            : "";
        addressModel.contactPersonName = firstName != null
            ? "$firstName${Get.find<UserController>().userInfoModel?.lName ?? ""}"
            : "";
        addressModel.addressLabel = 'others';
      }
    } else {
      addressModel.contactPersonNumber = "";
      addressModel.contactPersonName = "";
    }
    Get.find<ServiceLocationController>().saveUserAddress(addressModel);
  }

  Future<void> loginWithSocialMedia(
    SocialLogInBody socialLogInBody,
    Function callback,
  ) async {
    _isLoading = true;
    update();
    Response response = await authRepo.loginWithSocialMedia(socialLogInBody);
    _isLoading = false;
    if (response.statusCode == 200 &&
        response.body['response_code'] == "auth_login_200") {
      Map map = response.body;
      String? message = '';
      String? token = '';
      String? tempToken = '';
      String? email;
      UserInfoModel? userInfoModel;
      try {
        message = map['message'] ?? '';
      } catch (e) {
        debugPrint('error ===> $e');
      }

      try {
        token = map['content']['token'];
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      try {
        tempToken = map['content']['temporary_token'];
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      try {
        email = map['content']['email'];
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      if (map['content']['user'] != null) {
        try {
          userInfoModel = UserInfoModel.fromJson(map['content']['user']);
          callback(
            true,
            null,
            message,
            null,
            userInfoModel,
            socialLogInBody.medium,
            null,
            null,
          );
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }

      if (token != null) {
        saveUserNumberAndPassword(number: "", password: "");
        await authRepo.saveUserToken(token);
        await authRepo.saveUserToken(token);
        await Get.find<UserController>().getUserInfo(reload: true);
        authRepo.updateToken();
        callback(
          true,
          token,
          message,
          null,
          null,
          null,
          socialLogInBody.userName,
          socialLogInBody.email,
        );
      }

      if (tempToken != null) {
        callback(
          true,
          null,
          message,
          tempToken,
          null,
          null,
          socialLogInBody.userName,
          socialLogInBody.email ?? email,
        );
      }

      update();
    } else {
      String? errorMessage = response.body['message'] ?? response.statusText;
      callback(
        false,
        '',
        errorMessage,
        null,
        null,
        null,
        socialLogInBody.userName,
        socialLogInBody.email,
      );
      update();
    }
  }

  Future<ResponseModel?> sendVerificationCode({
    required String identity,
    required String identityType,
    required SendOtpType type,
    int checkUser = 1,
    String fromPage = "",
    bool isResend = false,
    String? redirectUrl,
  }) async {
    ResponseModel? responseModel;
    if (isResend) {
      _isResendLoading = true;
      update();
    }
    if (type == SendOtpType.firebase) {
      log(
        "Sending OTP for Firebase Verification to $identity with type $identityType from page $fromPage",
      );
      _sendOtpForFirebaseVerification(
        identity: identity,
        identityType: identityType,
        fromPage: fromPage,
        isResend: isResend,
        redirectUrl: redirectUrl,
      );
    } else if (type == SendOtpType.verification) {
      log(
        "Sending OTP for Verification Screen to $identity with type $identityType from page $fromPage",
      );
      responseModel = await _sendOtpForVerificationScreen(
        identity: identity,
        identityType: identityType,
        checkUser: checkUser,
        isResend: isResend,
      );
    } else {
      responseModel = await _sendOtpForForgetPassword(
        identity: identity,
        identityType: identityType,
        isResend: isResend,
      );
    }
    if (isResend) {
      _isResendLoading = false;
      update();
    }
    return responseModel;
  }

  Future<ResponseModel> sendOtpForVerificationScreenFromMain({
    required String identity,
    required String identityType,
    required int checkUser,
    bool isResend = false,
  }) async {
    if (!isResend) {
      _isLoading = true;
      update();
    }
    log(
      "API Call: Sending OTP for Verification Screen to $identity with type $identityType and checkUser $checkUser",
    );
    Response response = await authRepo.sendOtpForVerificationScreen(
      identity: identity,
      identityType: identityType,
      checkUser: checkUser,
    );
    // log(
    //   "API Response: Status Code ${response.statusCode}, Body: ${response.body['content']}, Message: ${response.body['message']}",
    // );
    if (response.statusCode == 200 &&
        response.body["response_code"] == "default_200") {
      if (!isResend) {
        _isLoading = false;
        update();
      }
      Map<String, dynamic> content = response.body['content'] ?? {};
      ResponseModel _response = ResponseModel(true, "", content);
      // log('response model ${_response.content?['otp']}');
      return _response;
    } else {
      if (!isResend) {
        _isLoading = false;
        update();
      }
      String responseText = "";
      if (response.statusCode == 500) {
        responseText = "Internal Server Error";
      } else {
        responseText = response.body["message"] ?? response.statusText;
      }
      return ResponseModel(false, responseText);
    }
  }

  Future<ResponseModel> _sendOtpForVerificationScreen({
    required String identity,
    required String identityType,
    required int checkUser,
    bool isResend = false,
  }) async {
    if (!isResend) {
      _isLoading = true;
      update();
    }

    Response response = await authRepo.sendOtpForVerificationScreen(
      identity: identity,
      identityType: identityType,
      checkUser: checkUser,
    );

    log(response.body.toString());

    if (response.statusCode == 200 &&
        response.body["response_code"] == "default_200") {
      if (!isResend) {
        _isLoading = false;
        update();
      }

      return ResponseModel(true, "");
    } else {
      if (!isResend) {
        _isLoading = false;
        update();
      }
      String responseText = "";
      if (response.statusCode == 500) {
        responseText = "Internal Server Error";
      } else {
        responseText = response.body["message"] ?? response.statusText;
      }
      return ResponseModel(false, responseText);
    }
  }

  Future<ResponseModel> _sendOtpForForgetPassword({
    required String identity,
    required String identityType,
    bool isResend = false,
  }) async {
    if (!isResend) {
      _isLoading = true;
      update();
    }
    Response response = await authRepo.sendOtpForForgetPassword(
      identity,
      identityType,
    );

    if (response.statusCode == 200 &&
        response.body["response_code"] == "default_200") {
      if (!isResend) {
        _isLoading = false;
        update();
      }
      return ResponseModel(true, "");
    } else {
      if (!isResend) {
        _isLoading = false;
        update();
      }
      String responseText = "";
      if (response.statusCode == 500) {
        responseText = "Internal Server Error";
      } else {
        responseText = response.body["message"] ?? response.statusText;
      }
      return ResponseModel(false, responseText);
    }
  }

  Future<void> _sendOtpForFirebaseVerification({
    required String identity,
    required String identityType,
    required String fromPage,
    bool isResend = false,
    String? redirectUrl,
  }) async {
    if (!isResend) {
      _isLoading = true;
      update();
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: identity,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        if (!isResend) {
          _isLoading = false;
        }
        if (isResend) {
          _isResendLoading = false;
        }
        update();
        if (fromPage == "profile") {
          Get.back();
        }
        if (e.code == 'invalid-phone-number') {
          customSnackBar(
            'please_submit_a_valid_phone_number',
            type: ToasterMessageType.info,
          );
        } else {
          customSnackBar('${e.message}'.replaceAll('_', ' ').capitalizeFirst);
        }
      },
      codeSent: (String vId, int? resendToken) {
        if (!isResend) {
          _isLoading = false;
        }
        if (isResend) {
          _isResendLoading = false;
        }
        update();
        if (fromPage == "profile") {
          Get.back();
        }
        Get.toNamed(
          ServiceRouteHelper.getVerificationRoute(
            identity: identity,
            identityType: identityType,
            fromPage: fromPage == "forget-password"
                ? "forget-password"
                : "firebase-otp",
            firebaseSession: vId,
            redirectUrl: redirectUrl,
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyOtpForVerificationScreen({
    required String identity,
    required String identityType,
    required String otp,
    required String fromPage,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.verifyOtpForVerificationScreen(
      identity,
      identityType,
      otp,
    );

    if (response!.statusCode == 200 &&
        response.body['response_code'] == "default_200") {
      customSnackBar(
        response.body["message"],
        type: ToasterMessageType.success,
      );
      if (fromPage == "profile") {
        Get.find<UserController>().getUserInfo(reload: false);
        if (Navigator.canPop(Get.context!)) {
          Navigator.pop(Get.context!);
        } else {
          Get.toNamed(ServiceRouteHelper.getEditProfileRoute());
        }
      } else {
        await _saveTokenAndNavigate(
          redirectRoute:
              redirectUrl ??
              (Get.find<ServiceLocationController>().getUserAddress() != null
                  ? ServiceRouteHelper.home
                  : ServiceRouteHelper.pickMap),
          token: response.body['content']['token'],
          emailPhone: "",
          password: "",
        );
      }
    } else {
      ResponseModel responseModel = _checkWrongOtp(response);
      customSnackBar(responseModel.message.toString().capitalizeFirst);
    }
    _isLoading = false;
    update();
  }

  Future<ResponseModel> verifyOtpForForgetPasswordScreen(
    String identity,
    String identityType,
    String otp, {
    bool fromOutsideUrl = false,
    bool shouldUpdate = true,
  }) async {
    _isLoading = true;

    if (fromOutsideUrl) {
      _forgetPasswordUrlSessionExpired = true;
    }

    if (shouldUpdate) {
      update();
    }

    Response response = await authRepo.verifyOtpForForgetPassword(
      identity,
      identityType,
      otp,
    );

    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_200') {
      _isLoading = false;
      _forgetPasswordUrlSessionExpired = false;
      update();
      return ResponseModel(true, "successfully_verified");
    } else {
      _isLoading = false;
      update();
      String responseText = "";
      if (response.statusCode == 500) {
        responseText = "Internal Server Error";
      } else if (response.statusCode == 400 &&
          response.body['errors'] != null) {
        responseText = response.body['errors'][0]['message'];
      } else {
        responseText = response.body["message"] ?? response.statusText;
      }
      return ResponseModel(false, responseText);
    }
  }

  Future<void> verifyOtpForPhoneOtpLoginFromMain({
    required String phone,
    required String otp,
  }) async {
    log('using this method for phone otp login verification for phone: $phone');
    _isLoading = true;
    update();
    Response? response = await authRepo.verifyOtpForPhoneOtpLogin(
      phone: phone,
      otp: otp,
    );
    log('API response for phone otp login verification: ${response?.body}');

    if (response!.statusCode == 200) {
      if (response.body['content']['token'] != null) {
        await _saveTokenAndNavigate(
          redirectRoute: null,
          token: response.body['content']['token'],
          emailPhone: phone,
          password: "",
        );
      } else if (response.body['content']['temporary_token'] != null) {
        // Get.offNamed(
        //   ServiceRouteHelper.getUpdateProfileRoute(
        //     phone: phone,
        //     redirectUrl: redirectUrl,
        //   ),
        // );
      }
    } else {
      ResponseModel responseModel = _checkWrongOtp(response);
      customSnackBar(responseModel.message ?? "");
    }
    _isLoading = false;
    update();
  }

  Future<void> verifyOtpForPhoneOtpLogin({
    required String phone,
    required String otp,
    String? redirectUrl,
  }) async {
    log('using this method for phone otp login verification for phone: $phone');
    _isLoading = true;
    update();
    Response? response = await authRepo.verifyOtpForPhoneOtpLogin(
      phone: phone,
      otp: otp,
    );

    if (response!.statusCode == 200) {
      if (response.body['content']['token'] != null) {
        await _saveTokenAndNavigate(
          redirectRoute: redirectUrl ?? ServiceRouteHelper.getMainRoute("home"),
          token: response.body['content']['token'],
          emailPhone: phone,
          password: "",
        );
      } else if (response.body['content']['temporary_token'] != null) {
        Get.offNamed(
          ServiceRouteHelper.getUpdateProfileRoute(
            phone: phone,
            redirectUrl: redirectUrl,
          ),
        );
      }
    } else {
      ResponseModel responseModel = _checkWrongOtp(response);
      customSnackBar(responseModel.message ?? "");
    }
    _isLoading = false;
    update();
  }

  Future<void> verifyOtpForFirebaseOtp({
    String? session,
    String? phone,
    String? code,
    required String fromPage,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.verifyOtpForFirebaseOtpLogin(
      session: session,
      phone: phone,
      code: code,
    );

    if (response!.statusCode == 200) {
      if (fromPage == "forget-password") {
        Get.offNamed(
          ServiceRouteHelper.getChangePasswordRoute(
            body: ForgetPasswordBody(
              identity: phone,
              identityType: "phone",
              otp: code,
              fromUrl: 0,
              isFirebaseOtp: 1,
            ),
            redirectUrl: redirectUrl,
          ),
        );
      } else {
        if (response.body['content']['token'] != null) {
          await _saveTokenAndNavigate(
            redirectRoute:
                redirectUrl ??
                (Get.find<ServiceLocationController>().getUserAddress() != null
                    ? ServiceRouteHelper.home
                    : ServiceRouteHelper.pickMap),
            token: response.body['content']['token'],
            emailPhone: phone,
          );
        } else if (response.body['content']['temporary_token'] != null) {
          Get.offNamed(
            ServiceRouteHelper.getUpdateProfileRoute(
              phone: phone ?? "",
              redirectUrl: redirectUrl,
            ),
          );
        }
      }
    } else {
      ResponseModel responseModel = _checkWrongOtp(response);
      customSnackBar(responseModel.message);
    }
    _isLoading = false;
    update();
  }

  Future<void> updateNewUserProfileAndLoginFromMain({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
  }) async {
    _isLoading = true;
    update();

    log(
      'Updating new user profile and logging in with phone: $phone, email: $email',
    );

    Response response = await authRepo.updateNewUserProfileAndLogin(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
    );

    log(
      'API response for updating new user profile and login: ${response.body}',
    );

    if (response.statusCode == 200) {
      if (response.body['content']['token'] != null) {
        await _saveTokenAndNavigate(
          redirectRoute: null,
          token: response.body['content']['token'],
          emailPhone: phone,
          password: "",
        );
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> updateNewUserProfileAndLogin({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();

    Response response = await authRepo.updateNewUserProfileAndLogin(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
    );

    if (response.statusCode == 200) {
      if (response.body['content']['token'] != null) {
        await _saveTokenAndNavigate(
          redirectRoute:
              redirectUrl ??
              (Get.find<ServiceLocationController>().getUserAddress() != null
                  ? ServiceRouteHelper.home
                  : ServiceRouteHelper.pickMap),
          token: response.body['content']['token'],
          emailPhone: phone,
          password: "",
        );
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> registerWithSocialMedia({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();
    Response response = await authRepo.registerWithSocialMedia(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
    );

    if (response.statusCode == 200) {
      if (response.body['content']['token'] != null) {
        await _saveTokenAndNavigate(
          redirectRoute:
              redirectUrl ??
              (Get.find<ServiceLocationController>().getUserAddress() != null
                  ? ServiceRouteHelper.home
                  : ServiceRouteHelper.pickMap),
          token: response.body['content']['token'],
          emailPhone: "",
          password: "",
        );
      } else if (response.body['content']['temporary_token'] != null) {
        var config = Get.find<ServiceSplashController>().configModel.content;
        SendOtpType type = config?.firebaseOtpVerification == 1
            ? SendOtpType.firebase
            : SendOtpType.verification;

        await sendVerificationCode(
          identity: phone!,
          identityType: "phone",
          type: type,
        ).then((status) {
          if (status != null) {
            if (status.isSuccess!) {
              Get.toNamed(
                ServiceRouteHelper.getVerificationRoute(
                  identity: phone,
                  identityType: "phone",
                  fromPage: type == SendOtpType.firebase
                      ? "firebase-otp"
                      : "otp-login",
                  firebaseSession: type == SendOtpType.firebase
                      ? status.message
                      : null,
                  redirectUrl: redirectUrl,
                ),
              );
            } else {
              customSnackBar(status.message.toString().capitalizeFirst);
            }
          }
        });
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> existingAccountCheck({
    String? email,
    required int userResponse,
    required String medium,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();
    Response response = await authRepo.existingAccountCheck(
      email: email ?? "",
      userResponse: userResponse,
      medium: medium,
    );
    if (response.statusCode == 200) {
      if (response.body['content']['token'] != null) {
        await _saveTokenAndNavigate(
          redirectRoute:
              redirectUrl ??
              (Get.find<ServiceLocationController>().getUserAddress() != null
                  ? ServiceRouteHelper.home
                  : ServiceRouteHelper.pickMap),
          token: response.body['content']['token'],
        );
      } else if (response.body['content']['temporary_token'] != null) {
        Get.offNamed(
          ServiceRouteHelper.getUpdateProfileRoute(
            email: email ?? "",
            tempToken: response.body['content']['temporary_token'],
            redirectUrl: redirectUrl,
          ),
        );
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> resetPassword({
    required String identity,
    required String identityType,
    required String otp,
    required String password,
    required String confirmPassword,
    required int isFirebaseOtp,
    String? redirectUrl,
  }) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.resetPassword(
      identity,
      identityType,
      otp,
      password,
      confirmPassword,
      isFirebaseOtp,
    );

    if (response!.statusCode == 200 &&
        response.body['response_code'] == "default_password_reset_200") {
      Get.offNamed(ServiceRouteHelper.getSignInRoute(redirectUrl: redirectUrl));
      customSnackBar(
        'password_changed_successfully'.tr,
        type: ToasterMessageType.success,
      );
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  ResponseModel _checkWrongOtp(Response response) {
    if (verificationCode.length == 6 && response.statusCode == 403) {
      _isWrongOtpSubmitted = true;
    }
    String responseText = "";
    if (response.statusCode == 500) {
      responseText = "Internal Server Error";
    } else {
      responseText = response.body["message"] ?? "verification_failed".tr;
    }
    return ResponseModel(false, responseText);
  }

  void updateVerificationCode(String query) {
    _verificationCode = query;
    _isWrongOtpSubmitted = false;
    update();
  }

  void updateForgetPasswordUrlSessionExpiredStatus({
    required bool status,
    bool shouldUpdate = false,
  }) {
    _forgetPasswordUrlSessionExpired = status;
    if (shouldUpdate) {
      update();
    }
  }

  void toggleTerms({bool? value, bool shouldUpdate = true}) {
    if (value != null) {
      _acceptTerms = value;
    } else {
      _acceptTerms = !_acceptTerms;
    }
    if (shouldUpdate) {
      update();
    }
  }

  void toggleIsNumberLogin({bool? value, bool isUpdate = true}) {
    if (value == null) {
      _isNumberLogin = !_isNumberLogin;
    } else {
      _isNumberLogin = value;
    }
    initCountryCode();
    if (isUpdate) {
      update();
    }
  }

  void toggleSelectedLoginMedium({
    required LoginMedium loginMedium,
    bool isUpdate = true,
  }) {
    _selectedLoginMedium = loginMedium;
    if (isUpdate) {
      update();
    }
  }

  void cancelTermsAndCondition() {
    _acceptTerms = false;
  }

  void toggleRememberMe({bool? value, bool shouldUpdate = true}) {
    if (value != null) {
      _isActiveRememberMe = value;
    } else {
      _isActiveRememberMe = !_isActiveRememberMe;
    }
    if (shouldUpdate) {
      update();
    }
  }

  void toggleReferralBottomSheetShow() {
    authRepo.toggleReferralBottomSheetShow(false);
    update();
  }

  bool getIsShowReferralBottomSheet() {
    return authRepo.getIsShowReferralBottomSheet();
  }

  bool isLoggedIn() => authRepo.isLoggedIn();
  String getUserNumber() => authRepo.getUserNumber();
  String getUserCountryCode() => authRepo.getUserCountryCode();
  String getUserPassword() => authRepo.getUserPassword();
  bool isNotificationActive() => authRepo.isNotificationActive();

  void saveUserNumberAndPassword({
    required String number,
    required String password,
  }) => authRepo.saveUserNumberAndPassword(number, password, countryDialCode);
  Future<bool> clearUserNumberAndPassword() async =>
      authRepo.clearUserNumberAndPassword();

  bool clearSharedData({Response? response}) =>
      authRepo.clearSharedData(response: response);
  String getUserToken() => authRepo.getUserToken();

  void toggleNotificationSound() {
    authRepo.toggleNotificationSound(!isNotificationActive());
    update();
  }

  // GoogleSignInAccount? googleAccount;
  // GoogleSignInAuthentication? auth;

  // Future<void> socialLogin() async {
  //   googleAccount = (await _googleSignIn.signIn());
  //   auth = await googleAccount?.authentication;
  //   update();
  // }

  // Future<void> googleLogout() async {
  //   try{
  //     googleAccount = (await _googleSignIn.disconnect())!;
  //     auth = await googleAccount!.authentication;
  //   }catch(e){
  //     if (kDebugMode) {
  //       print("");
  //     }
  //   }
  // }

  Future<void> signOutWithFacebook() async {
    await FacebookAuth.instance.logOut();
  }

  Future<void> updateToken() async {
    await authRepo.updateToken();
  }

  Future<void> saveUserToken({required String token}) async {
    await authRepo.saveUserToken(token);
    update();
  }

  void initCountryCode({String? countryCode}) {
    countryDialCode =
        countryCode ??
        CountryCode.fromCountryCode(
          Get.find<ServiceSplashController>()
                  .configModel
                  .content
                  ?.countryCode ??
              "BD",
        ).dialCode ??
        "+880";
  }

  Future<SocialLogInBody?> _googleWebSignIn() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential = await auth.signInWithPopup(
        googleProvider,
      );

      return SocialLogInBody(
        uniqueId: userCredential.credential?.accessToken,
        token: userCredential.credential?.accessToken,
        medium: SocialLoginType.google.name,
        email: userCredential.user?.email,
        guestId: Get.find<ServiceSplashController>().getGuestId(),
      );
    } catch (e) {
      customSnackBar(e.toString());
    }
    return null;
  }

  Future<SocialLogInBody?> googleLogin() async {
    SocialLogInBody? socialLoginModel;

    if (kIsWeb) {
      socialLoginModel = await _googleWebSignIn();
    } else {
      try {
        if (signIn.supportsAuthenticate()) {
          await signIn
              .initialize(serverClientId: AppConstants.googleServerClientId)
              .then((_) async {
                googleAccount = await signIn.authenticate();
                const List<String> scopes = <String>['email'];
                final auth = await googleAccount?.authorizationClient
                    .authorizationForScopes(scopes);

                socialLoginModel = SocialLogInBody(
                  uniqueId: auth?.accessToken,
                  token: auth?.accessToken,
                  medium: SocialLoginType.google.name,
                  email: googleAccount?.email,
                  userName: googleAccount?.displayName,
                  guestId: Get.find<ServiceSplashController>().getGuestId(),
                );
              });
        } else {
          debugPrint("Google Sign-In not supported on this device.");
        }
      } catch (e) {
        debugPrint("google_login: $e");
      }
    }

    return socialLoginModel;
  }

  Future<SocialLogInBody?> facebookLogin() async {
    final FacebookLoginController facebookLoginController =
        Get.find<FacebookLoginController>();

    await facebookLoginController.login();

    if (facebookLoginController.result.status == LoginStatus.success) {
      final Map userData = await facebookLoginController.facebookAuth
          .getUserData(fields: 'name, email');

      return SocialLogInBody(
        email: userData['email'],
        token: facebookLoginController.result.accessToken?.tokenString,
        uniqueId: userData['id'],
        medium: SocialLoginType.facebook.name,
        userName: userData['name'],
        guestId: Get.find<ServiceSplashController>().getGuestId(),
      );
    }

    return null;
  }

  Future<void> googleLogout() async {
    try {
      await signIn.signOut();
      await signIn.disconnect();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> facebookLogout() async {
    await Get.find<FacebookLoginController>().facebookAuth.logOut();
  }

  // Future<void> socialLogout() async {
  //   final UserInfoModel? user = Provider.of<ProfileProvider>(Get.context!, listen: false).userInfoModel;
  //   if(user?.loginMedium?.toLowerCase() == SocialLoginOptionsEnum.google.name) {
  //     try{
  //       await signIn.signOut();
  //       await signIn.disconnect();
  //     }catch(e){
  //       log("Error: $e");
  //     }
  //
  //
  //   }else if(user?.loginMedium?.toLowerCase() == SocialLoginOptionsEnum.facebook.name) {
  //     await facebookAuth.logOut();
  //   }
  //
  // }
}
