import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class ProviderLocationInfo extends StatelessWidget {
  final ProviderData? provider;
  const ProviderLocationInfo({super.key, this.provider});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceLocationController>(
      initState: (state) async {
        await Get.find<ServiceLocationController>().getAddressList();
      },
      builder: (locationController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider != null ? 'provider_location'.tr : "service_location".tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            provider == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Dimensions.paddingSizeDefault,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSeven,
                          ),
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeDefault,
                        ),
                        child: Text(
                          'you_have_go_to_provider_location_hint'.tr,
                          style: robotoSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSeven,
                          ),
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeDefault,
                        ),
                        child: RichText(
                          text: TextSpan(
                            text: "the".tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: " ${'service_location'.tr} ",
                                style: robotoSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                              TextSpan(
                                text:
                                    " ${'will_be_available_after_a_provider_accepts_hint'.tr} ",
                                style: robotoRegular,
                              ),

                              TextSpan(
                                text: " ${'booking_details'.tr.capitalize} ",
                                style: robotoSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeDefault,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSeven,
                      ),
                      color: Theme.of(
                        context,
                      ).hintColor.withValues(alpha: 0.05),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              spacing: 10,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        spacing: Dimensions.paddingSizeEight,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            provider?.companyName ?? "",
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                            ),
                                          ),

                                          Text(
                                            provider?.companyPhone ?? "",
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color!
                                                  .withValues(alpha: .6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showGeneralDialog(
                                          context: Get.context!,
                                          pageBuilder: (_, a1, a2) {
                                            return SizedBox(
                                              height: 300,
                                              width: 300,
                                              child: _ProviderMapWidget(
                                                provider: provider,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusSeven,
                                          ),
                                          color: Theme.of(context).cardColor,
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            width: 0.5,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeSmall,
                                          vertical:
                                              Dimensions.paddingSizeExtraSmall,
                                        ),

                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_sharp,
                                              size: 15,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              "map_view".tr,
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_sharp,
                                      size: 15,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        provider?.companyAddress ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
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

            provider != null
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSeven,
                      ),
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    margin: const EdgeInsets.only(
                      top: Dimensions.paddingSizeDefault,
                      bottom: Dimensions.paddingSizeExtraSmall,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeDefault,
                    ),
                    child: Text(
                      "you_have_to_go_to_provider_location_in_order_to_receive_this_service"
                          .tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        );
      },
    );
  }
}

class _ProviderMapWidget extends StatefulWidget {
  final ProviderData? provider;
  const _ProviderMapWidget({required this.provider});

  @override
  State<_ProviderMapWidget> createState() => _ProviderMapWidgetState();
}

class _ProviderMapWidgetState extends State<_ProviderMapWidget> {
  late LatLng _initialPosition;
  late Marker marker;

  @override
  void initState() {
    super.initState();
    _initialPosition = LatLng(
      widget.provider?.coordinates?.latitude ?? 23.0,
      widget.provider?.coordinates?.longitude ?? 90.0,
    );
    marker = Marker(
      markerId: const MarkerId("provider location"),
      position: LatLng(_initialPosition.latitude, _initialPosition.longitude),
      infoWindow: InfoWindow(
        title: widget.provider?.companyName,
        snippet: widget.provider?.companyAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: ResponsiveHelper.isDesktop(context)
            ? 600
            : Dimensions.webMaxWidth,
        decoration: context.width > 700
            ? BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              )
            : null,

        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeSmall,
                horizontal: Dimensions.paddingSizeLarge,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                  SizedBox(
                    height: 250,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _initialPosition,
                              zoom: 16,
                            ),
                            minMaxZoomPreference: const MinMaxZoomPreference(
                              0,
                              16,
                            ),
                            myLocationButtonEnabled: false,
                            onMapCreated:
                                (GoogleMapController mapController) {},
                            scrollGesturesEnabled: !Get.isDialogOpen!,
                            zoomControlsEnabled: true,
                            markers: {marker},
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  CustomButton(
                    radius: Dimensions.radiusSmall,
                    buttonText: "ok".tr,
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 50),
                Text('provider_location'.tr),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
