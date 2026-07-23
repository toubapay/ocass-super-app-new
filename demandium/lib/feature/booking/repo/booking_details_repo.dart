import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class BookingDetailsRepo {
  final SharedPreferences sharedPreferences;
  final ServiceApiClient apiClient;
  BookingDetailsRepo({
    required this.sharedPreferences,
    required this.apiClient,
  });

  Future<Response> getBookingDetails({required String bookingID}) async {
    return await apiClient.getData("${AppConstants.bookingDetails}/$bookingID");
  }

  Future<Response> getSubBookingDetails({required String bookingID}) async {
    return await apiClient.getData(
      "${AppConstants.subBookingDetails}/$bookingID",
    );
  }

  Future<Response> trackBookingDetails({
    required String bookingID,
    required String phoneNUmber,
  }) async {
    return await apiClient.postData("${AppConstants.trackBooking}/$bookingID", {
      "phone": phoneNUmber,
    });
  }

  Future<Response> bookingCancel({required String bookingID}) async {
    return await apiClient.postData(
      '${AppConstants.bookingCancel}/$bookingID',
      {"booking_status": "canceled", "_method": "put"},
    );
  }

  Future<Response> subBookingCancel({required String bookingID}) async {
    return await apiClient.postData(
      '${AppConstants.subBookingCancel}/$bookingID',
      {},
    );
  }

  Future<void> setLastIncompleteOfflineBookingId(String bookingId) async {
    await sharedPreferences.setString(
      AppConstants.lastIncompleteOfflineBookingId,
      bookingId,
    );
  }

  String getLastIncompleteOfflineBookingId() {
    return sharedPreferences.getString(
          AppConstants.lastIncompleteOfflineBookingId,
        ) ??
        "";
  }
}
