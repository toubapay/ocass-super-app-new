import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class HtmlViewerScreen extends StatefulWidget {
  final HtmlType? type;
  final String? pageKey;
  const HtmlViewerScreen({super.key, required this.type, this.pageKey});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<HtmlViewController>().getPagesContent(
      widget.pageKey ?? widget.type?.value ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    String? data;
    String? image;

    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<HtmlViewController>(
      builder: (htmlViewController) {
        data = htmlViewController.pageDetailsModel?.content ?? '';

        image = htmlViewController.pageDetailsModel?.image;

        return CustomPopWidget(
          child: Scaffold(
            drawer: ResponsiveHelper.isDesktop(context)
                ? const AddressSelectionDrawer()
                : null,

            endDrawer: ResponsiveHelper.isDesktop(context)
                ? const MenuDrawer()
                : null,
            appBar: CustomAppBar(
              title: htmlViewController.pageDetailsModel?.title ?? '',
            ),

            body: FooterBaseView(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Skeletonizer(
                  enabled: htmlViewController.pageDetailsModel == null,
                  child: Column(
                    children: [
                      if ((data?.isNotEmpty ?? false) ||
                          (htmlViewController.pageDetailsModel == null)) ...[
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        Padding(
                          padding: EdgeInsets.all(
                            isDesktop ? 0 : Dimensions.paddingSizeSmall,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              isDesktop
                                  ? Dimensions.radiusDefault
                                  : Dimensions.radiusSmall,
                            ),
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: isDesktop
                                      ? 185
                                      : (MediaQuery.sizeOf(context).width / 7),
                                  width: double.infinity,
                                  child: CustomImage(
                                    fit: BoxFit.cover,
                                    image: image ?? "",
                                    placeholder: Images.businessPagePlaceholder,
                                    placeHolderBoxFit: BoxFit.fill,
                                  ),
                                ),

                                if (isDesktop) ...[
                                  Container(
                                    height: 185,
                                    width: double.infinity,
                                    color: Colors.black.withValues(alpha: 0.30),
                                    child: Center(
                                      child: Text(
                                        htmlViewController
                                                .pageDetailsModel
                                                ?.title ??
                                            '',
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault,
                          ),
                          margin: EdgeInsets.only(
                            left: ResponsiveHelper.isDesktop(context)
                                ? 0
                                : Dimensions.paddingSizeSmall,
                            right: ResponsiveHelper.isDesktop(context)
                                ? 0
                                : Dimensions.paddingSizeSmall,
                            top: Dimensions.paddingSizeLarge,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSeven,
                            ),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(1, 1),
                                blurRadius: 5,
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Html(
                                data: data,
                                style: {"p": Style(fontSize: FontSize.medium)},
                              ),
                            ],
                          ),
                        ),
                      ] else
                        NoDataScreen(text: 'no_data_found'.tr),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: Get.find<ServiceAuthController>().isLoggedIn()
                ? GetBuilder<ConversationController>(
                    builder: (conversationController) {
                      return FloatingActionButton(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        hoverColor: Colors.black26,
                        onPressed: conversationController.isLoading
                            ? null
                            : () {
                                String userId =
                                    Get.find<ServiceSplashController>()
                                        .configModel
                                        .content!
                                        .adminDetails!
                                        .id!;
                                String phone =
                                    Get.find<ServiceSplashController>()
                                        .configModel
                                        .content
                                        ?.businessPhone ??
                                    "";
                                String name = "admin";
                                String image =
                                    "${Get.find<ServiceSplashController>().configModel.content?.faviconFullPath}";
                                Get.find<ConversationController>()
                                    .createChannel(
                                      userId,
                                      "",
                                      name: name,
                                      image: image,
                                      fromBookingDetailsPage: false,
                                      phone: phone,
                                    );
                              },
                        child: Center(
                          child: conversationController.isLoading
                              ? const SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Image.asset(Images.adminChat, scale: 2.8),
                        ),
                      );
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}
