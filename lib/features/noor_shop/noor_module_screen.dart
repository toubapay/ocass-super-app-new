import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/noor_shop/noor_catalog.dart';
import 'package:sixam_mart/features/noor_shop/noor_module_slides.dart';
import 'package:sixam_mart/features/noor_shop/noor_shop_widgets.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';

/// Inside a shop module (Supermarché, Restaurants, Pharmacie, Boutique), as
/// the web app's /boutique page (marcheocass/src/pages/Shop.jsx):
/// - green header with the module name, then the search box;
/// - the shop modules as chips (the current one in gold);
/// - two tabs: Produits, and Boutiques / Restaurants / Pharmacies / Magasins;
/// - in Produits, the round icons Tout, Populaires, Nouveautés then the
///   categories; "Tout" is the module home: Populaires, Nouveautés, the
///   offers (flash sale, offers, campaigns, brands), then one row per
///   category, each with its title and "Tout voir" above the products.
class NoorModuleScreen extends StatelessWidget {
  const NoorModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splash) {
      final module = splash.module;
      if (module == null) return const SizedBox.shrink();
      return _ModuleBody(key: ValueKey('noor-module-${module.id}'), module: module);
    });
  }
}

class _ModuleBody extends StatefulWidget {
  final ModuleModel module;
  const _ModuleBody({super.key, required this.module});

  @override
  State<_ModuleBody> createState() => _ModuleBodyState();
}

class _ModuleBodyState extends State<_ModuleBody> {
  bool _storesTab = false;
  // 'home' (the module home), 'popular', 'new' or a category id.
  String _rayon = 'home';
  List<Map<String, dynamic>> _categories = [];
  int _reload = 0;

  List<Item>? _items;
  List<Store>? _stores;
  String? _error;
  final _scroll = ScrollController();

  int get _moduleId => widget.module.id!;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final c = await NoorCatalog.categories(_moduleId);
      if (mounted) setState(() => _categories = c);
    } catch (_) {}
  }

  /// What the sellers of the module are called (as storeWords in Shop.jsx).
  ({String tab, String none}) get _storeWords {
    switch (widget.module.moduleType) {
      case 'food':
        return (tab: 'noor_restaurants'.tr, none: 'noor_no_restaurant'.tr);
      case 'pharmacy':
        return (tab: 'noor_pharmacies'.tr, none: 'noor_no_pharmacy'.tr);
      case 'grocery':
        return (tab: 'noor_markets'.tr, none: 'noor_no_market'.tr);
      default:
        return (tab: 'noor_shops'.tr, none: 'noor_no_shop'.tr);
    }
  }

  Future<void> _loadList() async {
    setState(() {
      _items = null;
      _stores = null;
      _error = null;
    });
    try {
      if (_storesTab) {
        _stores = await NoorCatalog.stores(_moduleId);
      } else if (_rayon == 'popular') {
        _items = await NoorCatalog.popular(_moduleId, limit: 30);
      } else if (_rayon == 'new') {
        _items = await NoorCatalog.newArrivals(_moduleId, limit: 30);
      } else if (_rayon != 'home') {
        _items = await NoorCatalog.categoryItems(_moduleId, int.parse(_rayon));
      }
    } catch (_) {
      _error = 'noor_load_error'.tr;
      _items ??= [];
      _stores ??= [];
    }
    if (mounted) setState(() {});
  }

  void _pickTab(bool stores) {
    if (stores == _storesTab) return;
    setState(() {
      _storesTab = stores;
      _rayon = 'home';
    });
    if (stores) _loadList();
  }

  void _pick(String rayon) {
    setState(() {
      _storesTab = false;
      _rayon = rayon;
    });
    if (rayon != 'home') _loadList();
    if (_scroll.hasClients) _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Future<void> _refresh() async {
    await _loadCategories();
    setState(() => _reload++);
    if (_storesTab || _rayon != 'home') await _loadList();
  }

  @override
  Widget build(BuildContext context) {
    final words = _storeWords;
    return Container(
      color: NoorShopColors.bg,
      child: Column(children: [
        _Header(module: widget.module),
        Expanded(
          child: RefreshIndicator(
            color: NoorShopColors.green,
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    // The module's slide show (admin: Module home slides manager).
                    NoorModuleSlides(moduleId: _moduleId, onCategory: (id) => _pick('$id')),
                    const _SearchBox(),
                    _ModuleChips(current: widget.module),
                    _Segmented(
                      labels: ['noor_products'.tr, words.tab],
                      index: _storesTab ? 1 : 0,
                      onPick: (i) => _pickTab(i == 1),
                    ),
                    if (!_storesTab) _CategoryIcons(categories: _categories, active: _rayon, onPick: _pick),
                  ]),
                ),
                SliverToBoxAdapter(child: _content(words.none, words.tab)),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _content(String noStore, String storesTitle) {
    if (!_storesTab && _rayon == 'home') {
      return _ModuleHome(key: ValueKey('home-$_reload'), moduleId: _moduleId, categories: _categories, onSeeAll: _pick);
    }
    final String title = _storesTab
        ? storesTitle
        : _rayon == 'popular'
            ? 'noor_popular'.tr
            : _rayon == 'new'
                ? 'noor_new'.tr
                : '${_categories.firstWhereOrNull((c) => '${c['id']}' == _rayon)?['name'] ?? ''}';

    final Widget body = _storesTab
        ? (_stores == null
            ? const NoorLoading()
            : _stores!.isEmpty
                ? NoorEmpty(title: noStore, text: 'noor_nothing_here'.tr)
                : Column(children: [for (final s in _stores!) NoorStoreCard(store: s)]))
        : (_items == null
            ? const NoorLoading()
            : _items!.isEmpty
                ? NoorEmpty(title: 'noor_no_product'.tr, text: 'noor_nothing_here'.tr)
                : NoorProductGrid(items: _items!));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (!_storesTab) NoorSectionHead(title: title),
      if (_storesTab) const SizedBox(height: 4),
      if (_error != null)
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(_error!, style: const TextStyle(color: Color(0xFFC62828)))),
      body,
    ]);
  }
}

/// Green page header (.page-header): back to the home screen, module name.
class _Header extends StatelessWidget {
  final ModuleModel module;
  const _Header({required this.module});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0B3D2E), NoorShopColors.green, Color(0xFF136B50)], stops: [0, 0.55, 1]),
      ),
      padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
      child: SizedBox(
        height: 52,
        child: Row(children: [
          IconButton(
            tooltip: 'noor_home'.tr,
            onPressed: () => Get.find<SplashController>().removeModule(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Expanded(
            child: Text(module.moduleName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
          ),
        ]),
      ),
    );
  }
}

/// White search box on the grey page (.search-box): opens the search screen.
class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(children: [
              const Icon(Icons.search, color: NoorShopColors.muted),
              const SizedBox(width: 8),
              Text('noor_search_product'.tr, style: const TextStyle(color: NoorShopColors.muted, fontSize: 16)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// The shop modules as chips (.chips): the current one in gold, scrolled
/// into view when the module opens.
class _ModuleChips extends StatefulWidget {
  final ModuleModel current;
  const _ModuleChips({required this.current});

  @override
  State<_ModuleChips> createState() => _ModuleChipsState();
}

class _ModuleChipsState extends State<_ModuleChips> {
  final _list = ScrollController();
  final _activeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chip = _activeKey.currentContext?.findRenderObject() as RenderBox?;
      final list = context.findRenderObject() as RenderBox?;
      if (chip == null || list == null || !_list.hasClients) return;
      final x = chip.localToGlobal(Offset.zero, ancestor: list).dx;
      final target = (_list.offset + x - 16).clamp(0.0, _list.position.maxScrollExtent);
      _list.jumpTo(target);
    });
  }

  @override
  void dispose() {
    _list.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.current;
    final splash = Get.find<SplashController>();
    final all = splash.moduleList ?? const <ModuleModel>[];
    final shops = [for (int i = 0; i < all.length; i++) if (isNoorShopModule(all[i])) (i, all[i])];
    if (shops.length < 2) return const SizedBox(height: 4);
    return SizedBox(
      height: 50,
      child: ListView.separated(
        controller: _list,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        itemCount: shops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, k) {
          final (index, m) = shops[k];
          final on = m.id == current.id;
          return Material(
            key: on ? _activeKey : null,
            color: on ? NoorShopColors.gold : Colors.white,
            shape: StadiumBorder(side: BorderSide(color: on ? NoorShopColors.gold : NoorShopColors.line)),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: on ? null : () => splash.switchModule(index, true),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Center(
                  child: Text(m.moduleName ?? '',
                      style: TextStyle(fontSize: 15.5, fontWeight: on ? FontWeight.w700 : FontWeight.w500, color: on ? const Color(0xFF2A1D00) : Colors.black87)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Two-part switch (.segmented): white active part, green text, gold line.
class _Segmented extends StatelessWidget {
  final List<String> labels;
  final int index;
  final void Function(int) onPick;
  const _Segmented({required this.labels, required this.index, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFE9E9EC), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        for (int i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onPick(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: i == index ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  border: i == index ? const Border(bottom: BorderSide(color: NoorShopColors.gold, width: 3)) : null,
                  boxShadow: i == index ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 3, offset: const Offset(0, 1))] : null,
                ),
                alignment: Alignment.center,
                child: Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: i == index ? NoorShopColors.green : const Color(0xFF555555))),
              ),
            ),
          ),
      ]),
    );
  }
}

/// Round icons scrolling sideways (CategoryIcons in the web app): Tout,
/// Populaires, Nouveautés, then the module's categories.
class _CategoryIcons extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String active;
  final void Function(String) onPick;
  const _CategoryIcons({required this.categories, required this.active, required this.onPick});

  static const _goldSoft = Color(0xFFF8EDCC);
  static const _goldDark = Color(0xFF6E500A);

  Widget _tile({required String key, required Widget icon, required String label, bool soft = false}) {
    final on = active == key;
    return InkWell(
      onTap: () => onPick(key),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 82,
        child: Column(children: [
          AnimatedScale(
            scale: on ? 1.04 : 1,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: soft ? _goldSoft : Colors.white,
                border: Border.all(color: on ? NoorShopColors.gold : Colors.transparent, width: 2.5),
                boxShadow: soft ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: icon,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, height: 1.2, fontWeight: on ? FontWeight.w700 : FontWeight.w400, color: on ? _goldDark : Colors.black87)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
        children: [
          _tile(key: 'home', icon: const Icon(Icons.grid_view_outlined, color: _goldDark, size: 26), label: 'noor_all'.tr),
          _tile(key: 'popular', icon: const Icon(Icons.local_fire_department_outlined, color: _goldDark, size: 26), label: 'noor_popular'.tr),
          _tile(key: 'new', icon: const Icon(Icons.auto_awesome_outlined, color: _goldDark, size: 26), label: 'noor_new'.tr),
          for (final c in categories)
            _tile(
              key: '${c['id']}',
              soft: true,
              icon: '${c['image_full_url'] ?? ''}'.isNotEmpty
                  ? CustomImage(image: '${c['image_full_url']}', width: 62, height: 62, fit: BoxFit.cover)
                  : Text('${c['name'] ?? '?'}'.characters.first.toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _goldDark)),
              label: '${c['name'] ?? ''}',
            ),
        ],
      ),
    );
  }
}

/// The module home, as in the web app: Populaires, Nouveautés, the offers
/// (flash sale, offers, campaigns, brands), then one row per category.
class _ModuleHome extends StatelessWidget {
  final int moduleId;
  final List<Map<String, dynamic>> categories;
  final void Function(String rayon) onSeeAll;
  const _ModuleHome({super.key, required this.moduleId, required this.categories, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      NoorProductRow(title: 'noor_popular'.tr, load: () => NoorCatalog.popular(moduleId), onSeeAll: () => onSeeAll('popular')),
      NoorProductRow(title: 'noor_new'.tr, load: () => NoorCatalog.newArrivals(moduleId), onSeeAll: () => onSeeAll('new')),
      _FlashSaleRow(moduleId: moduleId),
      NoorProductRow(title: 'noor_offers'.tr, load: () => NoorCatalog.itemCampaigns(moduleId), campaign: true),
      _CampaignRow(moduleId: moduleId),
      _BrandRow(moduleId: moduleId),
      for (final c in categories)
        NoorProductRow(
          key: ValueKey('cat-${c['id']}'),
          title: '${c['name'] ?? ''}',
          load: () => NoorCatalog.categoryItems(moduleId, c['id'] is int ? c['id'] : int.parse('${c['id']}'), limit: 10),
          onSeeAll: () => onSeeAll('${c['id']}'),
        ),
    ]);
  }
}

class _FlashSaleRow extends StatefulWidget {
  final int moduleId;
  const _FlashSaleRow({required this.moduleId});

  @override
  State<_FlashSaleRow> createState() => _FlashSaleRowState();
}

class _FlashSaleRowState extends State<_FlashSaleRow> {
  ({String? endDate, List<Item> items})? _flash;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    NoorCatalog.flashSale(widget.moduleId).then((f) {
      if (!mounted) return;
      setState(() => _flash = f);
      if (f.endDate != null) _tick = Timer.periodic(const Duration(seconds: 1), (_) => mounted ? setState(() {}) : null);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _left() {
    final end = DateTime.tryParse(_flash?.endDate ?? '');
    if (end == null) return '';
    final d = end.difference(DateTime.now());
    if (d.isNegative) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.inDays > 0 ? '${d.inDays}j ' : ''}${two(d.inHours % 24)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final f = _flash;
    if (f == null || f.items.isEmpty) return const SizedBox.shrink();
    final left = _left();
    return NoorProductRow(
      key: ValueKey('flash-${widget.moduleId}'),
      title: 'noor_flash_sale'.tr,
      leading: const Icon(Icons.bolt_rounded, color: Color(0xFFF5A623), size: 26),
      trailing: left.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFFF4E0), borderRadius: BorderRadius.circular(10)),
              child: Text(left, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFB26A00), fontFeatures: [FontFeature.tabularFigures()])),
            ),
      flash: true,
      load: () async => f.items,
    );
  }
}

class _CampaignRow extends StatefulWidget {
  final int moduleId;
  const _CampaignRow({required this.moduleId});

  @override
  State<_CampaignRow> createState() => _CampaignRowState();
}

class _CampaignRowState extends State<_CampaignRow> {
  List<Map<String, dynamic>> _campaigns = [];

  @override
  void initState() {
    super.initState();
    NoorCatalog.basicCampaigns(widget.moduleId).then((c) {
      if (mounted) setState(() => _campaigns = c);
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    if (_campaigns.isEmpty) return const SizedBox.shrink();
    final w = MediaQuery.sizeOf(context).width * 0.72;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      NoorSectionHead(title: 'noor_campaigns'.tr),
      SizedBox(
        height: w / 2 + 30,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _campaigns.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final c = _campaigns[i];
            return InkWell(
              onTap: () => Get.toNamed(RouteHelper.getBasicCampaignRoute(BasicCampaignModel.fromJson(c))),
              child: SizedBox(
                width: w,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(borderRadius: BorderRadius.circular(16), child: CustomImage(image: '${c['image_full_url'] ?? ''}', width: w, height: w / 2, fit: BoxFit.cover)),
                  const SizedBox(height: 5),
                  Text('${c['title'] ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class _BrandRow extends StatefulWidget {
  final int moduleId;
  const _BrandRow({required this.moduleId});

  @override
  State<_BrandRow> createState() => _BrandRowState();
}

class _BrandRowState extends State<_BrandRow> {
  List<Map<String, dynamic>> _brands = [];

  @override
  void initState() {
    super.initState();
    NoorCatalog.brands(widget.moduleId).then((b) {
      if (mounted) setState(() => _brands = b);
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    if (_brands.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      NoorSectionHead(title: 'noor_brands'.tr),
      SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _brands.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _BrandTile(brand: _brands[i], size: 68),
        ),
      ),
    ]);
  }
}

class _BrandTile extends StatelessWidget {
  final Map<String, dynamic> brand;
  final double size;
  const _BrandTile({required this.brand, required this.size});

  @override
  Widget build(BuildContext context) {
    final id = brand['id'] is int ? brand['id'] as int : int.tryParse('${brand['id']}') ?? 0;
    final name = '${brand['name'] ?? ''}';
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => NoorCatalog.openBrand(id, name),
      child: SizedBox(
        width: size + 10,
        child: Column(children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: NoorShopColors.line)),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(6),
            child: '${brand['image_full_url'] ?? ''}'.isNotEmpty
                ? CustomImage(image: '${brand['image_full_url']}', fit: BoxFit.contain)
                : Center(child: Text(name.isEmpty ? '?' : name.characters.first.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: NoorShopColors.gold))),
          ),
          const SizedBox(height: 5),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
