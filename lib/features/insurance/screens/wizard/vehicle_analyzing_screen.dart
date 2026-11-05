import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/features/insurance/controllers/insurance_controller.dart';
import 'package:sixam_mart/features/insurance/screens/wizard/vehicle_basics_screen.dart';
import 'package:sixam_mart/features/insurance/widgets/license_art.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// "Nous analysons tes informations": sends the licence photos to be read
/// (scan animation meanwhile), then opens the vehicle step. A failed reading
/// still continues: the customer types the details instead.
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
    // The animation stays at least a moment, so the step doesn't just flash.
    final minWait = Future.delayed(const Duration(milliseconds: 1800));
    final license = await Get.find<InsuranceController>().analyzeDriverLicense(widget.front, widget.back);
    await minWait;
    if (!mounted) return;
    Get.off(() => VehicleBasicsScreen(license: license, readingAttempted: true));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.66;
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, foregroundColor: Theme.of(context).textTheme.bodyLarge?.color),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, 0, Dimensions.paddingSizeLarge, Dimensions.paddingSizeLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ins_analyzing_title'.tr, style: robotoBold.copyWith(fontSize: 24, height: 1.25)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text('ins_analyzing_hint'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: 16)),
            Expanded(child: Center(child: ScanningLicenseArt(width: width))),
          ]),
        ),
      ),
    );
  }
}
