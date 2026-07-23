import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/onboard/controllers/onboard_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    Get.find<OnBoardingController>().getOnBoardingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      body: SafeArea(
        child: GetBuilder<OnBoardingController>(
          builder: (onBoardingController) {
            bool showIndicatorAndButton = onBoardingController.selectedIndex <
                onBoardingController.onBoardingList.length - 1;
            return onBoardingController.onBoardingList.isNotEmpty
                ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.05),
                    Theme.of(context).colorScheme.background,
                    Theme.of(context).colorScheme.background,
                  ],
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Stack(
                    children: [
                      // Background decorative elements
                      Positioned(
                        top: -100,
                        right: -100,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        left: -50,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      Column(
                        children: [
                          // Skip button at top right
                          if (showIndicatorAndButton &&
                              onBoardingController.selectedIndex != 2)
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: TextButton(
                                  onPressed: _configureToRouteInitialPage,
                                  child: Text(
                                    'skip'.tr,
                                    style: robotoMedium.copyWith(
                                      color:
                                      Theme.of(context).primaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          Expanded(
                            child: PageView.builder(
                              itemCount: onBoardingController
                                  .onBoardingList.length,
                              controller: _pageController,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return SingleChildScrollView(
                                        physics: const ClampingScrollPhysics(),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight: constraints.maxHeight,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                      // Image with modern container
                                      if (showIndicatorAndButton &&
                                          onBoardingController
                                              .onBoardingList[index]
                                              .imageUrl !=
                                              '')
                                        Container(
                                          width: 280,
                                          height: 280,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.2),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding:
                                            const EdgeInsets.all(30),
                                            child: Image.asset(
                                              onBoardingController
                                                  .onBoardingList[index]
                                                  .imageUrl,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                          height: context.height * 0.06),

                                      // Title with gradient text
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            LinearGradient(
                                              colors: [
                                                Theme.of(context)
                                                    .primaryColor,
                                                Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.7),
                                              ],
                                            ).createShader(bounds),
                                        child: Text(
                                          onBoardingController
                                              .onBoardingList[index]
                                              .title,
                                          style: robotoBold.copyWith(
                                            fontSize: 28,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                          height: context.height * 0.03),

                                      // Description
                                      Text(
                                        onBoardingController
                                            .onBoardingList[index]
                                            .description,
                                        style: robotoRegular.copyWith(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .disabledColor,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              onPageChanged: (index) {
                                onBoardingController
                                    .changeSelectIndex(index);
                                if (onBoardingController.selectedIndex ==
                                    3) {
                                  _configureToRouteInitialPage();
                                }
                              },
                            ),
                          ),

                          // Modern progress indicator
                          if (showIndicatorAndButton)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 40),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: (onBoardingController
                                          .selectedIndex +
                                          1) /
                                          (onBoardingController
                                              .onBoardingList.length -
                                              1),
                                      backgroundColor: Theme.of(context)
                                          .disabledColor
                                          .withOpacity(0.2),
                                      color:
                                      Theme.of(context).primaryColor,
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '${onBoardingController.selectedIndex + 1}/${onBoardingController.onBoardingList.length - 1}',
                                    style: robotoMedium.copyWith(
                                      color:
                                      Theme.of(context).primaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: context.height * 0.04),

                          // Next/Get Started Button with white text
                          if (showIndicatorAndButton)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20),
                              child: Container(
                                height: 56,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.9),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: CustomButton(
                                  buttonText: onBoardingController
                                      .selectedIndex !=
                                      2
                                      ? 'next'.tr
                                      : 'get_started'.tr,
                                  transparent: true,
                                  fontSize: 16,
                                  textColor:
                                  Colors.white, // White text color
                                  onPressed: () {
                                    if (onBoardingController
                                        .selectedIndex !=
                                        2) {
                                      _pageController.nextPage(
                                        duration: const Duration(
                                            milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    } else {
                                      _configureToRouteInitialPage();
                                    }
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
                : const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _configureToRouteInitialPage() async {
    Get.find<SplashController>().disableIntro();
    await Get.find<AuthController>().guestLogin();
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<LocationController>()
          .navigateToLocationScreen(RouteHelper.onBoarding, offNamed: true)
          .then((v) {
        _pageController.jumpToPage(
            Get.find<OnBoardingController>().onBoardingList.length - 2);
      });
    }
  }
}