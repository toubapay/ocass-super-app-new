import 'package:demandium/api/remote/client_api.dart';
import 'package:demandium/util/app_constants.dart';
import 'package:get/get.dart';

class LoyaltyPointRepo {
  final ServiceApiClient apiClient;
  LoyaltyPointRepo({required this.apiClient});

  Future<Response> convertLoyaltyPoint(String point) async {
    return await apiClient.postData(AppConstants.convertLoyaltyPointUri, {
      "point": point,
    });
  }

  Future<Response> getLoyaltyPointData(int offset) async {
    return await apiClient.getData(
      "${AppConstants.loyaltyPointTransactionData}?limit=10&offset=$offset",
    );
  }
}
