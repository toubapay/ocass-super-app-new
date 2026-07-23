import 'package:flutter/material.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';
import 'package:sixam_mart/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/features/home/widgets/views/visit_again_view.dart';
import 'package:sixam_mart/helper/auth_helper.dart';

// Import the BannerView and ThemeController
import '../../../../common/widgets/module_header_with_background.dart';
import '../../widgets/banner_view.dart';
import '../../widgets/views/best_store_nearby_view.dart';

class FoodHomeScreen extends StatelessWidget {
  const FoodHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const ModuleHeaderWithBackground(),

      // SizedBox(
      //   width: MediaQuery.of(context).size.width,
      //   child: const Column(
      //     children: [
      //       BannerView(isFeatured: true),
      //       SizedBox(height: 12),
      //     ],
      //   ),
      // ),
      const CategoryView(),

      // Banner after CategoryView without background image

      // const HeaderLocationView(),
      isLoggedIn ? const VisitAgainView(fromFood: true) : const SizedBox(),

      const SpecialOfferView(isFood: true, isShop: false),
      const HighlightWidget(),
      const TopOffersNearMe(),
      const BestReviewItemView(),
      const BestStoreNearbyView(),
      const ItemThatYouLoveView(forShop: false),
      const MostPopularItemView(isFood: true, isShop: false),
      // const RecommendedStoreView(),
      const JustForYouView(),
      const NewOnMartView(isNewStore: true, isPharmacy: false, isShop: false),
    ]);
  }
}
