import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class ServiceCouponController extends GetxController implements GetxService {
  final CouponRepo couponRepo;
  ServiceCouponController({required this.couponRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CouponModel>? _activeCouponList;
  List<CouponModel>? get activeCouponList => _activeCouponList;

  List<CouponModel>? _expiredCouponList;
  List<CouponModel>? get expiredCouponList => _expiredCouponList;

  int _selectedCouponIndex = -1;
  int get selectedCouponIndex => _selectedCouponIndex;

  TabController? voucherTabController;
  CouponTabState __couponTabCurrentState = CouponTabState.currentCoupon;
  CouponTabState get couponTabCurrentState => __couponTabCurrentState;

  Future<void> getCouponList({bool reload = true}) async {
    if (reload) {
      _activeCouponList = null;
      _expiredCouponList = null;
    }

    Response response = await couponRepo.getCouponList();
    if (response.statusCode == 200) {
      _activeCouponList = [];
      _expiredCouponList = [];
      response.body["content"]['active_coupons']['data'].forEach((category) {
        _activeCouponList!.add(CouponModel.fromJson(category));
      });
      response.body["content"]['expired_coupons']['data'].forEach((category) {
        _expiredCouponList!.add(CouponModel.fromJson(category));
      });
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future<ResponseModel> applyCoupon(String couponCode) async {
    _isLoading = true;
    update();

    Response response = await couponRepo.applyCoupon(couponCode);
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'coupon_applied_200') {
      for (int i = 0; i < _activeCouponList!.length - 1; i++) {
        if (_activeCouponList?[i].couponCode == couponCode ||
            (_activeCouponList?[i].couponCode?.toLowerCase() ==
                couponCode.toLowerCase())) {
          _activeCouponList![i].isUsed = 1;
        } else {
          _activeCouponList![i].isUsed = 0;
        }
      }
      await Get.find<ServiceCartController>().getCartListFromServer();
      Get.find<ServiceCartController>().updateBookingAmountWithoutCoupon();

      _isLoading = false;
      update();
      return ResponseModel(true, response.body['message']);
    } else {
      _isLoading = false;
      update();

      return ResponseModel(false, response.body['message']);
    }
  }

  Future<void> removeCoupon({int? index, bool fromCheckout = false}) async {
    _isLoading = true;
    update();
    Response response = await couponRepo.removeCoupon();
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_update_200') {
      await Get.find<ServiceCartController>().getCartListFromServer();
      if (!fromCheckout) {
        Get.back();
      }
      customCouponSnackBar(
        "removed".tr,
        subtitle: "coupon_removed_successfully",
      );
      if (index != null) {
        _activeCouponList?[index].isUsed = 0;
      }
    } else {
      if (!fromCheckout) {
        Get.back();
        customSnackBar(
          response.body['message'],
          type: ToasterMessageType.success,
        );
      }
    }
    _isLoading = false;
    update();
  }

  void updateTabBar(CouponTabState couponTabState, {bool isUpdate = true}) {
    __couponTabCurrentState = couponTabState;
    if (isUpdate) {
      update();
    }
  }

  void updateSelectedCouponIndex({int? index, bool shouldUpdate = true}) {
    if (index != null) {
      _selectedCouponIndex = index;
    }
    if (shouldUpdate) {
      update();
    }
  }
}

enum CouponTabState { currentCoupon, usedCoupon }
