import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class CookiesView extends StatelessWidget {
  const CookiesView({super.key});

  @override
  Widget build(BuildContext context) {
    double padding =
        (MediaQuery.of(context).size.width - Dimensions.webMaxWidth) / 2;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: Get.isDarkMode ? 1 : 0.8),
      ),
      padding: EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
        horizontal: ResponsiveHelper.isDesktop(context)
            ? padding
            : Dimensions.paddingSizeDefault,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isDesktop(context)
              ? 0
              : Dimensions.paddingSizeDefault,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'your_privacy_matters'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Padding(
              padding: const EdgeInsets.only(
                bottom: Dimensions.paddingSizeSmall,
              ),
              child: Text(
                Get.find<ServiceSplashController>()
                        .configModel
                        .content
                        ?.cookiesText ??
                    "",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.justify,
                maxLines: 100,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    Get.find<ServiceSplashController>().saveCookiesData(false);
                    Get.find<ServiceSplashController>().cookiesStatusChange(
                      Get.find<ServiceSplashController>()
                              .configModel
                              .content
                              ?.cookiesText ??
                          "",
                    );
                  },
                  child: Text(
                    'no_thanks'.tr,
                    style: robotoRegular.copyWith(
                      color: Colors.white70,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),

                SizedBox(
                  width: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.paddingSizeExtraLarge
                      : Dimensions.paddingSizeLarge,
                ),

                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(80, 35),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    Get.find<ServiceSplashController>().saveCookiesData(true);
                    Get.find<ServiceSplashController>().cookiesStatusChange(
                      Get.find<ServiceSplashController>()
                              .configModel
                              .content
                              ?.cookiesText ??
                          "",
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: 5,
                    ),
                    child: Center(
                      child: Text(
                        'yes_accept'.tr,
                        style: robotoRegular.copyWith(
                          color: Colors.white70,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
