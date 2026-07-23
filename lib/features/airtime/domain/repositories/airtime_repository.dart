import 'dart:developer';

import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/airtime/domain/models/airtime_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

class AirtimeRepository {
  /// Send airtime via Backend Gateway
  Future<AirtimeTransactionResponse?> sendAirtime({
    required String montant,
    required String telephone,
    required String operateur,
  }) async {
    try {
      final response = await Get.find<ApiClient>().postData(
        AppConstants.buyAirtimeUri,
        {
          'amount': montant,
          'phone': telephone,
          'operator': operateur,
          'pin': '1234',
        },
        handleError: false, // Prevent ApiChecker from showing generic error
      );
      log('response ${response.body}');

      if (response.statusCode == 200 && response.body != null) {
        log('status code ok');
        if (response.body['data'] != null) {
          return AirtimeTransactionResponse.fromJson(response.body['data']);
        }
        return AirtimeTransactionResponse(status: 'success');
      } else {
        log('error response: ${response.body}');
        log('status code: ${response.statusCode}');
        log('status text: ${response.statusText}');
        
        // Extract error message from response body
        String errorMessage = 'Unknown error occurred';
        if (response.body != null && response.body is Map) {
          log('Response body is Map: ${response.body}');
          errorMessage = response.body['message'] ?? response.statusText ?? errorMessage;
        } else {
          log('Response body is NOT Map or null');
          errorMessage = response.statusText ?? errorMessage;
        }
        
        log('Final error message: $errorMessage');
        
        return AirtimeTransactionResponse(
          status: 'ERROR',
          errorMessage: errorMessage,
        );
      }
    } catch (e) {
      log('exception..');
      return AirtimeTransactionResponse(
        status: 'ERROR',
        errorMessage: 'Server could not be reached: $e',
      );
    }
  }

  /// Remove old GetBalance logic, not supported in new UI
  Future<String?> getBalance() async {
    return null;
  }
}
