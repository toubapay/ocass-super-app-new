import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/features/parcel/domain/models/parcel_category_model.dart';
import 'package:sixam_mart/features/parcel/screens/parcel_address_picker_screen.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/custom_validator.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Parcel addresses, as on the Noor web app (Yango Express style): a route
/// card with two big rows, "D'où" and "Où", each opening the full-screen
/// address picker, then the sender and receiver contacts on the same
/// screen. A signed-in customer is the sender, from the account.
class ParcelLocationScreen extends StatefulWidget {
  final ParcelCategoryModel category;
  const ParcelLocationScreen({super.key, required this.category});

  @override
  State<ParcelLocationScreen> createState() => _ParcelLocationScreenState();
}

class _ParcelLocationScreenState extends State<ParcelLocationScreen> {
  final _senderName = TextEditingController();
  final _senderPhone = TextEditingController();
  final _receiverName = TextEditingController();
  final _receiverPhone = TextEditingController();

  late String _dialCode;
  String _profileName = '';
  String _profilePhone = ''; // national part, e.g. "77 000 05 58"
  bool _editSender = false;
  bool _busy = false;

  ParcelController get _parcel => Get.find<ParcelController>();

  @override
  void initState() {
    super.initState();
    _dialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel?.country ?? 'SN').dialCode ?? '+221';
    // Pickup starts at the customer's delivery address; the destination must be chosen.
    _parcel.setPickupAddress(AddressHelper.getUserAddressFromSharedPref(), false);
    _parcel.setDestinationAddress(null, notify: false);
    _parcel.setIsPickedUp(true, false);
    _parcel.setIsSender(true, false);
    _parcel.setCountryCode(_dialCode, true);
    _parcel.setCountryCode(_dialCode, false);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!AuthHelper.isLoggedIn()) return;
    final profile = Get.find<ProfileController>();
    if (profile.userInfoModel == null) await profile.getUserInfo();
    final u = profile.userInfoModel;
    if (u == null || !mounted) return;
    _profileName = '${u.fName ?? ''} ${u.lName ?? ''}'.trim();
    _profilePhone = '';
    try {
      final p = PhoneNumber.parse(u.phone ?? '');
      _dialCode = '+${p.countryCode}';
      _profilePhone = p.nsn;
    } catch (_) {}
    _useProfile();
  }

  bool get _senderFromProfile => AuthHelper.isLoggedIn() && !_editSender && _profileName.isNotEmpty && _profilePhone.length >= 9;

  void _useProfile() {
    setState(() {
      _editSender = false;
      _senderName.text = _profileName;
      _senderPhone.text = _profilePhone;
    });
    _parcel.setCountryCode(_dialCode, true);
  }

  @override
  void dispose() {
    _senderName.dispose();
    _senderPhone.dispose();
    _receiverName.dispose();
    _receiverPhone.dispose();
    super.dispose();
  }

  /// Opens the picker, then resolves the delivery zone of the chosen point.
  Future<void> _pick({required bool pickup}) async {
    final chosen = await Get.to<AddressModel>(() => ParcelAddressPickerScreen(
          title: pickup ? 'parcel_pickup_address'.tr : 'parcel_delivery_address'.tr,
        ));
    if (chosen == null || chosen.latitude == null || chosen.longitude == null) return;
    setState(() => _busy = true);
    final zone = await Get.find<LocationController>().getZone(chosen.latitude, chosen.longitude, false);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!zone.isSuccess || zone.zoneIds.isEmpty) {
      showCustomSnackBar('service_not_available_in_this_area'.tr);
      return;
    }
    final address = AddressModel(
      id: chosen.id,
      address: chosen.address,
      addressType: chosen.addressType ?? 'others',
      latitude: chosen.latitude,
      longitude: chosen.longitude,
      zoneId: zone.zoneIds.first,
      zoneIds: zone.zoneIds,
      zoneData: zone.zoneData,
      method: chosen.method,
    );
    if (pickup) {
      _parcel.setPickupAddress(address, true);
      if (!_senderFromProfile && _senderName.text.isEmpty) _senderName.text = chosen.contactPersonName ?? '';
    } else {
      _parcel.setDestinationAddress(address);
      // A saved address brings its contact when the receiver is still empty.
      if (_receiverName.text.isEmpty && (chosen.contactPersonName ?? '').isNotEmpty) _receiverName.text = chosen.contactPersonName!;
      if (_receiverPhone.text.isEmpty && (chosen.contactPersonNumber ?? '').isNotEmpty) {
        try {
          _receiverPhone.text = PhoneNumber.parse(chosen.contactPersonNumber!).nsn;
        } catch (_) {}
      }
    }
    setState(() {});
  }

  Future<void> _continue() async {
    final pickup = _parcel.pickupAddress;
    final destination = _parcel.destinationAddress;
    if (pickup == null || pickup.latitude == null) return showCustomSnackBar('select_pickup_address'.tr);
    if (destination == null) return showCustomSnackBar('select_destination_address'.tr);
    if (_senderName.text.trim().isEmpty) return showCustomSnackBar('enter_sender_name'.tr);
    if (_receiverName.text.trim().isEmpty) return showCustomSnackBar('enter_receiver_name'.tr);

    final sender = await CustomValidator.isPhoneValid('${_parcel.senderCountryCode ?? _dialCode}${_senderPhone.text.trim()}');
    if (!sender.isValid) return showCustomSnackBar('invalid_phone_number'.tr);
    final receiver = await CustomValidator.isPhoneValid('${_parcel.receiverCountryCode ?? _dialCode}${_receiverPhone.text.trim()}');
    if (!receiver.isValid) return showCustomSnackBar('invalid_phone_number'.tr);

    // The pickup may still be the saved delivery address: make sure it has a zone.
    var pickupZone = pickup.zoneId;
    var pickupZones = pickup.zoneIds;
    var pickupZoneData = pickup.zoneData;
    if (pickupZone == null || pickupZone == 0) {
      setState(() => _busy = true);
      final zone = await Get.find<LocationController>().getZone(pickup.latitude, pickup.longitude, false);
      if (mounted) setState(() => _busy = false);
      if (!zone.isSuccess || zone.zoneIds.isEmpty) return showCustomSnackBar('service_not_available_in_this_area'.tr);
      pickupZone = zone.zoneIds.first;
      pickupZones = zone.zoneIds;
      pickupZoneData = zone.zoneData;
    }

    final from = AddressModel(
      id: pickup.id,
      address: pickup.address,
      addressType: pickup.addressType,
      latitude: pickup.latitude,
      longitude: pickup.longitude,
      zoneId: pickupZone,
      zoneIds: pickupZones,
      zoneData: pickupZoneData,
      method: pickup.method,
      contactPersonName: _senderName.text.trim(),
      contactPersonNumber: sender.phone,
    );
    final to = AddressModel(
      id: destination.id,
      address: destination.address,
      addressType: destination.addressType,
      latitude: destination.latitude,
      longitude: destination.longitude,
      zoneId: destination.zoneId,
      zoneIds: destination.zoneIds,
      zoneData: destination.zoneData,
      method: destination.method,
      contactPersonName: _receiverName.text.trim(),
      contactPersonNumber: receiver.phone,
    );
    _parcel.setPickupAddress(from, false);
    _parcel.setDestinationAddress(to);
    Get.toNamed(RouteHelper.getParcelRequestRoute(widget.category, from, to));
    Get.find<CheckoutController>().updateFirstTime();
    Get.find<CheckoutController>().updateFirstTimeCodActive();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      appBar: CustomAppBar(title: 'parcel_addresses_title'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: GetBuilder<ParcelController>(builder: (parcel) {
          return Column(children: [
            if (_busy) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Center(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      _Card(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Column(children: [
                          _RouteRow(
                            icon: Icons.inventory_2_outlined,
                            label: 'parcel_from'.tr,
                            placeholder: 'parcel_from_placeholder'.tr,
                            value: parcel.pickupAddress?.address,
                            onTap: () => _pick(pickup: true),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E5EA)),
                          _RouteRow(
                            icon: Icons.flag_outlined,
                            label: 'parcel_to'.tr,
                            placeholder: 'parcel_to_placeholder'.tr,
                            value: parcel.destinationAddress?.address,
                            onTap: () => _pick(pickup: false),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 14),
                      _Card(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          _ContactTitle(icon: Icons.inventory_2_outlined, text: 'parcel_sender'.tr),
                          const SizedBox(height: 12),
                          if (_senderFromProfile)
                            _SenderSummary(name: _profileName, phone: '$_dialCode $_profilePhone', onEdit: () => setState(() => _editSender = true))
                          else ...[
                            _nameField(_senderName, 'parcel_your_name'.tr),
                            const SizedBox(height: 14),
                            _phoneField(_senderPhone, true, parcel.senderCountryCode),
                            if (AuthHelper.isLoggedIn() && _editSender)
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: TextButton(onPressed: _useProfile, child: Text('parcel_use_my_account'.tr)),
                              ),
                          ],
                          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Color(0xFFE5E5EA))),
                          _ContactTitle(icon: Icons.person_outline, text: 'parcel_receiver'.tr),
                          const SizedBox(height: 12),
                          _nameField(_receiverName, 'parcel_receiver_name_hint'.tr),
                          const SizedBox(height: 14),
                          _phoneField(_receiverPhone, false, parcel.receiverCountryCode),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            CustomButton(
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              buttonText: 'continue'.tr,
              isLoading: _busy,
              onPressed: _busy ? null : _continue,
            ),
          ]);
        }),
      ),
    );
  }

  Widget _nameField(TextEditingController c, String hint) => CustomTextField(
        titleText: hint,
        labelText: 'parcel_name'.tr,
        controller: c,
        inputType: TextInputType.name,
        capitalization: TextCapitalization.words,
      );

  Widget _phoneField(TextEditingController c, bool sender, String? code) => CustomTextField(
        titleText: '77 123 45 67',
        labelText: 'parcel_phone'.tr,
        controller: c,
        inputType: TextInputType.phone,
        isPhone: true,
        countryDialCode: code ?? _dialCode,
        onCountryChanged: (CountryCode cc) => _parcel.setCountryCode(cc.dialCode ?? _dialCode, sender),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }
}

/// One big "D'où" / "Où" row: icon tile, label, address (or placeholder), chevron.
class _RouteRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String placeholder;
  final String? value;
  final VoidCallback onTap;
  const _RouteRow({required this.icon, required this.label, required this.placeholder, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;
    final chosen = value != null && value!.trim().isNotEmpty;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 76),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: const Color(0xFFFBF3DC), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: gold),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (chosen) Text(label, style: robotoRegular.copyWith(fontSize: 14, color: Colors.black54)),
                Text(
                  chosen ? value! : placeholder,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: chosen ? robotoBold.copyWith(fontSize: 17) : robotoMedium.copyWith(fontSize: 17, color: const Color(0xFF9A9AA0)),
                ),
              ]),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9A9AA0)),
          ]),
        ),
      ),
    );
  }
}

class _ContactTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactTitle({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 20, color: Theme.of(context).primaryColor),
      const SizedBox(width: 8),
      Text(text, style: robotoBold.copyWith(fontSize: 18)),
    ]);
  }
}

/// Signed-in sender: the account's name and phone, with "Modifier".
class _SenderSummary extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onEdit;
  const _SenderSummary({required this.name, required this.phone, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).primaryColor;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFFBF3DC), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: gold,
            child: Text(name.isEmpty ? '?' : name[0].toUpperCase(), style: robotoBold.copyWith(color: Colors.white, fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: 16)),
              Text(phone, textDirection: TextDirection.ltr, style: robotoRegular.copyWith(color: Colors.black54)),
            ]),
          ),
          TextButton.icon(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 18, color: gold),
            label: Text('parcel_edit'.tr, style: robotoBold.copyWith(color: gold)),
          ),
        ]),
      ),
      const SizedBox(height: 6),
      Text('parcel_sender_from_account'.tr, style: robotoRegular.copyWith(fontSize: 13, color: Colors.black54)),
    ]);
  }
}
