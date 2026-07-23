import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';

class PromotionalBannerView extends StatelessWidget {
  const PromotionalBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(
      builder: (bannerController) {

        // 🔹 API abhi tak load nahi hui
        if (bannerController.promotionalBanner == null) {
          return const PromotionalBannerShimmerView();
        }

        final String? imageUrl =
            bannerController.promotionalBanner!.bottomSectionBannerFullUrl;

        // 🔹 image null ya empty hai
        if (imageUrl == null || imageUrl.isEmpty) {
          return const SizedBox();
        }

        return Container(
          height: 150,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius:
            BorderRadius.circular(Dimensions.paddingSizeDefault),
          ),
          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(Dimensions.paddingSizeDefault),
            child: CustomImage(
              image: imageUrl,
              fit: BoxFit.cover,
              height: 150, // ✅ FIXED
              width: double.infinity,
            ),
          ),
        );
      },
    );
  }
}


class PromotionalBannerShimmerView extends StatelessWidget {
  const PromotionalBannerShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        ),
      ),
    );
  }
}
