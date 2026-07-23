import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class AddressLabelWidget extends StatelessWidget {
  const AddressLabelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceLocationController>(
      builder: (locationController) {
        return SizedBox(
          width: ResponsiveHelper.isMobile(context)
              ? null
              : ResponsiveHelper.isWeb()
              ? Get.width / 2
              : 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'label_as'.tr,
                style: robotoSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: AddressLabel.values
                    .map(
                      (label) => InkWell(
                        hoverColor: Colors.transparent,
                        onTap: () {
                          locationController.updateAddressLabel(
                            addressLabel: label,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.isDesktop(context)
                                ? Dimensions.paddingSizeExtraMoreLarge * 1.2
                                : Dimensions.paddingSizeExtraLarge,
                            vertical: Dimensions.paddingSizeEight,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  label ==
                                      locationController.selectedAddressLabel
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).cardColor,
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                            color:
                                label == locationController.selectedAddressLabel
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).cardColor,
                            boxShadow:
                                Get.find<ServiceThemeController>().darkTheme
                                ? null
                                : cardShadow,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                label.index == 0
                                    ? Icons.home_filled
                                    : label.index == 1
                                    ? Icons.work
                                    : Icons.widgets,
                                color:
                                    label ==
                                        locationController.selectedAddressLabel
                                    ? Theme.of(context).cardColor
                                    : Theme.of(context).disabledColor,
                                size: Dimensions.paddingSizeDefault,
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall,
                              ),
                              Text(
                                label.name.tr,
                                style: robotoRegular.copyWith(
                                  color:
                                      label ==
                                          locationController
                                              .selectedAddressLabel
                                      ? Theme.of(context).cardColor
                                      : Theme.of(context).disabledColor,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
