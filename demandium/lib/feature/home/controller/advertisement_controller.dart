import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/helper/data_sync_helper.dart';
import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class ServiceAdvertisementController extends GetxController
    implements GetxService {
  final AdvertisementRepo advertisementRepo;
  ServiceAdvertisementController({required this.advertisementRepo});

  List<Advertisement>? _advertisementList;
  List<Advertisement>? get advertisementList => _advertisementList;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  Duration autoPlayDuration = const Duration(seconds: 7);

  bool autoPlay = true;

  Future<void> getAdvertisementList(bool reload) async {
    if (_advertisementList == null || reload) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () =>
            advertisementRepo.getAdvertisementList<CacheResponseData>(
              source: DataSourceEnum.local,
            ),
        fetchFromClient: () => advertisementRepo.getAdvertisementList(
          source: DataSourceEnum.client,
        ),
        onResponse: (data, source) {
          _advertisementList = [];
          data['content']['data'].forEach((banner) {
            _advertisementList!.add(Advertisement.fromJson(banner));
          });

          if (_advertisementList != null &&
              _advertisementList!.isNotEmpty &&
              _advertisementList![0].type == "video_promotion") {
            autoPlay = false;
          }
          update();
        },
      );
    }
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) {
      update();
    }
  }

  void updateAutoPlayStatus({bool shouldUpdate = false, bool status = false}) {
    autoPlay = status;
    if (shouldUpdate) {
      update();
    }
  }

  void updateIsFavoriteValue(
    int status,
    String providerId, {
    bool shouldUpdate = false,
  }) {
    _advertisementList?.forEach((element) {
      int? index;
      if (element.providerData?.id == providerId) {
        index = _advertisementList?.indexOf(element);
      }
      if (index != null && index > -1) {
        _advertisementList?[index].providerData?.isFavorite = status;
      }
    });
    if (shouldUpdate) {
      update();
    }
  }
}
