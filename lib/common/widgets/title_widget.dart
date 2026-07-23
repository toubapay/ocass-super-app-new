import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final String? image;
  const TitleWidget({super.key, required this.title, this.onTap, this.image});

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        children: [
          Text(title,
              style: robotoBold.copyWith(
                  fontSize: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.fontSizeLarge
                      : Dimensions.fontSizeLarge)),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          image != null
              ? Image.asset(
                  image!,
                  height: 20,
                  width: 20,
                )
              : const SizedBox(),
        ],
      ),
      (onTap != null)
          ? InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap as void Function()?,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'see_all'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      ltr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                      size: 12,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(),
    ]);
  }
}
