import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/helper/extension_helper.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class AllCategoryScreen extends StatelessWidget {
  const AllCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final double containerSize = isDesktop ? 80 : 65;
    final double imageSize = isDesktop ? 50 : 40;
    final double itemWidth = isDesktop ? 80 : 65;
    final double? pageSizeWidth = ResponsiveHelper.isDesktop(context)
        ? Dimensions.webMaxWidth * 0.6
        : null;

    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(title: 'all_categories'.tr),
        body: FooterBaseView(
          child: SizedBox(
            width: pageSizeWidth,
            child: GetBuilder<ServiceCategoryController>(
              builder: (categoryController) {
                return Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isMobile(context)
                          ? 3
                          : 4,
                      crossAxisSpacing: Dimensions.paddingSizeSmall,
                      mainAxisSpacing: Dimensions.paddingSizeSmall,
                      childAspectRatio: MediaQuery.of(context).size.width < 400
                          ? 0.85
                          : 0.95,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryController.categoryList?.length ?? 0,
                    itemBuilder: (context, index) {
                      return TextHover(
                        builder: (hovered) {
                          return InkWell(
                            onTap: () => Get.toNamed(
                              ServiceRouteHelper.getCategoryProductRoute(
                                categoryController.categoryList![index].slug!,
                                categoryController.categoryList?[index].name ??
                                    '',
                                index.toString(),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withValues(alpha: 0.05),
                                    offset: const Offset(0, 2),
                                    blurRadius: 10,
                                  ),
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withValues(alpha: 0.04),
                                    // offset: const Offset(0, 2),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: containerSize,
                                      width: containerSize,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                        ),
                                        color: context
                                            .customThemeColors
                                            .searchBarBorder,
                                      ),
                                      child: Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                          child: CustomImage(
                                            width: imageSize,
                                            height: imageSize,
                                            image:
                                                categoryController
                                                    .categoryList?[index]
                                                    .imageFullPath ??
                                                "",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: Dimensions.paddingSizeSmall,
                                    ),

                                    SizedBox(
                                      width: itemWidth,
                                      child: Text(
                                        categoryController
                                                .categoryList?[index]
                                                .name ??
                                            '',
                                        style: robotoRegular.copyWith(
                                          fontSize: isDesktop
                                              ? Dimensions.fontSizeDefault
                                              : Dimensions.fontSizeSmall,
                                          color: hovered
                                              ? Get.isDarkMode
                                                    ? Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color
                                                    : Theme.of(
                                                        context,
                                                      ).colorScheme.primary
                                              : Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.color,
                                        ),
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
