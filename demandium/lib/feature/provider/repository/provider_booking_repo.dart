import 'package:demandium/common/models/api_response_model.dart';
import 'package:demandium/common/repo/data_sync_repo.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:demandium/util/core_export.dart';

class ProviderBookingRepo extends DataSyncRepo{
  ProviderBookingRepo({required super.apiClient, required SharedPreferences super.sharedPreferences});


  Future<Response> getCategoryList() async {
    return await apiClient.getData('${AppConstants.categoryUrl}&limit=100&offset=1');
  }

  Future<ApiResponseModel<T>> getProviderList<T>(int offset, Map<String,dynamic> body,{required DataSourceEnum source, int limit = 10}) async {
    return await fetchData<T>("${AppConstants.getProviderList}?limit=$limit&offset=$offset", source, method: ApiMethodType.post, body: body);
  }

  Future<Response> getProviderDetails(String providerId, int offset) async {
    return await apiClient.getData("${AppConstants.getProviderDetails}?id=$providerId&limit=10&offset=$offset");
  }

  Future<Response> updateIsFavoriteStatus({required String serviceId}) async {
    return await apiClient.postData(AppConstants.updateFavoriteProviderStatus,{
      "provider_id" : serviceId
    });
  }
}