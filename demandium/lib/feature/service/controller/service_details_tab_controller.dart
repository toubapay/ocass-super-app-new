import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';
import 'package:flutter/scheduler.dart';

enum ServiceTabControllerState {serviceOverview,faq,review}

class ServiceTabController extends GetxController with GetTickerProviderStateMixin{
  final ServiceDetailsRepo serviceDetailsRepo;
  ServiceTabController({required this.serviceDetailsRepo});

  TabController? controller;
  var servicePageCurrentState = ServiceTabControllerState.serviceOverview;

  void initTabController({required int length}) {
    if (controller == null) {
      controller = TabController(vsync: this, length: length);
      update();
      return;
    }
    if (controller!.length == length) {
      update();
      return;
    }
    final oldController = controller!;
    controller = TabController(vsync: this, length: length);
    update();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      oldController.dispose();
    });
  }

  void updateServicePageCurrentState(ServiceTabControllerState state) {
    servicePageCurrentState = state;
    update();
  }

  List<Widget> serviceDetailsTabs(Service? service) {
    if (service != null && service.faqs != null && (service.faqs?.isNotEmpty ?? false)) {
      return [
        Tab(child: Text("service_overview".tr, maxLines: 2)),
        Tab(child: Text("faqs".tr, maxLines: 2)),
        Tab(child: Text("reviews".tr, maxLines: 2)),
      ];
    }
    return [
      Tab(child: Text("service_overview".tr, maxLines: 2)),
      Tab(child: Text("reviews".tr, maxLines: 2)),
    ];
  }

  bool? _isLoading;
  int? _pageSize = 0;
  ReviewContent? reviewContent;
  List<Review>? _reviewList;
  List<Review>? get reviewList => _reviewList;
  bool get isLoading => _isLoading!;
  int? get pageSize => _pageSize!;
  Rating? _rating;
  String? _serviceID;
  int? _offset = 1;
  Rating get rating => _rating!;
  int? get offset => _offset;
  String? get serviceID => _serviceID;


  Future<void> getServiceReview(String serviceID,int offset, {bool reload = true,}) async {
    _offset = offset;
    Response response = await serviceDetailsRepo.getServiceReviewList(serviceID,offset);
    if (response.statusCode == 200 && response.body['response_code'] ==  'default_200') {
      if(reload){
        _reviewList = [];
      }
       reviewContent = ReviewContent.fromJson(response.body['content']);
      if(_reviewList != null && offset != 1){
        _reviewList!.addAll(reviewContent!.reviews!.reviewList!);
      }else{
        _reviewList = [];
        _reviewList!.addAll(reviewContent!.reviews!.reviewList!);
      }
      _rating = reviewContent!.rating;
      _pageSize = response.body['content']['reviews']['last_page']?? 0;
    }
    update();
  }


  void updateProviderReviewExpendedStatus({int? index, bool shouldUpdate = true}){
    if(index  !=null){
      _reviewList?[index].isExpended = 1;
      if(shouldUpdate){
        update();
      }
    } else{
      if(_reviewList !=null && reviewList!.isNotEmpty){
        for(int index = 0; index < _reviewList!.length ; index ++){
          _reviewList?[index].isExpended = 0;
        }
      }
    }
  }
}