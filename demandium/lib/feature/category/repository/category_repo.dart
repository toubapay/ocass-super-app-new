import 'package:demandium/common/models/api_response_model.dart';
import 'package:demandium/common/repo/data_sync_repo.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:demandium/util/core_export.dart';

class CategoryRepo extends DataSyncRepo {
  CategoryRepo({required super.apiClient, required SharedPreferences super.sharedPreferences});

  Future<ApiResponseModel<T>> getCategoryList<T>({required DataSourceEnum source}) async {
    return await fetchData<T>('${AppConstants.categoryUrl}&limit=100&offset=1', source);
  }
  Future<Response> getItemsBasedOnCampaignId({required String campaignID}) async {
    return await apiClient.getData('${AppConstants.itemsBasedOnCampaignId}$campaignID&limit=100&offset=1');
  }

  Future<Response> getSubCategoryList(String parentSlug) async {
    return await apiClient.getData('${AppConstants.subcategoryUri}$parentSlug');
  }

  Future<Response> getCategoryServiceList(String categorySlug, int offset, String type) async {
    return await apiClient.getData('${AppConstants.categoryServiceUri}$categorySlug?limit=10&offset=$offset&type=$type');
  }


  Future<Response> getSearchData(String query, String categorySlug, String type) async {
    return await apiClient.getData(
      '${AppConstants.searchUri}services/search?name=$query&category_id=$categorySlug&type=$type&offset=1&limit=50',
    );
  }
}