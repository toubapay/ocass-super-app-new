import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';

/// Calls to /api/v1/customer/mobile-money. Errors are handled by the
/// controller (handleError: false) so their French message is shown as is.
class MobileMoneyRepository {
  ApiClient get _api => Get.find<ApiClient>();

  Future<Response> getConfig() => _api.getData(AppConstants.mobileMoneyConfigUri, handleError: false);

  Future<Response> preview(String phone, double amount) =>
      _api.postData(AppConstants.mobileMoneyPreviewUri, {'phone': phone, 'amount': amount}, handleError: false);

  Future<Response> send({required String phone, required double amount, required String pin, String? note, required String requestId}) =>
      _api.postData(
        AppConstants.mobileMoneySendUri,
        {'phone': phone, 'amount': amount, 'pin': pin, if (note != null && note.isNotEmpty) 'note': note, 'request_id': requestId},
        handleError: false,
      );

  Future<Response> setPin(String pin, {String? currentPin}) => _api.postData(
        AppConstants.mobileMoneyPinUri,
        {'pin': pin, 'pin_confirmation': pin, if (currentPin != null) 'current_pin': currentPin},
        handleError: false,
      );

  Future<Response> getTransfers({int offset = 1}) =>
      _api.getData(AppConstants.mobileMoneyTransfersUri, query: {'offset': '$offset', 'limit': '20'}, handleError: false);
}
