import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/features/insurance/controllers/insurance_controller.dart';
import 'package:sixam_mart/features/insurance/screens/wizard/carte_grise_capture_screen.dart';
import 'package:sixam_mart/features/insurance/widgets/insurance_policies_view.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Motor insurance: a quote started from a photo of the carte grise and
/// compared across every insurer, and the customer's policies ("Mes polices").
class InsuranceScreen extends StatefulWidget {
  final int initialTab;
  const InsuranceScreen({super.key, this.initialTab = 0});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    if (AuthHelper.isLoggedIn()) {
      Get.find<InsuranceController>().loadOptions();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthHelper.isLoggedIn()) {
      return Scaffold(
        appBar: CustomAppBar(title: 'ins_insurance'.tr),
        body: NotLoggedInScreen(callBack: (_) {
          Get.find<InsuranceController>().loadOptions();
          setState(() {});
        }),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'ins_insurance'.tr),
      body: Column(children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          indicatorColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Theme.of(context).disabledColor,
          tabs: [Tab(text: 'ins_new_quote'.tr), Tab(text: 'ins_my_policies'.tr)],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [_QuoteIntro(), InsurancePoliciesView()],
          ),
        ),
      ]),
    );
  }
}

class _QuoteIntro extends StatelessWidget {
  const _QuoteIntro();

  /// Starts a draft for the chosen vehicle, prefilled from the profile (fetched
  /// first if the screen opened before it loaded), then asks for the card.
  Future<void> _start(bool isMoto) async {
    Get.back();
    final profile = Get.find<ProfileController>();
    if (profile.userInfoModel == null) await profile.getUserInfo();
    final user = profile.userInfoModel;
    Get.find<InsuranceController>().startDraft(
      isMoto: isMoto,
      lastName: user?.lName,
      firstName: user?.fName,
      phone: user?.phone,
      email: user?.email,
    );
    Get.to(() => const CarteGriseCaptureScreen(side: CarteGriseSide.front));
  }

  void _chooseType(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, Dimensions.paddingSizeLarge, Dimensions.paddingSizeLarge, Dimensions.paddingSizeExtraLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
        ),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(child: Text('ins_choose_type'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge))),
              IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _TypeChoice(icon: Icons.directions_car_filled, label: 'ins_car'.tr, color: const Color(0xFF1E5EFF), onTap: () => _start(false)),
              _TypeChoice(icon: Icons.two_wheeler, label: 'ins_motorbike'.tr, color: const Color(0xFFE4572E), onTap: () => _start(true)),
            ]),
          ]),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return ListView(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, 32, Dimensions.paddingSizeLarge, 28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0B6E4F), Color(0xFF14A06F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.directions_car_filled, color: Colors.white, size: 44),
            SizedBox(width: 12),
            Icon(Icons.two_wheeler, color: Colors.white, size: 44),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text('ins_intro_title'.tr, style: robotoBold.copyWith(color: Colors.white, fontSize: 24, height: 1.25)),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
            child: Text('ins_intro_tagline'.tr, style: robotoMedium.copyWith(color: Colors.white)),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.bolt, color: primary),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: Text('ins_intro_instant'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text('ins_intro_steps'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, height: 1.4)),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          CustomButton(buttonText: 'ins_start'.tr, onPressed: () => _chooseType(context)),
        ]),
      ),
    ]);
  }
}

class _TypeChoice extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _TypeChoice({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Column(children: [
        Container(
          width: 64,
          height: 96,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(32)),
          child: Icon(icon, color: color, size: 36),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(label, style: robotoBold),
      ]),
    );
  }
}
