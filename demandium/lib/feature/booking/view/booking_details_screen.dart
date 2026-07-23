import 'dart:convert';
import 'package:demandium/common/models/popup_menu_model.dart';
import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/feature/booking/view/web_booking_details_screen.dart';
import 'package:demandium/feature/checkout/model/payment_response_model.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String? bookingID;
  final String? subBookingId;
  final String? phone;
  final String? fromPage;
  final String? token;
  const BookingDetailsScreen({
    super.key,
    this.bookingID,
    this.fromPage,
    this.phone,
    this.subBookingId,
    this.token,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen>
    with SingleTickerProviderStateMixin {
  final scaffoldState = GlobalKey<ScaffoldState>();
  TabController? tabController;
  bool isSubBooking = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: BookingDetailsTabs.values.length,
      vsync: this,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isValidToken(widget.token)) {
      String transactionId = _extractTransactionId(widget.token!);
      PaymentResponseModel? paymentResponse =
          await Get.find<CheckOutController>().getDigitalPaymentResponse(
            transactionId: transactionId,
          );

      if (_hasBookingRepeatId(paymentResponse) != null) {
        Get.find<BookingDetailsController>().getSubBookingDetails(
          bookingId: _hasBookingRepeatId(paymentResponse) ?? "",
        );
        setState(() {
          isSubBooking = true;
        });
      } else if (_hasBookingId(paymentResponse) != null) {
        Get.find<BookingDetailsController>().getBookingDetails(
          bookingId: _hasBookingId(paymentResponse) ?? "",
        );
        setState(() {
          isSubBooking = false;
        });
      }
    } else {
      if (_hasValidBookingId(widget.bookingID, widget.subBookingId)) {
        isSubBooking =
            widget.subBookingId != null && widget.subBookingId != "null";

        if (widget.fromPage == "track-booking") {
          Get.find<BookingDetailsController>().trackBookingDetails(
            widget.bookingID ?? "",
            "+${widget.phone?.trim()}",
            reload: false,
          );
        } else if (isSubBooking) {
          Get.find<BookingDetailsController>().getSubBookingDetails(
            bookingId: widget.subBookingId ?? "",
          );
        } else {
          Get.find<BookingDetailsController>().getBookingDetails(
            bookingId: widget.bookingID ?? "",
          );
        }
      }
    }
  }

  bool _isValidToken(String? token) {
    if (token == null || token == "null" || token.isEmpty) return false;
    String transactionReference = StringParser.parseString(
      utf8.decode(base64Url.decode(token)),
      "transaction_reference",
    );
    return transactionReference.isNotEmpty;
  }

  String _extractTransactionId(String token) {
    return StringParser.parseString(
      utf8.decode(base64Url.decode(token)),
      "transaction_reference",
    );
  }

  String? _hasBookingRepeatId(PaymentResponseModel? response) {
    return response?.content?.bookingRepeatId;
  }

  String? _hasBookingId(PaymentResponseModel? response) {
    return response?.content?.bookingId;
  }

  bool _hasValidBookingId(String? bookingID, String? subBookingId) {
    return bookingID != null || subBookingId != null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(
          title: "booking_details".tr,
          onBackPressed: () {
            if (widget.fromPage == 'fromNotification') {
              Get.offAllNamed(ServiceRouteHelper.getInitialRoute());
            } else {
              if (Navigator.canPop(context)) {
                Get.back();
              } else {
                Get.offAllNamed(ServiceRouteHelper.getInitialRoute());
              }
            }
          },
          actionWidget: GetBuilder<BookingDetailsController>(
            builder: (bookingDetailsController) {
              BookingDetailsContent? bookingDetailsContent = isSubBooking
                  ? bookingDetailsController.subBookingDetailsContent
                  : bookingDetailsController.bookingDetailsContent;

              if (bookingDetailsContent != null) {
                return bookingDetailsContent.bookingStatus == "pending"
                    ? PopupMenuButton<PopupMenuModel>(
                        shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(Dimensions.radiusSmall),
                          ),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.1),
                          ),
                        ),
                        surfaceTintColor: Theme.of(context).cardColor,
                        position: PopupMenuPosition.under,
                        elevation: 8,
                        shadowColor: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.3),
                        padding: EdgeInsets.zero,
                        menuPadding: EdgeInsets.zero,
                        itemBuilder: (BuildContext context) {
                          return bookingDetailsController
                              .getPopupMenuList(
                                bookingDetailsContent.bookingStatus ?? "",
                              )
                              .map((PopupMenuModel option) {
                                return PopupMenuItem<PopupMenuModel>(
                                  value: option,
                                  padding: EdgeInsets.zero,
                                  height: 45,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeDefault,
                                    ),
                                    child: Text(
                                      option.title.tr,
                                      style: robotoRegular,
                                    ),
                                  ),
                                  onTap: () async {
                                    if (option.title == "download_invoice") {
                                      String languageCode =
                                          Get.find<
                                                ServiceLocalizationController
                                              >()
                                              .locale
                                              .languageCode;
                                      String uri =
                                          "${AppConstants.baseUrl}${isSubBooking ? AppConstants.singleRepeatBookingInvoiceUrl : AppConstants.regularBookingInvoiceUrl}${bookingDetailsContent.id}/$languageCode";
                                      if (kDebugMode) {
                                        print("Uri : $uri");
                                      }
                                      await _launchUrl(Uri.parse(uri));
                                    } else if (option.title == "cancel") {
                                      Get.dialog(
                                        ConfirmationDialog(
                                          icon: Images.deleteProfile,
                                          title:
                                              'are_you_sure_to_cancel_this_full_booking'
                                                  .tr,
                                          description:
                                              'once_cancel_full_booking'.tr,
                                          noButtonText: "yes_cancel".tr,
                                          noButtonColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          noTextColor: Colors.white,
                                          yesButtonText: "not_now".tr,
                                          yesButtonColor: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          yesTextColor: Colors.white,
                                          onYesPressed: () {
                                            Get.back();
                                          },
                                          onNoPressed: () async {
                                            Get.back();
                                            Get.dialog(
                                              const CustomLoader(),
                                              barrierDismissible: false,
                                            );
                                            if (isSubBooking) {
                                              await bookingDetailsController
                                                  .subBookingCancel(
                                                    subBookingId:
                                                        bookingDetailsContent
                                                            .id ??
                                                        "",
                                                  );
                                            } else {
                                              await bookingDetailsController
                                                  .bookingCancel(
                                                    bookingId:
                                                        bookingDetailsContent
                                                            .id ??
                                                        "",
                                                  );
                                            }

                                            Get.back();
                                          },
                                        ),
                                        useSafeArea: false,
                                      );
                                    }
                                  },
                                );
                              })
                              .toList();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          child: Icon(Icons.more_vert_sharp),
                        ),
                      )
                    : IconButton(
                        onPressed: () async {
                          String languageCode =
                              Get.find<ServiceLocalizationController>()
                                  .locale
                                  .languageCode;
                          String uri =
                              "${AppConstants.baseUrl}${isSubBooking ? AppConstants.singleRepeatBookingInvoiceUrl : AppConstants.regularBookingInvoiceUrl}${bookingDetailsContent.id}/$languageCode";
                          if (kDebugMode) {
                            print("Uri : $uri");
                          }
                          await _launchUrl(Uri.parse(uri));
                        },
                        icon: const Icon(Icons.file_download_outlined),
                      );
              } else {
                return const SizedBox();
              }
            },
          ),
        ),

        body:
            widget.bookingID == null &&
                widget.subBookingId == null &&
                widget.token == null
            ? const NoDataScreen(
                text: "no_data_found",
                type: NoDataType.bookings,
              )
            : ResponsiveHelper.isDesktop(context)
            ? WebBookingDetailsScreen(
                isSubBooking: isSubBooking,
                id: isSubBooking ? widget.subBookingId : widget.bookingID,
                tabController: tabController,
              )
            : DefaultTabController(
                length: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BookingTabBar(
                      tabController: tabController,
                      isSubBooking: isSubBooking,
                    ),

                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          BookingDetailsSection(
                            id: isSubBooking
                                ? widget.subBookingId
                                : widget.bookingID,
                            isSubBooking: isSubBooking,
                          ),

                          BookingHistory(
                            id: isSubBooking
                                ? widget.subBookingId
                                : widget.bookingID,
                            isSubBooking: isSubBooking,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}

class BookingTabBar extends StatelessWidget {
  final TabController? tabController;
  final bool isSubBooking;
  const BookingTabBar({
    super.key,
    this.tabController,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsTabsController) {
        return Container(
          height: 45,
          width: Dimensions.webMaxWidth,
          color: Theme.of(context).cardColor,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.0),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelColor: Get.isDarkMode
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                    controller: tabController,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(child: Text('booking_details'.tr)),
                      Tab(child: Text('status'.tr)),
                    ],
                    onTap: (int? index) {
                      switch (index) {
                        case 0:
                          bookingDetailsTabsController.updateBookingStatusTabs(
                            BookingDetailsTabs.bookingDetails,
                          );
                          break;

                        case 1:
                          bookingDetailsTabsController.updateBookingStatusTabs(
                            BookingDetailsTabs.status,
                          );
                          break;
                      }
                    },
                  ),
                ),

                !ResponsiveHelper.isDesktop(context)
                    ? const SizedBox()
                    : GetBuilder<BookingDetailsController>(
                        builder: (bookingDetailsController) {
                          BookingDetailsContent? bookingDetailsContent =
                              isSubBooking
                              ? bookingDetailsTabsController
                                    .subBookingDetailsContent
                              : bookingDetailsTabsController
                                    .bookingDetailsContent;

                          return bookingDetailsContent != null
                              ? Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: InkWell(
                                          onTap: () async {
                                            String languageCode =
                                                Get.find<
                                                      ServiceLocalizationController
                                                    >()
                                                    .locale
                                                    .languageCode;
                                            String uri =
                                                "${AppConstants.baseUrl}${isSubBooking ? AppConstants.singleRepeatBookingInvoiceUrl : AppConstants.regularBookingInvoiceUrl}${bookingDetailsContent.id}/$languageCode";
                                            if (kDebugMode) {
                                              print("Uri : $uri");
                                            }
                                            await _launchUrl(Uri.parse(uri));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall,
                                              vertical:
                                                  Dimensions.paddingSizeEight,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.radiusDefault,
                                                  ),
                                              border: Border.all(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "invoice".tr,
                                                  style: robotoMedium.copyWith(
                                                    color: Get.isDarkMode
                                                        ? Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.color
                                                        : Theme.of(
                                                            context,
                                                          ).colorScheme.primary,
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall,
                                                ),

                                                SizedBox(
                                                  height: 15,
                                                  width: 15,
                                                  child: Image.asset(
                                                    Images.downloadImage,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        width: Dimensions.paddingSizeSmall,
                                      ),

                                      Get.find<ServiceAuthController>()
                                                  .isLoggedIn() &&
                                              ((bookingDetailsContent
                                                              .bookingStatus ==
                                                          "completed" &&
                                                      !isSubBooking &&
                                                      !(bookingDetailsContent
                                                              .isCustomizeBooking ??
                                                          false)) ||
                                                  bookingDetailsContent
                                                          .bookingStatus ==
                                                      "pending")
                                          ? GetBuilder<
                                              ServiceBookingController
                                            >(
                                              builder: (serviceBookingController) {
                                                return InkWell(
                                                  onTap: () {
                                                    if (bookingDetailsContent
                                                            .bookingStatus ==
                                                        "completed") {
                                                      serviceBookingController
                                                          .checkCartSubcategory(
                                                            bookingDetailsContent
                                                                .id!,
                                                            bookingDetailsContent
                                                                .subCategoryId!,
                                                          );
                                                    } else {
                                                      Get.dialog(
                                                        ConfirmationDialog(
                                                          icon: Images.warning,
                                                          title:
                                                              'are_you_sure_to_cancel_your_order'
                                                                  .tr,
                                                          description:
                                                              'your_order_will_be_cancel'
                                                                  .tr,
                                                          noButtonText:
                                                              "yes_cancel".tr,
                                                          noButtonColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          noTextColor:
                                                              Colors.white,
                                                          yesButtonText:
                                                              "not_now".tr,
                                                          yesButtonColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .error,
                                                          yesTextColor:
                                                              Colors.white,
                                                          buttonFontSize:
                                                              Dimensions
                                                                  .fontSizeSmall +
                                                              1,
                                                          onNoPressed: () async {
                                                            Get.back();
                                                            Get.dialog(
                                                              const CustomLoader(),
                                                              barrierDismissible:
                                                                  false,
                                                            );
                                                            if (isSubBooking) {
                                                              await bookingDetailsController
                                                                  .subBookingCancel(
                                                                    subBookingId:
                                                                        bookingDetailsContent
                                                                            .id ??
                                                                        "",
                                                                  );
                                                            } else {
                                                              await bookingDetailsController
                                                                  .bookingCancel(
                                                                    bookingId:
                                                                        bookingDetailsContent
                                                                            .id ??
                                                                        "",
                                                                  );
                                                            }
                                                            Get.back();
                                                          },
                                                          onYesPressed: () =>
                                                              Get.back(),
                                                        ),
                                                        useSafeArea: false,
                                                      );
                                                    }
                                                  },

                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            Dimensions
                                                                .radiusDefault,
                                                          ),
                                                      border: Border.all(
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                      ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: Dimensions
                                                              .paddingSizeEight,
                                                          horizontal: Dimensions
                                                              .paddingSizeLarge,
                                                        ),
                                                    child:
                                                        (serviceBookingController
                                                            .isLoading)
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      Dimensions
                                                                          .paddingSizeDefault,
                                                                ),
                                                            child: SizedBox(
                                                              height: 15,
                                                              width: 15,
                                                              child: CircularProgressIndicator(
                                                                color: Theme.of(
                                                                  context,
                                                                ).colorScheme.onPrimary,
                                                              ),
                                                            ),
                                                          )
                                                        : Text(
                                                            bookingDetailsContent
                                                                        .bookingStatus ==
                                                                    "completed"
                                                                ? "rebook".tr
                                                                : "cancel_booking"
                                                                      .tr,
                                                            style: robotoMedium.copyWith(
                                                              color:
                                                                  Get.isDarkMode
                                                                  ? Theme.of(
                                                                          context,
                                                                        )
                                                                        .textTheme
                                                                        .bodyLarge
                                                                        ?.color
                                                                  : Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .onPrimary,
                                                            ),
                                                          ),
                                                  ),
                                                );
                                              },
                                            )
                                          : const SizedBox(),

                                      bookingDetailsContent.bookingStatus ==
                                                  "completed" &&
                                              !isSubBooking &&
                                              Get.find<ServiceAuthController>()
                                                  .isLoggedIn()
                                          ? InkWell(
                                              onTap: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  useRootNavigator: true,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (context) =>
                                                      ReviewRecommendationDialog(
                                                        id: bookingDetailsContent
                                                            .id!,
                                                      ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        Dimensions
                                                            .radiusDefault,
                                                      ),
                                                  border: Border.all(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                  ),
                                                ),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeSmall,
                                                    ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: Dimensions
                                                          .paddingSizeEight,
                                                      horizontal: Dimensions
                                                          .paddingSizeLarge,
                                                    ),
                                                child: Text(
                                                  "review".tr,
                                                  style: robotoMedium.copyWith(
                                                    color: Get.isDarkMode
                                                        ? Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.color
                                                        : Theme.of(context)
                                                              .colorScheme
                                                              .onPrimary,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                )
                              : const SizedBox();
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}
