import 'dart:developer';

import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/address_selection_bottom_sheet.dart';

class AddressAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? backButton;
  const AddressAppBar({super.key, this.backButton = true});
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        AppBar(
          backgroundColor: Get.isDarkMode
              ? Theme.of(context).cardColor.withValues(alpha: .2)
              : Theme.of(context).primaryColor,
          shape: Border(
            bottom: BorderSide(
              width: .4,
              color: Theme.of(context).primaryColorLight.withValues(alpha: .2),
            ),
          ),
          elevation: 0,
          leadingWidth: 30,
          leading: SizedBox(),
          title: Row(
            children: [
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    useRootNavigator: true,
                    routeSettings: RouteSettings(name: '/'),
                    builder: (context) => const AddressSelectionBottomSheet(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'services_in'.tr,
                        style: robotoRegular.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeTine),
                      GetBuilder<ServiceLocationController>(
                        builder: (locationController) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (locationController.getUserAddress() != null)
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: size.width * 0.4,
                                  ),
                                  child: Tooltip(
                                    message:
                                        locationController
                                            .getUserAddress()
                                            ?.address ??
                                        '',
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: Dimensions.paddingSizeDefault,
                                        ),
                                        const SizedBox(
                                          width: Dimensions.paddingSizeMini,
                                        ),

                                        Flexible(
                                          child: Text(
                                            locationController
                                                    .getUserAddress()
                                                    ?.address ??
                                                '',
                                            style: robotoMedium.copyWith(
                                              color: Colors.white,
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall,
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeLarge,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                hoverColor: Colors.transparent,
                onTap: () =>
                    Get.toNamed(ServiceRouteHelper.getNotificationRoute()),
                child: const Icon(
                  Icons.notifications,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            log('rrrrr');
            print('eeee');
            Get.offAllNamed('/');
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10, top: 25),
            child: Container(
              height: 30,
              width: 30,

              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      Size(Dimensions.webMaxWidth, GetPlatform.isDesktop ? 70 : 56);
}
