import 'package:demandium/common/widgets/custom_tooltip_widget.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class ChooseServiceLocationWidget extends StatelessWidget {
  final ProviderData? provider;
  const ChooseServiceLocationWidget({super.key, this.provider});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceLocationController>(
      builder: (locationController) {
        return GetBuilder<ScheduleController>(
          builder: (scheduleController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                provider != null &&
                        scheduleController.selectedServiceType ==
                            ServiceType.repeat &&
                        locationController.selectedServiceLocationType ==
                            ServiceLocationType.provider
                    ? Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSeven,
                          ),
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.1),
                        ),
                        margin: const EdgeInsets.only(
                          top: Dimensions.paddingSizeDefault,
                          bottom: Dimensions.paddingSizeDefault,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeDefault,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            Text('note'.tr, style: robotoBold),
                            Text(
                              "provider_unavailable_hint_text".tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(height: Dimensions.paddingSizeDefault),

                provider != null &&
                        scheduleController.selectedServiceType ==
                            ServiceType.repeat &&
                        locationController.selectedServiceLocationType ==
                            ServiceLocationType.provider
                    ? Container(
                        height: 2,
                        width: double.infinity,
                        color: Theme.of(
                          context,
                        ).disabledColor.withValues(alpha: 0.2),
                        margin: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeDefault,
                        ),
                      )
                    : const SizedBox(),

                Row(
                  children: [
                    Text("getting_service_at".tr, style: robotoMedium),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    CustomToolTip(
                      message: "service_location_hint".tr,
                      preferredDirection: AxisDirection.down,
                      child: Icon(
                        Icons.help_outline_outlined,
                        color: Get.isDarkMode
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSeven),
                    border: Border.all(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                    color: Theme.of(context).cardColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: kIsWeb ? Dimensions.paddingSizeDefault : 0,
                    vertical: kIsWeb ? Dimensions.paddingSizeEight : 2,
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  child: RadioGroup<ServiceLocationType>(
                    groupValue: locationController.selectedServiceLocationType,
                    onChanged: (value) {
                      if (value != null) {
                        locationController.updateSelectedServiceLocationType(
                          type: value,
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              locationController
                                  .updateSelectedServiceLocationType(
                                    type: ServiceLocationType.customer,
                                  );
                            },
                            child: Row(
                              children: [
                                Radio<ServiceLocationType>(
                                  value: ServiceLocationType.customer,
                                  activeColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),

                                Text("my_location".tr),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          child: InkWell(
                            onTap: () {
                              locationController
                                  .updateSelectedServiceLocationType(
                                    type: ServiceLocationType.provider,
                                  );
                            },
                            child: Row(
                              children: [
                                Radio<ServiceLocationType>(
                                  value: ServiceLocationType.provider,
                                  activeColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),

                                Text("provider_location".tr),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
