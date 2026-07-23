import 'package:demandium/common/enums/enums.dart';
import 'package:demandium/common/models/api_response_model.dart';
import 'package:demandium/common/repo/data_sync_repo.dart';
import 'package:get/get.dart';
import 'package:demandium/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceRepo extends DataSyncRepo  {
  ServiceRepo({required super.apiClient, required SharedPreferences super.sharedPreferences});

  Future<ApiResponseModel<T>> getAllServiceList<T>({required DataSourceEnum source, int offset = 1}) async {
    return await fetchData<T>('${AppConstants.allServiceUri}?offset=$offset&limit=10', source);
  }

  Future<ApiResponseModel<T>>  getPopularServiceList<T>({required DataSourceEnum source, int offset = 1}) async {
    return await fetchData<T>('${AppConstants.popularServiceUri}?offset=$offset&limit=10', source);
  }

  Future<ApiResponseModel<T>> getTrendingServiceList<T>({required DataSourceEnum source, int offset = 1}) async {
    return await fetchData<T>('${AppConstants.trendingServiceUri}?offset=$offset&limit=10', source);
  }

  Future<ApiResponseModel<T>> getRecentlyViewedServiceList<T>({required DataSourceEnum source, int offset = 1}) async {
    return await fetchData<T>('${AppConstants.recentlyViewedServiceUri}?offset=$offset&limit=10', source);
  }

  Future<ApiResponseModel<T>> getFeatheredCategoryServiceList<T> ({required DataSourceEnum source, int offset = 1}) async {
    return await fetchData<T>(AppConstants.getFeaturedCategoryService, source);
  }

  Future<ApiResponseModel<T>> getRecommendedServiceList<T>({required DataSourceEnum source, int offset = 1}) async {
    return await fetchData<T>('${AppConstants.recommendedServiceUri}?limit=10&offset=$offset', source);
  }

  Future<Response> getRecommendedSearchList() async {
    return await apiClient.getData(AppConstants.recommendedSearchUri);
  }

  Future<Response> getOffersList(int offset) async {
    return await apiClient.getData('${AppConstants.offerListUri}?limit=10&offset=$offset');
  }

  Future<Response> getServiceListBasedOnSubCategory({required String subCategoryID, required int offset}) async {
    return await apiClient.getData('${AppConstants.serviceBasedOnSubcategory}$subCategoryID?limit=150&offset=$offset');
  }
  Future<Response> getItemsBasedOnCampaignId({required String campaignID}) async {
    return await apiClient.getData('${AppConstants.itemsBasedOnCampaignId}$campaignID&limit=100&offset=1');
  }

  Future<Response> updateIsFavoriteStatus({required String serviceId}) async {
    return await apiClient.postData(AppConstants.updateFavoriteServiceStatus,{
      "service_id" : serviceId
    });
  }

}
