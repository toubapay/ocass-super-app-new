import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/mobile_money/domain/models/mobile_money_models.dart';
import 'package:sixam_mart/features/mobile_money/widgets/money_widgets.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class MobileMoneySuccessScreen extends StatelessWidget {
  final MoneyTransfer transfer;
  const MobileMoneySuccessScreen({super.key, required this.transfer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'mm_title'.tr),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.check_circle, size: 72, color: Color(0xFF1E8E3E)),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text('mm_sent_title'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              '${fcfa(transfer.amount)} ${'mm_sent_to'.tr} ${transfer.counterpart?.name ?? ''} (${transfer.counterpart?.phone ?? ''})',
              textAlign: TextAlign.center,
              style: robotoRegular,
            ),
            const SizedBox(height: 6),
            Text('${'mm_reference'.tr} ${transfer.reference}', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            CustomButton(buttonText: 'mm_done'.tr, onPressed: () => Get.back()),
          ]),
        ),
      ),
    );
  }
}
