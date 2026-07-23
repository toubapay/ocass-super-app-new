import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class WalletBannerView extends StatelessWidget {
  final BonusModel? bonusModel;
  const WalletBannerView({super.key, this.bonusModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          width: 0.5,
        ),
        color: Theme.of(context).hoverColor,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: Get.find<ServiceLocalizationController>().isLtr ? 0 : null,
            left: Get.find<ServiceLocalizationController>().isLtr ? null : 0,
            child: Image.asset(
              Images.walletBannerBackground,
              width: 50,
              height: 80,
              opacity: const AlwaysStoppedAnimation(.15),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              right: Get.find<ServiceLocalizationController>().isLtr ? 40 : 0,
              left: Get.find<ServiceLocalizationController>().isLtr ? 0 : 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bonusModel?.bonusTitle ?? "",
                  style: robotoBold.copyWith(
                    color: Get.isDarkMode
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context).colorScheme.primary,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Get.find<ServiceLocalizationController>().isLtr
                        ? Dimensions.paddingSizeEight
                        : 0,
                  ),
                  child: Text(
                    "${'valid_till'.tr} ${DateConverter.stringToLocalDateOnly(bonusModel!.endDate!)}",
                    style: robotoMedium.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.color!.withValues(alpha: 0.8),
                    ),
                  ),
                ),

                Text(
                  bonusModel?.shortDescription ?? "",
                  style: robotoRegular.copyWith(
                    color: Get.isDarkMode
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context).colorScheme.primary,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
