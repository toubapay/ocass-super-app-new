import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class CouponScreen extends StatefulWidget {
  final bool fromCheckout;
  const CouponScreen({super.key, required this.fromCheckout});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen>
    with TickerProviderStateMixin {
  TabController? _couponTabController;

  @override
  initState() {
    _couponTabController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    );
    Get.find<ServiceCouponController>().getCouponList();
    _couponTabController?.addListener(() {
      Get.find<ServiceCouponController>().updateTabBar(
        _couponTabController?.index == 0
            ? CouponTabState.currentCoupon
            : CouponTabState.usedCoupon,
      );
    });

    Get.find<ServiceCouponController>().updateSelectedCouponIndex(
      index: -1,
      shouldUpdate: false,
    );

    super.initState();
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
        appBar: CustomAppBar(title: "voucher".tr, centerTitle: true),
        body: GetBuilder<ServiceCouponController>(
          builder: (ServiceCouponController) {
            List<CouponModel>? activeCouponList =
                ServiceCouponController.activeCouponList;
            List<CouponModel>? expiredCouponList =
                ServiceCouponController.expiredCouponList;
            return FooterBaseView(
              isScrollView: ResponsiveHelper.isWeb() ? true : false,
              isCenter: (activeCouponList == null || activeCouponList.isEmpty),
              child: WebShadowWrap(
                child: Container(
                  child:
                      ((activeCouponList != null && activeCouponList.isEmpty) &&
                          (expiredCouponList != null &&
                              expiredCouponList.isEmpty))
                      ? NoDataScreen(
                          text: "no_coupon_found".tr,
                          type: NoDataType.coupon,
                        )
                      : (activeCouponList != null && expiredCouponList != null)
                      ? Column(
                          children: [
                            if (activeCouponList.isNotEmpty ||
                                expiredCouponList.isNotEmpty)
                              Stack(
                                children: [
                                  Container(
                                    width: Get.width,
                                    height: 91,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      image: DecorationImage(
                                        image: AssetImage(Images.offerBanner),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 91,
                                    color: Colors.black54,
                                    width: Get.width,
                                  ),
                                ],
                              ),

                            TabBar(
                              controller: _couponTabController,
                              indicatorColor: Theme.of(context).primaryColor,
                              indicatorWeight: 3,
                              indicator: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Get.isDarkMode
                                        ? Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color!
                                              .withValues(alpha: .5)
                                        : Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              labelColor: Get.isDarkMode
                                  ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withValues(alpha: .8)
                                  : Theme.of(context).primaryColor,
                              unselectedLabelColor: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withValues(alpha: .5),
                              unselectedLabelStyle: robotoMedium.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: Dimensions.fontSizeLarge,
                              ),

                              labelStyle: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context).primaryColor,
                              ),
                              tabs: [
                                Padding(
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault,
                                  ),
                                  child: Text(
                                    'current_voucher'.tr,
                                    style: robotoMedium,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault,
                                  ),
                                  child: Text(
                                    'used_voucher'.tr,
                                    style: robotoMedium,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 1,
                              color: Theme.of(context).hintColor,
                            ),
                            if (!ResponsiveHelper.isWeb())
                              Expanded(
                                child: TabBarView(
                                  controller: _couponTabController,
                                  children: [
                                    _couponList(context, activeCouponList),
                                    _couponList(
                                      context,
                                      expiredCouponList,
                                      isExpired: true,
                                    ),
                                  ],
                                ),
                              ),
                            if (ResponsiveHelper.isWeb())
                              _couponTabController?.index == 0
                                  ? _couponList(context, activeCouponList)
                                  : _couponList(
                                      context,
                                      expiredCouponList,
                                      isExpired: true,
                                    ),
                          ],
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _couponList(
    BuildContext context,
    List<CouponModel> couponList, {
    bool isExpired = false,
  }) {
    return couponList.isNotEmpty
        ? GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: Dimensions.paddingSizeLarge,
              mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.paddingSizeLarge
                  : Dimensions.paddingSizeSmall,
              childAspectRatio: ResponsiveHelper.isMobile(context) ? 3.2 : 4,
              crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
              mainAxisExtent: Get.find<ServiceLocalizationController>().isLtr
                  ? 135
                  : 162,
            ),
            itemBuilder: (context, index) {
              return Voucher(
                isExpired: isExpired,
                couponModel: couponList[index],
                index: index,
                fromCheckout: widget.fromCheckout,
              );
            },
            itemCount: couponList.length,
          )
        : SizedBox(
            height: Get.height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Text(
                  isExpired
                      ? 'no_expired_coupon_found'.tr
                      : 'no_active_coupon_found'.tr,
                ),
              ),
            ),
          );
  }
}
