import 'dart:convert';
import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/common/models/api_response_model.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';


class DataSyncHelper {
  /// Generic method to fetch data from local and remote sources
  static Future<void> fetchAndSyncData({
    required Future<ApiResponseModel<CacheResponseData>> Function() fetchFromLocal,
    required Future<ApiResponseModel<Response>> Function() fetchFromClient,
    required Function(dynamic, DataSourceEnum source) onResponse,
  }) async {

    // Step 1: Try to load from the local source
    final localResponse = await fetchFromLocal();

    if (localResponse.isSuccess) {
      onResponse(jsonDecode(localResponse.response!.response), DataSourceEnum.local);
    }

    // Step 2: Try to load from the client (remote) source and update if successful
    final clientResponse = await fetchFromClient();
    if (clientResponse.isSuccess && clientResponse.response?.statusCode == 200) {
      onResponse(clientResponse.response?.body, DataSourceEnum.client);
    } else {


      if(clientResponse.response?.statusCode != 429){
        ApiChecker.checkApi(Response(
          body: clientResponse.response?.body,
          statusCode: clientResponse.response?.statusCode,
          statusText: clientResponse.response?.statusText,
        ));
      }
    }

  }
}


