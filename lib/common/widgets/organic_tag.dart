import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class OrganicTag extends StatelessWidget {
  final double? fontSize;
  final Item item;
  final bool placeTop;
  final bool placeInImage;
  final bool fromDetails;

  const OrganicTag(
      {super.key,
      this.fontSize,
      required this.item,
      this.placeTop = false,
      this.placeInImage = false,
      this.fromDetails = false});

  @override
  Widget build(BuildContext context) {
    // Return empty if not organic or not grocery module
    if (item.organic != 1 || item.moduleType != 'grocery') {
      return const SizedBox();
    }

    // For details page
    if (fromDetails) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 14,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              'organic'.tr,
              style: robotoMedium.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize:
                    fontSize ?? (ResponsiveHelper.isMobile(context) ? 10 : 12),
              ),
            ),
          ],
        ),
      );
    }

    // For card/in-image placement
    return Positioned(
      top: placeInImage ? null : (placeTop ? 8 : null),
      // Remove top positioning
      left: placeInImage ? 8 : 10,
      // Keep left positioning
      right: placeInImage ? null : null,
      bottom: placeInImage ? 8 : null,
      // Add bottom positioning for in-image
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green[700],
          borderRadius: placeInImage
              ? const BorderRadius.only(
                  topRight: Radius.circular(6), // Change to top-right only
                  bottomLeft: Radius.circular(6),
                )
              : BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 10,
              color: Colors.white,
            ),
            const SizedBox(width: 2),
            Text(
              'organic'.tr.toUpperCase(),
              style: robotoMedium.copyWith(
                color: Colors.white,
                fontSize:
                    fontSize ?? (ResponsiveHelper.isMobile(context) ? 8 : 10),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
