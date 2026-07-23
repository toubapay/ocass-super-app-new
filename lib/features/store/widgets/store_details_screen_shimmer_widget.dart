import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';

import '../../../util/dimensions.dart';

class StoreDetailsScreenShimmerWidget extends StatelessWidget {
  const StoreDetailsScreenShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: ResponsiveHelper.isMobile(context)
          ? _buildMobileShimmer(context)
          : _buildWebShimmer(context),
    );
  }

  Widget _buildMobileShimmer(BuildContext context) {
    return Column(
      children: [
        // Store Cover Image Shimmer
        Shimmer(
          child: Container(
            height: 220,
            color: Theme.of(context).shadowColor.withOpacity(0.3),
          ),
        ),

        // Store Info Card
        _buildStoreInfoShimmer(context),

        // Stats Row
        _buildStatsShimmer(context),

        // Section Header for Items
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: Dimensions.paddingSizeExtraSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child:
                        _buildShimmerContainer(context, width: 100, height: 20),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  _buildShimmerContainer(context, width: 150, height: 24),
                ],
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),

        // Items Grid View (2 items per row)
        _buildItemsGridShimmer(context),
      ],
    );
  }

  Widget _buildStoreInfoShimmer(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Store Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).shadowColor,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeLarge),

          // Store Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                _buildShimmerContainer(context, width: 180, height: 16),
                const SizedBox(height: 8),
                _buildShimmerContainer(context, width: 120, height: 14),
                const SizedBox(height: 8),
                _buildShimmerContainer(context, width: 160, height: 14),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // Action Buttons
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsShimmer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeDefault,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeLarge,
        horizontal: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItemShimmer(
            context,
            icon: Icons.star_rounded,
          ),
          _buildStatItemShimmer(
            context,
            icon: Icons.location_on_rounded,
          ),
          _buildStatItemShimmer(
            context,
            icon: Icons.timer_rounded,
          ),
          _buildStatItemShimmer(
            context,
            icon: Icons.local_shipping_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemShimmer(BuildContext context, {required IconData icon}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).cardColor,
            size: 20,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        _buildShimmerContainer(context, width: 50, height: 12),
      ],
    );
  }

  Widget _buildItemsGridShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 items per row
          crossAxisSpacing: Dimensions.paddingSizeDefault,
          mainAxisSpacing: Dimensions.paddingSizeDefault,
          childAspectRatio: 0.8, // Adjust aspect ratio for better appearance
        ),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 6, // Show 6 items (3 rows of 2)
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              color: Theme.of(context).cardColor,
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Item Image
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radiusLarge),
                    ),
                    color: Theme.of(context).shadowColor,
                  ),
                ),

                // Item Details
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildShimmerContainer(context,
                            width: double.infinity, height: 16),
                        _buildShimmerContainer(context, width: 80, height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildShimmerContainer(context,
                                width: 60, height: 16),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWebShimmer(BuildContext context) {
    return Column(
      children: [
        // Hero Section
        Container(
          height: 300,
          color: Theme.of(context).shadowColor.withOpacity(0.3),
          child: Center(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Row(
                children: [
                  // Cover Image
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 250,
                      margin: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusLarge),
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraLarge),

                  // Store Info
                  Expanded(
                    flex: 1,
                    child: _buildStoreInfoWebShimmer(context),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Stats Section
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeExtraLarge,
          ),
          child: Center(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: _buildStatsWebShimmer(context),
            ),
          ),
        ),

        // Featured Items Section
        Container(
          padding: const EdgeInsets.only(
            top: Dimensions.paddingSizeExtraLarge,
            bottom: Dimensions.paddingSizeLarge,
          ),
          child: Center(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: Dimensions.paddingSizeExtraSmall,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                              ),
                              child: _buildShimmerContainer(
                                context,
                                width: 100,
                                height: 20,
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            _buildShimmerContainer(
                              context,
                              width: 200,
                              height: 28,
                            ),
                          ],
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Featured Items Grid (2 items per row for web too)
                  _buildFeaturedItemsGridShimmer(context),
                ],
              ),
            ),
          ),
        ),

        // All Items Grid
        Container(
          padding: const EdgeInsets.only(
            bottom: Dimensions.paddingSizeExtraLarge,
          ),
          child: Center(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: _buildAllItemsGridShimmer(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreInfoWebShimmer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo and Title
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).shadowColor,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerContainer(context, width: 180, height: 22),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    _buildShimmerContainer(context, width: 120, height: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerContainer(context,
                  width: double.infinity, height: 14),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildShimmerContainer(context, width: 250, height: 14),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildShimmerContainer(context, width: 200, height: 14),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 140,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsWebShimmer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildWebStatItemShimmer(context),
          _buildWebStatItemShimmer(context),
          _buildWebStatItemShimmer(context),
          _buildWebStatItemShimmer(context),
          _buildWebStatItemShimmer(context),
        ],
      ),
    );
  }

  Widget _buildWebStatItemShimmer(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        _buildShimmerContainer(context, width: 60, height: 14),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        _buildShimmerContainer(context, width: 40, height: 12),
      ],
    );
  }

  Widget _buildFeaturedItemsGridShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 items per row for featured items too
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisSpacing: Dimensions.paddingSizeLarge,
          childAspectRatio: 1.1,
        ),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 4, // Show 4 featured items (2 rows of 2)
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              color: Theme.of(context).cardColor,
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Item Image
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radiusLarge),
                    ),
                    color: Theme.of(context).shadowColor,
                  ),
                ),

                // Item Details
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildShimmerContainer(context, width: 120, height: 18),
                        _buildShimmerContainer(context, width: 150, height: 14),
                        _buildShimmerContainer(context, width: 80, height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildShimmerContainer(context,
                                width: 60, height: 14),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllItemsGridShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.isDesktop(context)
              ? 4
              : 3, // Adjusted for better layout
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisSpacing: Dimensions.paddingSizeLarge,
          childAspectRatio: 0.85,
        ),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              color: Theme.of(context).cardColor,
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Item Image
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radiusLarge),
                    ),
                    color: Theme.of(context).shadowColor,
                  ),
                ),

                // Item Details
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildShimmerContainer(context, width: 100, height: 16),
                        _buildShimmerContainer(context, width: 140, height: 12),
                        _buildShimmerContainer(context, width: 70, height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildShimmerContainer(context,
                                width: 50, height: 12),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerContainer(BuildContext context,
      {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
    );
  }
}
