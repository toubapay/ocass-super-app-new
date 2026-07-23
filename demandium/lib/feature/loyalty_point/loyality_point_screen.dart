import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class LoyaltyPointScreen extends StatelessWidget {
  final String? fromNotification;
  const LoyaltyPointScreen({super.key, this.fromNotification});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceSplashController>(
      builder: (splashController) {
        if (splashController.currentDataSource == DataSourceEnum.client &&
            splashController.configModel.content?.loyaltyPointStatus == 0) {
          Future.delayed(const Duration(microseconds: 100)).then((value) {
            Get.offAllNamed(ServiceRouteHelper.getMainRoute("home"));
          });
        }
        return CustomPopWidget(
          child: Scaffold(
            drawer: ResponsiveHelper.isDesktop(context)
                ? const AddressSelectionDrawer()
                : null,

            endDrawer: ResponsiveHelper.isDesktop(context)
                ? const MenuDrawer()
                : null,
            appBar: CustomAppBar(
              title: 'loyalty_point'.tr,
              actionWidget: InkWell(
                onTap: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    transitionDuration: const Duration(milliseconds: 500),
                    barrierLabel: MaterialLocalizations.of(context).dialogLabel,
                    barrierColor: Colors.black.withValues(alpha: 0.5),
                    pageBuilder: (context, _, a) {
                      return const LoyaltyPointUsesManualDialog();
                    },
                    transitionBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position:
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOut,
                                ).drive(
                                  Tween<Offset>(
                                    begin: const Offset(0, -1.0),
                                    end: Offset.zero,
                                  ),
                                ),
                            child: child,
                          );
                        },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Image.asset(
                    Images.info,
                    width: 20,
                    height: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              onBackPressed: () {
                if (fromNotification == "fromNotification") {
                  Get.offAllNamed(ServiceRouteHelper.getMainRoute("home"));
                } else {
                  Get.back();
                }
              },
              bgColor: Theme.of(context).cardColor,
            ),
            body: GetBuilder<LoyaltyPointController>(
              initState: (_) {
                Get.find<LoyaltyPointController>().getLoyaltyPointData(1);
              },
              builder: (loyaltyPointController) {
                return FooterBaseView(
                  isScrollView: true,
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: loyaltyPointController.loyaltyPointModel != null
                        ? Column(
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LoyaltyPointTopCard(),

                                  LoyaltyPointListView(),
                                ],
                              ),
                              if (ResponsiveHelper.isDesktop(context))
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: Dimensions.paddingSizeSmall,
                                  ),
                                  child: CustomButton(
                                    width:
                                        Dimensions.currencyConvertButtonHeight,
                                    buttonText: "convert_to_currency".tr,
                                    assetIcon: Images.convertPoint,
                                    height: 45,
                                    radius: Dimensions.radiusExtraMoreLarge,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) {
                                          return const ConvertLoyaltyPointDialog();
                                        },
                                      );
                                    },
                                  ),
                                ),
                            ],
                          )
                        : Center(
                            child: SizedBox(
                              height: ResponsiveHelper.isDesktop(context)
                                  ? 100
                                  : Get.height * 0.85,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
            bottomSheet: GetBuilder<LoyaltyPointController>(
              builder: (loyaltyPointController) {
                if (!ResponsiveHelper.isDesktop(context) &&
                    Get.find<LoyaltyPointController>().loyaltyPointModel !=
                        null) {
                  return SizedBox(
                    height: 60,
                    width: Get.width,
                    child: CustomButton(
                      width: Dimensions.currencyConvertButtonHeight,
                      buttonText: "convert_to_currency".tr,
                      assetIcon: Images.convertPoint,
                      height: 45,
                      radius: Dimensions.radiusExtraMoreLarge,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return const ConvertLoyaltyPointDialog();
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
