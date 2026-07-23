import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

import '../../../helper/route_helper.dart';
import '../../location/controllers/location_controller.dart';
import '../../notification/controllers/notification_controller.dart';

class HeaderLocationView extends StatelessWidget {
  const HeaderLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeSmall,
        ),
        child: Row(
          children: [
            /// LOCATION SECTION
            Expanded(
              child: InkWell(
                onTap: () => Get.find<LocationController>()
                    .navigateToLocationScreen('home'),
                child: GetBuilder<LocationController>(
                  builder: (locationController) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AuthHelper.isLoggedIn()
                              ? AddressHelper.getUserAddressFromSharedPref()!
                                  .addressType!
                                  .tr
                              : 'Livraison'.tr,
                          style: robotoMedium.copyWith(
                            color: const Color(0xFF000000),
                            fontSize: Dimensions.fontSizeOverLarge2,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                AddressHelper.getUserAddressFromSharedPref()!
                                    .address!,
                                style: robotoRegular.copyWith(
                                  color: Colors.black.withOpacity(0.8),
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.expand_more,
                              color: Colors.black.withOpacity(0.8),
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            /// 🔹 NOTIFICATION ICON
            GetBuilder<NotificationController>(
              builder: (notificationController) {
                return Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.bell,
                        color: Colors.black,
                        size: 25,
                      ),
                      onPressed: () => Get.toNamed(
                        RouteHelper.getNotificationRoute(),
                      ),
                    ),
                    if (notificationController.hasNotification)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
