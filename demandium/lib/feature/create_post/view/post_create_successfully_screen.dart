import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class PostCreateSuccessfullyScreen extends StatelessWidget {
  const PostCreateSuccessfullyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        appBar: CustomAppBar(title: 'create_post'.tr),
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        body: FooterBaseView(
          isCenter: true,
          child: WebShadowWrap(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  child: Image.asset(
                    Images.rightMark,
                    height: 70,
                    width: 70,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Text(
                  "your_post_has_been_created_successfully".tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(
                  "stay_tuned_for_responses".tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeExtraLarge,
                    bottom: Dimensions.paddingSizeSmall,
                  ),
                  child: CustomButton(
                    buttonText: "view_post".tr,
                    height: ResponsiveHelper.isDesktop(context) ? 45 : 35,
                    width: ResponsiveHelper.isDesktop(context) ? 150 : 130,
                    radius: Dimensions.radiusExtraMoreLarge,
                    onPressed: () {
                      Get.offNamed(ServiceRouteHelper.getMyPostScreen());
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.offAllNamed(ServiceRouteHelper.getMainRoute(''));
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'go_back_to_home'.tr,
                    style: robotoRegular.copyWith(
                      color: Get.isDarkMode
                          ? Theme.of(context).primaryColorLight
                          : Theme.of(context).colorScheme.primary,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
