import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/features/mobile_money/domain/models/mobile_money_models.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/util/styles.dart';

/// "Mon code QR pour recevoir": others scan it (in the app, the web app or
/// with the phone camera) to send money to this account.
class MyQrSheet extends StatelessWidget {
  const MyQrSheet({super.key});

  static Future<void> show() => Get.bottomSheet(const MyQrSheet(), isScrollControlled: true, backgroundColor: Colors.transparent);

  @override
  Widget build(BuildContext context) {
    final user = Get.find<ProfileController>().userInfoModel;
    final phone = user?.phone ?? '';
    final link = payLink(phone);
    final name = [user?.fName, user?.lName].where((s) => s != null && s.isNotEmpty).join(' ');
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(child: Text('mm_my_qr'.tr, style: robotoBold.copyWith(fontSize: 21))),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
        ]),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 2))],
          ),
          child: QrImageView(data: link, size: 230, backgroundColor: Colors.white),
        ),
        Text(name, style: robotoBold.copyWith(fontSize: 19)),
        Text('+221 ${formatLocal(localDigits(phone))}', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
        const SizedBox(height: 10),
        Text('mm_my_qr_hint'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
            icon: const Icon(Icons.share_outlined),
            label: Text('mm_share_link'.tr),
            onPressed: () => SharePlus.instance.share(ShareParams(text: '${'mm_share_text'.tr} $link')),
          ),
        ),
      ]),
    );
  }
}
