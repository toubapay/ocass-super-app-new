import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/bill_payment/domain/models/bill_payment_model.dart';
import 'package:sixam_mart/features/bill_payment/domain/models/bill_payment_history_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

class BillPaymentRepository {
  /// Extract dynamic bill providers from the backend
  Future<dynamic> getProviders() async {
    try {
      final response = await Get.find<ApiClient>().getData(AppConstants.getProvidersUri);
      if (response.statusCode == 200 && response.body != null) {
        return response.body; 
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Extract invoice details from backend or partner
  Future<BillTransactionResponse?> checkInvoice({
    required String accountNumber,
    required String billerCode,
    required String countryCode,
  }) async {
    try {
      final response = await Get.find<ApiClient>().postData(
        AppConstants.checkInvoiceUri,
        {
          'account_number': accountNumber,
          'product_id': billerCode,
          'country_code': countryCode,
        },
      );

      if (response.statusCode == 200 && response.body != null) {
        if (response.body['data'] != null) {
            Map<String, dynamic> data = Map<String, dynamic>.from(response.body['data']);
            // Fallback: if backend didn't inject status into data, but top level says success
            if (data['status'] == null && response.body['status'] == 'success') {
              data['status'] = 'success';
            }
            return BillTransactionResponse.fromJson(data);
        }
        return BillTransactionResponse(status: 'success');
      } else {
        return BillTransactionResponse(
          status: 'ERROR',
          errorMessage: response.body != null && response.body['message'] != null 
              ? response.body['message'].toString() 
              : (response.statusText ?? 'Failed to check invoice'),
          minAmount: response.body != null && response.body['meta'] != null ? response.body['meta']['amount_bound_min']?.toString() : null,
          maxAmount: response.body != null && response.body['meta'] != null ? response.body['meta']['amount_bound_max']?.toString() : null,
        );
      }
    } catch (e) {
      return BillTransactionResponse(
        status: 'ERROR',
        errorMessage: 'Server could not be reached: $e',
      );
    }
  }

  /// Process the bill payment
  Future<BillTransactionResponse?> processPayment({
    required String amount,
    required String accountNumber,
    required String billerCode,
    required String countryCode,
    String? invoiceNumber,
  }) async {
    try {
      final response = await Get.find<ApiClient>().postData(
        AppConstants.payBillUri,
        {
          'amount': amount,
          'account_number': accountNumber,
          'product_id': billerCode,
          'country_code': countryCode,
          if (invoiceNumber != null) 'invoice_number': invoiceNumber,
        },
      );

      if (response.statusCode == 200 && response.body != null) {
        if (response.body['data'] != null) {
            Map<String, dynamic> data = Map<String, dynamic>.from(response.body['data']);
            if (data['status'] == null && response.body['status'] == 'success') {
              data['status'] = 'success';
            }
            return BillTransactionResponse.fromJson(data);
        }
        return BillTransactionResponse(status: 'success');
      } else {
        return BillTransactionResponse(
          status: 'ERROR',
          errorMessage: response.body != null && response.body['message'] != null 
              ? response.body['message'].toString() 
              : (response.statusText ?? 'Payment failed'),
          minAmount: response.body != null && response.body['meta'] != null ? response.body['meta']['amount_bound_min']?.toString() : null,
          maxAmount: response.body != null && response.body['meta'] != null ? response.body['meta']['amount_bound_max']?.toString() : null,
        );
      }
    } catch (e) {
      return BillTransactionResponse(
        status: 'ERROR',
        errorMessage: 'Server could not be reached: $e',
      );
    }
  }

  /// Get bill payment history for the logged-in user
  Future<BillPaymentHistoryModel?> getBillPaymentHistory({
    required int offset,
    int limit = 10,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (status != null) 'status': status,
      };
      final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      final uri = '${AppConstants.billPaymentHistoryUri}?$query';

      final response = await Get.find<ApiClient>().getData(uri);
      if (response.statusCode == 200 && response.body != null) {
        return BillPaymentHistoryModel.fromJson(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check payment status from transaction ID (legacy — used by BillPaymentController)
  Future<BillTransactionResponse?> checkPaymentStatus({
    required String transactionId,
  }) async {
    try {
      final response = await Get.find<ApiClient>().postData(
        AppConstants.checkPaymentStatusUri,
        {'transaction_id': transactionId},
      );

      if (response.statusCode == 200 && response.body != null) {
        if (response.body['data'] != null) {
          return BillTransactionResponse.fromJson(response.body['data']);
        }
        return BillTransactionResponse(status: 'success');
      } else {
        return BillTransactionResponse(
          status: 'ERROR',
          errorMessage: response.statusText ?? 'Failed to check payment status',
        );
      }
    } catch (e) {
      return BillTransactionResponse(
        status: 'ERROR',
        errorMessage: 'Server could not be reached: $e',
      );
    }
  }

  /// Refresh payment status and return the updated BillPaymentRecord from DB
  /// Used by the detail screen to refresh live status from LAM
  Future<({BillPaymentRecord? record, String? error})> refreshBillPaymentStatus({
    required String lamTransactionId,
  }) async {
    try {
      final response = await Get.find<ApiClient>().postData(
        AppConstants.checkPaymentStatusUri,
        {'transaction_id': lamTransactionId},
      );

      if (response.statusCode == 200 && response.body != null) {
        // Backend now returns the updated bill_payment DB record under 'data'
        final data = response.body['data'];
        if (data != null && data['id'] != null) {
          return (record: BillPaymentRecord.fromJson(data), error: null);
        }
        // Fallback: data is the raw LAM response (legacy or no DB record)
        return (record: null, error: null);
      }

      final msg = response.body?['message']?.toString()
          ?? response.statusText
          ?? 'Failed to refresh status';
      return (record: null, error: msg);
    } catch (e) {
      return (record: null, error: 'Could not reach server: $e');
    }
  }
}
