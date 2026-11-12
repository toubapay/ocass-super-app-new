import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

const _green = Color(0xFF0E4D3A);
const _gold = Color(0xFFE2B33C);
const _goldInk = Color(0xFF9A7209);

class _NewStore {
  final int id;
  final String name;
  final String? image;
  final int? moduleId;
  final String? moduleType;
  final bool open;
  final String? deliveryTime;

  _NewStore.fromJson(Map<String, dynamic> j)
      : id = (j['id'] as num).toInt(),
        name = (j['name'] ?? '').toString(),
        image = [j['cover_photo_full_url'], j['logo_full_url']].map((v) => v?.toString() ?? '').firstWhere((v) => v.isNotEmpty, orElse: () => ''),
        moduleId = (j['module_id'] as num?)?.toInt(),
        moduleType = j['module_type']?.toString(),
        open = j['open'] == true,
        deliveryTime = j['delivery_time']?.toString();
}

/// "Nouvelles boutiques" on the home screen: the six boutiques that joined
/// last, in a row scrolling sideways. Switched on/off in the admin
/// (Admin > Boutiques à la une).
class NewStoresSection extends StatefulWidget {
  const NewStoresSection({super.key});

  @override
  State<NewStoresSection> createState() => _NewStoresSectionState();
}

class _NewStoresSectionState extends State<NewStoresSection> {
  String _title = '';
  String _subtitle = '';
  List<_NewStore> _stores = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await Get.find<ApiClient>().getData(AppConstants.newStoresUri, handleError: false);
    if (!mounted || r.statusCode != 200 || r.body is! Map || r.body['enabled'] != true) return;
    setState(() {
      _title = (r.body['title'] ?? '').toString();
      _subtitle = (r.body['subtitle'] ?? '').toString();
      _stores = ((r.body['stores'] as List?) ?? []).whereType<Map>().map((s) => _NewStore.fromJson(Map<String, dynamic>.from(s))).toList();
    });
  }

  void _open(_NewStore s) {
    final splash = Get.find<SplashController>();
    for (final ModuleModel m in splash.moduleList ?? const <ModuleModel>[]) {
      if (m.id == s.moduleId) {
        splash.setModule(m);
        break;
      }
    }
    final store = Store(id: s.id, name: s.name, moduleId: s.moduleId);
    Get.toNamed(RouteHelper.getStoreRoute(id: s.id, page: 'module'), arguments: StoreScreen(store: store, fromModule: true));
  }

  String _kind(String? type) {
    switch (type) {
      case 'grocery':
        return 'new_stores_grocery'.tr;
      case 'food':
        return 'new_stores_food'.tr;
      case 'pharmacy':
        return 'new_stores_pharmacy'.tr;
      default:
        return 'new_stores_shop'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stores.isEmpty) return const SizedBox.shrink();
    final cardWidth = MediaQuery.sizeOf(context).width * 0.44;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
            if (_subtitle.isNotEmpty) Text(_subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF6E6E73))),
          ]),
        ),
        SizedBox(
          height: cardWidth + 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _stores.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(width: cardWidth, child: _card(_stores[i], cardWidth)),
          ),
        ),
      ]),
    );
  }

  Widget _card(_NewStore s, double size) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(s),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(fit: StackFit.expand, children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(center: Alignment(0.6, -0.8), radius: 1.1, colors: [Color(0x59E2B33C), _green], stops: [0, 0.55]),
                ),
                alignment: Alignment.center,
                child: Text(s.name.isEmpty ? '?' : s.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w800, color: _gold)),
              ),
              if (s.image != null && s.image!.isNotEmpty) CustomImage(image: s.image!, fit: BoxFit.cover),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _goldInk, borderRadius: BorderRadius.circular(10)),
                  child: Text('new_stores_badge'.tr, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(_kind(s.moduleType), maxLines: 1, style: const TextStyle(fontSize: 13, color: Color(0xFF6E6E73))),
              const SizedBox(height: 2),
              Text(
                s.open ? ['featured_open'.tr, if (s.deliveryTime != null && s.deliveryTime!.isNotEmpty) s.deliveryTime!].join(' · ') : 'new_stores_closed'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: s.open ? const Color(0xFF16794A) : const Color(0xFF6E6E73)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
