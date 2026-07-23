import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/helper/data_sync_helper.dart';
import 'package:demandium/util/core_export.dart';
import 'package:demandium/feature/web_landing/model/web_landing_model.dart';
import 'package:get/get.dart';

class WebLandingController extends GetxController implements GetxService {
  final WebLandingRepo webLandingRepo;

  WebLandingController({required this.webLandingRepo});

  WebLandingContent? _webLandingContent;
  List<SocialMedia>? _socialMedia;
  Map<String, dynamic>? _textContent ;

  int _currentPage = 0;
  int get currentPage => _currentPage;

  WebLandingContent? get webLandingContent=> _webLandingContent;
  List<SocialMedia>? get socialMedia=> _socialMedia;
  Map<String, dynamic>? get textContent=> _textContent;

  Future<void> getWebLandingContent({bool reload = true}) async {

    if(_webLandingContent == null || reload){
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: ()=> webLandingRepo.getWebLandingContents<CacheResponseData>( source: DataSourceEnum.local),
        fetchFromClient: ()=> webLandingRepo.getWebLandingContents(source: DataSourceEnum.client),
        onResponse: (data, source) {

          _webLandingContent = WebLandingContent.fromJson(data['content']);

          if(_webLandingContent?.socialMedia!=null){
            _socialMedia = _webLandingContent?.socialMedia;
          }
          update();
        },
      );
    }
  }

  void setPageIndex(int index){
    _currentPage = index;
    update();
  }

}