import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/common/widgets/image_dialog.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium/feature/notification/widget/notification_shimmer.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: "notifications".tr,
          isBackButtonExist: true,
        ),
        body: GetBuilder<ServiceNotificationController>(
          initState: (state) {
            Get.find<ServiceNotificationController>().getNotifications(1);
          },
          builder: (controller) {
            return FooterBaseView(
              isScrollView: true,
              scrollController: scrollController,
              isCenter:
                  Get.find<ServiceNotificationController>()
                      .notificationList
                      .isEmpty
                  ? true
                  : false,
              child: WebShadowWrap(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: controller.notificationModel == null
                      ? const NotificationShimmer()
                      : controller.notificationModel != null &&
                            controller.dateList.isEmpty
                      ? NoDataScreen(
                          text: 'no_notification_found'.tr,
                          type: NoDataType.notification,
                        )
                      : PaginatedListView(
                          scrollController: scrollController,
                          totalSize:
                              controller.notificationModel!.content!.total!,
                          onPaginate: (int offset) async => await controller
                              .getNotifications(offset, reload: false),
                          offset: controller
                              .notificationModel
                              ?.content
                              ?.currentPage,

                          itemView: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                            ),
                            itemBuilder: (context, index0) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          Dimensions.paddingSizeExtraSmall,
                                      vertical: Dimensions.paddingSizeSmall,
                                    ),
                                    child: Text(
                                      Get.find<ServiceNotificationController>()
                                          .dateList[index0]
                                          .toString(),
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.7),
                                      ),
                                      textDirection: TextDirection.ltr,
                                    ),
                                  ),
                                  if (controller.notificationList.isNotEmpty)
                                    Card(
                                      color: Theme.of(context).hoverColor,
                                      elevation: 0,
                                      child: ListView.builder(
                                        itemBuilder: (context, index1) {
                                          return InkWell(
                                            onTap: () => showDialog(
                                              context: context,
                                              builder: (ctx) => ImageDialog(
                                                imageUrl:
                                                    '${controller.notificationList[index0][index1].coverImageFullPath ?? ""}',
                                                title: controller
                                                    .notificationList[index0][index1]
                                                    .title
                                                    .toString()
                                                    .trim(),
                                                subTitle:
                                                    "${controller.notificationList[index0][index1].description}",
                                              ),
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeSmall,
                                                    vertical: Dimensions
                                                        .paddingSizeSmall,
                                                  ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              50,
                                                            ),
                                                        child: CustomImage(
                                                          image:
                                                              '${controller.notificationList[index0][index1].coverImageFullPath ?? ""}',
                                                          height: 30,
                                                          width: 30,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeDefault,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              controller
                                                                  .notificationList[index0][index1]
                                                                  .title
                                                                  .toString()
                                                                  .trim(),
                                                              style: robotoMedium.copyWith(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .textTheme
                                                                        .bodyLarge!
                                                                        .color!
                                                                        .withValues(
                                                                          alpha:
                                                                              0.7,
                                                                        ),
                                                                fontSize: Dimensions
                                                                    .fontSizeDefault,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeSmall,
                                                            ),
                                                            Text(
                                                              "${controller.notificationList[index0][index1].description ?? ""}",
                                                              maxLines: 2,
                                                              style: robotoRegular.copyWith(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .textTheme
                                                                        .bodyLarge!
                                                                        .color!
                                                                        .withValues(
                                                                          alpha:
                                                                              0.5,
                                                                        ),
                                                                fontSize: Dimensions
                                                                    .fontSizeDefault,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 40,
                                                        width: 60,
                                                        child: Text(
                                                          DateConverter.convertStringTimeToDate(
                                                            DateConverter.isoUtcStringToLocalDate(
                                                              controller
                                                                  .notificationList[index0][index1]
                                                                  .createdAt,
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
                                        },
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: controller
                                            .notificationList[index0]
                                            .length,
                                      ),
                                    ),
                                ],
                              );
                            },
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.dateList.length,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
