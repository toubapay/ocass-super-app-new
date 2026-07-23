import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/filter_view.dart';
import 'package:sixam_mart/features/home/widgets/store_filter_button_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class AllStoreFilterWidget extends StatelessWidget {
  const AllStoreFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        return Center(
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Container(
              width: Dimensions.webMaxWidth,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: ResponsiveHelper.isDesktop(context)
                  ? Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Get.find<SplashController>()
                              .configModel!
                              .moduleConfig!
                              .module!
                              .showRestaurantText!
                              ? 'restaurants'.tr
                              : 'stores'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${storeController.storeModel?.totalSize ?? 0} ${Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'restaurants_near_you'.tr : 'stores_near_you'.tr}',
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  filter(context, storeController),
                ],
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Get.find<SplashController>()
                            .configModel!
                            .moduleConfig!
                            .module!
                            .showRestaurantText!
                            ? 'restaurants'.tr
                            : 'stores'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${storeController.storeModel?.totalSize ?? 0} ${Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'restaurants_near_you'.tr : 'stores_near_you'.tr}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  filter(context, storeController),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget filter(BuildContext context, StoreController storeController) {
    return SizedBox(
      height: ResponsiveHelper.isDesktop(context) ? 42 : 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          if (!ResponsiveHelper.isDesktop(context))
            FilterView(storeController: storeController),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          // Modern rounded filter buttons
          StoreFilterButtonWidget(
            buttonText: 'all'.tr,
            onTap: () => storeController.setStoreType('all'),
            isSelected: storeController.storeType == 'all',
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          StoreFilterButtonWidget(
            buttonText: 'newly_joined'.tr,
            onTap: () => storeController.setStoreType('newly_joined'),
            isSelected: storeController.storeType == 'newly_joined',
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          StoreFilterButtonWidget(
            buttonText: 'popular'.tr,
            onTap: () => storeController.setStoreType('popular'),
            isSelected: storeController.storeType == 'popular',
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          StoreFilterButtonWidget(
            buttonText: 'top_rated'.tr,
            onTap: () => storeController.setStoreType('top_rated'),
            isSelected: storeController.storeType == 'top_rated',
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          if (ResponsiveHelper.isDesktop(context))
            FilterView(storeController: storeController),
        ],
      ),
    );
  }
}
