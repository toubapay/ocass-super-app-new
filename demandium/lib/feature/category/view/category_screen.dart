import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class CategoryScreen extends StatefulWidget {
  final String? fromPage;
  final String? campaignID;

  const CategoryScreen({super.key, this.fromPage, this.campaignID});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<CategoryModel>? categoryList;

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
        appBar: CustomAppBar(title: 'categories'.tr),
        body: SafeArea(
          child: Scrollbar(
            child: widget.fromPage == 'fromCampaign'
                ? GetBuilder<ServiceCategoryController>(
                    initState: (state) {
                      Get.find<ServiceCategoryController>()
                          .getCampaignBasedCategoryList(
                            widget.campaignID ?? "",
                            false,
                          );
                    },
                    builder: (categoryController) {
                      return _buildBody(
                        categoryController.campaignBasedCategoryList,
                      );
                    },
                  )
                : GetBuilder<ServiceCategoryController>(
                    initState: (state) {
                      Get.find<ServiceCategoryController>().getCategoryList(
                        false,
                      );
                    },
                    builder: (categoryController) {
                      return _buildBody(categoryController.categoryList);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<CategoryModel>? categoryList) {
    if (categoryList != null && categoryList.isEmpty) {
      return FooterBaseView(
        isCenter: true,
        child: NoDataScreen(
          type: NoDataType.categorySubcategory,
          text: 'no_category_found'.tr,
        ),
      );
    } else {
      if (categoryList != null) {
        return FooterBaseView(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isDesktop(context)
                          ? 6
                          : ResponsiveHelper.isTab(context)
                          ? 4
                          : 3,
                      childAspectRatio: (1 / 1),
                      mainAxisSpacing: Dimensions.paddingSizeSmall,
                      crossAxisSpacing: Dimensions.paddingSizeSmall,
                    ),
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    itemCount: categoryList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          if (widget.fromPage == 'fromCampaign') {
                            Get.find<ServiceCategoryController>()
                                .getSubCategoryList(
                                  categoryList[index].slug!,
                                ); //banner id is category here
                            Get.toNamed(
                              ServiceRouteHelper.subCategoryScreenRoute(
                                categoryList[index].name!,
                                categoryList[index].slug!,
                                index,
                              ),
                            );
                          } else {
                            Get.toNamed(
                              ServiceRouteHelper.getCategoryProductRoute(
                                categoryList[index].slug!,
                                categoryList[index].name!,
                                index.toString(),
                              ),
                            );
                          }
                        },

                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                            boxShadow: Get.isDarkMode
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors
                                          .grey[Get.isDarkMode ? 800 : 200]!,
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                child: CustomImage(
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  image: '${categoryList[index].imageFullPath}',
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault,
                                ),
                                child: Text(
                                  categoryList[index].name!,
                                  textAlign: TextAlign.center,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    }
  }
}
