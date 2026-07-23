import 'package:demandium/feature/booking/view/repeat_booking_details_screen.dart';
import 'package:demandium/feature/booking/view/web_booking_details_screen.dart';
import 'package:demandium/feature/booking/widget/booking_photo_evidence.dart';
import 'package:demandium/feature/booking/widget/booking_screen_shimmer.dart';
import 'package:demandium/feature/booking/widget/booking_service_location.dart';
import 'package:demandium/feature/booking/widget/repeat/all_booking_summary_widget.dart';
import 'package:demandium/feature/booking/widget/repeat/next_service_widget.dart';
import 'package:demandium/feature/booking/widget/repeat/repeat_booking_info_widget.dart';
import 'package:demandium/feature/booking/widget/repeat/repeat_booking_summary_widget.dart';
import 'package:demandium/feature/booking/widget/repeat/schedule_widget.dart';
import 'package:demandium/feature/booking/widget/timeline/customer_info_widget.dart';
import 'package:demandium/helper/booking_helper.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/feature/booking/widget/provider_info.dart';
import 'package:demandium/feature/booking/widget/service_man_info.dart';

class RepeatBookingDetailsWidget extends StatelessWidget {
  final TabController? tabController;
  final String? bookingId;
  const RepeatBookingDetailsWidget({
    super.key,
    this.tabController,
    this.bookingId,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => Get.find<BookingDetailsController>().getBookingDetails(
          bookingId: bookingId ?? "",
        ),
        child: GetBuilder<BookingDetailsController>(
          builder: (bookingDetailsTabController) {
            BookingDetailsContent? bookingDetails =
                bookingDetailsTabController.bookingDetailsContent;

            if (bookingDetails != null) {
              String bookingStatus = bookingDetails.bookingStatus ?? "";
              bool isLoggedIn = Get.find<ServiceAuthController>().isLoggedIn();
              RepeatBooking? nextBooking =
                  BookingHelper.getNextUpcomingRepeatBooking(bookingDetails);

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isDesktop(context)
                            ? 0
                            : Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ResponsiveHelper.isDesktop(context)
                              ? BookingDetailsTopCard(
                                  bookingDetailsContent: bookingDetails,
                                )
                              : const SizedBox(),
                          RepeatBookingTabBar(
                            tabController: tabController,
                            bookingDetails: bookingDetails,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          ResponsiveHelper.isDesktop(context)
                              ? _DesktopView(
                                  bookingDetails: bookingDetails,
                                  tabController: tabController!,
                                )
                              : Column(
                                  children: [
                                    RepeatBookingInfoWidget(
                                      bookingDetailsContent: bookingDetails,
                                    ),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeLarge,
                                    ),
                                    ScheduleWidget(
                                      bookingDetailsContent: bookingDetails,
                                    ),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeLarge,
                                    ),
                                    BookingServiceLocation(
                                      bookingDetails: bookingDetails,
                                    ),

                                    SizedBox(
                                      height: nextBooking != null
                                          ? Dimensions.paddingSizeLarge
                                          : 0,
                                    ),

                                    nextBooking != null
                                        ? NextServiceWidget(
                                            booking: nextBooking,
                                          )
                                        : const SizedBox(),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeLarge,
                                    ),
                                    AllBookingSummaryWidget(
                                      tabController: tabController,
                                      bookingDetails: bookingDetails,
                                    ),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeLarge,
                                    ),
                                    RepeatBookingSummeryWidget(
                                      bookingDetails: bookingDetails,
                                    ),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),
                                    bookingDetails.provider != null
                                        ? ProviderInfo(
                                            provider: bookingDetails.provider!,
                                          )
                                        : const SizedBox(),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeSmall,
                                    ),

                                    bookingDetails.serviceman != null
                                        ? ServiceManInfo(
                                            user: bookingDetails
                                                .serviceman!
                                                .user!,
                                          )
                                        : const SizedBox(),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeSmall,
                                    ),

                                    bookingDetails.photoEvidenceFullPath !=
                                                null &&
                                            bookingDetails
                                                .photoEvidenceFullPath!
                                                .isNotEmpty
                                        ? BookingPhotoEvidence(
                                            bookingDetailsContent:
                                                bookingDetails,
                                          )
                                        : const SizedBox(),

                                    SizedBox(
                                      height:
                                          bookingStatus == "completed" &&
                                              isLoggedIn
                                          ? Dimensions.paddingSizeExtraLarge * 3
                                          : Dimensions.paddingSizeExtraLarge,
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    ResponsiveHelper.isDesktop(context)
                        ? const FooterView()
                        : const SizedBox(),
                  ],
                ),
              );
            } else {
              return const SingleChildScrollView(child: BookingScreenShimmer());
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GetBuilder<BookingDetailsController>(
        builder: (bookingDetailsController) {
          if (bookingDetailsController.bookingDetailsContent != null) {
            return SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeDefault,
                      left: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Get.find<ServiceAuthController>().isLoggedIn() &&
                                (bookingDetailsController
                                            .bookingDetailsContent!
                                            .bookingStatus ==
                                        'accepted' ||
                                    bookingDetailsController
                                            .bookingDetailsContent!
                                            .bookingStatus ==
                                        'ongoing')
                            ? FloatingActionButton(
                                hoverColor: Colors.transparent,
                                elevation: 0.0,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                onPressed: () {
                                  BookingDetailsContent bookingDetailsContent =
                                      bookingDetailsController
                                          .bookingDetailsContent!;

                                  if (bookingDetailsContent.provider != null) {
                                    showModalBottomSheet(
                                      useRootNavigator: true,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (context) => CreateChannelDialog(
                                        isSubBooking: false,
                                      ),
                                    );
                                  } else {
                                    customSnackBar(
                                      'provider_or_service_man_assigned'.tr,
                                      type: ToasterMessageType.info,
                                    );
                                  }
                                },
                                child: Icon(
                                  Icons.message_rounded,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),

                  bookingDetailsController
                              .bookingDetailsContent!
                              .bookingStatus ==
                          'completed'
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Get.find<ServiceAuthController>().isLoggedIn()
                                  ? Expanded(
                                      child: CustomButton(
                                        radius: 5,
                                        buttonText: 'review'.tr,
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            useRootNavigator: true,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) =>
                                                ReviewRecommendationDialog(
                                                  id: bookingDetailsController
                                                      .bookingDetailsContent!
                                                      .id!,
                                                ),
                                          );
                                        },
                                      ),
                                    )
                                  : const SizedBox(),

                              Get.find<ServiceAuthController>().isLoggedIn()
                                  ? const SizedBox(width: 15)
                                  : const SizedBox(),

                              GetBuilder<ServiceBookingController>(
                                builder: (serviceBookingController) {
                                  return Expanded(
                                    child: CustomButton(
                                      radius: 5,
                                      isLoading:
                                          serviceBookingController.isLoading,
                                      buttonText: "rebook".tr,
                                      onPressed: () {
                                        serviceBookingController
                                            .checkCartSubcategory(
                                              bookingDetailsController
                                                  .bookingDetailsContent!
                                                  .id!,
                                              bookingDetailsController
                                                  .bookingDetailsContent!
                                                  .subCategoryId!,
                                            );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}

class _DesktopView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final TabController tabController;
  const _DesktopView({
    required this.bookingDetails,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    RepeatBooking? nextBooking = BookingHelper.getNextUpcomingRepeatBooking(
      bookingDetails,
    );
    return Center(
      child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: ScheduleWidget(
                              bookingDetailsContent: bookingDetails,
                            ),
                          ),
                          SizedBox(
                            width: nextBooking != null
                                ? Dimensions.paddingSizeLarge
                                : 0,
                          ),
                          nextBooking != null
                              ? Expanded(
                                  child: NextServiceWidget(
                                    booking: nextBooking,
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    AllBookingSummaryWidget(
                      tabController: tabController,
                      bookingDetails: bookingDetails,
                    ),

                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    RepeatBookingSummeryWidget(bookingDetails: bookingDetails),

                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeLarge),
              SizedBox(
                width: Dimensions.webMaxWidth / 3.5,
                child: Column(
                  children: [
                    CustomerInfoWidget(bookingDetails: bookingDetails),

                    BookingServiceLocation(bookingDetails: bookingDetails),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    ProviderInfo(provider: bookingDetails.provider),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    bookingDetails.serviceman != null
                        ? ServiceManInfo(user: bookingDetails.serviceman!.user!)
                        : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
