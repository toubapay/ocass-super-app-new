import 'package:demandium/api/remote/client_api.dart';
import 'package:get/get.dart';
import 'package:demandium/util/app_constants.dart';

class ServiceDetailsRepo {
  final ServiceApiClient apiClient;
  ServiceDetailsRepo({required this.apiClient});

  Future<Response> getServiceDetails(String slug, String fromPage) async {
    if (fromPage == "search_page") {
      return await apiClient.getData(
        '${AppConstants.serviceDetailsUri}/$slug?attribute=service',
      );
    } else {
      return await apiClient.getData('${AppConstants.serviceDetailsUri}/$slug');
    }
  }

  Future<Response> getServiceReviewList(String slug, int offset) async {
    return await apiClient.getData(
      '${AppConstants.getServiceReviewList}$slug?offset=$offset&limit=10',
    );
  }
}
