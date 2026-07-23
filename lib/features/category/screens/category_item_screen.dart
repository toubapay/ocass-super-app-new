import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_view2.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/cart_widget.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/veg_filter_widget.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/images.dart';
import '../../cart/controllers/cart_controller.dart';

class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryItemScreen(
      {super.key, required this.categoryID, required this.categoryName});

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen>
    with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final ScrollController storeScrollController = ScrollController();
  TabController? _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    log("this screen");
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    Get.find<CategoryController>().getSubCategoryList(widget.categoryID);

    Get.find<CategoryController>().getCategoryStoreList(
      widget.categoryID,
      1,
      Get.find<CategoryController>().type,
      false,
    );

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent &&
          Get.find<CategoryController>().categoryItemList != null &&
          !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryItemList(
            Get.find<CategoryController>().subCategoryIndex == 0
                ? widget.categoryID
                : Get.find<CategoryController>()
                .subCategoryList![
            Get.find<CategoryController>().subCategoryIndex]
                .id
                .toString(),
            Get.find<CategoryController>().offset + 1,
            Get.find<CategoryController>().type,
            false,
          );
        }
      }
    });
    storeScrollController.addListener(() {
      if (storeScrollController.position.pixels ==
          storeScrollController.position.maxScrollExtent &&
          Get.find<CategoryController>().categoryStoreList != null &&
          !Get.find<CategoryController>().isLoading) {
        int pageSize =
        (Get.find<CategoryController>().restPageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryStoreList(
            Get.find<CategoryController>().subCategoryIndex == 0
                ? widget.categoryID
                : Get.find<CategoryController>()
                .subCategoryList![
            Get.find<CategoryController>().subCategoryIndex]
                .id
                .toString(),
            Get.find<CategoryController>().offset + 1,
            Get.find<CategoryController>().type,
            false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (catController) {
      List<Item>? item;
      List<Store>? stores;
      if (catController.isSearching
          ? catController.searchItemList != null
          : catController.categoryItemList != null) {
        item = [];
        if (catController.isSearching) {
          item.addAll(catController.searchItemList!);
        } else {
          item.addAll(catController.categoryItemList!);
        }
      }
      if (catController.isSearching
          ? catController.searchStoreList != null
          : catController.categoryStoreList != null) {
        stores = [];
        if (catController.isSearching) {
          stores.addAll(catController.searchStoreList!);
        } else {
          stores.addAll(catController.categoryStoreList!);
        }
      }

      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (catController.isSearching) {
            catController.toggleSearch();
          } else {
            return;
          }
        },
        child: Scaffold(
          appBar: (ResponsiveHelper.isDesktop(context)
              ? const WebMenuBar()
              : AppBar(
            backgroundColor: Theme.of(context).cardColor,
            surfaceTintColor: Theme.of(context).cardColor,
            shadowColor: Theme.of(context).disabledColor.withOpacity(0.5),
            elevation: 2,
            title: catController.isSearching
                ? SizedBox(
              height: 45,
              child: TextField(
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'search'.tr,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault),
                      borderSide: BorderSide(
                          color: Theme.of(context).disabledColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault),
                      borderSide: BorderSide(
                          color: Theme.of(context).disabledColor),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => catController.toggleSearch(),
                      icon: Icon(
                        catController.isSearching
                            ? Icons.close_sharp
                            : Icons.search,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
                  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge),
                  onSubmitted: (String query) {
                    catController.searchData(
                      query,
                      catController.subCategoryIndex == 0
                          ? widget.categoryID
                          : catController
                          .subCategoryList![
                      catController.subCategoryIndex]
                          .id
                          .toString(),
                      catController.type,
                    );
                  }),
            )
                : Text(widget.categoryName,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                )),
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () {
                if (catController.isSearching) {
                  catController.toggleSearch();
                } else {
                  Get.back();
                }
              },
            ),
            actions: [
              !catController.isSearching
                  ? IconButton(
                onPressed: () => catController.toggleSearch(),
                icon: Icon(
                  catController.isSearching
                      ? Icons.close_sharp
                      : Icons.search,
                  color:
                  Theme.of(context).textTheme.bodyLarge!.color,
                ),
              )
                  : const SizedBox(),
              // IconButton(
              //   onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
              //   icon: CartWidget(
              //       color: Theme.of(context).textTheme.bodyLarge!.color,
              //       size: 25),
              // ),
              Container(
                child: Stack(children: [
                  IconButton(icon: Icon(Icons.shopping_cart, color: Theme.of(context).primaryColor), onPressed: () {
                    Navigator.pushNamed(context, RouteHelper.getCartRoute());
                  }),
                  Positioned(
                    top: 5, right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                      child: GetBuilder<CartController>(builder: (cartController) {
                        return Text(
                          cartController.cartList.length.toString(),
                          style: robotoMedium.copyWith(color: Colors.white, fontSize: 8),
                        );
                      }),
                    ),
                  ),

                ]),
              ),
              VegFilterWidget(
                  type: catController.type,
                  fromAppBar: true,
                  onSelected: (String type) {
                    if (catController.isSearching) {
                      catController.searchData(
                        catController.subCategoryIndex == 0
                            ? widget.categoryID
                            : catController
                            .subCategoryList![
                        catController.subCategoryIndex]
                            .id
                            .toString(),
                        '1',
                        type,
                      );
                    } else {
                      if (catController.isStore) {
                        catController.getCategoryStoreList(
                          catController.subCategoryIndex == 0
                              ? widget.categoryID
                              : catController
                              .subCategoryList![
                          catController.subCategoryIndex]
                              .id
                              .toString(),
                          1,
                          type,
                          true,
                        );
                      } else {
                        catController.getCategoryItemList(
                          catController.subCategoryIndex == 0
                              ? widget.categoryID
                              : catController
                              .subCategoryList![
                          catController.subCategoryIndex]
                              .id
                              .toString(),
                          1,
                          type,
                          true,
                        );
                      }
                    }
                  }),
              const SizedBox(width: Dimensions.paddingSizeSmall),
            ],
          )),
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: ResponsiveHelper.isDesktop(context)
              ? SingleChildScrollView(
            child: FooterView(
              child: Center(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(children: [
                      (catController.subCategoryList != null &&
                          !catController.isSearching)
                          ? Center(
                          child: Container(
                            height: 40,
                            width: Dimensions.webMaxWidth,
                            color: Theme.of(context).cardColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeExtraSmall),
                            child: ListView.builder(
                              key: scaffoldKey,
                              scrollDirection: Axis.horizontal,
                              itemCount:
                              catController.subCategoryList!.length,
                              padding: const EdgeInsets.only(
                                  left: Dimensions.paddingSizeSmall),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () =>
                                      catController.setSubCategoryIndex(
                                          index, widget.categoryID),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                        Dimensions.paddingSizeSmall,
                                        vertical: Dimensions
                                            .paddingSizeExtraSmall),
                                    margin: const EdgeInsets.only(
                                        right: Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall),
                                      color: index ==
                                          catController.subCategoryIndex
                                          ? Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1)
                                          : Colors.transparent,
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            catController
                                                .subCategoryList![index]
                                                .name!,
                                            style: index ==
                                                catController
                                                    .subCategoryIndex
                                                ? robotoMedium.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeSmall,
                                                color: Theme.of(context)
                                                    .primaryColor)
                                                : robotoRegular.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeSmall),
                                          ),
                                        ]),
                                  ),
                                );
                              },
                            ),
                          ))
                          : const SizedBox(),
                      Center(
                        child: Container(
                          width: Dimensions.webMaxWidth,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: Theme.of(context).primaryColor, // selected tab background
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelColor: Colors.white, // selected text color
                            unselectedLabelColor: Theme.of(context).disabledColor,
                            unselectedLabelStyle: robotoRegular.copyWith(
                              color: Theme.of(context).disabledColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                            labelStyle: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Colors.white,
                            ),
                            tabs: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200, // unselected background color
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Tab(text: 'item'.tr),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200, // unselected background color
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Tab(
                                  text: Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig!
                                      .module!
                                      .showRestaurantText!
                                      ? 'restaurants'.tr
                                      : 'stores'.tr,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 600,
                        child: NotificationListener(
                          onNotification: (dynamic scrollNotification) {
                            if (scrollNotification is ScrollEndNotification) {
                              if ((_tabController!.index == 1 &&
                                  !catController.isStore) ||
                                  _tabController!.index == 0 &&
                                      catController.isStore) {
                                catController.setRestaurant(
                                    _tabController!.index == 1);
                                if (catController.isSearching) {
                                  catController.searchData(
                                    catController.searchText,
                                    catController.subCategoryIndex == 0
                                        ? widget.categoryID
                                        : catController
                                        .subCategoryList![catController
                                        .subCategoryIndex]
                                        .id
                                        .toString(),
                                    catController.type,
                                  );
                                } else {
                                  if (_tabController!.index == 1) {
                                    catController.getCategoryStoreList(
                                      catController.subCategoryIndex == 0
                                          ? widget.categoryID
                                          : catController
                                          .subCategoryList![catController
                                          .subCategoryIndex]
                                          .id
                                          .toString(),
                                      1,
                                      catController.type,
                                      false,
                                    );
                                  } else {
                                    catController.getCategoryItemList(
                                      catController.subCategoryIndex == 0
                                          ? widget.categoryID
                                          : catController
                                          .subCategoryList![catController
                                          .subCategoryIndex]
                                          .id
                                          .toString(),
                                      1,
                                      catController.type,
                                      false,
                                    );
                                  }
                                }
                              }
                            }
                            return false;
                          },
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              SingleChildScrollView(
                                controller: scrollController,
                                child: ItemsView2(
                                  isStore: false,
                                  items: item,
                                  stores: null,
                                  noDataText: 'no_category_item_found'.tr,
                                ),
                              ),
                              SingleChildScrollView(
                                controller: storeScrollController,
                                child: ItemsView2(
                                  isStore: true,
                                  items: null,
                                  stores: stores,
                                  noDataText: Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig!
                                      .module!
                                      .showRestaurantText!
                                      ? 'no_category_restaurant_found'.tr
                                      : 'no_category_store_found'.tr,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      catController.isLoading
                          ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor)),
                          ))
                          : const SizedBox(),
                    ]),
                  )),
            ),
          )
              : SizedBox(
            width: Dimensions.webMaxWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (catController.subCategoryList != null &&
                    !catController.isSearching)
                    ? Container(
                  width: 80,
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.3))),
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeExtraSmall),
                  child: ListView.builder(
                    key: scaffoldKey,
                    scrollDirection: Axis.vertical,
                    itemCount:
                    catController.subCategoryList!.length,
                    padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeSmall),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      // print( "Image count :" "https://app.neartap.in/storage/app/public/category/${catController.subCategoryList![index].image}");
                      return InkWell(
                        onTap: () =>
                            catController.setSubCategoryIndex(
                                index, widget.categoryID),
                        child: SizedBox(
                          height: 100,
                          child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 60, width: 60,
                                  padding: const EdgeInsets
                                      .symmetric(
                                      horizontal: Dimensions
                                          .paddingSizeSmall,
                                      vertical: Dimensions
                                          .paddingSizeExtraSmall),
// margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(100),
                                    color: index ==
                                        catController
                                            .subCategoryIndex
                                        ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1)
                                        : Colors.transparent,
                                  ),
                                  child: catController
                                      .subCategoryList![
                                  index]
                                      .name! ==
                                      'All'
                                      ? Icon(
                                    Icons.grid_view,
                                    size: 30,
                                    color: index ==
                                        catController
                                            .subCategoryIndex
                                        ? Theme.of(context)
                                        .primaryColor
                                        : Theme.of(context)
                                        .disabledColor,
                                  )
                                      :
                                  Image.network(
                                    "${catController.subCategoryList![index].imageFullUrl}",
                                    height: 30,
                                    width: 30,
                                    // color: index ==
                                    //         catController
                                    //             .subCategoryIndex
                                    //     ? Theme.of(context)
                                    //         .primaryColor
                                    //     : Theme.of(context)
                                    //         .disabledColor,
                                    errorBuilder: (context,
                                        error, stackTrace) {
                                      print(
                                          "Image failed to load: ${catController.subCategoryList![index].imageFullUrl}");
                                      return Image.asset(
                                        Images.logo,
                                        height: 30,
                                        width: 30,
                                        // color: index ==
                                        //     catController
                                        //         .subCategoryIndex
                                        //     ? Theme.of(
                                        //     context)
                                        //     .primaryColor
                                        //     : Theme.of(
                                        //     context)
                                        //     .disabledColor,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                    height: Dimensions
                                        .paddingSizeExtraSmall),
                                Center(
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    catController
                                        .subCategoryList![index]
                                        .name!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: index ==
                                        catController
                                            .subCategoryIndex
                                        ? robotoMedium.copyWith(
                                        fontSize: Dimensions
                                            .fontSizeSmall,
                                        color: Theme.of(context)
                                            .primaryColor)
                                        : robotoRegular.copyWith(
                                        fontSize: Dimensions
                                            .fontSizeSmall),
                                  ),
                                ),
                              ]),
                        ),
                      );
                    },
                  ),
                )
                    : const SizedBox(),
                Expanded(
                  child: Column(children: [
// (catController.subCategoryList != null && !catController.isSearching) ? Center(child: Container(
// height: 40, width: Dimensions.webMaxWidth, color: Theme.of(context).cardColor,
// padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
// child: ListView.builder(
// key: scaffoldKey,
// scrollDirection: Axis.horizontal,
// itemCount: catController.subCategoryList!.length,
// padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
// physics: const BouncingScrollPhysics(),
// itemBuilder: (context, index) {
// return InkWell(
// onTap: () => catController.setSubCategoryIndex(index, widget.categoryID),
// child: Container(
// padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
// margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
// color: index == catController.subCategoryIndex ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
// ),
// child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
// Text(
// catController.subCategoryList![index].name!,
// style: index == catController.subCategoryIndex
// ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
// : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
// ),
// ]),
// ),
// );
// },
// ),
// )) : const SizedBox(),

                    Center(
                      child: Container(
                        width: Dimensions.webMaxWidth,
                        color: Theme.of(context).cardColor,
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: Theme.of(context).primaryColor,
                          indicatorWeight: 3,
                          labelColor: Theme.of(context).primaryColor, // selected tab text
                          unselectedLabelColor: Colors.black, // unselected tab text (white)
                          unselectedLabelStyle: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                          labelStyle: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                          tabs: [
                            Tab(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _tabController?.index == 0
                                      ? Theme.of(context).cardColor // selected
                                      : Theme.of(context).primaryColor.withOpacity(0.1), // unselected
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('item'.tr),
                              ),
                            ),
                            Tab(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _tabController?.index == 1
                                      ? Theme.of(context).cardColor
                                      : Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig!
                                      .module!
                                      .showRestaurantText!
                                      ? 'restaurants'.tr
                                      : 'stores'.tr,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    ,


                    Expanded(
                        child: NotificationListener(
                          onNotification: (dynamic scrollNotification) {
                            if (scrollNotification is ScrollEndNotification) {
                              if ((_tabController!.index == 1 &&
                                  !catController.isStore) ||
                                  _tabController!.index == 0 &&
                                      catController.isStore) {
                                catController.setRestaurant(
                                    _tabController!.index == 1);
                                if (catController.isSearching) {
                                  catController.searchData(
                                    catController.searchText,
                                    catController.subCategoryIndex == 0
                                        ? widget.categoryID
                                        : catController
                                        .subCategoryList![catController
                                        .subCategoryIndex]
                                        .id
                                        .toString(),
                                    catController.type,
                                  );
                                } else {
                                  if (_tabController!.index == 1) {
                                    catController.getCategoryStoreList(
                                      catController.subCategoryIndex == 0
                                          ? widget.categoryID
                                          : catController
                                          .subCategoryList![catController
                                          .subCategoryIndex]
                                          .id
                                          .toString(),
                                      1,
                                      catController.type,
                                      false,
                                    );
                                  } else {
                                    catController.getCategoryItemList(
                                      catController.subCategoryIndex == 0
                                          ? widget.categoryID
                                          : catController
                                          .subCategoryList![catController
                                          .subCategoryIndex]
                                          .id
                                          .toString(),
                                      1,
                                      catController.type,
                                      false,
                                    );
                                  }
                                }
                              }
                            }
                            return false;
                          },
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              SingleChildScrollView(
                                controller: scrollController,
                                child: ItemsView2(
                                  isStore: false,
                                  items: item,
                                  stores: null,
                                  noDataText: 'no_category_item_found'.tr,
                                ),
                              ),
                              SingleChildScrollView(
                                controller: storeScrollController,
                                child: ItemsView2(
                                  isStore: true,
                                  items: null,
                                  stores: stores,
                                  noDataText: Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig!
                                      .module!
                                      .showRestaurantText!
                                      ? 'no_category_restaurant_found'.tr
                                      : 'no_category_store_found'.tr,
                                ),
                              ),
                            ],
                          ),
                        )
                    ),

                    catController.isLoading
                        ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeSmall),
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor)),
                        ))
                        : const SizedBox(),
                  ]),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}