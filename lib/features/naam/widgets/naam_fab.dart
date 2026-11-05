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
            child: Material(
              elevation: 6,
              shape: const CircleBorder(),
              color: Colors.transparent,
              child: Stack(clipBehavior: Clip.none, children: [
                const NaamAvatar(size: 60, label: 'Naam'),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0F6B3E), width: 2),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
}
