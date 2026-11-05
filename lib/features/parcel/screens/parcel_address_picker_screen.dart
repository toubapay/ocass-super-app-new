import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/domain/models/prediction_model.dart';
import 'package:sixam_mart/features/location/screens/pick_map_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/styles.dart';

/// Full-screen address choice for a parcel, as on the web app (and Yango's
/// "Where from / Where to"): a big search field, current position, saved
/// addresses, or a point on the map. Pops with an [AddressModel] (address
/// text and coordinates; a saved address also carries its contact).
class ParcelAddressPickerScreen extends StatefulWidget {
  final String title;
  const ParcelAddressPickerScreen({super.key, required this.title});

  @override
  State<ParcelAddressPickerScreen> createState() => _ParcelAddressPickerScreenState();
}

class _ParcelAddressPickerScreenState extends State<ParcelAddressPickerScreen> {
  final _text = TextEditingController();
  Timer? _debounce;
  List<PredictionModel> _results = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (AuthHelper.isLoggedIn() && Get.find<AddressController>().addressList == null) {
      Get.find<AddressController>().getAddressList();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final r = await Get.find<LocationController>().searchLocation(context, value.trim());
        if (mounted && _text.text == value) setState(() => _results = r);
      } catch (_) {}
    });
  }

  Future<void> _choose(PredictionModel p) async {
    setState(() => _busy = true);
    try {
      final a = await Get.find<LocationController>().setLocation(p.placeId, p.description, null);
      if (!mounted) return;
      Get.back(result: AddressModel(address: p.description ?? a.address, latitude: a.latitude, longitude: a.longitude, addressType: 'others'));
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _here() async {
    setState(() => _busy = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('denied');
      }
      final pos = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 12));
      final address = await Get.find<LocationController>().getAddressFromGeocode(LatLng(pos.latitude, pos.longitude));
      if (!mounted) return;
      Get.back(result: AddressModel(address: address, latitude: '${pos.latitude}', longitude: '${pos.longitude}', addressType: 'others'));
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('parcel_location_denied'.tr)));
      }
    }
  }

  void _onMap() {
    AddressModel? picked;
    Get.toNamed(
      RouteHelper.getPickMapRoute('parcel', false),
      arguments: PickMapScreen(
        fromSignUp: false,
        fromAddAddress: false,
        canRoute: false,
        route: '',
        onPicked: (AddressModel a) => picked = a,
      ),
    )?.then((_) {
      if (picked != null && mounted) Get.back(result: picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final saved = AuthHelper.isLoggedIn() ? (Get.find<AddressController>().addressList ?? []) : <AddressModel>[];
    final searching = _text.text.trim().length >= 3;
    final gold = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 16, 0),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
              Expanded(child: Text(widget.title, style: robotoBold.copyWith(fontSize: 20), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: gold, width: 2),
              boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Row(children: [
              Icon(Icons.search, color: gold),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _text,
                  autofocus: true,
                  onChanged: _onChanged,
                  style: robotoRegular.copyWith(fontSize: 18),
                  decoration: InputDecoration.collapsed(hintText: 'parcel_search_hint'.tr),
                ),
              ),
            ]),
          ),
          if (_busy) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: GetBuilder<AddressController>(builder: (_) {
              return ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
                _Option(icon: Icons.my_location, title: 'parcel_my_position'.tr, onTap: _busy ? null : _here),
                _Option(icon: Icons.place_outlined, title: 'parcel_choose_on_map'.tr, onTap: _busy ? null : _onMap),
                ..._results.map((p) => _Option(
                      icon: Icons.search,
                      title: p.structuredFormat?.mainText?.text ?? p.description ?? '',
                      subtitle: p.structuredFormat?.secondaryText?.text,
                      onTap: _busy ? null : () => _choose(p),
                    )),
                if (!searching && saved.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 4),
                    child: Text('parcel_my_addresses'.tr, style: robotoBold.copyWith(color: Colors.black54, fontSize: 14)),
                  ),
                  ...saved.map((a) => _Option(
                        icon: Icons.bookmark_border,
                        title: (a.addressType ?? 'others').tr,
                        subtitle: a.address,
                        onTap: () => Get.back(result: a),
                      )),
                ],
              ]);
            }),
          ),
        ]),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _Option({required this.icon, required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA)))),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Color(0xFFF1F1F3), shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: 15)),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(color: Colors.black54, fontSize: 13)),
            ]),
          ),
        ]),
      ),
    );
  }
}
