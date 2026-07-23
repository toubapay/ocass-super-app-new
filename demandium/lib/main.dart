import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';
import 'helper/analytics/analytics_helper.dart';
import 'util/core_export.dart';
import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (ResponsiveHelper.isMobilePhone()) {
    await FlutterDownloader.initialize();
  }
  setPathUrlStrategy();
  AnalyticsHelper.init();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyATwpBSYz69b5Y9ryQLELOJIHZSpJcXf7I",
          authDomain: "demancms.firebaseapp.com",
          projectId: "demancms",
          storageBucket: "demancms.appspot.com",
          messagingSenderId: "889759666168",
          appId: "1:889759666168:web:ab661cb341d3e47384d00d",
        ),
      );
    } else if (Platform.isAndroid) {
      try {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyBYMyaGbvQhVf6YIfH1TEVT56Zs83QASxg",

            ///current_key here
            appId: "1:889759666168:android:64e5375b02e6121d84d00d",

            ///mobilesdk_app_id here
            messagingSenderId: "889759666168",

            ///project_number here
            projectId: "demancms",

            ///project_id her
          ),
        );
      } catch (e) {
        await Firebase.initializeApp();
      }
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Flutter bindings: ${e.toString()}');
    }
  }

  if (kIsWeb) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "482889663914976",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    await FirebaseMessaging.instance.requestPermission();
  }

  Map<String, Map<String, String>> languages = await di.init();
  NotificationBody? body;
  String? path;
  try {
    if (!kIsWeb) {
      path = await initDynamicLinks();
    }

    final RemoteMessage? remoteMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (remoteMessage != null) {
      body = NotificationHelper.convertNotification(remoteMessage.data);
    }
    await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  } catch (e) {
    if (kDebugMode) {
      print("");
    }
  }
  runApp(MyApp(languages: languages, body: body, route: path));
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBody? body;
  final String? route;
  const MyApp({
    super.key,
    required this.languages,
    required this.body,
    this.route,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

Future<String?> initDynamicLinks() async {
  final appLinks = AppLinks();
  final uri = await appLinks.getInitialLink();
  String? path;
  if (uri != null) {
    path = uri.path;
  } else {
    path = null;
  }
  return path;
}

class _MyAppState extends State<MyApp> {
  void _route() async {
    Get.find<ServiceSplashController>().getConfigData().then((success) async {
      if (Get.find<ServiceLocationController>().getUserAddress() != null) {
        AddressModel addressModel = Get.find<ServiceLocationController>()
            .getUserAddress()!;
        ZoneResponseModel responseModel =
            await Get.find<ServiceLocationController>().getZone(
              addressModel.latitude.toString(),
              addressModel.longitude.toString(),
              false,
            );
        addressModel.availableServiceCountInZone =
            responseModel.totalServiceCount;
        Get.find<ServiceLocationController>().saveUserAddress(addressModel);
      }
      Get.find<ServiceAuthController>().updateToken();
    });
  }

  @override
  void initState() {
    super.initState();

    if (kIsWeb || widget.route != null) {
      Get.find<ServiceSplashController>().initSharedData();
      Get.find<ServiceSplashController>().getCookiesData();
      Get.find<ServiceCartController>().getCartListFromServer();

      if (Get.find<ServiceAuthController>().isLoggedIn()) {
        Get.find<UserController>().getUserInfo();
      }

      if (Get.find<ServiceSplashController>().getGuestId().isEmpty) {
        var uuid = const Uuid().v1();
        Get.find<ServiceSplashController>().setGuestId(uuid);
      }
      _route();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceThemeController>(
      builder: (themeController) {
        return GetBuilder<ServiceLocalizationController>(
          builder: (localizeController) {
            return GetBuilder<ServiceSplashController>(
              builder: (splashController) {
                if ((GetPlatform.isWeb &&
                    splashController.configModel.content == null)) {
                  return const SizedBox();
                } else if ((!GetPlatform.isWeb &&
                        !Get.currentRoute.contains('/splash') &&
                        Get.currentRoute.isNotEmpty) &&
                    splashController.configModel.content == null) {
                  return Material(child: SplashLogoWidget());
                } else {
                  return GetMaterialApp(
                    title: AppConstants.appName,
                    debugShowCheckedModeBanner: false,
                    navigatorKey: Get.key,
                    scrollBehavior: const MaterialScrollBehavior().copyWith(
                      dragDevices: {
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.touch,
                      },
                    ),
                    theme: themeController.darkTheme ? dark : light,
                    locale: localizeController.locale,
                    translations: Messages(languages: widget.languages),
                    fallbackLocale: Locale(
                      AppConstants.languages[0].languageCode!,
                      AppConstants.languages[0].countryCode,
                    ),
                    initialRoute: GetPlatform.isWeb
                        ? ServiceRouteHelper.getInitialRoute()
                        : ServiceRouteHelper.getSplashRoute(
                            widget.body,
                            widget.route,
                          ),
                    getPages: ServiceRouteHelper.routes,
                    defaultTransition: Transition.fadeIn,
                    transitionDuration: const Duration(milliseconds: 500),
                    builder: (context, widget) => MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: const TextScaler.linear(1)),
                      child: Material(
                        child: SafeArea(
                          top: false,
                          bottom: GetPlatform.isAndroid,
                          child: Stack(
                            children: [
                              widget!,

                              GetBuilder<ServiceSplashController>(
                                builder: (splashController) {
                                  if (!splashController.savedCookiesData ||
                                      !splashController.getAcceptCookiesStatus(
                                        splashController
                                                .configModel
                                                .content
                                                ?.cookiesText ??
                                            "",
                                      )) {
                                    return ResponsiveHelper.isWeb()
                                        ? const Align(
                                            alignment: Alignment.bottomCenter,
                                            child: CookiesView(),
                                          )
                                        : const SizedBox();
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
