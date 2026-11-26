import 'package:sixam_mart/util/app_constants.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/features/listing/listing_api.dart';
import 'package:sixam_mart/features/listing/screens/listing_detail_screen.dart';
import 'package:sixam_mart/features/listing/screens/listing_packs_screen.dart';
import 'package:sixam_mart/features/listing/widgets/listing_ui.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/styles.dart';

/// Sell in a minute: photos (camera or gallery), then name, price and
/// description typed by hand or filled by the AI from the photos.
class ListingPostScreen extends StatefulWidget {
  const ListingPostScreen({super.key});

  @override
  State<ListingPostScreen> createState() => _ListingPostScreenState();
}

class _ListingPostScreenState extends State<ListingPostScreen> {
  final _picker = ImagePicker();
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  final List<XFile> _photos = [];
  ListingConfig? _config;
  Map? _me;
  int? _category;
  double? _lat;
  double? _lng;
  String? _place;
  bool _ai = false;
  bool _busy = false;
  String? _error;
  Map? _done;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final c = await ListingConfig.load();
    if (mounted) setState(() => _config = c);
    if (!AuthHelper.isLoggedIn()) return;
    final r = await ListingApi.me();
    if (mounted && r.statusCode == 200) setState(() => _me = r.body);
    final a = AddressHelper.getUserAddressFromSharedPref();
    if (_lat == null && a?.latitude != null && mounted) {
      setState(() {
        _lat = double.tryParse(a!.latitude!);
        _lng = double.tryParse(a.longitude ?? '');
        _place = a.address;
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  int get _max => _config?.maxPhotos ?? 5;

  Future<void> _pick(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final x = await _picker.pickImage(source: source, imageQuality: 75, maxWidth: 1600);
        if (x != null) setState(() => _photos.add(x));
      } else {
        final xs = await _picker.pickMultiImage(imageQuality: 75, maxWidth: 1600, limit: _max - _photos.length);
        setState(() => _photos.addAll(xs.take(_max - _photos.length)));
      }
    } catch (_) {}
  }

  Future<void> _fillWithAi() async {
    if (_photos.isEmpty) return;
    setState(() {
      _ai = true;
      _error = null;
    });
    final r = await ListingApi.ai(_photos);
    if (!mounted) return;
    setState(() {
      _ai = false;
      if (r.statusCode == 200 && r.body is Map) {
        final b = r.body as Map;
        if ((b['title'] ?? '').toString().isNotEmpty) _title.text = '${b['title']}';
        if (b['price'] != null && '${b['price']}' != '0') _price.text = '${(b['price'] as num).round()}';
        if ((b['description'] ?? '').toString().isNotEmpty) _desc.text = '${b['description']}';
        if (b['category_id'] != null) _category = b['category_id'];
      } else {
        _error = ListingApi.error(r);
      }
    });
  }

  Future<void> _locate() async {
    try {
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 12)));
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _place = 'lst_my_position'.tr;
      });
    } catch (_) {}
  }

  Future<void> _publish() async {
    final price = double.tryParse(_price.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (_photos.isEmpty || _title.text.trim().isEmpty || price == null) {
      setState(() => _error = 'lst_fill_required'.tr);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ListingApi.post({
      'title': _title.text.trim(),
      'price': '${price.round()}',
      if (_category != null) 'category_id': '$_category',
      if (_desc.text.trim().isNotEmpty) 'description': _desc.text.trim(),
      if (_lat != null) 'latitude': '$_lat',
      if (_lng != null) 'longitude': '$_lng',
      if (_place != null && _place != 'lst_my_position'.tr) 'address': _place!,
    }, _photos);
    if (!mounted) return;
    if (r.statusCode == 201 && r.body is Map) {
      setState(() {
        _busy = false;
        _done = r.body;
      });
    } else if (r.statusCode == 402 && AppConstants.playSafe) {
      setState(() {
        _busy = false;
        _error = 'lst_quota_none'.tr;
      });
    } else if (r.statusCode == 402) {
      setState(() => _busy = false);
      final bought = await Get.to(() => const ListingPacksScreen(reason: 'quota'));
      if (bought == true && mounted) _init();
    } else {
      setState(() {
        _busy = false;
        _error = ListingApi.error(r);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthHelper.isLoggedIn()) {
      return Scaffold(
        appBar: ListingBar(title: 'lst_post_title'.tr),
        body: NotLoggedInScreen(callBack: (_) => setState(() => _init())),
      );
    }
    if (_done != null) return _doneView();

    final quota = _me?['quota'] as Map?;
    final cats = _config?.categories ?? [];
    return Scaffold(
      backgroundColor: LColors.bg,
      appBar: ListingBar(title: 'lst_post_title'.tr),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (quota != null) _QuotaLine(quota: quota),
        Text('lst_step_photos'.tr, style: robotoBold.copyWith(fontSize: 16)),
        const SizedBox(height: 10),
        if (_photos.isEmpty)
          Row(children: [
            Expanded(child: _shot(Icons.photo_camera_outlined, 'lst_take_photo'.tr, () => _pick(ImageSource.camera))),
            const SizedBox(width: 10),
            Expanded(child: _shot(Icons.photo_library_outlined, 'lst_from_gallery'.tr, () => _pick(ImageSource.gallery))),
          ])
        else
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (var i = 0; i < _photos.length; i++) _thumb(i),
            if (_photos.length < _max)
              InkWell(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Wrap(children: [
                      ListTile(leading: const Icon(Icons.photo_camera_outlined), title: Text('lst_take_photo'.tr), onTap: () {
                        Navigator.pop(context);
                        _pick(ImageSource.camera);
                      }),
                      ListTile(leading: const Icon(Icons.photo_library_outlined), title: Text('lst_from_gallery'.tr), onTap: () {
                        Navigator.pop(context);
                        _pick(ImageSource.gallery);
                      }),
                    ]),
                  ),
                ),
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: LColors.line)),
                  child: const Icon(Icons.add_a_photo_outlined, color: LColors.muted),
                ),
              ),
          ]),
        const SizedBox(height: 18),
        Text('lst_step_details'.tr, style: robotoBold.copyWith(fontSize: 16)),
        const SizedBox(height: 10),
        if (_config?.aiFill == true)
          Material(
            color: LColors.cream,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _photos.isEmpty || _ai ? null : _fillWithAi,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFECD9A3)), borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  _ai
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: LColors.goldDark))
                      : const Icon(Icons.auto_awesome, color: LColors.goldDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_ai ? 'lst_ai_working'.tr : 'lst_ai_fill'.tr, style: robotoBold.copyWith(fontSize: 14)),
                      Text(_photos.isEmpty ? 'lst_ai_needs_photo'.tr : 'lst_ai_hint'.tr, style: robotoRegular.copyWith(fontSize: 12, color: LColors.muted)),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        const SizedBox(height: 10),
        _field(_title, 'lst_name'.tr, maxLength: 120),
        _field(_price, 'lst_price'.tr, keyboard: TextInputType.number, suffix: 'F'),
        DropdownButtonFormField<int>(
          initialValue: cats.any((c) => c.id == _category) ? _category : null,
          isExpanded: true,
          decoration: _decoration('lst_category'.tr),
          items: [for (final c in cats) DropdownMenuItem(value: c.id, child: Text('${c.icon}  ${c.name}'))],
          onChanged: (v) => setState(() => _category = v),
        ),
        const SizedBox(height: 10),
        _field(_desc, 'lst_description'.tr, lines: 4, maxLength: 2000),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: LColors.line)),
          child: Row(children: [
            const Icon(Icons.place_outlined, color: LColors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('lst_where'.tr, style: robotoBold.copyWith(fontSize: 13.5)),
                Text(_place ?? 'lst_no_place'.tr, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: 12, color: LColors.muted)),
              ]),
            ),
            TextButton(onPressed: _locate, child: Text('lst_use_my_position'.tr, style: robotoBold.copyWith(color: LColors.green, fontSize: 12.5))),
          ]),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(_error!, style: robotoMedium.copyWith(color: const Color(0xFF9B3412))),
          ),
        const SizedBox(height: 16),
        ListingButton(text: _busy ? 'lst_publishing'.tr : 'lst_publish'.tr, icon: Icons.send, busy: _busy, onTap: _publish),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _doneView() {
    final pending = _done?['status'] == 'pending';
    final id = _done?['listing']?['id'];
    return Scaffold(
      backgroundColor: LColors.bg,
      appBar: ListingBar(title: 'lst_published'.tr),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(pending ? '⏳' : '🎉', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 10),
            Text(pending ? 'lst_pending_title'.tr : 'lst_online_title'.tr, textAlign: TextAlign.center, style: robotoBold.copyWith(fontSize: 20)),
            const SizedBox(height: 6),
            Text(pending ? 'lst_pending_text'.tr : 'lst_online_text'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(color: LColors.muted)),
            const SizedBox(height: 20),
            if (!pending && id != null) ListingButton(text: 'lst_see_listing'.tr, style: 'green', onTap: () => Get.off(() => ListingDetailScreen(id: id))),
            const SizedBox(height: 10),
            ListingButton(
              text: 'lst_post_another'.tr,
              style: 'outline',
              onTap: () => setState(() {
                _done = null;
                _photos.clear();
                _title.clear();
                _price.clear();
                _desc.clear();
                _category = null;
                _init();
              }),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _shot(IconData icon, String label, VoidCallback onTap) => InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFB9C7C0), width: 1.5)),
          child: Column(children: [
            Icon(icon, size: 32, color: LColors.green),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: robotoBold.copyWith(color: LColors.green, fontSize: 13.5)),
          ]),
        ),
      );

  Widget _thumb(int i) => Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: SizedBox(
            width: 76,
            height: 76,
            child: kIsWeb ? Image.network(_photos[i].path, fit: BoxFit.cover) : Image.file(File(_photos[i].path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _photos.removeAt(i)),
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
        if (i == 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(color: LColors.green.withValues(alpha: 0.85), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13))),
              child: Text('lst_cover'.tr, textAlign: TextAlign.center, style: robotoBold.copyWith(color: Colors.white, fontSize: 9.5)),
            ),
          ),
      ]);

  InputDecoration _decoration(String label, {String? suffix}) => InputDecoration(
        labelText: label,
        suffixText: suffix,
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LColors.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LColors.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LColors.green, width: 1.5)),
      );

  Widget _field(TextEditingController c, String label, {int lines = 1, int? maxLength, TextInputType? keyboard, String? suffix}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(controller: c, maxLines: lines, maxLength: maxLength, keyboardType: keyboard, decoration: _decoration(label, suffix: suffix)),
      );
}

/// "Il te reste 2 annonces gratuites" / current package / extra listings.
class _QuotaLine extends StatelessWidget {
  final Map quota;
  const _QuotaLine({required this.quota});

  @override
  Widget build(BuildContext context) {
    final sub = quota['subscription'] as Map?;
    final String text;
    if (sub != null) {
      text = 'lst_quota_package'.trParams({
        'name': '${sub['name']}',
        'left': sub['listings_limit'] == null ? '∞' : '${(sub['listings_limit'] as int) - (sub['listings_used'] as int)}',
      });
    } else if ((quota['free_left'] ?? 0) > 0) {
      text = 'lst_quota_free'.trParams({'left': '${quota['free_left']}', 'total': '${quota['free_total']}'});
    } else if ((quota['extra_credits'] ?? 0) > 0) {
      text = 'lst_quota_credits'.trParams({'n': '${quota['extra_credits']}'});
    } else {
      text = 'lst_quota_none'.tr;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        const Icon(Icons.info_outline, size: 16, color: LColors.muted),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: robotoRegular.copyWith(fontSize: 12.5, color: LColors.muted))),
        if (!AppConstants.playSafe) TextButton(onPressed: () => Get.to(() => const ListingPacksScreen()), child: Text('lst_packs'.tr, style: robotoBold.copyWith(color: LColors.green, fontSize: 12.5))),
      ]),
    );
  }
}
