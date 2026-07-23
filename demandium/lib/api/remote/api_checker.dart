import 'dart:developer';

import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response, {bool showDefaultToaster = true}) {
    log('response  ${response.body}');
    if (response.statusCode == 401) {
      Get.find<ServiceAuthController>().clearSharedData(response: response);
      if (Get.currentRoute != ServiceRouteHelper.getInitialRoute()) {
        log('6');

        Get.offAllNamed(ServiceRouteHelper.getInitialRoute());
        customSnackBar("${response.statusCode!}".tr);
      }
    }
    if (response.statusCode == 204) {
      log('5');

      customSnackBar(
        'information_not_found'.tr,
        showDefaultSnackBar: showDefaultToaster,
      );
      Get.offAllNamed(ServiceRouteHelper.getInitialRoute());
    } else if (response.statusCode == 500) {
      log('4');

      customSnackBar(
        "${response.statusCode!}".tr,
        showDefaultSnackBar: showDefaultToaster,
      );
    } else if (response.statusCode == 400 && response.body['errors'] != null) {
      // log('3');

      // customSnackBar(
      //   "${response.body['errors'][0]['message']}",
      //   showDefaultSnackBar: showDefaultToaster,
      // );
    } else if (response.statusCode == 429) {
      log('2');

      customSnackBar(
        "too_many_request".tr,
        showDefaultSnackBar: showDefaultToaster,
      );
    } else {
      // log('1');
      // customSnackBar(
      //   "${response.body}",
      //   showDefaultSnackBar: showDefaultToaster,
      // );
    }
  }
}
