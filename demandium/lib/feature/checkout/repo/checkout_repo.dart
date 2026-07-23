import 'dart:convert';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class CheckoutRepo extends GetxService {
  final ServiceApiClient apiClient;
  CheckoutRepo({required this.apiClient});

  Future<Response> getPostDetails(String postId, String bidId) async {
    return await apiClient.getData(
      '${AppConstants.getPostDetails}/$postId?post_bid_id=$bidId',
    );
  }

  Future<Response> getOfflinePaymentMethod() async {
    Response response = await apiClient.getData(AppConstants.offlinePaymentUri);
    return response;
  }

  Future<Response> getDigitalPaymentResponse({String? transactionId}) async {
    return await apiClient.getData(
      '${AppConstants.digitalPaymentResponse}?transaction_id=$transactionId',
    );
  }

  Future<Response?> checkExistingUser({required String phone}) async {
    return await apiClient.postData(AppConstants.checkExistingUser, {
      "phone": phone,
    });
  }

  Future<Response?> submitOfflinePaymentData({
    required String bookingId,
    required String offlinePaymentId,
    required offlinePaymentInfo,
    required int isPartialPayment,
  }) async {
    return await apiClient.postData(AppConstants.offlinePaymentDataStore, {
      "booking_id": bookingId,
      "offline_payment_id": offlinePaymentId,
      "customer_information": offlinePaymentInfo,
      "is_partial": isPartialPayment,
    });
  }

  Future<Response?> switchPaymentMethod({
    required String bookingId,
    required String paymentMethod,
    int isPartial = 0,
    String? offlinePaymentId,
    String? offlinePaymentInfo,
  }) async {
    return await apiClient.postData(AppConstants.switchPaymentMethod, {
      "booking_id": bookingId,
      "payment_method": paymentMethod,
      "offline_payment_id": offlinePaymentId,
      "customer_information": offlinePaymentInfo,
      "is_partial": isPartial,
    });
  }

  Future<Response> placeBookingRequest({
    required String paymentMethod,
    String? serviceAddressID,
    required AddressModel serviceAddress,
    String? schedule,
    required String zoneId,
    required int isPartial,
    required String serviceLocation,
    required String serviceType,
    String? bookingType,
    String? dates,
    SignUpBody? newUserInfo,
  }) async {
    String address = jsonEncode(serviceAddress);
    return await apiClient.postData(AppConstants.placeRequest, {
      "payment_method": paymentMethod,
      "zone_id": zoneId,
      "service_schedule": schedule,
      "service_address_id": serviceAddressID,
      "guest_id": Get.find<ServiceSplashController>().getGuestId(),
      "service_address": address,
      "is_partial": isPartial,
      "service_type": serviceType,
      "booking_type": bookingType,
      "dates": dates,
      "new_user_info": newUserInfo != null ? jsonEncode(newUserInfo) : null,
      "service_location": serviceLocation,
    });
  }
}
