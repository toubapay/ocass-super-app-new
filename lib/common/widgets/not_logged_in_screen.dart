import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/styles.dart';

class NotLoggedInScreen extends StatelessWidget {
  final Function(bool success) callBack;
  const NotLoggedInScreen({super.key, required this.callBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FooterView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Floating Container
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.2),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: [0.1, 0.5, 1.0],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Ring
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),

                      // Middle Ring
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                      ),

                      // Inner Circle with Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 50,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),

                      // Floating Lock Icon
                      Positioned(
                        top: 30,
                        right: 30,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                // Text Content with Unique Layout
                Column(
                  children: [
                    // Main Title with Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'authentication_required'.tr,
                          style: robotoBold.copyWith(
                            fontSize: 24,
                            color:
                                Theme.of(context).textTheme.titleLarge!.color,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Subtitle with Creative Design
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'you_are_not_logged_in'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'please_login_to_continue'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: 14,
                              color: Theme.of(context).disabledColor,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40),

                // Animated Login Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        if (!ResponsiveHelper.isDesktop(context)) {
                          await Get.toNamed(
                              RouteHelper.getSignInRoute(Get.currentRoute));
                        } else {
                          Get.dialog(
                                  const Center(
                                      child: AuthDialogWidget(
                                          exitFromApp: false,
                                          backFromThis: true)),
                                  barrierDismissible: false)
                              .then((value) => callBack(true));
                        }
                        if (Get.find<OrderController>().showBottomSheet) {
                          Get.find<OrderController>().showRunningOrders();
                        }
                        callBack(true);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'login_to_continue'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Additional Info
                Text(
                  'join_thousands_of_happy_customers'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: 12,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
