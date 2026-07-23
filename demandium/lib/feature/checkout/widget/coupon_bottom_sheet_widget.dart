import 'package:demandium/common/widgets/no_data_screen.dart';
import 'package:demandium/feature/auth/controller/auth_controller.dart';
import 'package:demandium/feature/cart/controller/cart_controller.dart';
import 'package:demandium/feature/coupon/controller/coupon_controller.dart';
import 'package:demandium/feature/coupon/model/coupon_model.dart';
import 'package:demandium/feature/coupon/widgets/custom_coupon_snackber.dart';
import 'package:demandium/feature/coupon/widgets/voucher.dart';
import 'package:demandium/feature/splash/controller/theme_controller.dart';
import 'package:demandium/helper/price_converter.dart';
import 'package:demandium/helper/responsive_helper.dart';
import 'package:demandium/util/dimensions.dart';
import 'package:demandium/util/images.dart';
import 'package:demandium/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CouponBottomSheetWidget extends StatefulWidget {
  final double orderAmount;
  const CouponBottomSheetWidget({super.key, required this.orderAmount});
  @override
  State<CouponBottomSheetWidget> createState() =>
      _CouponBottomSheetWidgetState();
}

class _CouponBottomSheetWidgetState extends State<CouponBottomSheetWidget> {
  TextEditingController couponTextController = TextEditingController();

  CouponModel? couponModel;
  int? couponIndex;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceCouponController>(
      builder: (serviceCouponController) {
        bool isDesktop = ResponsiveHelper.isDesktop(context);

        List<CouponModel>? activeCouponList =
            serviceCouponController.activeCouponList;
        return Container(
          width: Dimensions.webMaxWidth / 2.5,

          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
            minHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(Dimensions.paddingSizeDefault),
              topRight: const Radius.circular(Dimensions.paddingSizeDefault),
              bottomLeft: ResponsiveHelper.isDesktop(context)
                  ? const Radius.circular(Dimensions.paddingSizeDefault)
                  : Radius.zero,
              bottomRight: ResponsiveHelper.isDesktop(context)
                  ? const Radius.circular(Dimensions.paddingSizeDefault)
                  : Radius.zero,
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  !isDesktop
                      ? Padding(
                          padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeDefault,
                            left: Dimensions.paddingSizeDefault,
                          ),
                          child: Center(
                            child: Container(
                              width: 35,
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeDefault,
                                ),
                                color: Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: .5),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  const Spacer(),

                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).disabledColor,
                      size: 25,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Dimensions.paddingSizeSmall,
                    ),
                    border: Border.all(
                      color: Get.find<ServiceThemeController>().darkTheme
                          ? Theme.of(context).hintColor.withValues(alpha: .15)
                          : Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: .15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(Dimensions.paddingSizeDefault),
                            ),
                          ),

                          child: TextFormField(
                            controller: couponTextController,
                            decoration: InputDecoration(
                              helperStyle: robotoRegular.copyWith(),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall,
                                ),
                                child: Image.asset(Images.copyCouponIcon),
                              ),
                              suffixIcon: InkWell(
                                onTap: () async {
                                  if (couponTextController.text.isEmpty) {
                                    customCouponSnackBar(
                                      "select_a_coupon",
                                      subtitle: 'select_a_coupon'.tr,
                                    );
                                  } else {
                                    serviceCouponController
                                        .updateSelectedCouponIndex(
                                          index: couponIndex,
                                        );

                                    if (Get.find<ServiceAuthController>()
                                        .isLoggedIn()) {
                                      if (Get.find<ServiceCartController>()
                                          .cartList
                                          .isNotEmpty) {
                                        bool addCoupon = false;

                                        if (couponModel != null) {
                                          Get.find<ServiceCartController>()
                                              .cartList
                                              .forEach((cart) {
                                                if (cart.totalCost >=
                                                    couponModel!
                                                        .discount!
                                                        .minPurchase!
                                                        .toDouble()) {
                                                  addCoupon = true;
                                                }
                                              });
                                        } else {
                                          addCoupon = true;
                                        }

                                        if (addCoupon) {
                                          await Get.find<
                                                ServiceCouponController
                                              >()
                                              .applyCoupon(
                                                couponTextController.text,
                                              )
                                              .then((value) async {
                                                if (value.isSuccess!) {
                                                  Get.find<
                                                        ServiceCartController
                                                      >()
                                                      .getCartListFromServer();
                                                  if (true) {
                                                    Get.back();
                                                  }

                                                  customCouponSnackBar(
                                                    "coupon_applied_successfully"
                                                        .tr,
                                                    subtitle:
                                                        "review_your_cart_for_applied_discounts"
                                                            .tr,
                                                    isError: false,
                                                  );
                                                } else {
                                                  customCouponSnackBar(
                                                    "can_not_apply_coupon",
                                                    subtitle:
                                                        "${value.message}",
                                                  );
                                                }
                                              });
                                        } else {
                                          customCouponSnackBar(
                                            "can_not_apply_coupon",
                                            subtitle:
                                                "${'valid_for_minimum_booking_amount_of'.tr} ${PriceConverter.convertPrice(couponModel?.discount?.minPurchase ?? 0)} ",
                                          );
                                        }
                                      } else {
                                        customCouponSnackBar(
                                          "oops",
                                          subtitle:
                                              "looks_like_no_service_is_added_to_your_cart",
                                        );
                                      }
                                    } else {
                                      customCouponSnackBar(
                                        "sorry_you_can_not_use_coupon",
                                        subtitle: "please_login_to_use_coupon",
                                      );
                                    }
                                  }
                                },

                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(
                                          Dimensions.paddingSizeExtraSmall,
                                        ),
                                      ),
                                    ),
                                    width: 80,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: Dimensions.paddingSizeSmall,
                                        ),
                                        child: serviceCouponController.isLoading
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Theme.of(
                                                        context,
                                                      ).cardColor,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                'apply'.tr,
                                                style: robotoMedium.copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              hintText: 'enter_coupon'.tr,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              suffixIconConstraints: const BoxConstraints(
                                maxHeight: 40,
                              ),
                              hintStyle: robotoRegular.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: .125),
                                  width: 0.125,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 0.125,
                                ),
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: .125),
                                  width: 0.125,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                ),
                child: Text(
                  'available_promo'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ),

              activeCouponList?.length != null
                  ? activeCouponList!.isNotEmpty
                        ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: Dimensions.paddingSizeDefault,
                              ),
                              child: ListView.separated(
                                separatorBuilder: (context, index) {
                                  return const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ); // Example: Adds spacing between items
                                },
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: activeCouponList.length,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    height: 130,
                                    child: Voucher(
                                      isExpired: false,
                                      couponModel: activeCouponList[index],
                                      index: index,
                                      fromCheckout: true,
                                      onTap: (CouponModel couponData) {
                                        couponTextController.text =
                                            couponData.couponCode ?? '';
                                        couponModel = couponData;
                                        couponIndex = index;
                                        customCouponSnackBar(
                                          "coupon_code_copied",
                                          subtitle:
                                              'press_apply_button_to_use_coupon',
                                          isError: false,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : NoDataScreen(text: 'no_coupon_available'.tr)
                  : const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
            ],
          ),
        );
      },
    );
  }
}
