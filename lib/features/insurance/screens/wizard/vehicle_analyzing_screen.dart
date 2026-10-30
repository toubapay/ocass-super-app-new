import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/features/insurance/controllers/insurance_controller.dart';
import 'package:sixam_mart/features/insurance/screens/wizard/vehicle_info_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Sends the carte grise photos to be read, then opens the vehicle form
/// prefilled with whatever was readable. A failed reading still continues:
/// the customer types the details instead.
class VehicleAnalyzingScreen extends StatefulWidget {
  final XFile front;
  final XFile? back;
  const VehicleAnalyzingScreen({super.key, required this.front, this.back});

  @override
  State<VehicleAnalyzingScreen> createState() => _VehicleAnalyzingScreenState();
}

class _VehicleAnalyzingScreenState extends State<VehicleAnalyzingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _analyze());
  }

  Future<void> _analyze() async {
    final extraction = await Get.find<InsuranceController>().analyzeVehicleDocument(widget.front, widget.back);
    if (!mounted) return;
    Get.off(() => VehicleInfoScreen(readFields: extraction?.filledCount ?? 0, readingAttempted: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(strokeWidth: 4, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text('ins_reading_card'.tr, textAlign: TextAlign.center, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text('ins_reading_card_hint'.tr, textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
            ]),
          ),
        ),
      ),
    );
  }
}
