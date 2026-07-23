import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class SubCategoryScreen extends StatefulWidget {
  final String? categoryTitle;
  final String? categorySlug;
  final int? subCategoryIndex;
  const SubCategoryScreen({
    super.key,
    this.categoryTitle,
    this.categorySlug,
    this.subCategoryIndex,
  });

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  @override
  void initState() {
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
        appBar: CustomAppBar(title: widget.categoryTitle),
        body: GetBuilder<ServiceCategoryController>(
          initState: (state) {
            Get.find<ServiceCategoryController>().getSubCategoryList(
              widget.categorySlug ?? "",
              shouldUpdate: false,
            ); //banner id is category here
          },
          builder: (categoryController) {
            return FooterBaseView(
              isCenter:
                  (categoryController.subCategoryList != null &&
                  categoryController.subCategoryList!.isEmpty),
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: CustomScrollView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: ResponsiveHelper.isDesktop(context)
                            ? Dimensions.paddingSizeExtraLarge
                            : 0,
                      ),
                    ),
                    const SubCategoryView(isScrollable: true),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
