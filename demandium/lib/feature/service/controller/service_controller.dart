import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/common/models/api_response_model.dart';
import 'package:demandium/feature/service/model/recommendation_search_model.dart';
import 'package:demandium/helper/data_sync_helper.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class ServiceController extends GetxController implements GetxService {
  final ServiceRepo serviceRepo;
  ServiceController({required this.serviceRepo});

  bool _isLoading = false;
  List<int>? _variationIndex;

  final int _cartIndex = -1;

  ServiceContent? _serviceContent;
  ServiceContent? _offerBasedServiceContent;
  ServiceContent? _popularBasedServiceContent;
  ServiceContent? _recommendedServiceContent;
  ServiceContent? _trendingServiceContent;
  ServiceContent? _recentlyViewServiceContent;
  ServiceContent? _subcategoryBasedServiceContent;
  FeatheredCategoryContent? _featheredCategoryContent;

  ServiceContent? get serviceContent => _serviceContent;
  ServiceContent? get offerBasedServiceContent => _offerBasedServiceContent;
  ServiceContent? get popularBasedServiceContent => _popularBasedServiceContent;
  ServiceContent? get recommendedBasedServiceContent =>
      _recommendedServiceContent;
  ServiceContent? get trendingServiceContent => _trendingServiceContent;
  ServiceContent? get recentlyViewServiceContent => _recentlyViewServiceContent;
  ServiceContent? get subcategoryBasedServiceContent =>
      _subcategoryBasedServiceContent;
  FeatheredCategoryContent? get featheredCategoryContent =>
      _featheredCategoryContent;

  List<Service>? _popularServiceList;
  List<Service>? _trendingServiceList;
  List<Service>? _recentlyViewServiceList;
  List<Service>? _recommendedServiceList;
  List<RecommendedSearch>? _recommendedSearchList;
  List<Service>? _subCategoryBasedServiceList;
  List<Service>? _campaignBasedServiceList;
  List<Service>? _offerBasedServiceList;
  List<Service>? _allService;
  List<CategoryData>? _categoryList;

  List<Service>? get allService => _allService;
  List<Service>? get popularServiceList => _popularServiceList;
  List<Service>? get trendingServiceList => _trendingServiceList;
  List<Service>? get recentlyViewServiceList => _recentlyViewServiceList;
  List<Service>? get recommendedServiceList => _recommendedServiceList;
  List<Service>? get subCategoryBasedServiceList =>
      _subCategoryBasedServiceList;
  List<Service>? get campaignBasedServiceList => _campaignBasedServiceList;
  List<Service>? get offerBasedServiceList => _offerBasedServiceList;
  List<RecommendedSearch>? get recommendedSearchList => _recommendedSearchList;
  List<CategoryData>? get categoryList => _categoryList;

  bool get isLoading => _isLoading;
  List<int>? get variationIndex => _variationIndex;

  int get cartIndex => _cartIndex;

  String? _fromPage;
  String? get fromPage => _fromPage!;

  final List<double> _lowestPriceList = [];
  List<double> get lowestPriceList => _lowestPriceList;

  @override
  Future<void> onInit() async {
    super.onInit();
    if (Get.find<ServiceAuthController>().isLoggedIn()) {
      await Get.find<UserController>().getUserInfo();

      await Get.find<ServiceCartController>().getCartListFromServer();
    }
  }

  Future<void> getAllServiceList(int offset, bool reload) async {
    if (offset != 1 || _allService == null || reload) {
      if (offset == 1) {
        DataSyncHelper.fetchAndSyncData(
          fetchFromLocal: () =>
              serviceRepo.getAllServiceList<CacheResponseData>(
                source: DataSourceEnum.local,
              ),
          fetchFromClient: () =>
              serviceRepo.getAllServiceList(source: DataSourceEnum.client),
          onResponse: (data, source) {
            _serviceContent = ServiceModel.fromJson(data).content;
            _allService = [];
            _allService!.addAll(_serviceContent?.serviceList ?? []);
            update();
          },
        );
      } else {
        ApiResponseModel response = await serviceRepo.getAllServiceList(
          offset: offset,
          source: DataSourceEnum.client,
        );
        if (response.response.statusCode == 200) {
          if (reload) {
            _allService = [];
          }
          _serviceContent = ServiceModel.fromJson(
            response.response.body,
          ).content;
          if (_allService != null && offset != 1) {
            _allService!.addAll(_serviceContent?.serviceList ?? []);
          }
        } else {
          ApiChecker.checkApi(response.response);
        }
        update();
      }
    }
  }

  Future<void> getPopularServiceList(int offset, bool reload) async {
    if (offset != 1 || _popularServiceList == null || reload) {
      if (offset == 1) {
        DataSyncHelper.fetchAndSyncData(
          fetchFromLocal: () =>
              serviceRepo.getPopularServiceList<CacheResponseData>(
                source: DataSourceEnum.local,
              ),
          fetchFromClient: () =>
              serviceRepo.getPopularServiceList(source: DataSourceEnum.client),
          onResponse: (data, source) {
            _popularBasedServiceContent = ServiceModel.fromJson(data).content;
            _popularServiceList = [];
            _popularServiceList!.addAll(
              _popularBasedServiceContent!.serviceList!,
            );

            update();
          },
        );
      } else {
        ApiResponseModel response = await serviceRepo.getPopularServiceList(
          offset: offset,
          source: DataSourceEnum.client,
        );
        if (response.response.statusCode == 200) {
          _popularBasedServiceContent = ServiceModel.fromJson(
            response.response?.body,
          ).content;

          if (_popularServiceList != null && offset != 1) {
            _popularServiceList!.addAll(
              _popularBasedServiceContent?.serviceList ?? [],
            );
          }
        } else {
          ApiChecker.checkApi(response.response);
        }
        update();
      }
    }
  }

  Future<void> getTrendingServiceList(int offset, bool reload) async {
    if (offset != 1 || _trendingServiceList == null || reload) {
      if (offset == 1) {
        DataSyncHelper.fetchAndSyncData(
          fetchFromLocal: () =>
              serviceRepo.getTrendingServiceList<CacheResponseData>(
                source: DataSourceEnum.local,
              ),
          fetchFromClient: () =>
              serviceRepo.getTrendingServiceList(source: DataSourceEnum.client),
          onResponse: (data, source) {
            _trendingServiceContent = ServiceModel.fromJson(data).content;
            _trendingServiceList = [];
            _trendingServiceList!.addAll(_trendingServiceContent!.serviceList!);

            update();
          },
        );
      } else {
        ApiResponseModel response = await serviceRepo.getTrendingServiceList(
          offset: offset,
          source: DataSourceEnum.client,
        );
        if (response.response.statusCode == 200) {
          if (reload) {
            _trendingServiceList = [];
          }
          _trendingServiceContent = ServiceModel.fromJson(
            response.response.body,
          ).content;
          if (_trendingServiceList != null && offset != 1) {
            _trendingServiceList!.addAll(_trendingServiceContent!.serviceList!);
          }
        } else {
          ApiChecker.checkApi(response.response);
        }
        update();
      }
    }
  }

  Future<void> getRecommendedServiceList(int offset, bool reload) async {
    if (offset != 1 || _recommendedServiceList == null || reload) {
      if (offset == 1) {
        DataSyncHelper.fetchAndSyncData(
          fetchFromLocal: () =>
              serviceRepo.getRecommendedServiceList<CacheResponseData>(
                source: DataSourceEnum.local,
              ),
          fetchFromClient: () => serviceRepo.getRecommendedServiceList(
            source: DataSourceEnum.client,
          ),
          onResponse: (data, source) {
            _recommendedServiceContent = ServiceModel.fromJson(data).content;
            _recommendedServiceList = [];
            _recommendedServiceList!.addAll(
              _recommendedServiceContent!.serviceList!,
            );
            update();
          },
        );
      } else {
        ApiResponseModel response = await serviceRepo.getRecommendedServiceList(
          offset: offset,
          source: DataSourceEnum.client,
        );
        if (response.response.statusCode == 200) {
          if (reload) {
            _recommendedServiceList = [];
          }
          _recommendedServiceContent = ServiceModel.fromJson(
            response.response.body,
          ).content;
          if (_recommendedServiceList != null && offset != 1) {
            _recommendedServiceList!.addAll(
              _recommendedServiceContent!.serviceList!,
            );
          }
        } else {
          ApiChecker.checkApi(response.response);
        }
        update();
      }
    }
  }

  Future<void> getRecentlyViewedServiceList(int offset, bool reload) async {
    if (offset != 1 || _recentlyViewServiceList == null || reload) {
      if (offset == 1) {
        DataSyncHelper.fetchAndSyncData(
          fetchFromLocal: () =>
              serviceRepo.getRecentlyViewedServiceList<CacheResponseData>(
                source: DataSourceEnum.local,
              ),
          fetchFromClient: () => serviceRepo.getRecentlyViewedServiceList(
            source: DataSourceEnum.client,
          ),
          onResponse: (data, source) {
            _recentlyViewServiceContent = ServiceModel.fromJson(data).content;
            _recentlyViewServiceList = [];
            _recentlyViewServiceList!.addAll(
              _recentlyViewServiceContent!.serviceList!,
            );
            update();
          },
        );
      } else {
        ApiResponseModel response = await serviceRepo
            .getRecentlyViewedServiceList(
              offset: offset,
              source: DataSourceEnum.client,
            );
        if (response.response.statusCode == 200) {
          if (reload) {
            _recentlyViewServiceList = [];
          }
          _recentlyViewServiceContent = ServiceModel.fromJson(
            response.response.body,
          ).content;
          if (_recentlyViewServiceList != null && offset != 1) {
            _recentlyViewServiceList!.addAll(
              _recentlyViewServiceContent!.serviceList!,
            );
          }
        }
        update();
      }
    }
  }

  Future<void> getFeatherCategoryList(bool reload) async {
    if (_featheredCategoryContent == null || reload) {
      if (reload) {
        _categoryList = [];
        _featheredCategoryContent = null;
      }

      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () =>
            serviceRepo.getFeatheredCategoryServiceList<CacheResponseData>(
              source: DataSourceEnum.local,
            ),
        fetchFromClient: () => serviceRepo.getFeatheredCategoryServiceList(
          source: DataSourceEnum.client,
        ),
        onResponse: (data, source) {
          _featheredCategoryContent = FeatheredCategoryModel.fromJson(
            data,
          ).content;

          if (_featheredCategoryContent!.categoryList != null ||
              _featheredCategoryContent!.categoryList!.isNotEmpty) {
            _categoryList = [];
            _featheredCategoryContent?.categoryList?.forEach((element) {
              if (element.servicesByCategory != null &&
                  element.servicesByCategory!.isNotEmpty) {
                _categoryList!.add(element);
              }
            });
          }
          update();
        },
      );
    }
  }

  Future<void> getSubCategoryBasedServiceList(
    String subCategoryID, {
    bool isShouldUpdate = true,
    bool showShimmerAlways = false,
    int offset = 1,
  }) async {
    if (subCategoryID != "") {
      Response response = await serviceRepo.getServiceListBasedOnSubCategory(
        subCategoryID: subCategoryID,
        offset: offset,
      );
      if (response.statusCode == 200) {
        _subcategoryBasedServiceContent = ServiceModel.fromJson(
          response.body,
        ).content;
        if (offset != 1 && _subCategoryBasedServiceList != null) {
          _subCategoryBasedServiceList!.addAll(
            _subcategoryBasedServiceContent?.serviceList ?? [],
          );
        } else {
          _subCategoryBasedServiceList = [];
          _subCategoryBasedServiceList!.addAll(
            _subcategoryBasedServiceContent?.serviceList ?? [],
          );
        }
      } else {
        ApiChecker.checkApi(response);
      }

      if (isShouldUpdate) {
        update();
      }
    } else {
      _subCategoryBasedServiceList = [];
    }
  }

  Future<void> getCampaignBasedServiceList(
    String campaignID,
    bool reload,
  ) async {
    Response response = await serviceRepo.getItemsBasedOnCampaignId(
      campaignID: campaignID,
    );
    if (response.body['response_code'] == 'default_200') {
      if (reload) {
        _campaignBasedServiceList = [];
      }
      response.body['content']['data'].forEach((serviceTypesModel) {
        if (ServiceTypesModel.fromJson(serviceTypesModel).service != null) {
          _campaignBasedServiceList!.add(
            ServiceTypesModel.fromJson(serviceTypesModel).service!,
          );
        }
      });
      Get.toNamed(
        ServiceRouteHelper.allServiceScreenRoute(
          "fromCampaign",
          campaignID: campaignID,
        ),
      );
    } else {
      customSnackBar('campaign_is_not_available_for_this_service'.tr);
      if (response.statusCode != 200) {
        ApiChecker.checkApi(response);
      }
    }
    update();
  }

  Future<void> getRecommendedSearchList({bool reload = false}) async {
    if (_recommendedSearchList == null || reload) {
      if (reload) {
        _recommendedSearchList = null;
        update();
      }
      Response response = await serviceRepo.getRecommendedSearchList();
      if (response.statusCode == 200) {
        if (response.body['content'] != null) {
          List<dynamic> list = response.body['content'];
          _recommendedSearchList = [];
          for (var element in list) {
            _recommendedSearchList?.add(RecommendedSearch.fromJson(element));
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  int _apiHitCount = 0;

  Future<void> updateIsFavoriteStatus({
    required String serviceId,
    required int currentStatus,
  }) async {
    _apiHitCount++;

    Response response = await serviceRepo.updateIsFavoriteStatus(
      serviceId: serviceId,
    );
    _apiHitCount--;
    int status;
    if (response.statusCode == 200 &&
        (response.body['response_code'] == "service_favorite_store_200" ||
            response.body['response_code'] == "service_remove_favorite_200")) {
      if (response.body['content']['status'] != null) {
        status = response.body['content']['status'];

        customSnackBar(
          response.body['message'],
          type: status == 1
              ? ToasterMessageType.success
              : ToasterMessageType.error,
        );
        updateIsFavoriteValue(status, serviceId);
      }
    }
    if (_apiHitCount == 0) {
      update();
    }
  }

  void updateIsFavoriteValue(
    int status,
    String serviceId, {
    bool shouldUpdate = false,
  }) {
    if (_allService != null) {
      int? index = _allService?.indexWhere(
        (element) => element.id == serviceId,
      );
      if (index != null && index > -1) {
        _allService![index].isFavorite = status;
      }
    }

    if (_popularServiceList != null) {
      int? index = _popularServiceList?.indexWhere(
        (element) => element.id == serviceId,
      );
      if (index != null && index > -1) {
        _popularServiceList![index].isFavorite = status;
      }
    }

    if (_trendingServiceList != null) {
      int? index = _trendingServiceList?.indexWhere(
        (element) => element.id == serviceId,
      );
      if (index != null && index > -1) {
        _trendingServiceList![index].isFavorite = status;
      }
    }

    if (_recentlyViewServiceList != null) {
      int? index = _recentlyViewServiceList?.indexWhere(
        (element) => element.id == serviceId,
      );
      if (index != null && index > -1) {
        _recentlyViewServiceList![index].isFavorite = status;
      }
    }

    if (_recommendedServiceList != null) {
      int? index = _recommendedServiceList?.indexWhere(
        (element) => element.id == serviceId,
      );
      if (index != null && index > -1) {
        _recommendedServiceList![index].isFavorite = status;
      }
    }

    if (_offerBasedServiceList != null) {
      int? index = _offerBasedServiceList?.indexWhere(
        (element) => element.id == serviceId,
      );
      if (index != null && index > -1) {
        _offerBasedServiceList![index].isFavorite = status;
      }
    }

    if (_subCategoryBasedServiceList != null) {
      int? index = _subCategoryBasedServiceList?.indexWhere(
        (element) => element.id == serviceId,
      );
      if (index != null && index > -1) {
        _subCategoryBasedServiceList![index].isFavorite = status;
      }
    }

    if (_campaignBasedServiceList != null) {
      int? index = _subCategoryBasedServiceList?.indexWhere(
        (element) => element.id == serviceId,
      );
      if (index != null && index > -1) {
        _subCategoryBasedServiceList![index].isFavorite = status;
      }
    }

    for (
      int categoryIndex = 0;
      categoryIndex < (_categoryList?.length ?? 0);
      categoryIndex++
    ) {
      int? serviceIndex = _categoryList![categoryIndex].servicesByCategory
          ?.indexWhere((element) => element.id == serviceId);

      if (serviceIndex != null && serviceIndex > -1) {
        _categoryList![categoryIndex]
                .servicesByCategory?[serviceIndex]
                .isFavorite =
            status;
      }
    }

    Get.find<AllSearchController>().updateIsFavoriteValue(
      status,
      serviceId,
      shouldUpdate: shouldUpdate,
    );
    Get.find<ProviderBookingController>().updateServiceIsFavoriteValue(
      status,
      serviceId,
      shouldUpdate: shouldUpdate,
    );

    if (shouldUpdate) {
      update();
    }
  }

  void cleanSubCategory() {
    _subCategoryBasedServiceList = null;
    update();
  }

  Future<void> getEmptyCampaignService() async {
    _campaignBasedServiceList = null;
  }

  Future<void> getMixedCampaignList(
    String campaignID,
    bool isWithPagination,
  ) async {
    if (!isWithPagination) {
      _campaignBasedServiceList = [];
    }
    Response response = await serviceRepo.getItemsBasedOnCampaignId(
      campaignID: campaignID,
    );
    if (response.body['response_code'] == 'default_200') {
      response.body['content']['data'].forEach((serviceTypesModel) {
        if (ServiceTypesModel.fromJson(serviceTypesModel).service != null) {
          _campaignBasedServiceList!.add(
            ServiceTypesModel.fromJson(serviceTypesModel).service!,
          );
        }
      });
      _isLoading = false;
      if (_campaignBasedServiceList!.isEmpty) {
        Get.find<ServiceCategoryController>().getCampaignBasedCategoryList(
          campaignID,
          false,
        );
      } else {
        Get.toNamed(
          ServiceRouteHelper.allServiceScreenRoute(
            "fromCampaign",
            campaignID: campaignID,
          ),
        );
      }
    } else {
      if (response.statusCode != 200) {
        ApiChecker.checkApi(response);
      } else {
        customSnackBar('campaign_is_not_available_for_this_service'.tr);
      }
    }
    update();
  }

  Future<void> getOffersList(int offset, bool reload) async {
    Response response = await serviceRepo.getOffersList(offset);
    if (response.statusCode == 200) {
      if (reload) {
        _offerBasedServiceList = [];
      }
      _offerBasedServiceContent = ServiceModel.fromJson(response.body).content;
      if (_offerBasedServiceList != null && offset != 1) {
        _offerBasedServiceList!.addAll(_offerBasedServiceContent!.serviceList!);
      } else {
        _offerBasedServiceList = [];
        _offerBasedServiceList!.addAll(_offerBasedServiceContent!.serviceList!);
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }
}
