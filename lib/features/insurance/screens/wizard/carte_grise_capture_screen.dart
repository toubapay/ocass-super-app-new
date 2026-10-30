import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/insurance/screens/wizard/vehicle_analyzing_screen.dart';
import 'package:sixam_mart/features/insurance/screens/wizard/vehicle_info_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

enum CarteGriseSide { front, back }

/// One side of the carte grise. The front offers manual entry instead (skips
/// the reading); the back can be skipped for older single-sided cards.
class CarteGriseCaptureScreen extends StatefulWidget {
  final CarteGriseSide side;
  final XFile? front;
  const CarteGriseCaptureScreen({super.key, required this.side, this.front});

  @override
  State<CarteGriseCaptureScreen> createState() => _CarteGriseCaptureScreenState();
}

class _CarteGriseCaptureScreenState extends State<CarteGriseCaptureScreen> {
  bool _busy = false;

  bool get _isFront => widget.side == CarteGriseSide.front;

  Future<void> _pick(ImageSource source) async {
    setState(() => _busy = true);
    try {
      // Small enough to upload quickly on mobile data, sharp enough to read the card.
      final photo = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 1600);
      if (photo == null || !mounted) return;
      if (_isFront) {
        // Same screen class for both sides: GetX would drop it as a duplicate route.
        Get.to(() => CarteGriseCaptureScreen(side: CarteGriseSide.back, front: photo), preventDuplicates: false);
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
      Get.to(() => const VehicleInfoScreen());
    } else {
      Get.to(() => VehicleAnalyzingScreen(front: widget.front!, back: null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: CustomAppBar(title: 'ins_carte_grise'.tr),
      body: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_isFront ? 'ins_photo_front_title'.tr : 'ins_photo_back_title'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(_isFront ? 'ins_photo_front_hint'.tr : 'ins_photo_back_hint'.tr,
              style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
          Expanded(
            child: Center(
              child: Container(
                width: 280,
                height: 180,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  border: Border.all(color: primary.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_isFront ? Icons.badge_outlined : Icons.flip_to_back_rounded, size: 52, color: primary),
                  const SizedBox(height: 8),
                  Text(_isFront ? 'ins_recto'.tr : 'ins_verso'.tr, style: robotoBold.copyWith(color: primary)),
                ]),
              ),
            ),
          ),
          Text('ins_photo_privacy'.tr, textAlign: TextAlign.center,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          CustomButton(
            buttonText: 'ins_take_photo'.tr,
            icon: Icons.photo_camera_outlined,
            isLoading: _busy,
            onPressed: _busy ? null : () => _pick(ImageSource.camera),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Center(
            child: TextButton(
              onPressed: _busy ? null : () => _pick(ImageSource.gallery),
              child: Text('ins_choose_from_gallery'.tr),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: _busy ? null : _skip,
              child: Text(_isFront ? 'ins_enter_manually'.tr : 'ins_skip_back'.tr),
            ),
          ),
        ]),
      ),
    );
  }
}
