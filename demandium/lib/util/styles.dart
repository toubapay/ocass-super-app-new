import 'package:demandium/feature/splash/controller/theme_controller.dart';
import 'package:demandium/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

var robotoLight = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w300,
  fontSize: Dimensions.fontSizeSmall,
  height: 1.5,
);

const robotoRegular = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
);

const robotoMedium = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

const robotoSemiBold = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w600,
);

const robotoBold = TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w700);

List<BoxShadow>? searchBoxShadow = [
  BoxShadow(
    offset: Offset(0, 4),
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 14,
    spreadRadius: 0,
  ),
];

List<BoxShadow> cardShadow = [
  const BoxShadow(
    offset: Offset(0, 2),
    spreadRadius: 2,
    blurRadius: 2,
    color: Color(0x20A8A8EA),
  ),
];

List<BoxShadow>? lightShadow = Get.isDarkMode
    ? [const BoxShadow()]
    : [
        const BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 3,
          spreadRadius: 1,
          color: Color(0x20D6D8E6),
        ),
      ];

List<BoxShadow>? shadow = Get.find<ServiceThemeController>().darkTheme
    ? [const BoxShadow()]
    : [
        BoxShadow(
          offset: const Offset(0, 3),
          color: Colors.grey[100]!,
          blurRadius: 1,
          spreadRadius: 2,
        ),
      ];

Decoration shimmerDecorationGreySoft = BoxDecoration(
  color: Colors.grey[Get.find<ServiceThemeController>().darkTheme ? 700 : 300],
  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
);

Decoration shimmerDecorationGreyHard = BoxDecoration(
  color: Colors.grey[Get.find<ServiceThemeController>().darkTheme ? 700 : 400],
  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
);
