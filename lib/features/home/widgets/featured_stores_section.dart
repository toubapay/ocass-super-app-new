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

const _gold = Color(0xFFB8901F);

class _FeaturedStore {
  final int id;
  final String name;
  final String? logo;
  final String? cover;
  final int? moduleId;
  final bool open;
  final String? deliveryTime;
  final String? label;

  _FeaturedStore.fromJson(Map<String, dynamic> j)
      : id = (j['id'] as num).toInt(),
        name = (j['name'] ?? '').toString(),
        logo = j['logo_full_url']?.toString(),
        cover = j['cover_photo_full_url']?.toString(),
        moduleId = (j['module_id'] as num?)?.toInt(),
        open = j['open'] == true,
        deliveryTime = j['delivery_time']?.toString(),
        label = (j['label'] ?? '').toString().trim().isEmpty ? null : j['label'].toString();
}

/// "Boutiques à la une" on the home screen, right after the services: the
/// stores picked on the admin's "Boutiques à la une" page plus every store
/// switched to "Featured" in the admin store list. One row of three cards
/// (swipe for more); "Voir tout" shows them all, three per row.
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
    return LayoutBuilder(builder: (context, box) {
      const gap = 10.0;
      final cardWidth = (box.maxWidth - 32 - 2 * gap) / 3;
      return Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(border: Border(left: BorderSide(color: _gold, width: 4))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, height: 1.15)),
                    if (_subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(_subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ),
                  ]),
                ),
              ),
              if (_stores.length > 3)
                TextButton(
                  onPressed: () => Get.to(() => _FeaturedAllScreen(title: _title, stores: _stores, onOpen: _open)),
                  child: Text('${'view_all'.tr.capitalizeFirst} ›', style: const TextStyle(color: _green, fontWeight: FontWeight.w700)),
                ),
            ]),
          ),
          SizedBox(
            height: _FeaturedCard.height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _stores.length,
              separatorBuilder: (_, __) => const SizedBox(width: gap),
              itemBuilder: (_, i) => SizedBox(width: cardWidth, child: _FeaturedCard(store: _stores[i], onTap: () => _open(_stores[i]))),
            ),
          ),
        ]),
      );
    });
  }
}

const _green = Color(0xFF0E4D3A);

/// One store: cover photo (or the Noor green-gold gradient), round logo,
/// name, open/closed and the admin's badge.
class _FeaturedCard extends StatelessWidget {
  static const height = 168.0;
  final _FeaturedStore store;
  final VoidCallback onTap;
  const _FeaturedCard({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = store;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.10), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(children: [
            SizedBox(
              height: 92,
              child: Stack(clipBehavior: Clip.none, children: [
                Positioned.fill(
                  bottom: 18,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [_green, Color(0xFF1D7A5C), _gold], stops: [0, 0.6, 1], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                    child: s.cover != null && s.cover!.isNotEmpty ? CustomImage(image: s.cover!, fit: BoxFit.cover) : null,
                  ),
                ),
                if (s.label != null)
                  Positioned(
                    top: 6,
                    left: 6,
                    right: 6,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF97731A), Color(0xFFC9A23C), Color(0xFF86650F)]),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(s.label!, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800, shadows: [Shadow(color: Color(0x59000000), blurRadius: 1, offset: Offset(0, 1))])),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 4, offset: const Offset(0, 1))],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(fit: StackFit.expand, children: [
                        Center(child: Text(s.name.isEmpty ? '?' : s.name[0].toUpperCase(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _green))),
                        if (s.logo != null && s.logo!.isNotEmpty) CustomImage(image: s.logo!, fit: BoxFit.cover),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 5, 6, 8),
                child: Column(children: [
                  SizedBox(
                    height: 32,
                    child: Text(s.name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, height: 1.2)),
                  ),
                  const Spacer(),
                  Text(s.open ? 'featured_open'.tr : 'new_stores_closed'.tr,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: s.open ? const Color(0xFF15803D) : const Color(0xFF9CA3AF))),
                  Text(
                    s.open ? (s.deliveryTime ?? '') : 'featured_schedule'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// "Voir tout": every featured store, three per row.
class _FeaturedAllScreen extends StatelessWidget {
  final String title;
  final List<_FeaturedStore> stores;
  final void Function(_FeaturedStore) onOpen;
  const _FeaturedAllScreen({required this.title, required this.stores, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F4),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: _green,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: stores.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: _FeaturedCard.height,
        ),
        itemBuilder: (_, i) => _FeaturedCard(store: stores[i], onTap: () => onOpen(stores[i])),
      ),
    );
  }
}
