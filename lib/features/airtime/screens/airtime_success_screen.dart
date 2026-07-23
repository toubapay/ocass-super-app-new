import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/airtime/domain/models/airtime_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class AirtimeSuccessScreen extends StatelessWidget {
  final AirtimeTransactionResponse response;
  final AirtimeOperator? operator;
  const AirtimeSuccessScreen({super.key, required this.response, this.operator});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            
            // Success Icon Animation/Image
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF00AA13).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF00AA13),
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            
            Text('top_up_successful'.tr,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'your_airtime_request_has_been_processed'.tr,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            
            const Spacer(),
            
            // Transaction Details Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildDetailRow('recipient'.tr, response.telephone ?? '-'),
                  const Divider(height: 32),
                  _buildDetailRow('amount'.tr, PriceConverter.convertPrice(double.tryParse(response.montant ?? '0') ?? 0)),
                  const Divider(height: 32),
                  _buildDetailRow('operator'.tr, operator?.name ?? '-'),
                  const Divider(height: 32),
                  _buildDetailRow('transaction_id'.tr, response.transactionId ?? '-'),
                  const Divider(height: 32),
                  _buildDetailRow('status'.tr, response.status?.toUpperCase() ?? 'SUCCESS', color: const Color(0xFF00AA13)),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Done Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AA13),
                    foregroundColor: Colors.white,
                    shape: RoundedRectanglePlatform.borderRadius(20),
                    elevation: 0,
                  ),
                  child: Text('back_to_home'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: color ?? const Color(0xFF1E1B4B),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class RoundedRectanglePlatform {
  static RoundedRectangleBorder borderRadius(double radius) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}
