import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

const _gold = Color(0xFFB8901F);

class _Brand {
  final int id;
  final String name;
  final String? logo;
  final int? moduleId;
  final int count;

  _Brand.fromJson(Map<String, dynamic> j)
      : id = (j['id'] as num).toInt(),
        name = (j['name'] ?? '').toString(),
        logo = j['image_full_url']?.toString(),
        moduleId = (j['module_id'] as num?)?.toInt(),
        count = (j['items_count'] as num?)?.toInt() ?? 0;
}

/// "Marques" on the home screen: 25 brands (most products on sale first) in
/// two rows of three cards scrolling sideways, with "Voir tout ›" to every
/// brand, three per row. Switched on/off in the admin (Admin > Boutiques à
/// la une).
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
    return LayoutBuilder(builder: (context, box) {
      const gap = 10.0;
      final cardWidth = (box.maxWidth - 32 - 2 * gap) / 3;
      final rows = _brands.length > 3 ? 2 : 1;
      final columns = (_brands.length / rows).ceil();
      return Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
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
              TextButton(
                onPressed: () => Get.to(() => _BrandsAllScreen(title: _title, onOpen: _open)),
                child: Text('${'view_all'.tr.capitalizeFirst} ›', style: const TextStyle(color: _green, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          SizedBox(
            height: rows * _BrandCard.height + (rows - 1) * gap,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: columns,
              separatorBuilder: (_, __) => const SizedBox(width: gap),
              itemBuilder: (_, col) => SizedBox(
                width: cardWidth,
                child: Column(children: [
                  for (var row = 0; row < rows; row++)
                    if (col * rows + row < _brands.length) ...[
                      if (row > 0) const SizedBox(height: gap),
                      SizedBox(height: _BrandCard.height, child: _BrandCard(brand: _brands[col * rows + row], onTap: () => _open(_brands[col * rows + row]))),
                    ],
                ]),
              ),
            ),
          ),
        ]),
      );
    });
  }
}

const _green = Color(0xFF0E4D3A);

/// One brand: its logo on a light gold tile, name and number of products.
class _BrandCard extends StatelessWidget {
  static const height = 136.0;
  final _Brand brand;
  final VoidCallback onTap;
  const _BrandCard({required this.brand, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = brand;
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Column(children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFBF6E6), Color(0xFFF3EAD0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEFE3BF)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(fit: StackFit.expand, children: [
                    Center(child: Text(s.name.isEmpty ? '?' : s.name[0].toUpperCase(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _gold))),
                    if (s.logo != null && s.logo!.isNotEmpty)
                      Padding(padding: const EdgeInsets.all(8), child: CustomImage(image: s.logo!, fit: BoxFit.contain)),
                  ]),
                ),
              ),
              const SizedBox(height: 6),
              Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(
                s.count > 0 ? (s.count == 1 ? 'home_brands_one' : 'home_brands_many').tr.replaceAll('{0}', '${s.count}') : 'home_brands_discover'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// "Voir tout": every brand, three per row.
class _BrandsAllScreen extends StatefulWidget {
  final String title;
  final void Function(_Brand) onOpen;
  const _BrandsAllScreen({required this.title, required this.onOpen});

  @override
  State<_BrandsAllScreen> createState() => _BrandsAllScreenState();
}

class _BrandsAllScreenState extends State<_BrandsAllScreen> {
  List<_Brand>? _brands;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await Get.find<ApiClient>().getData('${AppConstants.homeBrandsUri}?all=1', handleError: false);
    if (!mounted) return;
    setState(() {
      _brands = r.statusCode == 200 && r.body is Map
          ? ((r.body['brands'] as List?) ?? []).whereType<Map>().map((s) => _Brand.fromJson(Map<String, dynamic>.from(s))).toList()
          : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final brands = _brands;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F4),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: _green,
        foregroundColor: Colors.white,
      ),
      body: brands == null
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: brands.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: _BrandCard.height,
              ),
              itemBuilder: (_, i) => _BrandCard(brand: brands[i], onTap: () => widget.onOpen(brands[i])),
            ),
    );
  }
}
