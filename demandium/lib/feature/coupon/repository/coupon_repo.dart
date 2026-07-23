import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class CouponRepo {
  final ServiceApiClient apiClient;
  CouponRepo({required this.apiClient});

  Future<Response> getCouponList() async {
    return await apiClient.getData(AppConstants.couponUri);
  }

  Future<Response> applyCoupon(String couponCode) async {
    return await apiClient.postData(AppConstants.applyCoupon, {
      'coupon_code': couponCode,
      "guest_id": Get.find<ServiceSplashController>().getGuestId(),
    });
  }

  Future<Response> removeCoupon() async {
    return await apiClient.getData(
      "${AppConstants.removeCoupon}?guest_id=${Get.find<ServiceSplashController>().getGuestId()}",
    );
  }
}
