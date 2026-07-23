import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class ServiceBookingRepo {
  final SharedPreferences sharedPreferences;
  final ServiceApiClient apiClient;

  ServiceBookingRepo({
    required this.sharedPreferences,
    required this.apiClient,
  });

  Future<Response> getBookingList({
    required int offset,
    required String bookingStatus,
    required String serviceType,
  }) async {
    return await apiClient.getData(
      "${AppConstants.bookingList}?limit=10&offset=$offset&booking_status=$bookingStatus&service_type=$serviceType",
    );
  }

  Future<Response> getBookingDetails({required String bookingID}) async {
    return await apiClient.getData("${AppConstants.bookingDetails}/$bookingID");
  }

  Future<Response> addRebookToServer(String bookingId) async {
    return await apiClient.postData(AppConstants.rebookApi, {
      'booking_id': bookingId,
      'guest_id': Get.find<ServiceSplashController>().getGuestId(),
    });
  }

  Future<Response> rebookCheck(String bookingId) async {
    return await apiClient.postData(AppConstants.rebookAvailabilityApi, {
      'booking_id': bookingId,
      'guest_id': Get.find<ServiceSplashController>().getGuestId(),
    });
  }
}
