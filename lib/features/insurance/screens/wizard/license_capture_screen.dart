import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/insurance/screens/wizard/vehicle_analyzing_screen.dart';
import 'package:sixam_mart/features/insurance/screens/wizard/vehicle_basics_screen.dart';
import 'package:sixam_mart/features/insurance/widgets/license_art.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

enum LicenseSide { front, back }

/// One side of the driving licence, as in Wave's scan steps. The front offers
/// manual entry instead (no reading); the back can be skipped for an old licence.
class LicenseCaptureScreen extends StatefulWidget {
  final LicenseSide side;
  final XFile? front;
  const LicenseCaptureScreen({super.key, required this.side, this.front});

  @override
  State<LicenseCaptureScreen> createState() => _LicenseCaptureScreenState();
}

class _LicenseCaptureScreenState extends State<LicenseCaptureScreen> {
  bool _busy = false;

  bool get _isFront => widget.side == LicenseSide.front;

  Future<void> _pick(ImageSource source) async {
    setState(() => _busy = true);
    try {
      // Small enough to upload quickly on mobile data, sharp enough to read the card.
      final photo = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 1600);
      if (photo == null || !mounted) return;
      if (_isFront) {
        // Same screen class for both sides: GetX would drop it as a duplicate route.
        Get.to(() => LicenseCaptureScreen(side: LicenseSide.back, front: photo), preventDuplicates: false);
      } else {
        Get.to(() => VehicleAnalyzingScreen(front: widget.front!, back: photo));
      }
    } catch (_) {
      showCustomSnackBar('ins_camera_unavailable'.tr);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _skip() {
    if (_isFront) {
      Get.to(() => const VehicleBasicsScreen());
    } else {
      Get.to(() => VehicleAnalyzingScreen(front: widget.front!, back: null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 2 * Dimensions.paddingSizeLarge;
    final link = robotoBold.copyWith(fontSize: 17, color: Theme.of(context).primaryColor);
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, foregroundColor: Theme.of(context).textTheme.bodyLarge?.color),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, 0, Dimensions.paddingSizeLarge, Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_isFront ? 'ins_license_front_title'.tr : 'ins_license_back_title'.tr, style: robotoBold.copyWith(fontSize: 24, height: 1.25)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(_isFront ? 'ins_license_front_hint'.tr : 'ins_license_back_hint'.tr,
                style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: 16)),
            Expanded(child: Center(child: _isFront ? PhoneOverLicenseArt(width: width) : FlipLicenseArt(width: width))),
            Text('ins_photo_privacy'.tr, textAlign: TextAlign.center,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            CustomButton(
              buttonText: 'ins_take_photo'.tr,
              icon: Icons.photo_camera_outlined,
              isLoading: _busy,
              onPressed: _busy ? null : () => _pick(ImageSource.camera),
            ),
            Center(
              child: TextButton(onPressed: _busy ? null : () => _pick(ImageSource.gallery), child: Text('ins_choose_from_gallery'.tr)),
            ),
            Center(
              child: TextButton(
                onPressed: _busy ? null : _skip,
                child: Text(_isFront ? 'ins_enter_manually'.tr : 'ins_license_skip_back'.tr, style: link),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
