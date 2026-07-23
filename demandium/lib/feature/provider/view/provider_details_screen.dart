import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/feature/provider/widgets/provider_details_shimmer.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class ProviderDetailsScreen extends StatefulWidget {
  final String providerId;
  const ProviderDetailsScreen({super.key, required this.providerId});

  @override
  ProviderDetailsScreenState createState() => ProviderDetailsScreenState();
}

class ProviderDetailsScreenState extends State<ProviderDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();

    final providerBookingController = Get.find<ProviderBookingController>();

    providerBookingController.updateTabBarPinned(false);

    providerBookingController
        .getProviderDetailsData(widget.providerId, true)
        .then((value) {
          tabController = TabController(
            length:
                Get.find<ProviderBookingController>().categoryItemList.length,
            vsync: this,
          );
          Get.find<ServiceCartController>().updatePreselectedProvider(null);
        });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: const AnimatedCustomAppBar(),
        body: GetBuilder<ProviderBookingController>(
          builder: (providerBookingController) {
            if (providerBookingController.providerDetailsContent != null) {
              if (providerBookingController.providerDetailsContent?.provider ==
                  null) {
                return NoDataScreen(
                  text: 'no_data_found'.tr,
                  type: NoDataType.provider,
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification.metrics.axis == Axis.vertical) {
                    final threshold =
                        (context.width / 3 + 275) - kToolbarHeight;
                    if (scrollNotification.metrics.pixels >= threshold &&
                        !providerBookingController
                            .isTabBarPinnedNotifier
                            .value) {
                      providerBookingController.updateTabBarPinned(true);
                    } else if (scrollNotification.metrics.pixels < threshold &&
                        providerBookingController
                            .isTabBarPinnedNotifier
                            .value) {
                      providerBookingController.updateTabBarPinned(false);
                    }
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (providerBookingController
                              .providerDetailsContent
                              ?.provider
                              ?.serviceAvailability ==
                          0)
                        SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.1),
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeDefault,
                              horizontal: Dimensions.paddingSizeLarge,
                            ),
                            child: Center(
                              child: Text(
                                'provider_is_currently_unavailable'.tr,
                                style: robotoMedium,
                              ),
                            ),
                          ),
                        ),

                      SizedBox(
                        height: Get.height * 0.9,
                        width: Dimensions.webMaxWidth,
                        child: Stack(
                          children: [
                            VerticalScrollableTabView(
                              tabController: tabController,
                              listItemData:
                                  providerBookingController.categoryItemList,
                              verticalScrollPosition:
                                  VerticalScrollPosition.begin,
                              eachItemChild: (object, index) => CategorySection(
                                category: object as CategoryModelItem,
                                providerData: providerBookingController
                                    .providerDetailsContent
                                    ?.provider,
                              ),
                              slivers: [
                                // if(!ResponsiveHelper.isDesktop(context)) SliverToBoxAdapter(child: SizedBox(height: (context.width / 3) * 0.7)),
                                if (!ResponsiveHelper.isDesktop(context))
                                  SliverToBoxAdapter(
                                    child: CustomImage(
                                      image:
                                          providerBookingController
                                              .providerDetailsContent
                                              ?.provider
                                              ?.coverImageFullPath ??
                                          '',
                                      placeholder: Images.placeholder,
                                      width: context.width,
                                      height: context.width / 3,
                                    ),
                                  ),

                                ResponsiveHelper.isDesktop(context)
                                    ? SliverToBoxAdapter(
                                        child: ProviderDetailsTopCard(
                                          providerId: widget.providerId,
                                        ),
                                      )
                                    : const SliverToBoxAdapter(),

                                SliverAppBar(
                                  automaticallyImplyLeading: false,
                                  backgroundColor: Colors.transparent,
                                  pinned: true,
                                  leading: const SizedBox(),
                                  actions: const [SizedBox()],
                                  expandedHeight:
                                      !ResponsiveHelper.isDesktop(context)
                                      ? 270
                                      : 0,
                                  elevation: 0,
                                  flexibleSpace:
                                      !ResponsiveHelper.isDesktop(context)
                                      ? FlexibleSpaceBar(
                                          background: ProviderDetailsTopCard(
                                            providerId: widget.providerId,
                                          ),
                                        )
                                      : SizedBox(),
                                  toolbarHeight: 0,
                                  bottom: PreferredSize(
                                    preferredSize: const Size.fromHeight(45),
                                    child: Container(
                                      height: 45,
                                      width: Dimensions.webMaxWidth,
                                      color: Theme.of(context).cardColor,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.0,
                                          ),
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.4),
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        child: TabBar(
                                          isScrollable: true,
                                          controller: tabController,
                                          indicatorColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          labelColor: Get.isDarkMode
                                              ? Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.color
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          unselectedLabelColor:
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withValues(alpha: 0.7),
                                          unselectedLabelStyle: robotoRegular,
                                          tabs: providerBookingController
                                              .categoryItemList
                                              .map((e) => Tab(text: e.title))
                                              .toList(),
                                          onTap: (index) {
                                            VerticalScrollableTabBarStatus.setIndex(
                                              index,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                if (providerBookingController
                                    .categoryItemList
                                    .isEmpty)
                                  SliverToBoxAdapter(
                                    child: NoDataScreen(
                                      text:
                                          'no_subscribed_subcategories_available',
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (ResponsiveHelper.isDesktop(context))
                        const FooterView(),
                    ],
                  ),
                ),
              );
            } else {
              return const FooterBaseView(child: ProviderDetailsShimmer());
            }
          },
        ),
      ),
    );
  }
}

class AnimatedCustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final double height;

  const AnimatedCustomAppBar({super.key, this.height = kToolbarHeight});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProviderBookingController>();

    return ValueListenableBuilder<bool>(
      valueListenable: controller.isTabBarPinnedNotifier,
      builder: (context, isPinned, child) {
        return CustomAppBar(
          title: isPinned
              ? controller.providerDetailsContent?.provider?.companyName ??
                    "provider_details".tr
              : "provider_details".tr,
          showCart: true,
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
