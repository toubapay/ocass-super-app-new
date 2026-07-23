import 'dart:developer';

import 'package:demandium/feature/home/widget/nearby_provider_listview.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class HomeScreen extends StatefulWidget {
  static Future<void> loadData(
    bool reload, {
    int availableServiceCount = 1,
  }) async {
    if (availableServiceCount == 0) {
      Get.find<ServiceBannerController>().getBannerList(reload);
    } else {
      await Future.wait([
        Get.find<ServiceController>().getRecommendedSearchList(),
        Get.find<ServiceController>().getAllServiceList(1, reload),
        Get.find<ServiceBannerController>().getBannerList(reload),
        Get.find<ServiceAdvertisementController>().getAdvertisementList(reload),
        Get.find<ServiceCategoryController>().getCategoryList(reload),
        Get.find<ServiceController>().getPopularServiceList(1, reload),
        Get.find<ServiceController>().getTrendingServiceList(1, reload),
        Get.find<ProviderBookingController>().getProviderList(1, reload),
        Get.find<NearbyProviderController>().getProviderList(1, reload),
        Get.find<ServiceCampaignController>().getCampaignList(reload),
        Get.find<ServiceController>().getRecommendedServiceList(1, reload),
        Get.find<CheckOutController>().getOfflinePaymentMethod(
          false,
          shouldUpdate: false,
        ),
        Get.find<ServiceController>().getFeatherCategoryList(reload),
        if (Get.find<ServiceAuthController>().isLoggedIn())
          Get.find<ServiceAuthController>().updateToken(),
        if (Get.find<ServiceAuthController>().isLoggedIn())
          Get.find<ServiceController>().getRecentlyViewedServiceList(1, reload),
      ]);

      Get.find<BookingDetailsController>().manageDialog();
    }
  }

  final AddressModel? addressModel;
  final bool showServiceNotAvailableDialog;
  const HomeScreen({
    super.key,
    this.addressModel,
    required this.showServiceNotAvailableDialog,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AddressModel? _previousAddress;
  int availableServiceCount = 0;
  bool loading = true;

  _checkPermission() async {
    var locationController = Get.find<ServiceLocationController>();

    if (locationController.getUserAddress() == null) {
      log("this is the address :" + locationController.address.toString());
      AddressModel address = await locationController.getCurrentLocation(
        true,
        deviceCurrentLocation: true,
      );
      ZoneResponseModel response = await locationController.getZone(
        address.latitude!,
        address.longitude!,
        false,
      );

      if (response.isSuccess) {
        locationController.saveAddressAndNavigate(
          address,
          false,
          '',
          true,
          true,
        );
      } else {
        loading = false;
        setState(() {});
        //Get.toNamed(ServiceRouteHelper.getPickMapRoute(route == null ? ServiceRouteHelper.accessLocation : route!, route != null, 'false', null, previousAddress));
      }
    } else {
      loading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    if (Get.find<ServiceSplashController>().getGuestId().isEmpty) {
      log('guest id is missing..');
      var uuid = const Uuid().v1();
      Get.find<ServiceSplashController>().setGuestId(uuid);
    }

    Get.find<ServiceLocalizationController>().filterLanguage(
      shouldUpdate: false,
    );
    if (Get.find<ServiceAuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo();
      Get.find<ServiceLocationController>().getAddressList();
    }
    if (Get.find<ServiceLocationController>().getUserAddress() != null) {
      availableServiceCount = Get.find<ServiceLocationController>()
          .getUserAddress()!
          .availableServiceCountInZone!;
    }
    HomeScreen.loadData(false, availableServiceCount: availableServiceCount);

    _previousAddress = widget.addressModel;

    if (_previousAddress != null &&
        availableServiceCount == 0 &&
        widget.showServiceNotAvailableDialog) {
      Future.delayed(const Duration(microseconds: 1000), () {
        Get.dialog(
          ServiceNotAvailableDialog(
            address: _previousAddress,
            forCard: false,
            showButton: true,
            onBackPressed: () {
              Get.back();
              Get.find<ServiceLocationController>().setZoneContinue('false');
            },
          ),
        );
      });
    }
    _checkPermission();
  }

  PreferredSizeWidget homeAppBar({
    GlobalKey<CustomShakingWidgetState>? signInShakeKey,
  }) {
    if (ResponsiveHelper.isDesktop(context)) {
      return WebMenuBar(signInShakeKey: signInShakeKey);
    } else {
      return const AddressAppBar(backButton: false);
    }
  }

  final ScrollController scrollController = ScrollController();
  final signInShakeKey = GlobalKey<CustomShakingWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBar(signInShakeKey: signInShakeKey),
      drawer: ResponsiveHelper.isDesktop(context)
          ? const AddressSelectionDrawer()
          : null,
      endDrawer: ResponsiveHelper.isDesktop(context)
          ? const MenuDrawer()
          : null,
      body: ResponsiveHelper.isDesktop(context)
          ? WebHomeScreen(
              scrollController: scrollController,
              availableServiceCount: availableServiceCount,
              signInShakeKey: signInShakeKey,
            )
          : loading
          ? Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
              ),
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Shimmer(
                    duration: const Duration(seconds: 2),
                    enabled: true,
                    color: Colors.grey,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                        boxShadow: Get.isDarkMode
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.grey[200]!,
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedSmoothIndicator(
                      activeIndex: 0,
                      count: 3,
                      effect: ExpandingDotsEffect(
                        dotHeight: 7,
                        dotWidth: 7,
                        spacing: 5,
                        activeDotColor: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.6),
                        dotColor: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (availableServiceCount > 0) {
                    Get.find<ServiceSplashController>().getConfigData();
                    await Get.find<ServiceController>().getAllServiceList(
                      1,
                      true,
                    );
                    await Get.find<ServiceBannerController>().getBannerList(
                      true,
                    );
                    await Get.find<ServiceAdvertisementController>()
                        .getAdvertisementList(true);
                    await Get.find<ServiceCategoryController>().getCategoryList(
                      true,
                    );
                    await Get.find<ServiceController>()
                        .getRecommendedServiceList(1, true);
                    await Get.find<ProviderBookingController>().getProviderList(
                      1,
                      true,
                    );
                    await Get.find<ServiceController>().getPopularServiceList(
                      1,
                      true,
                    );
                    await Get.find<ServiceController>().getTrendingServiceList(
                      1,
                      true,
                    );
                    await Get.find<ServiceCampaignController>().getCampaignList(
                      true,
                    );
                    await Get.find<ServiceController>().getFeatherCategoryList(
                      true,
                    );
                    await Get.find<ServiceCartController>()
                        .getCartListFromServer();
                    if (Get.find<ServiceAuthController>().isLoggedIn()) {
                      await Get.find<ServiceController>()
                          .getRecentlyViewedServiceList(1, true);
                    }
                  } else {
                    await Get.find<ServiceBannerController>().getBannerList(
                      true,
                    );
                  }
                },
                child: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: GetBuilder<ServiceSplashController>(
                    builder: (splashController) {
                      return GetBuilder<ProviderBookingController>(
                        builder: (providerController) {
                          return GetBuilder<ServiceController>(
                            builder: (serviceController) {
                              bool isAvailableProvider =
                                  providerController.providerList != null &&
                                  providerController.providerList!.isNotEmpty;
                              int? providerBooking = splashController
                                  .configModel
                                  .content
                                  ?.directProviderBooking;
                              bool isLtr =
                                  Get.find<ServiceLocalizationController>()
                                      .isLtr;

                              return CustomScrollView(
                                controller: scrollController,
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: ClampingScrollPhysics(),
                                ),
                                slivers: [
                                  const SliverToBoxAdapter(
                                    child: SizedBox(
                                      height: Dimensions.paddingSizeSmall,
                                    ),
                                  ),

                                  const HomeSearchWidget(),

                                  SliverToBoxAdapter(
                                    child: Center(
                                      child: SizedBox(
                                        width: Dimensions.webMaxWidth,
                                        child: Column(
                                          children: [
                                            const BannerView(),
                                            availableServiceCount > 0
                                                ? Column(
                                                    children: [
                                                      const Padding(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeDefault,
                                                        ),
                                                        child: CategoryView(),
                                                      ),

                                                      const Padding(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeDefault,
                                                        ),
                                                        child:
                                                            HighlightProviderWidget(),
                                                      ),

                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeLarge,
                                                      ),
                                                      HorizontalScrollServiceView(
                                                        fromPage:
                                                            'popular_services',
                                                        serviceList:
                                                            serviceController
                                                                .popularServiceList,
                                                      ),

                                                      const RandomCampaignView(),

                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeLarge,
                                                      ),
                                                      RecommendedServiceView(
                                                        height: isLtr
                                                            ? 210
                                                            : 225,
                                                      ),

                                                      SizedBox(
                                                        height:
                                                            (providerBooking ==
                                                                    1 &&
                                                                (isAvailableProvider ||
                                                                    providerController
                                                                            .providerList ==
                                                                        null))
                                                            ? Dimensions
                                                                  .paddingSizeLarge
                                                            : 0,
                                                      ),

                                                      (providerBooking == 1 &&
                                                              (isAvailableProvider ||
                                                                  providerController
                                                                          .providerList ==
                                                                      null))
                                                          ? NearbyProviderListview(
                                                              height: isLtr
                                                                  ? 190
                                                                  : 205,
                                                            )
                                                          : const SizedBox(),

                                                      (providerBooking == 1 &&
                                                              (isAvailableProvider ||
                                                                  providerController
                                                                          .providerList ==
                                                                      null))
                                                          ? Padding(
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeDefault,
                                                                vertical: Dimensions
                                                                    .paddingSizeLarge,
                                                              ),
                                                              child: SizedBox(
                                                                height: 160,
                                                                child: ExploreProviderCard(
                                                                  showShimmer:
                                                                      providerController
                                                                          .providerList ==
                                                                      null,
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox(),

                                                      if (Get.find<
                                                                ServiceSplashController
                                                              >()
                                                              .configModel
                                                              .content
                                                              ?.directProviderBooking ==
                                                          1)
                                                        const HomeRecommendProvider(
                                                          height: 220,
                                                        ),

                                                      if (Get.find<
                                                                ServiceSplashController
                                                              >()
                                                              .configModel
                                                              .content
                                                              ?.biddingStatus ==
                                                          1)
                                                        (serviceController
                                                                        .allService !=
                                                                    null &&
                                                                serviceController
                                                                    .allService!
                                                                    .isNotEmpty)
                                                            ? const Padding(
                                                                padding: EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      Dimensions
                                                                          .paddingSizeDefault,
                                                                  vertical:
                                                                      Dimensions
                                                                          .paddingSizeLarge,
                                                                ),
                                                                child:
                                                                    HomeCreatePostView(
                                                                      showShimmer:
                                                                          false,
                                                                    ),
                                                              )
                                                            : const SizedBox(),

                                                      if (Get.find<
                                                            ServiceAuthController
                                                          >()
                                                          .isLoggedIn())
                                                        HorizontalScrollServiceView(
                                                          fromPage:
                                                              'recently_view_services',
                                                          serviceList:
                                                              serviceController
                                                                  .recentlyViewServiceList,
                                                        ),
                                                      const CampaignView(),
                                                      HorizontalScrollServiceView(
                                                        fromPage:
                                                            'trending_services',
                                                        serviceList:
                                                            serviceController
                                                                .trendingServiceList,
                                                      ),

                                                      const FeatheredCategoryView(),

                                                      (serviceController
                                                                      .allService !=
                                                                  null &&
                                                              serviceController
                                                                  .allService!
                                                                  .isNotEmpty)
                                                          ? (ResponsiveHelper.isMobile(
                                                                      context,
                                                                    ) ||
                                                                    ResponsiveHelper.isTab(
                                                                      context,
                                                                    ))
                                                                ? Padding(
                                                                    padding: const EdgeInsets.fromLTRB(
                                                                      Dimensions
                                                                          .paddingSizeDefault,
                                                                      15,
                                                                      Dimensions
                                                                          .paddingSizeDefault,
                                                                      Dimensions
                                                                          .paddingSizeSmall,
                                                                    ),
                                                                    child: TitleWidget(
                                                                      textDecoration:
                                                                          TextDecoration
                                                                              .underline,
                                                                      title:
                                                                          'all_service'
                                                                              .tr,
                                                                      onTap: () =>
                                                                          Get.toNamed(
                                                                            ServiceRouteHelper.getSearchResultRoute(),
                                                                          ),
                                                                    ),
                                                                  )
                                                                : const SizedBox.shrink()
                                                          : const SizedBox.shrink(),

                                                      PaginatedListView(
                                                        scrollController:
                                                            scrollController,
                                                        totalSize:
                                                            serviceController
                                                                .serviceContent
                                                                ?.total,
                                                        offset:
                                                            serviceController
                                                                .serviceContent
                                                                ?.currentPage,
                                                        onPaginate:
                                                            (
                                                              int offset,
                                                            ) async =>
                                                                await serviceController
                                                                    .getAllServiceList(
                                                                      offset,
                                                                      false,
                                                                    ),
                                                        showBottomSheet: true,
                                                        itemView: ServiceViewVertical(
                                                          service:
                                                              serviceController
                                                                      .serviceContent !=
                                                                  null
                                                              ? serviceController
                                                                    .allService
                                                              : null,
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal:
                                                                ResponsiveHelper.isDesktop(
                                                                  context,
                                                                )
                                                                ? Dimensions
                                                                      .paddingSizeExtraSmall
                                                                : Dimensions
                                                                      .paddingSizeDefault,
                                                            vertical:
                                                                ResponsiveHelper.isDesktop(
                                                                  context,
                                                                )
                                                                ? Dimensions
                                                                      .paddingSizeExtraSmall
                                                                : 0,
                                                          ),
                                                          type: 'others',
                                                          noDataType:
                                                              NoDataType.home,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox(
                                                    height:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.height *
                                                        .6,
                                                    child:
                                                        const ServiceNotAvailableScreen(),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
