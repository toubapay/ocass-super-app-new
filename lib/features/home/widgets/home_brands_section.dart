import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

const _gold = Color(0xFF9A7209);

class _Brand {
  final int id;
  final String name;
  final String? logo;
  final int? moduleId;
  final int count;
  final String? label = null;

  _Brand.fromJson(Map<String, dynamic> j)
      : id = (j['id'] as num).toInt(),
        name = (j['name'] ?? '').toString(),
        logo = j['image_full_url']?.toString(),
        moduleId = (j['module_id'] as num?)?.toInt(),
        count = (j['items_count'] as num?)?.toInt() ?? 0;
}

/// "Marques" on the home screen: the brands with the most products on sale,
/// as cards in a three-row grid scrolling sideways (same layout as "Boutiques
/// à la une"). Switched on/off in the admin (Admin > Boutiques à la une).
class HomeBrandsSection extends StatefulWidget {
  const HomeBrandsSection({super.key});

  @override
  State<HomeBrandsSection> createState() => _HomeBrandsSectionState();
}

class _HomeBrandsSectionState extends State<HomeBrandsSection> {
  String _title = '';
  String _subtitle = '';
  List<_Brand> _brands = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await Get.find<ApiClient>().getData(AppConstants.homeBrandsUri, handleError: false);
    if (!mounted || r.statusCode != 200 || r.body is! Map || r.body['enabled'] != true) return;
    setState(() {
      _title = (r.body['title'] ?? '').toString();
      _subtitle = (r.body['subtitle'] ?? '').toString();
      _brands = ((r.body['brands'] as List?) ?? []).whereType<Map>().map((s) => _Brand.fromJson(Map<String, dynamic>.from(s))).toList();
    });
  }

  void _open(_Brand s) {
    final splash = Get.find<SplashController>();
    // The brand's products are listed per service (beauty, shop…): switch to it first.
    for (final ModuleModel m in splash.moduleList ?? const <ModuleModel>[]) {
      if (m.id == s.moduleId) {
        splash.setModule(m);
        break;
      }
    }
    Get.toNamed(RouteHelper.getBrandsItemScreen(s.id, s.name));
  }

  @override
  Widget build(BuildContext context) {
    if (_brands.isEmpty) return const SizedBox.shrink();
    final rows = _brands.length >= 3 ? 3 : _brands.length;
    final columns = (_brands.length / rows).ceil();
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
                  if (col * rows + row < _brands.length) ...[
                    if (row > 0) const SizedBox(height: 10),
                    SizedBox(height: cardHeight, child: _card(_brands[col * rows + row])),
                  ],
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _card(_Brand s) {
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
                    (s.count == 1 ? 'home_brands_one' : 'home_brands_many').tr.replaceAll('{0}', '${s.count}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6E6E73)),
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
