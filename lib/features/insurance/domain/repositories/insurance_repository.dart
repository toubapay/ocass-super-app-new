import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';

/// Calls to /api/v1/customer/insurance. Errors are handled by the controller
/// (handleError: false) because the backend answers with codes the flow acts
/// on, such as `missing_vehicle_details`.
class InsuranceRepository {
  ApiClient get _api => Get.find<ApiClient>();

  Future<Response> getOptions() => _api.getData(AppConstants.insuranceOptionsUri, handleError: false);

  /// Sends the carte grise photos to be read. The backend never stores them.
  Future<Response> analyzeVehicleDocument(XFile front, XFile? back) => _api.postMultipartData(
        AppConstants.insuranceVehicleAnalyzeUri,
        {},
        [MultipartBody('front', front), if (back != null) MultipartBody('back', back)],
        handleError: false,
      );

  Future<Response> requestQuotes(Map<String, dynamic> body) =>
      _api.postData(AppConstants.insuranceQuotesUri, body, handleError: false, timeout: 60);

  Future<Response> getQuoteRequest(int id) =>
      _api.getData('${AppConstants.insuranceQuoteRequestUri}/$id', handleError: false);

  Future<Response> updateDetails(int quoteRequestId, Map<String, dynamic> body) =>
      _api.putData('${AppConstants.insuranceQuoteRequestUri}/$quoteRequestId/details', body, handleError: false);

  Future<Response> purchase(int quoteId) => _api.postData(
        '${AppConstants.insurancePurchaseUri}/$quoteId/purchase',
        {
          'callback': AppConstants.baseUrl + AppConstants.insurancePaymentCallbackPath,
          'payment_platform': GetPlatform.isWeb ? 'web' : 'app',
        },
        handleError: false,
        timeout: 60,
      );

  Future<Response> getPolicies({int offset = 1, int limit = 20}) => _api.getData(
        AppConstants.insurancePoliciesUri,
        query: {'offset': '$offset', 'limit': '$limit'},
        handleError: false,
      );

  Future<Response> getPolicy(int id) => _api.getData('${AppConstants.insurancePoliciesUri}/$id', handleError: false);
}
