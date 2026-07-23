import 'dart:convert';
import 'package:demandium/common/widgets/confirmation_widget.dart';
import 'package:demandium/feature/checkout/model/payment_response_model.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

enum PageState { orderDetails, payment, complete }

enum PaymentMethodName { digitalPayment, cos, walletMoney, offline, none }

class CheckOutController extends GetxController implements GetxService {
  final CheckoutRepo checkoutRepo;
  CheckOutController({required this.checkoutRepo});

  PageState currentPageState = PageState.orderDetails;
  var selectedPaymentMethod = PaymentMethodName.none;
  bool showCoupon = false;
  bool cancelPayment = false;

  PostDetailsContent? postDetails;
  double totalAmount = 0.0;
  double referralDiscountAmount = 0.0;
  double totalVat = 0.0;

  DigitalPaymentMethod? _selectedDigitalPaymentMethod;
  DigitalPaymentMethod? get selectedDigitalPaymentMethod =>
      _selectedDigitalPaymentMethod;

  OfflinePaymentModel? _selectedOfflineMethod;
  OfflinePaymentModel? get selectedOfflineMethod => _selectedOfflineMethod;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<TextEditingController> _offlinePaymentInputField = [];
  List<TextEditingController> get offlinePaymentInputField =>
      _offlinePaymentInputField;

  List<Map<String, String>> _offlinePaymentInputFieldValues = [];
  List<Map<String, String>> get offlinePaymentInputFieldValues =>
      _offlinePaymentInputFieldValues;

  List<DigitalPaymentMethod> _digitalPaymentList = [];
  List<DigitalPaymentMethod> get digitalPaymentList => _digitalPaymentList;

  List<PaymentMethodButton> _othersPaymentList = [];
  List<PaymentMethodButton> get othersPaymentList => _othersPaymentList;

  List<OfflinePaymentModel> _offlinePaymentModelList = [];
  List<OfflinePaymentModel> get offlinePaymentModelList =>
      _offlinePaymentModelList;

  bool _acceptTerms = false;
  bool get acceptTerms => _acceptTerms;

  bool _isPlacedOrderSuccessfully = true;
  bool get isPlacedOrderSuccessfully => _isPlacedOrderSuccessfully;

  String _bookingReadableId = "";
  String get bookingReadableId => _bookingReadableId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _loading = false;
  bool get loading => _loading;

  bool _isCheckedCreateAccount = false;
  bool get isCheckedCreateAccount => _isCheckedCreateAccount;

  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  void updateState(PageState currentPage, {bool shouldUpdate = true}) {
    currentPageState = currentPage;
    if (shouldUpdate) {
      update();
    }
  }

  void changePaymentMethod({
    DigitalPaymentMethod? digitalMethod,
    OfflinePaymentModel? offlinePaymentModel,
    bool walletPayment = false,
    bool cashAfterService = false,
    bool shouldUpdate = true,
  }) {
    if (offlinePaymentModel != null) {
      _selectedOfflineMethod = offlinePaymentModel;
      selectedPaymentMethod = PaymentMethodName.offline;
    } else if (digitalMethod != null) {
      _selectedDigitalPaymentMethod = digitalMethod;
      _selectedOfflineMethod = null;
      selectedPaymentMethod = PaymentMethodName.digitalPayment;
    } else if (walletPayment) {
      _selectedDigitalPaymentMethod = null;
      _selectedOfflineMethod = null;
      selectedPaymentMethod = PaymentMethodName.walletMoney;
    } else if (cashAfterService) {
      _selectedDigitalPaymentMethod = null;
      _selectedOfflineMethod = null;
      selectedPaymentMethod = PaymentMethodName.cos;
    } else {
      _autoSelectPaymentMethod();
    }

    if (shouldUpdate) {
      update();
    }
  }

  void _autoSelectPaymentMethod() {
    if (_othersPaymentList.isNotEmpty &&
        _othersPaymentList.length == 1 &&
        _digitalPaymentList.isEmpty) {
      selectedPaymentMethod =
          _othersPaymentList[0].paymentMethodName == PaymentMethodName.cos
          ? PaymentMethodName.cos
          : PaymentMethodName.walletMoney;
    } else if (_othersPaymentList.isEmpty &&
        _digitalPaymentList.isNotEmpty &&
        _digitalPaymentList.length == 1) {
      if (_digitalPaymentList[0].gateway != "offline") {
        selectedPaymentMethod = PaymentMethodName.digitalPayment;
        _selectedDigitalPaymentMethod = _digitalPaymentList[0];
      } else {
        selectedPaymentMethod = PaymentMethodName.offline;
        _selectedDigitalPaymentMethod = _digitalPaymentList[0];
      }
    } else {
      selectedPaymentMethod = PaymentMethodName.none;
      _selectedDigitalPaymentMethod = null;
      _selectedOfflineMethod = null;
    }
  }

  void initializedOfflinePaymentTextField({
    bool shouldUpdate = false,
    List<BookingOfflinePayment>? existingData,
    String? existingOfflineId,
  }) {
    _offlinePaymentInputField = [];
    _offlinePaymentInputFieldValues = [];
    for (
      int i = 0;
      i < selectedOfflineMethod!.customerInformation!.length;
      i++
    ) {
      if (selectedOfflineMethod?.id == existingOfflineId &&
          existingData != null) {
        int? index = existingData.indexWhere(
          (element) =>
              element.key ==
              selectedOfflineMethod!.customerInformation?[i].fieldName,
        );
        Get.find<CheckOutController>().offlinePaymentInputField.add(
          TextEditingController(
            text: index != -1 ? existingData[index].value : "",
          ),
        );
      } else {
        Get.find<CheckOutController>().offlinePaymentInputField.add(
          TextEditingController(),
        );
      }
    }
    if (shouldUpdate) {
      update();
    }
  }

  Future<void> placeBookingRequest({
    required String paymentMethod,
    String? schedule,
    int isPartial = 0,
    required AddressModel address,
    String? offlinePaymentId,
    String? customerInformation,
    double? bookingAmount,
    int? selectedOfflinePaymentIndex,
  }) async {
    String zoneId = Get.find<ServiceLocationController>()
        .getUserAddress()!
        .zoneId
        .toString();
    var scheduleController = Get.find<ScheduleController>();

    ServiceType serviceType = scheduleController.selectedServiceType;
    RepeatBookingType repeatBookingType =
        scheduleController.selectedRepeatBookingType;

    SignUpBody? newUserInfo = CheckoutHelper.getNewUserInfo(
      address: address,
      password: passwordController.text,
      isCheckedCreateAccount: isCheckedCreateAccount,
    );

    String? repeatBookingDates = CheckoutHelper.getRepeatBookingScheduleList(
      repeatBookingType: repeatBookingType,
      dateRange: repeatBookingType == RepeatBookingType.daily
          ? scheduleController.pickedDailyRepeatBookingDateRange
          : scheduleController.pickedWeeklyRepeatBookingDateRange,
      time: repeatBookingType == RepeatBookingType.daily
          ? scheduleController.pickedDailyRepeatTime
          : scheduleController.pickedWeeklyRepeatTime,
      dateTimeList: scheduleController.pickedCustomRepeatBookingDateTimeList,
      selectedDays: scheduleController.getWeeklyPickedDays(),
    );

    _isLoading = true;
    update();

    if (Get.find<ServiceCartController>().cartList.isNotEmpty) {
      Response response = await checkoutRepo.placeBookingRequest(
        paymentMethod: paymentMethod,
        zoneId: zoneId,
        schedule: schedule,
        serviceAddressID: address.id == "null" ? "" : address.id,
        serviceAddress: address,
        isPartial: isPartial,
        serviceType: serviceType.name,
        bookingType: repeatBookingType.name,
        dates: repeatBookingDates,
        newUserInfo: newUserInfo,
        serviceLocation: Get.find<ServiceLocationController>()
            .selectedServiceLocationType
            .name,
      );
      if (response.statusCode == 200 &&
          response.body["response_code"] == "booking_place_success_200") {
        _isPlacedOrderSuccessfully = true;
        _bookingReadableId = response.body['content']['readable_id'].toString();
        String? token = response.body['content']['token'];
        Get.find<ServiceCartController>().getCartListFromServer();

        if (paymentMethod != "offline_payment") {
          updateState(PageState.complete);
          if (ResponsiveHelper.isWeb()) {
            String token = base64Encode(
              utf8.encode("&&attribute_id=$_bookingReadableId"),
            );
            Get.toNamed(
              ServiceRouteHelper.getCheckoutRoute(
                'cart',
                Get.find<CheckOutController>().currentPageState.name,
                "null",
                token: token,
              ),
            );
          }

          customSnackBar(
            '${response.body['message']}'.tr,
            type: ToasterMessageType.success,
            margin: 55,
          );
        } else {
          String? bookingId = response.body['content']['booking_id'][0];
          customSnackBar(
            'now_pay_you_bill_using_the_payment_method'.tr,
            toasterTitle: 'your_booking_has_been_placed_successfully'.tr,
            type: ToasterMessageType.success,
            duration: 4,
          );
          Get.offAllNamed(
            ServiceRouteHelper.getOfflinePaymentRoute(
              totalAmount: bookingAmount ?? 0,
              index: selectedOfflinePaymentIndex ?? 0,
              bookingId: bookingId,
              fromPage: "checkout",
              newUserInfo: newUserInfo,
              readableId: _bookingReadableId,
            ),
          );
        }

        if (token != null) {
          _saveTokenAndHandelPhoneVerification(
            token: token,
            userInfo: newUserInfo,
            paymentMethod: paymentMethod,
          );
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      Get.offNamed(ServiceRouteHelper.getOrderSuccessRoute('fail'));
    }

    _isLoading = false;
    update();
  }

  void _saveTokenAndHandelPhoneVerification({
    String? token,
    SignUpBody? userInfo,
    String? paymentMethod,
  }) {
    bool isActivePhoneVerification =
        Get.find<ServiceSplashController>()
                .configModel
                .content
                ?.phoneVerification ==
            1
        ? true
        : false;

    if (isActivePhoneVerification) {
      if (paymentMethod != "offline_payment") {
        Future.delayed(const Duration(seconds: 1), () {
          if (ResponsiveHelper.isDesktop(Get.context!)) {
            Get.dialog(
              Center(
                child: _guestCreateAccountPhoneVerificationTitle(
                  userInfo: userInfo,
                ),
              ),
            );
          } else {
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: Get.context!,
              builder: (_) {
                return _guestCreateAccountPhoneVerificationTitle(
                  userInfo: userInfo,
                );
              },
            );
          }
        });
      }
    } else {
      if (token != null) {
        Get.find<ServiceAuthController>().saveUserToken(token: token);
        Get.find<UserController>().getUserInfo();
      }
    }
  }

  Widget _guestCreateAccountPhoneVerificationTitle({SignUpBody? userInfo}) {
    return ConfirmationWidget(
      icon: Images.otp,
      iconSize: 100,
      title: "need_to_verify_your_phone",
      subtitleWidget: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: DefaultTextStyle.of(Get.context!).style,
          children: [
            TextSpan(
              text: 'account_created_successfully_verify_your_phone'.tr,
              style: robotoRegular.copyWith(
                color: Theme.of(
                  Get.context!,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            TextSpan(
              text: StringParser.obfuscateMiddle("${userInfo?.phone}"),
              style: robotoMedium.copyWith(
                color: Theme.of(Get.context!).textTheme.bodyLarge!.color,
                height: 1.5,
              ),
            ),

            TextSpan(
              text: 'you_can_skip_now_but_later'.tr,
              style: robotoRegular.copyWith(
                color: Theme.of(
                  Get.context!,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
      yesButtonColor: Theme.of(Get.context!).colorScheme.primary,
      yesButtonText: 'verify_now'.tr,
      noButtonText: "not_now".tr,
      onYesPressed: () async {
        var config = Get.find<ServiceSplashController>().configModel.content;
        String identity = userInfo?.phone ?? "";
        String identityType = "phone";
        SendOtpType type = config?.firebaseOtpVerification == 1
            ? SendOtpType.firebase
            : SendOtpType.verification;

        await Get.find<ServiceAuthController>()
            .sendVerificationCode(
              identity: identity,
              identityType: identityType,
              type: type,
            )
            .then((status) {
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
                    ),
                  );
                } else {
                  customSnackBar(status.message.toString().capitalizeFirst);
                }
              }
            });
      },
    );
  }

  Future<void> getPostDetails(String postID, String bidId) async {
    totalAmount = 0.0;
    postDetails = null;
    Response response = await checkoutRepo.getPostDetails(postID, bidId);
    if (response.body['response_code'] == 'default_200') {
      postDetails = PostDetailsContent.fromJson(
        response.body['content']['post_details'],
      );
      totalAmount = postDetails?.service?.tax ?? 0;
      if (postDetails?.serviceAddress != null) {
        Get.find<ServiceLocationController>().updateSelectedAddress(
          postDetails?.serviceAddress,
          shouldUpdate: false,
        );
      }
      if (postDetails?.bookingSchedule != null) {
        Get.find<ScheduleController>().buildSchedule(
          scheduleType: ScheduleType.schedule,
          schedule: postDetails?.bookingSchedule,
        );
      }
      if (response.body['content']['referral_amount'] != null) {
        referralDiscountAmount =
            double.tryParse(
              response.body['content']['referral_amount'].toString(),
            ) ??
            0;
      }
    } else {
      postDetails = PostDetailsContent();
      if (response.statusCode != 200) {
        ApiChecker.checkApi(response);
      }
    }
    update();
  }

  Future<bool> checkExistingUser({required String phone}) async {
    _isLoading = true;
    update();
    Response? response = await checkoutRepo.checkExistingUser(phone: phone);

    if (response!.statusCode == 400 &&
        response.body['response_code'] == "user_exist_400") {
      _isLoading = false;
      update();
      return false;
    } else {
      _isLoading = false;
      update();
      return true;
    }
  }

  Future<void> submitOfflinePaymentData({
    required String bookingId,
    required String offlinePaymentId,
    required offlinePaymentInfo,
    required int isPartialPayment,
    required String fromPage,
    SignUpBody? newUserInfo,
    String? readableId,
  }) async {
    _isLoading = true;
    update();
    Response? response = await checkoutRepo.submitOfflinePaymentData(
      bookingId: bookingId,
      offlinePaymentId: offlinePaymentId,
      offlinePaymentInfo: offlinePaymentInfo,
      isPartialPayment: isPartialPayment,
    );

    if (response!.statusCode == 200) {
      customSnackBar(
        'now_wait_for_your_payment_to_be_verified'.tr,
        toasterTitle: "your_payment_confirm_successfully".tr,
        type: ToasterMessageType.success,
      );

      if (fromPage == "checkout") {
        String? token;
        if (readableId != null) {
          token = base64Encode(utf8.encode("&&attribute_id=$readableId"));
        }
        Get.toNamed(
          ServiceRouteHelper.getCheckoutRoute(
            'cart',
            "complete",
            "null",
            token: token,
          ),
        );
      } else if (fromPage == "custom-post") {
        Get.offNamed(ServiceRouteHelper.getOrderSuccessRoute('success'));
      } else {
        await Get.find<BookingDetailsController>().getBookingDetails(
          bookingId: bookingId,
        );
        if (Navigator.canPop(Get.context!)) {
          Get.back();
        } else {
          Get.offAllNamed(ServiceRouteHelper.getMainRoute('home'));
        }
      }

      if (fromPage == "checkout" &&
          Get.find<ServiceSplashController>()
                  .configModel
                  .content
                  ?.phoneVerification ==
              1 &&
          !Get.find<ServiceAuthController>().isLoggedIn()) {
        Future.delayed(const Duration(seconds: 1), () {
          _saveTokenAndHandelPhoneVerification(userInfo: newUserInfo);
        });
      }
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  Future<void> switchPaymentMethod({
    required String bookingId,
    required String paymentMethod,
    int isPartial = 0,
    String? offlinePaymentId,
    String? offlinePaymentInfo,
  }) async {
    _isLoading = true;
    update();
    Response? response = await checkoutRepo.switchPaymentMethod(
      bookingId: bookingId,
      paymentMethod: paymentMethod,
      offlinePaymentId: offlinePaymentId,
      offlinePaymentInfo: offlinePaymentInfo,
      isPartial: isPartial,
    );

    if (response!.statusCode == 200) {
      await Get.find<BookingDetailsController>().getBookingDetails(
        bookingId: bookingId,
      );
      Get.back();
      customSnackBar(
        "your_payment_confirm_successfully".tr,
        type: ToasterMessageType.success,
        showDefaultSnackBar: false,
      );
    } else {
      ApiChecker.checkApi(response, showDefaultToaster: false);
    }

    _isLoading = false;
    update();
  }

  void calculateTotalAmount(double amount) {
    totalAmount = 0.00;
    totalVat = 0.00;
    double serviceTax = postDetails?.service?.tax ?? 1;
    double extraFee = CheckoutHelper.getAdditionalCharge();
    totalAmount =
        amount +
        ((amount * serviceTax) / 100) +
        extraFee -
        referralDiscountAmount;
    totalVat = (amount * serviceTax) / 100;
  }

  Future<void> getOfflinePaymentMethod(
    bool isReload, {
    bool shouldUpdate = true,
    int? selectedIndex,
    AutoScrollController? scrollController,
  }) async {
    if (_offlinePaymentModelList.isEmpty || isReload) {
      _offlinePaymentModelList = [];
    }

    if (_offlinePaymentModelList.isEmpty) {
      _loading = true;
      Response response = await checkoutRepo.getOfflinePaymentMethod();
      if (response.statusCode == 200) {
        _offlinePaymentModelList = [];
        List<dynamic> list = response.body['content']['data'];
        for (var element in list) {
          _offlinePaymentModelList.add(OfflinePaymentModel.fromJson(element));
        }

        if (_offlinePaymentModelList.isNotEmpty) {
          if (selectedIndex == null ||
              _offlinePaymentModelList.length < selectedIndex) {
            _selectedOfflineMethod = _offlinePaymentModelList.first;
          } else {
            _selectedOfflineMethod = _offlinePaymentModelList[selectedIndex];

            if (selectedIndex != -1) {
              await scrollController!.scrollToIndex(
                selectedIndex,
                preferPosition: AutoScrollPosition.middle,
              );
              await scrollController.highlight(selectedIndex);
            }
          }
        }
      }
      _loading = false;
      update();
    }
  }

  Future<PaymentResponseModel?> getDigitalPaymentResponse({
    String? transactionId,
  }) async {
    Response response = await checkoutRepo.getDigitalPaymentResponse(
      transactionId: transactionId,
    );

    PaymentResponseModel? paymentResponseModel;
    if (response.statusCode == 200) {
      paymentResponseModel = PaymentResponseModel.fromJson(response.body);
    }

    return paymentResponseModel;
  }

  void getPaymentMethodList({
    bool shouldUpdate = false,
    bool isPartialPayment = false,
    bool avoidPartialPayment = false,
  }) {
    final ConfigModel configModel =
        Get.find<ServiceSplashController>().configModel;
    _digitalPaymentList = [];
    _othersPaymentList = [];
    _isLoading = false;

    if (isPartialPayment &&
        configModel.content?.partialPaymentCombinator != "all" &&
        configModel.content?.partialPayment == 1) {
      if (configModel.content?.partialPaymentCombinator == "digital_payment") {
        _othersPaymentList = [
          if (configModel.content?.walletStatus == 1 &&
              Get.find<ServiceAuthController>().isLoggedIn() &&
              Get.find<ServiceCartController>().walletBalance > 0 &&
              !avoidPartialPayment)
            PaymentMethodButton(
              title: "pay_via_wallet".tr,
              paymentMethodName: PaymentMethodName.walletMoney,
              assetName: Images.walletMenu,
            ),
        ];
        if (configModel.content?.digitalPayment == 1) {
          digitalPaymentList.addAll(
            configModel.content?.paymentMethodList ?? [],
          );
        }
      } else if (configModel.content?.partialPaymentCombinator ==
          "cash_after_service") {
        _digitalPaymentList = [];
        _othersPaymentList = [
          if (configModel.content?.walletStatus == 1 &&
              Get.find<ServiceAuthController>().isLoggedIn() &&
              Get.find<ServiceCartController>().walletBalance > 0 &&
              !avoidPartialPayment)
            PaymentMethodButton(
              title: "pay_via_wallet".tr,
              paymentMethodName: PaymentMethodName.walletMoney,
              assetName: Images.walletMenu,
            ),
          if (configModel.content?.cashAfterService == 1)
            PaymentMethodButton(
              title: "pay_after_service".tr,
              paymentMethodName: PaymentMethodName.cos,
              assetName: Images.cod,
            ),
        ];
      } else if (configModel.content?.partialPaymentCombinator ==
          "offline_payment") {
        _othersPaymentList = [
          if (configModel.content?.walletStatus == 1 &&
              Get.find<ServiceAuthController>().isLoggedIn() &&
              Get.find<ServiceCartController>().walletBalance > 0 &&
              !avoidPartialPayment)
            PaymentMethodButton(
              title: "pay_via_wallet".tr,
              paymentMethodName: PaymentMethodName.walletMoney,
              assetName: Images.walletMenu,
            ),
        ];
        if (configModel.content?.offlinePayment == 1) {
          digitalPaymentList.add(
            DigitalPaymentMethod(gateway: "offline", gatewayImage: ""),
          );
        }
      }
    } else {
      _othersPaymentList = [
        if (configModel.content?.walletStatus == 1 &&
            Get.find<ServiceAuthController>().isLoggedIn() &&
            Get.find<ServiceCartController>().walletBalance > 0 &&
            !avoidPartialPayment)
          PaymentMethodButton(
            title: "pay_via_wallet".tr,
            paymentMethodName: PaymentMethodName.walletMoney,
            assetName: Images.walletMenu,
          ),

        if (configModel.content?.cashAfterService == 1)
          PaymentMethodButton(
            title: "pay_after_service".tr,
            paymentMethodName: PaymentMethodName.cos,
            assetName: Images.cod,
          ),
      ];

      if (configModel.content?.digitalPayment == 1) {
        digitalPaymentList.addAll(configModel.content?.paymentMethodList ?? []);
      }
      if (configModel.content?.offlinePayment == 1) {
        digitalPaymentList.add(
          DigitalPaymentMethod(gateway: "offline", gatewayImage: ""),
        );
      }
    }
    if (shouldUpdate) {
      update();
    }
  }

  void parseToken(String token) async {
    try {
      _bookingReadableId = StringParser.parseString(
        utf8.decode(base64Url.decode(token)),
        "attribute_id",
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    String? transactionId;
    try {
      transactionId = StringParser.parseString(
        utf8.decode(base64Url.decode(token)),
        "transaction_reference",
      );

      if (transactionId.isNotEmpty) {
        PaymentResponseModel? paymentResponse = await getDigitalPaymentResponse(
          transactionId: transactionId,
        );

        if (paymentResponse != null) {
          String? loginToken = paymentResponse.content?.loginToken;
          String? phone = paymentResponse.content?.newUserPhone;

          SignUpBody? newUserInfo = SignUpBody(phone: phone);
          if (phone != null) {
            _saveTokenAndHandelPhoneVerification(
              token: loginToken,
              userInfo: newUserInfo,
              paymentMethod: "",
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void updateBookingPlaceStatus({
    bool status = true,
    bool shouldUpdate = false,
  }) {
    _isPlacedOrderSuccessfully = status;
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

  void toggleIsCheckedCreateAccount({bool? value, bool shouldUpdate = true}) {
    if (value != null) {
      _isCheckedCreateAccount = value;
    } else {
      _isCheckedCreateAccount = !_isCheckedCreateAccount;
    }
    if (shouldUpdate) {
      update();
    }
  }

  void resetCreateAccountWithExistingInfo() {
    _isCheckedCreateAccount = false;
    passwordController.clear();
    confirmPasswordController.clear();
  }
}
