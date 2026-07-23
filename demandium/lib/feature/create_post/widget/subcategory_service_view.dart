import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class SubcategoryServiceView extends StatefulWidget {
  final String categorySlug;
  const SubcategoryServiceView({super.key, required this.categorySlug});

  @override
  State<SubcategoryServiceView> createState() => _SubcategoryServiceViewState();
}

class _SubcategoryServiceViewState extends State<SubcategoryServiceView>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    Get.find<ServiceCategoryController>()
        .getSubCategoryList(widget.categorySlug, shouldUpdate: false)
        .then((value) {
          Get.find<ServiceController>().getSubCategoryBasedServiceList(
            Get.find<ServiceCategoryController>().subCategoryList != null &&
                    Get.find<ServiceCategoryController>()
                        .subCategoryList!
                        .isNotEmpty
                ? Get.find<ServiceCategoryController>()
                      .subCategoryList![0]
                      .slug!
                : "",
            showShimmerAlways: true,
          );
          tabController = TabController(
            length:
                Get.find<ServiceCategoryController>().subCategoryList?.length ??
                0,
            vsync: this,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        ),
        insetPadding: const EdgeInsets.all(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: pointerInterceptor(),
      );
    }
    return pointerInterceptor();
  }

  Padding pointerInterceptor() {
    return Padding(
      padding: EdgeInsets.only(
        top: ResponsiveHelper.isWeb() ? 0 : Dimensions.cartDialogPadding,
      ),
      child: PointerInterceptor(
        child: GetBuilder<ServiceCategoryController>(
          builder: (categoryController) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: Get.height / 1.5,
                  width: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.webMaxWidth / 1.5
                      : Dimensions.webMaxWidth,
                  padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeLarge,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radiusExtraLarge),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                height: 5,
                                width: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.fontSizeDefault,
                                  ),
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),

                            (categoryController.subCategoryList != null &&
                                    categoryController
                                        .subCategoryList!
                                        .isNotEmpty)
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeDefault,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      color: Theme.of(context).cardColor,
                                    ),
                                    child: TabBar(
                                      controller: tabController,
                                      unselectedLabelColor: Colors.grey,
                                      isScrollable: true,
                                      indicatorColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                      labelColor: Get.isDarkMode
                                          ? Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      labelStyle: robotoMedium,
                                      tabs: categoryController.subCategoryList!
                                          .map((e) {
                                            return Tab(text: e.name);
                                          })
                                          .toList(),
                                      onTap: (index) async {
                                        Get.find<ServiceController>()
                                            .getSubCategoryBasedServiceList(
                                              categoryController
                                                      .subCategoryList?[index]
                                                      .slug ??
                                                  "",
                                              showShimmerAlways: true,
                                            );
                                      },
                                    ),
                                  )
                                : const SizedBox(),

                            GetBuilder<ServiceController>(
                              builder: (serviceController) {
                                if ((categoryController.subCategoryList !=
                                            null &&
                                        serviceController
                                                .subCategoryBasedServiceList !=
                                            null &&
                                        serviceController
                                            .subCategoryBasedServiceList!
                                            .isEmpty) ||
                                    (categoryController.subCategoryList !=
                                            null &&
                                        categoryController
                                            .subCategoryList!
                                            .isEmpty)) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      top: Get.height * 0.1,
                                    ),
                                    child: NoDataScreen(
                                      text: 'no_services_found'.tr,
                                      type: NoDataType.service,
                                    ),
                                  );
                                } else if (serviceController
                                            .subCategoryBasedServiceList !=
                                        null &&
                                    categoryController.subCategoryList !=
                                        null) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      top: ResponsiveHelper.isDesktop(context)
                                          ? 0
                                          : Dimensions.paddingSizeDefault,
                                      bottom:
                                          Dimensions.paddingSizeExtraMoreLarge,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.only(
                                            bottom: Dimensions
                                                .paddingSizeExtraLarge,
                                          ),
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: serviceController
                                              .subCategoryBasedServiceList!
                                              .length,
                                          itemBuilder: (context, index) {
                                            num lowestPrice = 0.0;
                                            if (serviceController
                                                    .subCategoryBasedServiceList?[index]
                                                    .variationsAppFormat !=
                                                null) {
                                              if (serviceController
                                                      .subCategoryBasedServiceList?[index]
                                                      .variationsAppFormat!
                                                      .zoneWiseVariations !=
                                                  null) {
                                                lowestPrice = serviceController
                                                    .subCategoryBasedServiceList![index]
                                                    .variationsAppFormat!
                                                    .zoneWiseVariations![0]
                                                    .price!;
                                                for (
                                                  var i = 0;
                                                  i <
                                                      serviceController
                                                          .subCategoryBasedServiceList![index]
                                                          .variationsAppFormat!
                                                          .zoneWiseVariations!
                                                          .length;
                                                  i++
                                                ) {
                                                  if (serviceController
                                                          .subCategoryBasedServiceList![index]
                                                          .variationsAppFormat!
                                                          .zoneWiseVariations![i]
                                                          .price! <
                                                      lowestPrice) {
                                                    lowestPrice = serviceController
                                                        .subCategoryBasedServiceList![index]
                                                        .variationsAppFormat!
                                                        .zoneWiseVariations![i]
                                                        .price!;
                                                  }
                                                }
                                              }
                                            }
                                            Discount discountModel =
                                                PriceConverter.discountCalculation(
                                                  serviceController
                                                      .subCategoryBasedServiceList![index],
                                                );
                                            return GestureDetector(
                                              onTap: () {
                                                Get.back();
                                                Get.find<CreatePostController>()
                                                    .updateSelectedService(
                                                      serviceController
                                                          .subCategoryBasedServiceList![index],
                                                    );
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: Dimensions
                                                          .paddingSizeSmall,
                                                      horizontal: Dimensions
                                                          .paddingSizeDefault,
                                                    ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    Dimensions.paddingSizeSmall,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault,
                                                        ),
                                                    boxShadow:
                                                        Get.find<
                                                              ServiceThemeController
                                                            >()
                                                            .darkTheme
                                                        ? [const BoxShadow()]
                                                        : [
                                                            BoxShadow(
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    2,
                                                                  ),
                                                              blurRadius: 5,
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                    alpha: 0.05,
                                                                  ),
                                                            ),
                                                          ],
                                                    color: Theme.of(
                                                      context,
                                                    ).cardColor,
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusSmall,
                                                            ),
                                                        child: CustomImage(
                                                          height: 90,
                                                          width: 90,
                                                          fit: BoxFit.cover,
                                                          image:
                                                              "${serviceController.subCategoryBasedServiceList?[index].thumbnailFullPath}",
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeDefault,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall,
                                                            ),
                                                            Text(
                                                              serviceController
                                                                      .subCategoryBasedServiceList?[index]
                                                                      .name ??
                                                                  "",
                                                              style: robotoMedium
                                                                  .copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeLarge,
                                                                  ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeSmall,
                                                            ),
                                                            Text(
                                                              "starts_from".tr,
                                                              style: robotoRegular.copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeDefault,
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .textTheme
                                                                        .bodyMedium!
                                                                        .color!
                                                                        .withValues(
                                                                          alpha:
                                                                              0.5,
                                                                        ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall,
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                if (discountModel
                                                                        .discountAmount! >
                                                                    0)
                                                                  Directionality(
                                                                    textDirection:
                                                                        TextDirection
                                                                            .ltr,
                                                                    child: Text(
                                                                      PriceConverter.convertPrice(
                                                                        lowestPrice
                                                                            .toDouble(),
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                      style: robotoRegular.copyWith(
                                                                        fontSize:
                                                                            Dimensions.fontSizeLarge,
                                                                        decoration:
                                                                            TextDecoration.lineThrough,
                                                                        color:
                                                                            Theme.of(
                                                                              context,
                                                                            ).colorScheme.error.withValues(
                                                                              alpha: .8,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                discountModel
                                                                            .discountAmount! >
                                                                        0
                                                                    ? Directionality(
                                                                        textDirection:
                                                                            TextDirection.ltr,
                                                                        child: Text(
                                                                          PriceConverter.convertPrice(
                                                                            lowestPrice.toDouble(),
                                                                            discount:
                                                                                discountModel.discountAmount!.toDouble(),
                                                                            discountType:
                                                                                discountModel.discountAmountType,
                                                                          ),
                                                                          style: robotoMedium.copyWith(
                                                                            fontSize:
                                                                                Dimensions.paddingSizeDefault,
                                                                            color:
                                                                                Get.isDarkMode
                                                                                ? Theme.of(
                                                                                    context,
                                                                                  ).primaryColorLight
                                                                                : Theme.of(
                                                                                    context,
                                                                                  ).primaryColor,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Directionality(
                                                                        textDirection:
                                                                            TextDirection.ltr,
                                                                        child: Text(
                                                                          PriceConverter.convertPrice(
                                                                            lowestPrice.toDouble(),
                                                                          ),
                                                                          style: robotoMedium.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeLarge,
                                                                            color:
                                                                                Get.isDarkMode
                                                                                ? Theme.of(
                                                                                    context,
                                                                                  ).primaryColorLight
                                                                                : Theme.of(
                                                                                    context,
                                                                                  ).primaryColor,
                                                                          ),
                                                                        ),
                                                                      ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(
                                          height: Dimensions.paddingSizeLarge,
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisSpacing:
                                              Dimensions.paddingSizeLarge,
                                          mainAxisSpacing:
                                              ResponsiveHelper.isDesktop(
                                                context,
                                              )
                                              ? Dimensions.paddingSizeDefault
                                              : Dimensions.paddingSizeSmall,
                                          crossAxisCount:
                                              ResponsiveHelper.isMobile(context)
                                              ? 1
                                              : 1,
                                          mainAxisExtent:
                                              ResponsiveHelper.isMobile(context)
                                              ? 115
                                              : 120,
                                        ),
                                    itemCount: 6,
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(
                                      bottom: Dimensions.paddingSizeExtraLarge,
                                      top: Dimensions.paddingSizeDefault,
                                    ),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (BuildContext context, index) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeDefault,
                                        ),
                                        child: SubCategoryShimmer(
                                          isEnabled: true,
                                          hasDivider: false,
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (ResponsiveHelper.isDesktop(context))
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: GestureDetector(
                      onTap: () => Get.back(),

                      child: Icon(
                        Icons.close,
                        size: 25,
                        color: Get.isDarkMode
                            ? Theme.of(context).textTheme.bodyMedium?.color
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
