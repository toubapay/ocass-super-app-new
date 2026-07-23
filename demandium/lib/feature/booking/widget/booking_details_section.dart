import 'package:demandium/feature/booking/widget/booking_otp_widget.dart';
import 'package:demandium/feature/booking/widget/booking_photo_evidence.dart';
import 'package:demandium/feature/booking/widget/booking_service_location.dart';
import 'package:demandium/feature/booking/widget/payment_info_widget.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/feature/booking/widget/regular/booking_summery_widget.dart';
import 'package:demandium/feature/booking/widget/provider_info.dart';
import 'package:demandium/feature/booking/widget/service_man_info.dart';
import 'booking_screen_shimmer.dart';

class BookingDetailsSection extends StatelessWidget {
  final String? id;
  final bool isSubBooking;
  const BookingDetailsSection({super.key, this.id, required this.isSubBooking});
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (id != null) {
          if (isSubBooking) {
            await Get.find<BookingDetailsController>().getSubBookingDetails(
              bookingId: id!,
            );
          } else {
            await Get.find<BookingDetailsController>().getBookingDetails(
              bookingId: id!,
            );
          }
        }
      },
      child: Scaffold(
        body: GetBuilder<BookingDetailsController>(
          builder: (bookingDetailsTabController) {
            BookingDetailsContent? bookingDetails = isSubBooking
                ? bookingDetailsTabController.subBookingDetailsContent
                : bookingDetailsTabController.bookingDetailsContent;
            if (bookingDetails != null) {
              String bookingStatus = bookingDetails.bookingStatus ?? "";
              bool isLoggedIn = Get.find<ServiceAuthController>().isLoggedIn();

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        BookingInfo(
                          bookingDetails: bookingDetails,
                          bookingDetailsTabController:
                              bookingDetailsTabController,
                          isSubBooking: isSubBooking,
                        ),

                        (Get.find<ServiceSplashController>()
                                    .configModel
                                    .content!
                                    .confirmationOtpStatus! &&
                                (bookingStatus == "accepted" ||
                                    bookingStatus == "ongoing"))
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  top: Dimensions.paddingSizeDefault,
                                ),
                                child: BookingOtpWidget(
                                  bookingDetails: bookingDetails,
                                ),
                              )
                            : const SizedBox(
                                height: Dimensions.paddingSizeDefault,
                              ),

                        PaymentView(
                          bookingDetails: bookingDetails,
                          isSubBooking: isSubBooking,
                        ),

                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        BookingServiceLocation(bookingDetails: bookingDetails),

                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        BookingSummeryWidget(bookingDetails: bookingDetails),

                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        bookingDetails.provider != null
                            ? ProviderInfo(provider: bookingDetails.provider!)
                            : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        bookingDetails.serviceman != null
                            ? ServiceManInfo(
                                user: bookingDetails.serviceman!.user!,
                              )
                            : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        bookingDetails.photoEvidenceFullPath != null &&
                                bookingDetails.photoEvidenceFullPath!.isNotEmpty
                            ? BookingPhotoEvidence(
                                bookingDetailsContent: bookingDetails,
                              )
                            : const SizedBox(),

                        SizedBox(
                          height: bookingStatus == "completed" && isLoggedIn
                              ? Dimensions.paddingSizeExtraLarge * 3
                              : Dimensions.paddingSizeExtraLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const SingleChildScrollView(child: BookingScreenShimmer());
            }
          },
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: GetBuilder<BookingDetailsController>(
          builder: (bookingDetailsController) {
            if (bookingDetailsController.bookingDetailsContent != null) {
              return Column(
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
                                        isSubBooking: isSubBooking,
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

                              if (!(bookingDetailsController
                                      .bookingDetailsContent!
                                      .isCustomizeBooking ??
                                  false)) ...[
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
                            ],
                          ),
                        )
                      : const SizedBox(),
                ],
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
