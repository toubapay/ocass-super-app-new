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

const _gold = Color(0xFF9A7209);

class _FeaturedStore {
  final int id;
  final String name;
  final String? logo;
  final int? moduleId;
  final bool open;
  final String? deliveryTime;
  final String? label;

  _FeaturedStore.fromJson(Map<String, dynamic> j)
      : id = (j['id'] as num).toInt(),
        name = (j['name'] ?? '').toString(),
        logo = j['logo_full_url']?.toString(),
        moduleId = (j['module_id'] as num?)?.toInt(),
        open = j['open'] == true,
        deliveryTime = j['delivery_time']?.toString(),
        label = (j['label'] ?? '').toString().trim().isEmpty ? null : j['label'].toString();
}

/// "Boutiques à la une" on the home screen: the boutiques the admin promotes
/// (Admin > Boutiques à la une), as cards in a three-row grid scrolling
/// sideways, like Glovo's "Top brands".
class FeaturedStoresSection extends StatefulWidget {
  const FeaturedStoresSection({super.key});

  @override
  State<FeaturedStoresSection> createState() => _FeaturedStoresSectionState();
}

class _FeaturedStoresSectionState extends State<FeaturedStoresSection> {
  String _title = '';
  String _subtitle = '';
  List<_FeaturedStore> _stores = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await Get.find<ApiClient>().getData(AppConstants.featuredStoresUri, handleError: false);
    if (!mounted || r.statusCode != 200 || r.body is! Map || r.body['enabled'] != true) return;
    setState(() {
      _title = (r.body['title'] ?? '').toString();
      _subtitle = (r.body['subtitle'] ?? '').toString();
      _stores = ((r.body['stores'] as List?) ?? []).whereType<Map>().map((s) => _FeaturedStore.fromJson(Map<String, dynamic>.from(s))).toList();
    });
  }

  void _open(_FeaturedStore s) {
    final splash = Get.find<SplashController>();
    // The boutique belongs to a service (supermarket, pharmacy…): switch to it first.
    for (final ModuleModel m in splash.moduleList ?? const <ModuleModel>[]) {
      if (m.id == s.moduleId) {
        splash.setModule(m);
        break;
      }
    }
    final store = Store(id: s.id, name: s.name, moduleId: s.moduleId);
    Get.toNamed(RouteHelper.getStoreRoute(id: s.id, page: 'module'), arguments: StoreScreen(store: store, fromModule: true));
  }

  @override
  Widget build(BuildContext context) {
    if (_stores.isEmpty) return const SizedBox.shrink();
    final rows = _stores.length >= 3 ? 3 : _stores.length;
    final columns = (_stores.length / rows).ceil();
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width * 0.78;
    const cardHeight = 88.0;
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
          height: rows * cardHeight + (rows - 1) * 10,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: columns,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, col) => SizedBox(
              width: cardWidth,
              child: Column(children: [
                for (var row = 0; row < rows; row++)
                  if (col * rows + row < _stores.length) ...[
                    if (row > 0) const SizedBox(height: 10),
                    SizedBox(height: cardHeight, child: _card(_stores[col * rows + row])),
                  ],
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _card(_FeaturedStore s) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _open(s),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECECF0)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Stack(children: [
            Row(children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFECECF0)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(fit: StackFit.expand, children: [
                  Center(child: Text(s.name.isEmpty ? '?' : s.name[0], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _gold))),
                  if (s.logo != null && s.logo!.isNotEmpty) CustomImage(image: s.logo!, fit: BoxFit.cover),
                ]),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                    padding: EdgeInsets.only(right: s.label != null ? 54 : 0),
                    child: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s.open ? ['featured_open'.tr, if (s.deliveryTime != null && s.deliveryTime!.isNotEmpty) s.deliveryTime!].join(' · ') : 'featured_schedule'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: s.open ? const Color(0xFF16794A) : const Color(0xFF6E6E73)),
                  ),
                ]),
              ),
            ]),
            if (s.label != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(99)),
                  child: Text(s.label!, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
