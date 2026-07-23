import 'dart:convert';
import 'package:demandium/feature/auth/view/update_profile_screen.dart';
import 'package:demandium/feature/booking/view/repeat_booking_details_screen.dart';
import 'package:demandium/feature/checkout/view/offline_payment_screen.dart';
import 'package:demandium/feature/home/all_category_screen.dart';
import 'package:demandium/feature/provider/view/nearby_provider/near_by_provider_screen.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class ServiceRouteHelper {
  static const String initial = '/service';
  static const String splash = '/service-splash';
  static const String home = '/service-home';
  static const String offers = '/service-offers';
  static const String signIn = '/sign-in';
  static const String signUp = '/service-sign-up';
  static const String accessLocation = '/service-access-location';
  static const String pickMap = '/service-pick-map';
  static const String verification = '/service-verification';
  static const String sendOtpScreen = '/service-send-otp';
  static const String changePassword = '/service-change-password';
  static const String searchScreen = '/service-search';
  static const String serviceDetails = '/service-service';
  static const String profile = '/profile';
  static const String profileEdit = '/service-profile-edit';
  static const String notification = '/service-notification';
  static const String address = '/service-address';
  static const String orderSuccess = '/service-order-completed';
  static const String checkout = '/service-checkout';
  static const String customPostCheckout = '/service-custom-checkout';
  static const String termsAndConditions = '/service-terms-and-conditions';
  static const String aboutUs = '/service-about-us';
  static const String privacyPolicy = '/service-privacy-policy';
  static const String cancellationPolicy = '/service-cancellation-policy';
  static const String refundPolicy = '/service-refund-policy';
  static const String categories = '/service-categories';
  static const String categoryProduct = '/service-category';
  static const String support = '/service-support';
  static const String update = '/service-update';
  static const String cart = '/service-cart';
  static const String addAddress = '/service-add-address';
  static const String editAddress = '/service-edit-address';
  static const String chatScreen = '/service-chat-screen';
  static const String chatInbox = '/service-chat-inbox';
  static const String onBoardScreen = '/service-onBoardScreen';
  static const String settingScreen = '/service-settingScreen';
  static const String languageScreen = '/service-language';
  static const String voucherScreen = '/service-vouchers';
  static const String bookingListScreen = '/service-booking-list';
  static const String bookingDetailsScreen = '/service-booking-details';
  static const String repeatBookingDetailsScreen = '/service-repeat-booking';
  static const String trackBooking = '/service-track-booking';
  static const String rateReviewScreen = '/service-rate-review-screen';
  static const String allServiceScreen = '/service-services';
  static const String featheredServiceScreen =
      '/service-feathered-service-screen';
  static const String subCategoryScreen = '/service-subcategory-screen';
  static const String notLoggedScreen = '/service-not-logged-screen';
  static const String suggestService = '/service-suggest-service';
  static const String suggestServiceList = '/service-suggest-service-list';
  static const String myWallet = '/service-my-wallet';
  static const String loyaltyPoint = '/service-my-point';
  static const String referAndEarn = '/service-refer-and-earn';
  static const String allProviderList = '/service-all-provider';
  static const String providerDetailsScreen = '/service-provider';
  static const String providerReviewScreen = '/service-provider-review-screen';
  static const String providerAvailabilityScreen =
      '/service-provider-availability-screen';
  static const String createPost = '/service-create-post';
  static const String createPostSuccessfully =
      '/service-create-post-successfully';
  static const String myPost = '/service-my-post';
  static const String providerOfferList = '/service-provider-offer-list';
  static const String providerOfferDetails = '/service-provider-offer-details';
  static const String providerWebView = '/service-provider-web-view';
  static const String serviceArea = '/service-service-area';
  static const String serviceAreaMap = '/service-service-area-map';
  static const String customImageListScreen =
      '/service-custom-image-list-screen';
  static const String zoomImage = '/service-zoom-image';
  static const String favorite = '/service-favorite';
  static const String nearByProvider = '/service-nearby-provider';
  static const String maintenance = '/service-maintenance';
  static const String updateProfile = '/service-update-profile';
  static const String offlinePayment = '/service-offline-payment';
  static const String allCategoriesScreen = '/service-all-categories';

  static String getInitialRoute() => initial;
  static String getSplashRoute(NotificationBody? body, String? route) {
    String data = 'null';
    if (body != null) {
      List<int> encoded = utf8.encode(jsonEncode(body));
      data = base64Encode(encoded);
    }
    return '$splash?data=$data&route=$route';
  }

  static String getOffersRoute() => offers;
  static String getSignInRoute({String? redirectUrl}) {
    final existingRedirect =
        RedirectRouteValidator._extractRedirectFromCurrentRoute();

    final isIgnoreRedirection =
        redirectUrl?.contains(ServiceRouteHelper.checkout) ?? false;

    // Use existing redirect if valid, otherwise use provided parameter
    final finalRedirect = isIgnoreRedirection
        ? ServiceRouteHelper.home
        : (existingRedirect ?? redirectUrl);

    return '$signIn?redirect_to=$finalRedirect';
  }

  static String getSignUpRoute({String? redirectUrl}) =>
      '$signUp?redirect_to=$redirectUrl';
  static String getSendOtpScreen({String? redirectUrl}) =>
      '$sendOtpScreen?redirect_to=$redirectUrl';

  static String getVerificationRoute({
    required String identity,
    required String identityType,
    required String fromPage,
    String? firebaseSession,
    String? redirectUrl,
  }) {
    String data = Uri.encodeComponent(jsonEncode(identity));
    String session = base64Url.encode(utf8.encode(firebaseSession ?? ''));

    return '$verification?identity=$data&identity_type=$identityType&redirect_to=$redirectUrl&fromPage=$fromPage&session=$session';
  }

  static String getChangePasswordRoute({
    ForgetPasswordBody? body,
    String? redirectUrl,
  }) {
    String data = "";
    if (body != null) {
      List<int> encodedCBody = utf8.encode(jsonEncode(body.toJson()));
      data = base64Encode(encodedCBody);
    }
    return '$changePassword?token=$data&redirect_to=$redirectUrl';
  }

  static String getAccessLocationRoute(String page) =>
      '$accessLocation?page=$page';
  static String getPickMapRoute(
    String page,
    bool canRoute,
    String isFromCheckout,
    ZoneModel? zone,
    AddressModel? previousAddress,
  ) {
    String zoneData = "";
    String addressData = "";
    if (zone != null) {
      List<int> encodedCategory = utf8.encode(jsonEncode(zone.toJson()));
      zoneData = base64Encode(encodedCategory);
    }
    if (previousAddress != null) {
      List<int> encodedAddress = utf8.encode(
        jsonEncode(previousAddress.toJson()),
      );
      addressData = base64Encode(encodedAddress);
    }
    return '$pickMap?page=$page&route=${canRoute.toString()}&checkout=$isFromCheckout&zone=$zoneData&address=$addressData';
  }

  static String getMainRoute(
    String page, {
    AddressModel? previousAddress,
    String? showServiceNotAvailableDialog,
  }) {
    String data = '';
    if (previousAddress != null) {
      List<int> encoded = utf8.encode(jsonEncode(previousAddress.toJson()));
      data = base64Encode(encoded);
    }
    return '$home?page=$page&address=$data&showDialog=$showServiceNotAvailableDialog';
  }

  static String getSearchResultRoute({String? queryText, String? fromPage}) {
    String data = '';
    if (queryText != null && queryText != '' && queryText != 'null') {
      List<int> encoded = utf8.encode(jsonEncode(queryText));
      data = base64Encode(encoded);
    }
    return '$searchScreen?fromPage=${fromPage ?? ''}&query=$data';
  }

  static String getServiceRoute(String slug, {String fromPage = "others"}) =>
      '$serviceDetails/$slug?fromPage=$fromPage';
  static String getProfileRoute() => profile;
  static String getEditProfileRoute() => profileEdit;
  static String getNotificationRoute() => notification;
  static String getAddressRoute(String fromPage) =>
      '$address?fromProfileScreen=$fromPage';
  static String getOrderSuccessRoute(String status) =>
      '$orderSuccess?flag=$status';
  static String getCheckoutRoute(
    String page,
    String currentPage,
    String addressId, {
    bool? reload,
    String? token,
  }) =>
      '$checkout?currentPage=$currentPage&addressID=$addressId&reload=$reload&token=$token';

  static String getCustomPostCheckoutRoute(
    String postId,
    String providerId,
    String amount,
    String bidId,
  ) {
    List<int> encoded = utf8.encode(amount);
    String data = base64Encode(encoded);
    return "$customPostCheckout?postId=$postId&providerId=$providerId&amount=$data&bid_id=$bidId";
  }

  static String getTrackBookingRoute() => trackBooking;

  static String getTermsAndConditionsRoute() => termsAndConditions;
  static String getAboutUsRoute() => aboutUs;
  static String getPrivacyPolicyRoute() => privacyPolicy;
  static String getCancellationPolicyRoute() => cancellationPolicy;
  static String getRefundPolicyRoute() => refundPolicy;

  static String getCategoryRoute(String fromPage, String campaignID) =>
      '$categories?fromPage=$fromPage&campaignID=$campaignID';
  static String getCategoryProductRoute(
    String slug,
    String name,
    String subCategoryIndex,
  ) {
    String slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();

    return '$categoryProduct/$slug?index=$subCategoryIndex';
  }

  static String getSupportRoute() => support;
  static String getUpdateRoute(String fromPage) => '$update?update=$fromPage';
  static String getCartRoute() => cart;
  static String getAddAddressRoute(bool fromCheckout) =>
      '$addAddress?page=${fromCheckout ? 'checkout' : 'address'}';
  static String getEditAddressRoute(AddressModel address, bool fromCheckout) {
    String data = base64Url.encode(utf8.encode(jsonEncode(address.toJson())));
    return '$editAddress?data=$data&page=${fromCheckout ? 'checkout' : 'address'}';
  }

  static String getChatScreenRoute(
    String channelId,
    String name,
    String image,
    String phone,
    String userType, {
    String? fromNotification,
  }) =>
      '$chatScreen?channelID=$channelId&name=$name&image=$image&phone=$phone&userType=$userType&fromNotification=$fromNotification';
  static String getSettingRoute() => settingScreen;
  static String getBookingScreenRoute(bool isFromMenu) =>
      '$bookingListScreen?isFromMenu=$isFromMenu';
  static String getInboxScreenRoute({String? fromNotification}) =>
      '$chatInbox?fromNotification=$fromNotification';
  static String getVoucherRoute({required String fromPage}) =>
      "$voucherScreen?fromCheckout=$fromPage";
  static String getBookingDetailsScreen({
    String? bookingID,
    String? subBookingId,
    String? phone,
    String? fromPage,
  }) =>
      '$bookingDetailsScreen?booking_id=$bookingID&sub_booking_id=$subBookingId&phone=$phone&fromPage=$fromPage';
  static String getRepeatBookingDetailsScreen({
    String? bookingId,
    String? fromPage,
    String? subBookingId,
  }) =>
      '$repeatBookingDetailsScreen?booking_id=$bookingId&sub_booking_id=$subBookingId&fromPage=$fromPage';
  static String getRateReviewScreen(String id) => '$rateReviewScreen?id=$id';
  static String allServiceScreenRoute(
    String fromPage, {
    String campaignID = '',
  }) => '$allServiceScreen?fromPage=$fromPage&campaignID=$campaignID';
  static String getFeatheredCategoryService(
    String fromPage,
    String categorySlug,
  ) => '$featheredServiceScreen?fromPage=$fromPage&categorySlug=$categorySlug';
  static String subCategoryScreenRoute(
    String categoryName,
    String categorySlug,
    int subCategoryIndex,
  ) =>
      '$subCategoryScreen?categoryName=$categoryName&categorySlug=$categorySlug&subCategoryIndex=$subCategoryIndex';
  static String getLanguageScreen(String fromPage) =>
      '$languageScreen?fromPage=$fromPage';
  static String getNotLoggedScreen(String redirectUrl, String appbarTitle) =>
      '$notLoggedScreen?redirect_to=$redirectUrl&appbarTitle=$appbarTitle';
  static String getMyWalletScreen({
    String? flag,
    String? token,
    String? fromNotification,
  }) => '$myWallet?flag=$flag&&token=$token&fromNotification=$fromNotification';
  static String getLoyaltyPointScreen({String? fromNotification}) =>
      '$loyaltyPoint?fromNotification=$fromNotification';
  static String getReferAndEarnScreen() => referAndEarn;
  static String getNewSuggestedServiceScreen() => suggestService;
  static String getNewSuggestedServiceList() => suggestServiceList;
  static String getAllProviderRoute() => allProviderList;
  static String getProviderDetails(String providerId) =>
      '$providerDetailsScreen/$providerId';
  static String getProviderReviewScreen(String providerId) =>
      '$providerReviewScreen?id=$providerId';
  static String getProviderAvailabilityScreen(String providerId) =>
      '$providerAvailabilityScreen?provider_id=$providerId';
  static String getCreatePostScreen({String? schedule}) {
    List<int> encoded = utf8.encode(jsonEncode(schedule));
    String data = base64Encode(encoded);
    return "$createPost?schedule=$data";
  }

  static String getCreatePostSuccessfullyScreen() => createPostSuccessfully;
  static String getMyPostScreen({String? fromNotification}) =>
      '$myPost?fromNotification=$fromNotification';
  static String getProviderOfferListScreen(
    String postId,
    String status,
    MyPostData myPostData,
  ) {
    List<int> encoded = utf8.encode(jsonEncode(myPostData.toJson()));
    String data = base64Encode(encoded);
    return "$providerOfferList?postId=$postId&myPostData=$data&status=$status";
  }

  static String getProviderOfferDetailsScreen(
    String postId,
    ProviderOfferData providerOfferData,
  ) {
    List<int> encoded = utf8.encode(jsonEncode(providerOfferData.toJson()));
    String data = base64Encode(encoded);
    return "$providerOfferDetails?postId=$postId&providerOfferData=$data";
  }

  static String getProviderWebView() => providerWebView;
  static String getServiceArea() => serviceArea;
  static String getServiceAreaMap() => serviceAreaMap;
  static String getNearByProviderScreen({int tabIndex = 0}) =>
      "$nearByProvider?tabIndex=$tabIndex";
  static String getCustomImageListScreen({
    required List<String> imageList,
    required String imagePath,
    required int index,
    String? appBarTitle,
    String? createdAt,
  }) {
    String imageListString = base64Encode(utf8.encode(jsonEncode(imageList)));
    return '$customImageListScreen?imageList=$imageListString&imagePath=$imagePath&index=$index&appBarTitle=$appBarTitle&createdAt=$createdAt';
  }

  static String getZoomImageScreen({
    required String image,
    required String imagePath,
    String? createdAt,
  }) => '$zoomImage?image=$image&imagePath=$imagePath&createdAt=$createdAt';
  static String getMyFavoriteScreen() => favorite;
  static String getMaintenanceRoute() => maintenance;
  static String getUpdateProfileRoute({
    String? phone,
    String? email,
    String? tempToken,
    String? userName,
    String? redirectUrl,
  }) {
    final String data1 = Uri.encodeComponent(jsonEncode(phone ?? ""));
    final String data2 = Uri.encodeComponent(jsonEncode(email ?? ""));
    final String data3 = Uri.encodeComponent(jsonEncode(tempToken ?? ""));
    final String data4 = Uri.encodeComponent(jsonEncode(userName ?? ""));
    final String decodedRedirectUrl = Uri.encodeComponent(
      jsonEncode(redirectUrl ?? ""),
    );

    return "$updateProfile?phone=$data1&email=$data2&temp-token=$data3&user-name=$data4&redirect_to=$decodedRedirectUrl";
  }

  static String getOfflinePaymentRoute({
    double? totalAmount,
    int? index,
    String? bookingId,
    String? readableId,
    int isPartialPayment = 0,
    required String fromPage,
    SignUpBody? newUserInfo,
    List<BookingOfflinePayment>? offlinePaymentData,
    String? offlinePaymentId,
  }) {
    String userData = "";
    String offlineData = 'null';
    if (newUserInfo != null) {
      List<int> encodedCategory = utf8.encode(jsonEncode(newUserInfo.toJson()));
      userData = base64Encode(encodedCategory);
    }

    if (offlinePaymentData != null && offlinePaymentData.isNotEmpty) {
      List<int> encoded = utf8.encode(
        jsonEncode(offlinePaymentData.map((body) => body.toJson()).toList()),
      );
      offlineData = base64Encode(encoded);
    }
    return "$offlinePayment?amount=$totalAmount&index=$index&id=$bookingId&readable_id=$readableId&partial=$isPartialPayment&page=$fromPage&data=$userData&offline=$offlineData&offline_id=$offlinePaymentId";
  }

  static String getAllCategoriesScreen() => allCategoriesScreen;

  static List<GetPage> routes = [
    GetPage(
      name: initial,
      page: () => getRoute(
        ResponsiveHelper.isDesktop(Get.context)
            ? AccessLocationScreen(
                fromSignUp: false,
                route: ServiceRouteHelper.getMainRoute('home'),
              )
            : const BottomNavScreen(
                pageIndex: 0,
                previousAddress: null,
                showServiceNotAvailableDialog: true,
              ),
      ),
    ),
    GetPage(
      name: splash,
      page: () {
        NotificationBody? data;
        if (Get.parameters['data'] != 'null') {
          List<int> decode = base64Decode(
            Get.parameters['data']!.replaceAll(' ', '+'),
          );
          data = NotificationBody.fromJson(jsonDecode(utf8.decode(decode)));
        }
        return SplashScreen(body: data, route: Get.parameters['route']);
      },
    ),
    GetPage(
      name: languageScreen,
      page: () => LanguageScreen(fromPage: Get.parameters['fromPage']),
    ),
    GetPage(name: offers, page: () => getRoute(const OfferScreen())),
    GetPage(
      name: signIn,
      page: () => SignInScreen(
        exitFromApp:
            Get.parameters['page'] == signUp ||
            Get.parameters['page'] == splash,
        redirectRoute:
            RedirectRouteValidator.getValidRoute(
                  Get.parameters['redirect_to'],
                ) ==
                null
            ? null
            : jsonEncode(Get.parameters),
      ),
      middlewares: [RedirectToHomeMiddleware()],
    ),
    GetPage(
      name: signUp,
      page: () => SignUpScreen(
        referralCode: Get.parameters['referral_code'],
        redirectRoute: RedirectRouteValidator.getValidRoute(
          Get.parameters['redirect_to'],
        ),
      ),
      middlewares: [RedirectToHomeMiddleware()],
    ),

    GetPage(
      name: accessLocation,
      page: () => AccessLocationScreen(
        fromHome: Get.parameters['page'] == 'home',
        fromSignUp: Get.parameters['page'] == signUp,
        route: null,
      ),
    ),
    GetPage(
      name: pickMap,
      page: () {
        PickMapScreen? pickMapScreen = Get.arguments;
        bool fromAddress = Get.parameters['page'] == 'add-address';
        ZoneModel? zoneData;
        AddressModel? addressData;
        if (Get.parameters['zone'] != "") {
          try {
            List<int> category = base64Decode(Get.parameters['zone'] ?? "");
            zoneData = ZoneModel.fromJson(jsonDecode(utf8.decode(category)));
          } catch (e) {
            if (kDebugMode) {
              print("");
            }
          }
        }
        if (Get.parameters['address'] != "") {
          try {
            List<int> address = base64Decode(Get.parameters['address'] ?? "");
            addressData = AddressModel.fromJson(
              jsonDecode(utf8.decode(address)),
            );
          } catch (e) {
            if (kDebugMode) {
              print("");
            }
          }
        }

        return (fromAddress && pickMapScreen == null)
            ? const NotFoundScreen()
            : pickMapScreen ??
                  PickMapScreen(
                    fromSignUp: Get.parameters['page'] == signUp,
                    fromAddAddress: fromAddress,
                    route: Get.parameters['page'],
                    canRoute: Get.parameters['route'] == 'true',
                    formCheckout: Get.parameters['checkout'] == 'true',
                    zone: zoneData,
                    previousAddress: addressData,
                  );
      },
    ),

    GetPage(
      name: home,
      page: () {
        AddressModel? addressData;
        if (Get.parameters['address'] != "") {
          try {
            List<int> address = base64Decode(
              Get.parameters['address']!.replaceAll(" ", "+"),
            );
            addressData = AddressModel.fromJson(
              jsonDecode(utf8.decode(address)),
            );
          } catch (e) {
            if (kDebugMode) {
              print("Address Model : $addressData");
            }
          }
        }
        return getRoute(
          BottomNavScreen(
            pageIndex: Get.parameters['page'] == 'home'
                ? 0
                : Get.parameters['page'] == 'booking'
                ? 1
                : Get.parameters['page'] == 'cart'
                ? 2
                : Get.parameters['page'] == 'order'
                ? 3
                : Get.parameters['page'] == 'menu'
                ? 4
                : 0,
            previousAddress: addressData,
            showServiceNotAvailableDialog:
                Get.parameters['showDialog'] == 'false' ? false : true,
          ),
        );
      },
    ),

    GetPage(
      name: sendOtpScreen,
      page: () {
        return ForgetPassScreen(
          redirectUrl: RedirectRouteValidator.getValidRoute(
            Get.parameters['redirect_to'] ?? '',
          ),
        );
      },
    ),

    GetPage(
      name: verification,
      page: () {
        String data = Uri.decodeComponent(
          jsonDecode(Get.parameters['identity']!),
        );
        return VerificationScreen(
          identity: data,
          identityType: Get.parameters['identity_type']!,
          fromPage: Get.parameters['fromPage']!,
          firebaseSession: Get.parameters['session'] == 'null'
              ? null
              : utf8.decode(base64Url.decode(Get.parameters['session'] ?? '')),
          redirectRoute: RedirectRouteValidator.getValidRoute(
            Get.parameters['redirect_to'],
          ),
        );
      },
    ),

    GetPage(
      name: changePassword,
      page: () {
        List<int> decode = base64Decode(Get.parameters['token']!);
        ForgetPasswordBody? forgetPasswordBody = ForgetPasswordBody.fromJson(
          jsonDecode(utf8.decode(decode)),
        );
        return NewPassScreen(
          forgetPasswordBody: forgetPasswordBody,
          redirectUrl: RedirectRouteValidator.getValidRoute(
            Get.parameters['redirect_to'],
          ),
        );
      },
    ),

    GetPage(
      name: featheredServiceScreen,
      page: () {
        return AllFeatheredCategoryServiceView(
          fromPage: Get.parameters['fromPage'],
          categorySlug: Get.parameters['categorySlug'],
        );
      },
    ),

    GetPage(
      name: searchScreen,
      page: () {
        List<int> decode = [];
        String queryText = '';
        try {
          if (Get.parameters['query'] != '' &&
              Get.parameters['query'] != "null") {
            decode = base64Decode(
              Get.parameters['query']!.replaceAll(' ', '+'),
            );
            queryText = jsonDecode(utf8.decode(decode));
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error : $e");
          }
        }
        return getRoute(
          SearchResultScreen(
            queryText: queryText,
            fromPage: Get.parameters['fromPage'],
          ),
        );
      },
    ),

    GetPage(
      name: '$serviceDetails/:slug',
      binding: ServiceDetailsBinding(),
      page: () {
        return getRoute(
          Get.arguments ??
              ServiceDetailsScreen(
                serviceID: Get.parameters['slug'],
                fromPage: Get.parameters['fromPage'],
              ),
          isIgnoreRouteExistCheck: true,
        );
      },
    ),

    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: profileEdit, page: () => getRoute(const EditProfileScreen())),
    GetPage(
      name: notification,
      page: () => getRoute(const NotificationScreen()),
    ),

    GetPage(
      name: orderSuccess,
      page: () => getRoute(
        OrderSuccessfulScreen(
          status: Get.parameters['flag'].toString().contains('success') ? 1 : 0,
        ),
      ),
    ),

    GetPage(
      name: checkout,
      page: () {
        if (Get.parameters['flag'] == 'failed' ||
            Get.parameters['flag'] == 'fail' ||
            Get.parameters['flag'] == 'cancelled' ||
            Get.parameters['flag'] == 'canceled' ||
            Get.parameters['flag'] == 'cancel') {
          return getRoute(const OrderSuccessfulScreen(status: 0));
        }
        return getRoute(
          CheckoutScreen(
            Get.parameters.containsKey('flag') &&
                    Get.parameters['flag']! == 'success'
                ? 'complete'
                : Get.parameters['currentPage'] ?? "orderDetails",
            Get.parameters['addressID'] != null
                ? Get.parameters['addressID']!
                : 'null',
            reload:
                Get.parameters['reload'].toString() == "true" ||
                    Get.parameters['reload'].toString() == "null"
                ? true
                : false,
            token: Get.parameters["token"],
          ),
        );
      },
      middlewares: [
        AuthMiddleware(pageTitle: 'checkout', canGuestCheckout: true),
      ],
    ),

    GetPage(
      name: customPostCheckout,
      page: () {
        List<int> decode = base64Decode(Get.parameters['amount']!);
        String data = utf8.decode(decode);
        return CustomPostCheckoutScreen(
          postId: Get.parameters['postId']!,
          providerId: Get.parameters['providerId']!,
          amount: data,
          bidId: Get.parameters['bid_id']!,
        );
      },
    ),

    GetPage(
      name: termsAndConditions,
      page: () => const HtmlViewerScreen(type: HtmlType.termsAndCondition),
    ),

    GetPage(
      name: aboutUs,
      page: () => const HtmlViewerScreen(type: HtmlType.aboutUs),
    ),

    GetPage(
      name: privacyPolicy,
      page: () => const HtmlViewerScreen(type: HtmlType.privacyPolicy),
    ),

    GetPage(
      name: cancellationPolicy,
      page: () => const HtmlViewerScreen(type: HtmlType.cancellationPolicy),
    ),

    GetPage(
      name: refundPolicy,
      page: () => const HtmlViewerScreen(type: HtmlType.refundPolicy),
    ),

    GetPage(
      name: categories,
      page: () => getRoute(
        CategoryScreen(
          fromPage: Get.parameters['fromPage'],
          campaignID: Get.parameters['campaignID'],
        ),
      ),
    ),

    GetPage(
      name: '$categoryProduct/:slug',
      page: () {
        return getRoute(
          CategorySubCategoryScreen(
            categorySlug: Get.parameters['slug'] ?? '',
            categoryIndex: Get.parameters['index'] ?? "0",
          ),
          isIgnoreRouteExistCheck: true,
        );
      },
    ),
    GetPage(name: support, page: () => SupportScreen()),
    GetPage(
      name: update,
      page: () => UpdateScreen(fromPage: Get.parameters['update']),
    ),
    GetPage(name: cart, page: () => getRoute(const CartScreen(fromNav: false))),
    GetPage(
      name: addAddress,
      page: () =>
          AddAddressScreen(fromCheckout: Get.parameters['page'] == 'checkout'),
    ),
    GetPage(
      name: editAddress,
      page: () {
        AddressModel? address;

        try {
          address = AddressModel.fromJson(
            jsonDecode(
              utf8.decode(
                base64Url.decode(Get.parameters['data']!.replaceAll(' ', '+')),
              ),
            ),
          );
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
        return getRoute(
          AddAddressScreen(
            fromCheckout: Get.parameters['page'] == 'checkout',
            address: address,
          ),
        );
      },
    ),

    GetPage(
      name: chatScreen,
      transition: Transition.topLevel,
      page: () => ConversationDetailsScreen(
        channelID: Get.parameters['channelID'],
        name: Get.parameters['name'],
        phone: Get.parameters['phone'],
        image: Get.parameters['image'],
        userType: Get.parameters['userType'] ?? "",
        formNotification: Get.parameters['fromNotification'] ?? "",
      ),
    ),

    GetPage(
      name: chatInbox,
      binding: ConversationBinding(),
      page: () => ConversationListScreen(
        fromNotification: Get.parameters['fromNotification'],
      ),
      middlewares: [AuthMiddleware(pageTitle: 'inbox')],
    ),

    GetPage(
      name: address,
      page: () => AddressScreen(fromPage: Get.parameters['fromProfileScreen']),
      middlewares: [AuthMiddleware(pageTitle: 'my_address')],
    ),
    GetPage(
      binding: OnBoardBinding(),
      name: onBoardScreen,
      page: () => const OnBoardingScreen(),
    ),
    GetPage(name: settingScreen, page: () => const SettingScreen()),
    GetPage(
      name: voucherScreen,
      page: () => getRoute(
        CouponScreen(
          fromCheckout: Get.parameters['fromCheckout'] == "checkout",
        ),
      ),
    ),
    GetPage(
      binding: BookingBinding(),
      name: bookingDetailsScreen,
      page: () {
        return BookingDetailsScreen(
          bookingID: Get.parameters['booking_id'],
          subBookingId: Get.parameters['sub_booking_id'],
          phone: Get.parameters['phone'],
          fromPage: Get.parameters['fromPage'],
          token: Get.parameters["token"],
        );
      },
    ),

    GetPage(
      binding: BookingBinding(),
      name: repeatBookingDetailsScreen,
      page: () => RepeatBookingDetailsScreen(
        bookingId: Get.parameters['booking_id'].toString(),
        fromPage: Get.parameters['fromPage'],
      ),
    ),

    GetPage(
      binding: BookingBinding(),
      name: trackBooking,
      page: () => const BookingTrackScreen(),
    ),
    GetPage(
      binding: ServiceBinding(),
      name: allServiceScreen,
      page: () => getRoute(
        AllServiceView(
          fromPage: Get.parameters['fromPage'],
          campaignID: Get.parameters['campaignID'],
        ),
      ),
    ),
    GetPage(
      binding: ServiceBinding(),
      name: subCategoryScreen,
      page: () => SubCategoryScreen(
        categoryTitle: Get.parameters['categoryName'],
        categorySlug: Get.parameters['categorySlug'],
        subCategoryIndex: int.tryParse(
          Get.parameters['subCategoryIndex'] ?? "",
        ),
      ),
    ),
    GetPage(
      binding: SubmitReviewBinding(),
      name: rateReviewScreen,
      page: () {
        return RateReviewScreen(id: Get.parameters['id']);
      },
    ),
    GetPage(
      name: bookingListScreen,
      page: () => BookingListScreen(
        isFromMenu: Get.parameters['isFromMenu'] == "true" ? true : false,
      ),
      middlewares: [AuthMiddleware(pageTitle: 'my_bookings')],
    ),
    GetPage(
      name: notLoggedScreen,
      page: () => NotLoggedInScreen(
        redirectUrl:
            RedirectRouteValidator.getValidRoute(
              Get.parameters['redirect_to'] ?? '',
            ) ??
            '',
        appbarTitle: Get.parameters['appbarTitle'] ?? '',
      ),
    ),
    GetPage(
      binding: SuggestServiceBinding(),
      name: suggestService,
      page: () => getRoute(const SuggestServiceScreen()),
    ),
    GetPage(
      binding: SuggestServiceBinding(),
      name: suggestServiceList,
      page: () => getRoute(const SuggestedServiceListScreen()),
    ),
    GetPage(
      binding: WalletBinding(),
      name: myWallet,
      page: () => WalletScreen(
        status: Get.parameters['flag'],
        token: Get.parameters['token'],
        fromNotification: Get.parameters['fromNotification'],
      ),
    ),
    GetPage(
      binding: LoyaltyPointBinding(),
      name: loyaltyPoint,
      page: () => LoyaltyPointScreen(
        fromNotification: Get.parameters['fromNotification'],
      ),
    ),
    GetPage(
      name: referAndEarn,
      page: () => const ReferAndEarnScreen(),
      middlewares: [AuthMiddleware(pageTitle: 'refer_and_earn')],
    ),
    GetPage(
      name: allProviderList,
      page: () => getRoute(const AllProviderView()),
    ),
    GetPage(
      name: '$providerDetailsScreen/:id',
      page: () => getRoute(
        ProviderDetailsScreen(providerId: Get.parameters['id']!),
        isIgnoreRouteExistCheck: true,
      ),
    ),
    GetPage(
      name: providerReviewScreen,
      page: () =>
          getRoute(ProviderReviewScreen(providerId: Get.parameters['id'])),
    ),
    GetPage(
      name: providerAvailabilityScreen,
      page: () => getRoute(
        ProviderAvailabilityWidget(providerId: Get.parameters['provider_id']!),
      ),
    ),
    GetPage(
      name: createPost,
      page: () => const CreatePostScreen(),
      middlewares: [AuthMiddleware(pageTitle: 'create_post')],
    ),
    GetPage(
      name: createPostSuccessfully,
      page: () => getRoute(const PostCreateSuccessfullyScreen()),
    ),
    GetPage(
      name: myPost,
      page: () =>
          AllPostScreen(fromNotification: Get.parameters["fromNotification"]),
      middlewares: [AuthMiddleware(pageTitle: 'my_posts')],
    ),
    GetPage(
      name: providerOfferList,
      page: () {
        MyPostData? post;
        try {
          List<int> decode = base64Decode(
            Get.parameters['myPostData']!.replaceAll(' ', '+'),
          );
          post = MyPostData.fromJson(jsonDecode(utf8.decode(decode)));
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
        return ProviderOfferListScreen(
          postId: Get.parameters['postId'],
          myPostData: post,
          status: Get.parameters['status'],
        );
      },
    ),

    GetPage(
      name: providerOfferDetails,
      page: () {
        List<int> decode = base64Decode(
          Get.parameters['providerOfferData']!.replaceAll(' ', '+'),
        );
        ProviderOfferData data = ProviderOfferData.fromJson(
          jsonDecode(utf8.decode(decode)),
        );
        return ProviderOfferDetailsScreen(
          postId: Get.parameters['postId'],
          providerOfferData: data,
        );
      },
    ),

    GetPage(name: providerWebView, page: () => const ProviderWebView()),
    GetPage(name: serviceArea, page: () => const ServiceAreaScreen()),
    GetPage(name: serviceAreaMap, page: () => const ServiceAreaMapScreen()),
    GetPage(
      name: nearByProvider,
      page: () => NearByProviderScreen(
        tabIndex: int.tryParse(Get.parameters['tabIndex'] ?? "0") ?? 0,
      ),
    ),

    GetPage(
      name: customImageListScreen,
      page: () {
        List<int> decode = base64Decode(
          Get.parameters['imageList']!.replaceAll(' ', '+'),
        );
        var value = jsonDecode(utf8.decode(decode));
        List<String> imageList = (value as List)
            .map((item) => item.toString())
            .toList();

        return ImageDetailScreen(
          imageList: imageList,
          index: int.parse(Get.parameters['index']!),
          appbarTitle: Get.parameters['appBarTitle'],
          createdAt: Get.parameters['createdAt'],
        );
      },
    ),

    GetPage(
      name: zoomImage,
      page: () {
        return ZoomImage(
          image: Get.parameters['image']!,
          imagePath: Get.parameters['imagePath']!,
          createdAt: Get.parameters['createdAt'],
        );
      },
    ),

    GetPage(
      name: favorite,
      middlewares: [AuthMiddleware(pageTitle: 'my_favorite')],
      page: () {
        return const MyFavoriteScreen();
      },
    ),
    GetPage(name: maintenance, page: () => const MaintenanceScreen()),
    GetPage(
      name: updateProfile,
      page: () {
        String phone = Uri.decodeComponent(
          jsonDecode(Get.parameters['phone'] ?? ""),
        );
        String email = Uri.decodeComponent(
          jsonDecode(Get.parameters['email'] ?? ""),
        );
        String tempToken = Uri.decodeComponent(
          jsonDecode(Get.parameters['temp-token'] ?? ""),
        );
        String userName = Uri.decodeComponent(
          jsonDecode(Get.parameters['user-name'] ?? ""),
        );
        String redirectTo = Uri.decodeComponent(
          jsonDecode(Get.parameters['redirect_to'] ?? ""),
        );

        return UpdateProfileScreen(
          phone: phone,
          email: email,
          tempToken: tempToken,
          userName: userName,
          redirectUrl: RedirectRouteValidator.getValidRoute(redirectTo),
        );
      },
    ),
    GetPage(
      name: offlinePayment,
      page: () {
        SignUpBody? newUserInfo;
        List<BookingOfflinePayment>? offlinePaymentData;

        try {
          if (Get.parameters['data'] != null) {
            List<int> decode = base64Decode(
              Get.parameters['data']!.replaceAll(' ', '+'),
            );
            newUserInfo = SignUpBody.fromJson(jsonDecode(utf8.decode(decode)));
          }
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
        try {
          if (Get.parameters['offline'] != 'null') {
            List<int> decode = base64Decode(
              Get.parameters['offline']!.replaceAll(' ', '+'),
            );
            List<dynamic> jsonList = jsonDecode(utf8.decode(decode));
            offlinePaymentData = jsonList
                .map((json) => BookingOfflinePayment.fromJson(json))
                .toList();
          }
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
        return OfflinePaymentScreen(
          totalAmount: double.tryParse(Get.parameters['amount'] ?? "0"),
          index: int.tryParse(Get.parameters['index'] ?? "0"),
          bookingId: Get.parameters['id'],
          isPartialPayment: int.tryParse(Get.parameters['partial'] ?? "0"),
          fromPage: Get.parameters['page'] ?? "",
          newUserInfo: newUserInfo,
          offlinePaymentData: offlinePaymentData,
          offlinePaymentId: Get.parameters['offline_id'],
          readableId: Get.parameters['readable_id'],
        );
      },
    ),

    GetPage(name: allCategoriesScreen, page: () => const AllCategoryScreen()),
  ];

  static Widget getRoute(
    Widget navigateTo, {
    bool isIgnoreRouteExistCheck = false,
  }) {
    bool isRouteExist =
        (Get.currentRoute == "/" ||
            routes.any((route) {
              String routeName = route.name == "/"
                  ? "*"
                  : route.name.replaceAll("/", "");
              return Get.currentRoute.split('?')[0].replaceAll("/", "") ==
                  routeName;
            }) ||
            !kIsWeb) ||
        isIgnoreRouteExistCheck;

    var config = Get.find<ServiceSplashController>()
        .configModel
        .content
        ?.maintenanceMode;
    bool maintenance =
        config?.maintenanceStatus == 1 &&
        config?.selectedMaintenanceSystem?.webApp == 1 &&
        kIsWeb &&
        !AppConstants.avoidMaintenanceMode;
    return !isRouteExist
        ? const NotFoundScreen()
        : maintenance
        ? const MaintenanceScreen()
        : Get.find<ServiceLocationController>().getUserAddress() != null
        ? navigateTo
        : AccessLocationScreen(fromSignUp: false, route: Get.currentRoute);
  }

  static ({String path, Map<String, String>? parameters})
  parseRedirectRouteToNavigate(String redirectRoute) {
    try {
      final decodedParams = jsonDecode(redirectRoute) as Map<String, dynamic>;
      final redirectPath =
          decodedParams['redirect_to'] ?? ServiceRouteHelper.initial;

      final uri = Uri.parse(redirectPath);
      final mergedParameters = _mergeRouteParameters(uri, decodedParams);
      final cleanPath = uri.path.isNotEmpty
          ? uri.path
          : ServiceRouteHelper.initial;

      return (path: cleanPath, parameters: mergedParameters);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing redirect route: $e');
      }
      return _defaultRouteData();
    }
  }

  /// Merges query parameters from URI and decoded JSON, excluding 'redirect_to'
  static Map<String, String>? _mergeRouteParameters(
    Uri uri,
    Map<String, dynamic> decodedParams,
  ) {
    final parameters = <String, String>{...uri.queryParameters};

    decodedParams.forEach((key, value) {
      if (key != 'redirect_to' && value != null) {
        parameters[key] = value.toString();
      }
    });

    if (parameters.isEmpty) return null;

    return parameters;
  }

  /// Returns default route data for error cases
  static ({String path, Map<String, String> parameters}) _defaultRouteData() {
    return (path: ServiceRouteHelper.initial, parameters: <String, String>{});
  }

  // static String? _getValidRedirectRoute(String? route) {
  //    if (route == null || route == 'null' || route.isEmpty) {
  //      return null;
  //    }
  //
  //    ///ServiceRouteHelper.signIn,  ServiceRouteHelper.signUp, ServiceRouteHelper.sendOtpScreen, ServiceRouteHelper.verification  all are string
  //    if(route.contains(ServiceRouteHelper.signIn)) return null;
  //    if(route.contains(ServiceRouteHelper.signUp)) return null;
  //    if(route.contains(ServiceRouteHelper.sendOtpScreen)) return null;
  //    if(route.contains(ServiceRouteHelper.verification)) return null;
  //
  //    return route;
  //  }
}

class RedirectToHomeMiddleware extends GetMiddleware {
  // final ServiceAuthController authController =
  //     Get.find<ServiceAuthController>();

  @override
  int? get priority => 0; // High priority to check before others

  @override
  RouteSettings? redirect(String? route) {
    SharedPreferences sharedPreferences = Get.find();

    if (!sharedPreferences.containsKey('token')) return null;

    return RouteSettings(name: ServiceRouteHelper.home);
  }
}

class AuthMiddleware extends GetMiddleware {
  final String? pageTitle;
  final bool canGuestCheckout;
  // ⚠️ Ensure your AuthService is initialized, e.g., in GetMaterialApp bindings or main()
  // final ServiceAuthController authController =
  //     Get.find<ServiceAuthController>();

  AuthMiddleware({required this.pageTitle, this.canGuestCheckout = false});

  @override
  int? get priority => 1; // High priority to check before others

  @override
  RouteSettings? redirect(String? route) {
    SharedPreferences sharedPreferences = Get.find();
    final bool isAbleToCheckout =
        (canGuestCheckout &&
        Get.find<ServiceSplashController>()
                .configModel
                .content
                ?.guestCheckout ==
            1);

    if (isAbleToCheckout) return null;

    if (!sharedPreferences.containsKey(AppConstants.token)) {
      // 1. URL-encode the *full* current route (e.g., /booking-details?id=123)
      final String encodedIntendedRoute = Uri.encodeComponent(
        route ?? ServiceRouteHelper.initial,
      );

      // 2. Redirect to the login screen, adding the intended route as a query parameter
      // The resulting URL will look like: /sign-in?redirect_to=%2Fbooking-details%3Fid%3D123
      return RouteSettings(
        name: ServiceRouteHelper.getNotLoggedScreen(
          encodedIntendedRoute,
          pageTitle ?? '',
        ),
        // arguments is now null/empty, as we are relying on the URL
      );
    }

    // User is logged in, proceed to the intended route
    return null;
  }
}

class RedirectRouteValidator {
  // Private constructor to prevent instantiation
  RedirectRouteValidator._();

  /// Routes that should never be used as redirect targets.
  /// These are authentication flow routes that would create redirect loops.
  static const Set<String> _authenticationRoutes = {
    ServiceRouteHelper.signIn,
    ServiceRouteHelper.signUp,
    ServiceRouteHelper.sendOtpScreen,
    ServiceRouteHelper.verification,
    ServiceRouteHelper.changePassword, // Consider adding this too
  };

  static String? getValidRoute(String? route) {
    // Early return for null/empty/invalid values - O(1)
    if (route == null || route.isEmpty || route == 'null') {
      return null;
    }

    // Check if route contains any authentication pattern - O(n*m)
    // Short-circuits on first match for better average performance
    final isAuthRoute = _authenticationRoutes.any(route.contains);

    return isAuthRoute ? null : route;
  }

  static String? _extractRedirectFromCurrentRoute() {
    try {
      final uri = Uri.parse(Get.currentRoute);
      final redirect = uri.queryParameters['redirect_to'];

      // Return null if empty or 'null' string
      return (redirect?.isNotEmpty ?? false) ? redirect : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing current route: $e');
      }
      return null;
    }
  }
}
