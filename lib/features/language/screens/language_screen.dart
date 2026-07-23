import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/language/screens/web_language_screen.dart';
import 'package:sixam_mart/features/language/widgets/language_card_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/styles.dart';

class ChooseLanguageScreen extends StatefulWidget {
  final bool fromMenu;
  const ChooseLanguageScreen({super.key, this.fromMenu = false});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.fromMenu || ResponsiveHelper.isDesktop(context))
          ? CustomAppBar(title: 'language'.tr, backButton: true)
          : null,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      body:
          GetBuilder<LocalizationController>(builder: (localizationController) {
        return ResponsiveHelper.isDesktop(context)
            ? const WebLanguageScreen()
            : Stack(
                children: [
                  // Background decorative elements
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      // Animated Header
                      Container(
                        height: 200,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Add space before the icon
                                  const SizedBox(
                                      height:
                                          40), // ← Add this line for space before icon

                                  // Floating language icon
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).primaryColor,
                                          Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.7),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.translate_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'choose_your_language'.tr,
                                    style: robotoBold.copyWith(
                                      fontSize: 22,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .color,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Language Cards in Grid
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.6,
                            ),
                            itemCount: localizationController.languages.length,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 100),
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Theme.of(context).cardColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: localizationController
                                                .selectedLanguageIndex ==
                                            index
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: LanguageCardWidget(
                                  languageModel:
                                      localizationController.languages[index],
                                  localizationController:
                                      localizationController,
                                  index: index,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Floating Next Button
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.9),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CustomButton(
                        buttonText: 'next'.tr,
                        transparent: true,
                        textColor:
                            Colors.white, // ← Add this line to make text white
                        onPressed: () {
                          if (localizationController.languages.isNotEmpty &&
                              localizationController.selectedLanguageIndex !=
                                  -1) {
                            localizationController.setLanguage(Locale(
                              AppConstants
                                  .languages[localizationController
                                      .selectedLanguageIndex]
                                  .languageCode!,
                              AppConstants
                                  .languages[localizationController
                                      .selectedLanguageIndex]
                                  .countryCode,
                            ));
                            if (widget.fromMenu) {
                              Navigator.pop(context);
                            } else {
                              Get.offNamed(RouteHelper.getOnBoardingRoute());
                            }
                          } else {
                            showCustomSnackBar('select_a_language'.tr);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
      }),
    );
  }
}
