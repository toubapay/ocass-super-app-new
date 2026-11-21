import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/cart_widget.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/noor_shop/noor_catalog.dart';
import 'package:sixam_mart/features/noor_shop/noor_shop_widgets.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/service_icon_helper.dart';

/// Inside a shop module (Supermarché, Restaurants, Pharmacie, Boutique), as
/// the web app's /boutique page:
/// - the other modules at the top, to jump from one to another;
/// - tabs: Produits, Boutiques (Restaurants, Pharmacies...), Populaires,
///   Nouveautés, Marques;
/// - in Produits, the categories as round pictures, then the module home:
///   Populaires, Nouveautés, the offers (flash sale, campaigns), then one
///   row per category. A category opens its products.
class NoorModuleScreen extends StatelessWidget {
  const NoorModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splash) {
      final module = splash.module;
      if (module == null) return const SizedBox.shrink();
      // A fresh state (tab, category, lists) for each module.
      return _ModuleBody(key: ValueKey('noor-module-${module.id}'), module: module);
    });
  }
}

enum _Tab { products, stores, popular, news, brands }

class _ModuleBody extends StatefulWidget {
  final ModuleModel module;
  const _ModuleBody({super.key, required this.module});

  @override
  State<_ModuleBody> createState() => _ModuleBodyState();
}

class _ModuleBodyState extends State<_ModuleBody> {
  _Tab _tab = _Tab.products;
  // null = the module home; otherwise the id of the category shown.
  int? _categoryId;
  List<Map<String, dynamic>> _categories = [];
  int _reload = 0;

  // Lists of the other tabs and of an opened category.
  List<Item>? _items;
  List<Store>? _stores;
  List<Map<String, dynamic>>? _brands;
  String? _error;

  int get _moduleId => widget.module.id!;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final c = await NoorCatalog.categories(_moduleId);
      if (mounted) setState(() => _categories = c);
    } catch (_) {}
  }

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
      _brands = null;
      _error = null;
    });
    try {
      switch (_tab) {
        case _Tab.products:
          if (_categoryId != null) _items = await NoorCatalog.categoryItems(_moduleId, _categoryId!);
          break;
        case _Tab.stores:
          _stores = await NoorCatalog.stores(_moduleId);
          break;
        case _Tab.popular:
          _items = await NoorCatalog.popular(_moduleId, limit: 30);
          break;
        case _Tab.news:
          _items = await NoorCatalog.newArrivals(_moduleId, limit: 30);
          break;
        case _Tab.brands:
          _brands = await NoorCatalog.brands(_moduleId);
          break;
      }
    } catch (e) {
      _error = 'noor_load_error'.tr;
      _items ??= [];
      _stores ??= [];
      _brands ??= [];
    }
    if (mounted) setState(() {});
  }

  void _pickTab(_Tab t) {
    if (t == _tab && t != _Tab.products) return;
    setState(() {
      _tab = t;
      _categoryId = null;
    });
    if (t != _Tab.products) _loadList();
  }

  void _pickCategory(int? id) {
    setState(() {
      _tab = _Tab.products;
      _categoryId = id;
    });
    if (id != null) _loadList();
  }

  Future<void> _refresh() async {
    await _loadCategories();
    setState(() => _reload++);
    if (_tab != _Tab.products || _categoryId != null) await _loadList();
  }

  @override
  Widget build(BuildContext context) {
    final words = _storeWords;
    final tabs = <(_Tab, String)>[
      (_Tab.products, 'noor_products'.tr),
      (_Tab.stores, words.tab),
      (_Tab.popular, 'noor_popular'.tr),
      (_Tab.news, 'noor_new'.tr),
      (_Tab.brands, 'noor_brands'.tr),
    ];
    return Container(
      color: NoorShopColors.bg,
      child: RefreshIndicator(
        color: NoorShopColors.green,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Header(module: widget.module)),
            SliverToBoxAdapter(child: _ModuleNav(current: widget.module)),
            SliverPersistentHeader(pinned: true, delegate: _TabsDelegate(tabs: tabs, current: _tab, onPick: _pickTab)),
            if (_tab == _Tab.products) SliverToBoxAdapter(child: _CategoryIcons(categories: _categories, active: _categoryId, onPick: _pickCategory)),
            SliverToBoxAdapter(child: _content(words.none)),
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }

  Widget _content(String noStore) {
    if (_tab == _Tab.products && _categoryId == null) {
      return _ModuleHome(
        key: ValueKey('home-$_reload'),
        moduleId: _moduleId,
        categories: _categories,
        onSeeAll: (key) {
          if (key == 'popular') {
            _pickTab(_Tab.popular);
          } else if (key == 'new') {
            _pickTab(_Tab.news);
          } else if (key == 'brands') {
            _pickTab(_Tab.brands);
          } else {
            _pickCategory(int.tryParse(key));
          }
        },
      );
    }

    String title;
    switch (_tab) {
      case _Tab.popular:
        title = 'noor_popular'.tr;
        break;
      case _Tab.news:
        title = 'noor_new'.tr;
        break;
      case _Tab.stores:
        title = _storeWords.tab;
        break;
      case _Tab.brands:
        title = 'noor_brands'.tr;
        break;
      case _Tab.products:
        title = '${_categories.firstWhereOrNull((c) => c['id'] == _categoryId)?['name'] ?? ''}';
    }

    Widget body;
    if (_tab == _Tab.stores) {
      body = _stores == null
          ? const NoorLoading()
          : _stores!.isEmpty
              ? NoorEmpty(title: noStore, text: 'noor_nothing_here'.tr)
              : Column(children: [for (final s in _stores!) NoorStoreCard(store: s)]);
    } else if (_tab == _Tab.brands) {
      body = _brands == null
          ? const NoorLoading()
          : _brands!.isEmpty
              ? NoorEmpty(title: 'noor_no_brand'.tr)
              : _BrandGrid(brands: _brands!);
    } else {
      body = _items == null
          ? const NoorLoading()
          : _items!.isEmpty
              ? NoorEmpty(title: 'noor_no_product'.tr, text: 'noor_nothing_here'.tr)
              : NoorProductGrid(items: _items!);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      NoorSectionHead(title: title),
      if (_error != null)
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(_error!, style: const TextStyle(color: Color(0xFFC62828)))),
      body,
    ]);
  }
}

/// Green header: back to the home screen, module name, cart, search box.
class _Header extends StatelessWidget {
  final ModuleModel module;
  const _Header({required this.module});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NoorShopColors.green,
      padding: EdgeInsets.fromLTRB(6, MediaQuery.paddingOf(context).top > 0 ? 4 : 8, 10, 14),
      child: Column(children: [
        Row(children: [
          IconButton(
            tooltip: 'noor_home'.tr,
            onPressed: () => Get.find<SplashController>().removeModule(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Expanded(
            child: Text(module.moduleName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          IconButton(
            onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
            icon: const CartWidget(color: Colors.white, size: 24),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 0, 0),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(children: [
                  const Icon(Icons.search, color: NoorShopColors.muted),
                  const SizedBox(width: 8),
                  Text('noor_search_product'.tr, style: const TextStyle(color: NoorShopColors.muted, fontSize: 15)),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/// The shop modules at the top of each module: one tap to change module.
class _ModuleNav extends StatelessWidget {
  final ModuleModel current;
  const _ModuleNav({required this.current});

  @override
  Widget build(BuildContext context) {
    final splash = Get.find<SplashController>();
    final all = splash.moduleList ?? const <ModuleModel>[];
    final shops = [for (int i = 0; i < all.length; i++) if (isNoorShopModule(all[i])) (i, all[i])];
    if (shops.length < 2) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        itemCount: shops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, k) {
          final (index, m) = shops[k];
          final on = m.id == current.id;
          final icon = ServiceIcons.forModule(m);
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: on ? null : () => splash.switchModule(index, true),
            child: Container(
              width: 82,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: on ? const Color(0xFFEAF3EF) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: on ? NoorShopColors.green : Colors.transparent, width: 1.5),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: icon != null ? SvgPicture.asset(icon) : CustomImage(image: m.iconFullUrl ?? '', fit: BoxFit.contain),
                ),
                const SizedBox(height: 3),
                Text(m.moduleName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: on ? FontWeight.w800 : FontWeight.w600, color: on ? NoorShopColors.green : Colors.black87)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _TabsDelegate extends SliverPersistentHeaderDelegate {
  final List<(_Tab, String)> tabs;
  final _Tab current;
  final void Function(_Tab) onPick;
  _TabsDelegate({required this.tabs, required this.current, required this.onPick});

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(children: [
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            children: [
              for (final (t, label) in tabs)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: t == current,
                    showCheckmark: false,
                    onSelected: (_) => onPick(t),
                    selectedColor: NoorShopColors.green,
                    backgroundColor: const Color(0xFFF1F4F3),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, color: t == current ? Colors.white : Colors.black87),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: NoorShopColors.line),
      ]),
    );
  }

  @override
  bool shouldRebuild(_TabsDelegate old) => old.current != current || old.tabs.length != tabs.length || old.tabs.first.$2 != tabs.first.$2;
}

/// The categories as small round pictures scrolling sideways ("Tout" first),
/// as CategoryIcons in the web app.
class _CategoryIcons extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int? active;
  final void Function(int?) onPick;
  const _CategoryIcons({required this.categories, required this.active, required this.onPick});

  Widget _tile({required bool on, required Widget icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 74,
        child: Column(children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: on ? NoorShopColors.green : NoorShopColors.line, width: on ? 2.2 : 1),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(height: 5),
          Text(label, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, height: 1.15, fontWeight: on ? FontWeight.w800 : FontWeight.w600, color: on ? NoorShopColors.green : Colors.black87)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox(height: 6);
    return SizedBox(
      height: 112,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
        children: [
          _tile(on: active == null, icon: const Icon(Icons.grid_view_rounded, color: NoorShopColors.green), label: 'noor_all'.tr, onTap: () => onPick(null)),
          for (final c in categories)
            _tile(
              on: active == c['id'],
              icon: '${c['image_full_url'] ?? ''}'.isNotEmpty
                  ? CustomImage(image: '${c['image_full_url']}', width: 58, height: 58, fit: BoxFit.cover)
                  : Text('${c['name'] ?? '?'}'.characters.first.toUpperCase(),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: NoorShopColors.gold)),
              label: '${c['name'] ?? ''}',
              onTap: () => onPick(c['id'] is int ? c['id'] : int.tryParse('${c['id']}')),
            ),
        ],
      ),
    );
  }
}

/// The module home, as in the web app: Populaires, Nouveautés, the offers,
/// then one row per category.
class _ModuleHome extends StatelessWidget {
  final int moduleId;
  final List<Map<String, dynamic>> categories;
  final void Function(String key) onSeeAll;
  const _ModuleHome({super.key, required this.moduleId, required this.categories, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      NoorBannerSlider(moduleId: moduleId),
      NoorProductRow(title: 'noor_popular'.tr, load: () => NoorCatalog.popular(moduleId), onSeeAll: () => onSeeAll('popular')),
      NoorProductRow(title: 'noor_new'.tr, load: () => NoorCatalog.newArrivals(moduleId), onSeeAll: () => onSeeAll('new')),
      _FlashSaleRow(moduleId: moduleId),
      NoorProductRow(title: 'noor_offers'.tr, load: () => NoorCatalog.itemCampaigns(moduleId), campaign: true),
      _CampaignRow(moduleId: moduleId),
      _BrandRow(moduleId: moduleId, onSeeAll: () => onSeeAll('brands')),
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
  final VoidCallback onSeeAll;
  const _BrandRow({required this.moduleId, required this.onSeeAll});

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
      NoorSectionHead(title: 'noor_brands'.tr, onSeeAll: widget.onSeeAll),
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

class _BrandGrid extends StatelessWidget {
  final List<Map<String, dynamic>> brands;
  const _BrandGrid({required this.brands});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: brands.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 10, childAspectRatio: 0.85),
      itemBuilder: (_, i) => _BrandTile(brand: brands[i], size: 78),
    );
  }
}
