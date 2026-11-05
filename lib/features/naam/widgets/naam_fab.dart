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
              child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
                const NaamAvatar(size: 62),
                Positioned(
                  top: 3,
                  right: 3,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0E4D3A), width: 2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E4D3A),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFF2D27A), width: 1.5),
                    ),
                    child: const Text('Naam', style: TextStyle(color: Color(0xFFF2D27A), fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
}
