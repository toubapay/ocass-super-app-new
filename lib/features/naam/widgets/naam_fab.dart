import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/naam/screens/naam_screen.dart';
import 'package:sixam_mart/helper/route_helper.dart';

/// The home screen's round button that opens Naam.
class NaamFab extends StatelessWidget {
  const NaamFab({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Tooltip(
          message: 'naam_menu'.tr,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Get.toNamed(RouteHelper.getNaamRoute()),
            child: Material(elevation: 6, shape: const CircleBorder(), child: const NaamAvatar(size: 56)),
          ),
        ),
      );
}
