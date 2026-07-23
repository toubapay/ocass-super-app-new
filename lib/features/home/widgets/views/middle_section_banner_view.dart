import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class MiddleSectionBannerView extends StatelessWidget {
  const MiddleSectionBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CampaignController>(builder: (campaignController) {
      return campaignController.basicCampaignList != null
          ? campaignController.basicCampaignList!.isNotEmpty
              ? Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFE8F4FC),
                        Color(0xFFD6EBF7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading and Subheading
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeDefault,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'featured_this_week'.tr,
                              style: robotoBold.copyWith(
                                fontSize: 22,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'explore_your_need'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3x2 Grid of Campaign Images
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeExtraSmall,
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeDefault,
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: campaignController.basicCampaignList!.length > 6 
                              ? 6 
                              : campaignController.basicCampaignList!.length,
                          itemBuilder: (context, index) {
                            return _FeaturedBannerCard(
                              imageUrl: campaignController.basicCampaignList![index].imageFullUrl,
                              onTap: () => Get.toNamed(RouteHelper.getBasicCampaignRoute(
                                campaignController.basicCampaignList![index],
                              )),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox()
          : const MiddleSectionBannerShimmerView();
    });
  }
}

class _FeaturedBannerCard extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;

  const _FeaturedBannerCard({
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE3F1FA),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: const Color(0xFF4A90D9),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault - 2),
          child: CustomImage(
            image: '$imageUrl',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}

class MiddleSectionBannerShimmerView extends StatelessWidget {
  const MiddleSectionBannerShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8F4FC),
            Color(0xFFD6EBF7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer(
                  child: Container(
                    height: 22,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer(
                  child: Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeDefault,
              0,
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeDefault,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: true,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
