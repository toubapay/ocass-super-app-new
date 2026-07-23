import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/home/widgets/category_pop_up.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

import '../../../category/domain/models/category_model.dart';

// Helper function to calculate display item count
// Ensures we show complete columns and "+" appears in last row
int _getDisplayCount(int totalCategories) {
  const int rowCount = 3; // ✅ only 3 rows
  const int maxItems = 21; // 3 rows × 7 columns

  if (totalCategories >= maxItems) {
    return maxItems;
  }

  // +1 for "see all" so it stays in 3rd row
  int columns = ((totalCategories + 1) / rowCount).ceil();
  int displayCount = columns * rowCount;

  return displayCount > maxItems ? maxItems : displayCount;
}

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    return GetBuilder<SplashController>(builder: (splashController) {
      bool isPharmacy = splashController.module != null &&
          splashController.module!.moduleType.toString() ==
              AppConstants.pharmacy;
      bool isFood = splashController.module != null &&
          splashController.module!.moduleType.toString() == AppConstants.food;

      return GetBuilder<CategoryController>(builder: (categoryController) {
        return (categoryController.categoryList != null &&
                categoryController.categoryList!.isEmpty)
            ? const SizedBox()
            : isPharmacy
                ? PharmacyCategoryView(categoryController: categoryController)
                : isFood
                    ? FoodCategoryView(categoryController: categoryController)
                    : Column(
                        children: [
                          SizedBox(
                            // Height for 4 rows (75 image + text + spacing per row)
                            height: 260,
                            child: categoryController.categoryList != null
                                ? GridView.builder(
                                    scrollDirection:
                                        Axis.horizontal, // horizontal scroll
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2, // 4 rows
                                      mainAxisSpacing: 10, // space between rows
                                      crossAxisSpacing:
                                          10, // space between columns
                                      childAspectRatio:
                                          1.4, // width/height ratio
                                    ),
                                    itemCount: _getDisplayCount(
                                        categoryController
                                            .categoryList!.length),
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeSmall),
                                    itemBuilder: (context, index) {
                                      int totalCategories = categoryController
                                          .categoryList!.length;
                                      int displayCount =
                                          _getDisplayCount(totalCategories);
                                      // Show + on last slot if there are more categories than displayed
                                      bool isSeeAll =
                                          index == displayCount - 1 &&
                                              totalCategories >= displayCount;
                                      // Check if this slot has an actual category
                                      bool hasCategory =
                                          index < totalCategories;
                                      // Empty slot (filler to complete the grid)
                                      bool isEmpty = !hasCategory && !isSeeAll;

                                      // Return empty space for filler slots
                                      if (isEmpty) {
                                        return const SizedBox();
                                      }

                                      return InkWell(
                                        onTap: () {
                                          if (isSeeAll) {
                                            Get.toNamed(
                                                RouteHelper.getCategoryRoute());
                                          } else if (hasCategory) {
                                            Get.toNamed(
                                              RouteHelper.getCategoryItemRoute(
                                                categoryController
                                                    .categoryList![index].id,
                                                categoryController
                                                    .categoryList![index].name!,
                                              ),
                                            );
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 75,
                                              width: 75,
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .radiusSmall),
                                                    child: hasCategory
                                                        ? CustomImage(
                                                            image:
                                                                '${categoryController.categoryList![index].imageFullUrl}',
                                                            height: 75,
                                                            width: 75,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Container(
                                                            height: 75,
                                                            width: 75,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey[200],
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusSmall),
                                                            ),
                                                          ),
                                                  ),
                                                  isSeeAll
                                                      ? Positioned.fill(
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusSmall),
                                                              gradient:
                                                                  LinearGradient(
                                                                begin: Alignment
                                                                    .topCenter,
                                                                end: Alignment
                                                                    .bottomCenter,
                                                                colors: [
                                                                  Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.4),
                                                                  Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.6),
                                                                  Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.4),
                                                                ],
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                '+${totalCategories - (displayCount - 1)}', // Remaining categories (displayCount-1 because last slot is "+")
                                                                style:
                                                                    robotoMedium
                                                                        .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeExtraLarge,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .cardColor,
                                                                ),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraSmall),
                                            Text(
                                              isSeeAll
                                                  ? 'see_all'.tr
                                                  : hasCategory
                                                      ? categoryController
                                                          .categoryList![index]
                                                          .name!
                                                      : '',
                                              style: robotoMedium.copyWith(
                                                fontSize: 11,
                                                color: isSeeAll
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .color,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : CategoryShimmer(
                                    categoryController: categoryController),
                          ),
                          ResponsiveHelper.isMobile(context)
                              ? const SizedBox()
                              : categoryController.categoryList != null
                                  ? Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (con) => Dialog(
                                                    child: SizedBox(
                                                        height: 550,
                                                        width: 600,
                                                        child: CategoryPopUp(
                                                          categoryController:
                                                              categoryController,
                                                        ))));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: Dimensions
                                                    .paddingSizeSmall),
                                            child: CircleAvatar(
                                              radius: 35,
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              child: Text('view_all'.tr,
                                                  style: TextStyle(
                                                      fontSize: Dimensions
                                                          .paddingSizeDefault,
                                                      color: Theme.of(context)
                                                          .cardColor)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        )
                                      ],
                                    )
                                  : CategoryShimmer(
                                      categoryController: categoryController),
                        ],
                      );
      });
    });
  }
}

class PharmacyCategoryView extends StatelessWidget {
  final CategoryController categoryController;
  const PharmacyCategoryView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    final categories = categoryController.categoryList ?? [];

    return SizedBox(
      height: 280, // 2 rows height
      child: categories.isNotEmpty
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeDefault,
                top: Dimensions.paddingSizeDefault,
              ),
              itemCount: (categories.length / 2).ceil(),
              itemBuilder: (context, columnIndex) {
                int first = columnIndex * 2;
                int second = first + 1;

                return Padding(
                  padding:
                      const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: Column(
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      _categoryItem(context, categories[first], first),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      if (second < categories.length)
                        _categoryItem(context, categories[second], second),
                    ],
                  ),
                );
              },
            )
          : PharmacyCategoryShimmer(categoryController: categoryController),
    );
  }

  /// 🔥 SAME DESIGN — COPY OF YOUR EXISTING ITEM
  Widget _categoryItem(
      BuildContext context, CategoryModel category, int index) {
    return InkWell(
      onTap: () {
        Get.toNamed(RouteHelper.getCategoryItemRoute(
          category.id,
          category.name!,
        ));
      },
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(100),
            topRight: Radius.circular(100),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.3),
              Theme.of(context).cardColor.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Column(children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(100),
              topRight: Radius.circular(100),
            ),
            child: CustomImage(
              image: category.imageFullUrl ?? '',
              height: 60,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              category.name ?? '',
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ]),
      ),
    );
  }
}

class FoodCategoryView extends StatelessWidget {
  final CategoryController categoryController;
  const FoodCategoryView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Increased height for 3 rows
      height: 360, // Changed from 240 to 360 for 3 rows (3x120)
      child: categoryController.categoryList != null
          ? GridView.builder(
              scrollDirection: Axis.horizontal, // horizontal scroll
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeDefault,
                top: Dimensions.paddingSizeDefault,
                bottom: Dimensions.paddingSizeDefault,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Changed from 2 to 3 for 3 rows
                mainAxisSpacing: 10, // spacing between rows
                crossAxisSpacing: 15, // spacing between columns
                childAspectRatio: 1.1, // adjust width/height
              ),
              itemCount: categoryController.categoryList!.length >
                      15 // Changed from 10 to 15 (3x5)
                  ? 15
                  : categoryController.categoryList!.length,
              itemBuilder: (context, index) {
                // Changed see all logic for 3 rows
                bool isSeeAll = index == 14 &&
                    categoryController.categoryList!.length >
                        15; // Changed from 9 to 14

                return InkWell(
                  onTap: () {
                    if (isSeeAll) {
                      Get.toNamed(RouteHelper.getCategoryRoute());
                    } else {
                      Get.toNamed(RouteHelper.getCategoryItemRoute(
                        categoryController.categoryList![index].id,
                        categoryController.categoryList![index].name!,
                      ));
                    }
                  },
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: SizedBox(
                    width: 70,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100)),
                              child: CustomImage(
                                image:
                                    '${categoryController.categoryList![index].imageFullUrl}',
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            isSeeAll
                                ? Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(100)),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.4),
                                            Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.6),
                                            Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.4),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '+${categoryController.categoryList!.length - 15}', // Changed from -10 to -15
                                          style: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraLarge,
                                            color: Theme.of(context).cardColor,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Text(
                          isSeeAll
                              ? 'see_all'.tr
                              : categoryController.categoryList![index].name ??
                                  '',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: isSeeAll
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : FoodCategoryShimmer(categoryController: categoryController),
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const CategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.only(
          left: Dimensions.paddingSizeSmall,
          top: Dimensions.paddingSizeDefault),
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 1, vertical: Dimensions.paddingSizeDefault),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: SizedBox(
              width: 80,
              child: Column(children: [
                Container(
                    height: 75,
                    width: 75,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : Dimensions.paddingSizeExtraSmall,
                      right: Dimensions.paddingSizeExtraSmall,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      color: Colors.grey[300],
                    )),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Padding(
                  padding: EdgeInsets.only(
                      right: index == 0 ? Dimensions.paddingSizeExtraSmall : 0),
                  child: Container(
                    height: 10,
                    width: 50,
                    color: Colors.grey[300],
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class FoodCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const FoodCategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              bottom: Dimensions.paddingSizeDefault,
              left: Dimensions.paddingSizeDefault,
              top: Dimensions.paddingSizeDefault),
          child: SizedBox(
            width: 60,
            child: Column(children: [
              ClipOval(
                child: Shimmer(
                  child: Container(
                      height: 60,
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).shadowColor,
                      )),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Expanded(
                child: Shimmer(
                  child: Container(
                    height: 10,
                    width: 50,
                    color: Theme.of(context).shadowColor,
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class PharmacyCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const PharmacyCategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              bottom: Dimensions.paddingSizeDefault,
              left: Dimensions.paddingSizeDefault,
              top: Dimensions.paddingSizeDefault),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              width: 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    topRight: Radius.circular(100)),
              ),
              child: Column(children: [
                Container(
                    height: 60,
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(100),
                          topRight: Radius.circular(100)),
                      color: Colors.grey[300],
                    )),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Container(
                    height: 10,
                    width: 50,
                    color: Colors.grey[300],
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
