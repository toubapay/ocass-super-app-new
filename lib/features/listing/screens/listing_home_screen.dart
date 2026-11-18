import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/listing/listing_api.dart';
import 'package:sixam_mart/features/listing/screens/listing_detail_screen.dart';
import 'package:sixam_mart/features/listing/screens/listing_messages_screen.dart';
import 'package:sixam_mart/features/listing/screens/listing_mine_screen.dart';
import 'package:sixam_mart/features/listing/screens/listing_post_screen.dart';
import 'package:sixam_mart/features/listing/widgets/listing_ui.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/styles.dart';

/// Noor Annonces: browse (Produits), categories (Catégories) and sell
/// (Publier), the same bottom bar as the /listing/ web app.
class ListingHomeScreen extends StatefulWidget {
  const ListingHomeScreen({super.key});

  @override
  State<ListingHomeScreen> createState() => _ListingHomeScreenState();
}

class _ListingHomeScreenState extends State<ListingHomeScreen> {
  int _tab = 1; // 0 categories, 1 products
  ListingConfig? _config;
  bool _loading = true;
  int _unread = 0;
  final _products = GlobalKey<ListingBrowseState>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await ListingConfig.load();
    if (!mounted) return;
    setState(() {
      _config = c;
      _loading = false;
    });
    _refreshUnread();
  }

  Future<void> _refreshUnread() async {
    if (!AuthHelper.isLoggedIn()) return;
    final r = await ListingApi.me();
    if (mounted && r.statusCode == 200 && r.body is Map) setState(() => _unread = (r.body['unread'] ?? 0) as int);
  }

  void _openCategory(ListingCategory c) {
    Get.to(() => Scaffold(
          backgroundColor: LColors.bg,
          appBar: ListingBar(title: '${c.icon} ${c.name}'),
          body: ListingBrowse(config: _config, categoryId: c.id),
        ));
  }

  Future<void> _post() async {
    await Get.to(() => const ListingPostScreen());
    _products.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(backgroundColor: LColors.bg, body: Center(child: CircularProgressIndicator(color: LColors.green)));
    }
    if (_config != null && !_config!.status) {
      return Scaffold(
        appBar: ListingBar(title: 'lst_title'.tr),
        body: ListingEmpty(emoji: '🛑', text: 'lst_closed'.tr),
      );
    }

    return Scaffold(
      backgroundColor: LColors.bg,
      appBar: ListingBar(
        title: _tab == 0 ? 'lst_categories'.tr : 'lst_title'.tr,
        actions: [
          ListingIconButton(
            icon: Icons.chat_bubble_outline,
            tooltip: 'lst_messages'.tr,
            badge: _unread,
            onTap: () async {
              await Get.to(() => const ListingMessagesScreen());
              _refreshUnread();
            },
          ),
          ListingIconButton(icon: Icons.person_outline, tooltip: 'lst_my_listings'.tr, onTap: () => Get.to(() => const ListingMineScreen())),
        ],
      ),
      body: IndexedStack(index: _tab, children: [
        _Categories(config: _config, onTap: _openCategory),
        ListingBrowse(key: _products, config: _config, showTabs: true),
      ]),
      bottomNavigationBar: _BottomBar(
        tab: _tab,
        onPost: _post,
        onTab: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int tab;
  final VoidCallback onPost;
  final ValueChanged<int> onTab;
  const _BottomBar({required this.tab, required this.onPost, required this.onTab});

  @override
  Widget build(BuildContext context) {
    Widget item(int i, IconData icon, String label) => Expanded(
          child: InkWell(
            onTap: () => onTab(i),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: tab == i ? LColors.green : LColors.muted, size: 24),
              const SizedBox(height: 3),
              Text(label, style: robotoBold.copyWith(fontSize: 11.5, color: tab == i ? LColors.green : LColors.muted)),
            ]),
          ),
        );
    return Container(
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: LColors.line))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(children: [
            Expanded(
              child: InkWell(
                onTap: onPost,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LColors.goldGradient,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: LColors.goldDark.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 2),
                  Text('lst_post'.tr, style: robotoBold.copyWith(fontSize: 11.5, color: LColors.muted)),
                ]),
              ),
            ),
            item(0, Icons.grid_view_rounded, 'lst_categories'.tr),
            item(1, Icons.sell_outlined, 'lst_products'.tr),
          ]),
        ),
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  final ListingConfig? config;
  final ValueChanged<ListingCategory> onTap;
  const _Categories({required this.config, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cats = config?.categories ?? [];
    if (cats.isEmpty) return ListingEmpty(emoji: '📦', text: 'lst_no_category'.tr);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.95),
      itemCount: cats.length,
      itemBuilder: (_, i) {
        final c = cats[i];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onTap(c),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: LColors.line), borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(8),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(c.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 6),
                Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: 13)),
                Text('lst_count'.trParams({'n': '${c.count}'}), style: robotoRegular.copyWith(fontSize: 11.5, color: LColors.muted)),
              ]),
            ),
          ),
        );
      },
    );
  }
}

/// The listings grid with search, sort (récents, plus vus, près de moi) and
/// category chips. Also used for one category or one seller.
class ListingBrowse extends StatefulWidget {
  final ListingConfig? config;
  final int? categoryId;
  final String? seller;
  final bool showTabs;
  const ListingBrowse({super.key, this.config, this.categoryId, this.seller, this.showTabs = false});

  @override
  State<ListingBrowse> createState() => ListingBrowseState();
}

class ListingBrowseState extends State<ListingBrowse> {
  static const _page = 20;
  String _sort = 'recent';
  int? _category;
  String _q = '';
  final _search = TextEditingController();
  List<ListingItem>? _items;
  List<ListingItem> _featured = [];
  int _total = 0;
  String? _error;
  bool _more = false;
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _category = widget.categoryId;
    final address = AddressHelper.getUserAddressFromSharedPref();
    _lat = double.tryParse(address?.latitude ?? '');
    _lng = double.tryParse(address?.longitude ?? '');
    reload();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // The grid never shows boosted listings: they have their own row on top.
  Map<String, dynamic> _query(int offset, {bool featured = false}) => {
        'featured': featured ? 1 : 0,
        'sort': _sort,
        'category': _category,
        'q': _q,
        'seller': widget.seller,
        'lat': _lat,
        'lng': _lng,
        'limit': _page,
        'offset': offset,
      };

  Future<void> reload() async {
    setState(() {
      _items = null;
      _error = null;
    });
    if (_sort == 'nearby') {
      final ok = await _locate();
      if (!ok) {
        if (mounted) setState(() => _error = 'lst_location_needed'.tr);
        return;
      }
    }
    final results = await Future.wait([ListingApi.items(_query(0)), ListingApi.items({..._query(0, featured: true), 'limit': 12})]);
    final r = results[0];
    final f = results[1];
    if (!mounted) return;
    setState(() {
      _featured = f.statusCode == 200 && f.body is Map ? [for (final j in f.body['items'] ?? []) ListingItem.fromJson(j)] : [];
      if (r.statusCode == 200 && r.body is Map) {
        _items = [for (final j in r.body['items'] ?? []) ListingItem.fromJson(j)];
        _total = r.body['total'] ?? 0;
      } else {
        _error = ListingApi.error(r);
      }
    });
  }

  Future<void> _loadMore() async {
    setState(() => _more = true);
    final r = await ListingApi.items(_query(_items!.length));
    if (!mounted) return;
    setState(() {
      _more = false;
      if (r.statusCode == 200 && r.body is Map) _items!.addAll([for (final j in r.body['items'] ?? []) ListingItem.fromJson(j)]);
    });
  }

  Future<bool> _locate() async {
    try {
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) return _lat != null;
      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 10)));
      _lat = pos.latitude;
      _lng = pos.longitude;
      return true;
    } catch (_) {
      return _lat != null;
    }
  }

  void _set(VoidCallback change) {
    setState(change);
    reload();
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.config?.categories ?? [];
    return RefreshIndicator(
      color: LColors.green,
      onRefresh: reload,
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: (v) => _set(() => _q = v.trim()),
                decoration: InputDecoration(
                  hintText: 'lst_search_hint'.tr,
                  prefixIcon: const Icon(Icons.search, color: LColors.muted),
                  suffixIcon: _q.isEmpty
                      ? null
                      : IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () {
                          _search.clear();
                          _set(() => _q = '');
                        }),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: LColors.line)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: LColors.line)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: LColors.green)),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (final s in [['recent', 'lst_recent'], ['popular', 'lst_popular'], ['nearby', 'lst_nearby']])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(s[1].tr),
                        selected: _sort == s[0],
                        onSelected: (_) => _set(() => _sort = s[0]),
                        selectedColor: LColors.green,
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                        side: const BorderSide(color: LColors.line),
                        labelStyle: robotoBold.copyWith(fontSize: 13, color: _sort == s[0] ? Colors.white : Colors.black87),
                        shape: const StadiumBorder(),
                      ),
                    ),
                ]),
              ),
              if (widget.showTabs && cats.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 84,
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                    _chip('✨', 'lst_all'.tr, _category == null, () => _set(() => _category = null)),
                    for (final c in cats) _chip(c.icon, c.name, _category == c.id, () => _set(() => _category = c.id)),
                  ]),
                ),
              ],
              if (_q.isNotEmpty || widget.seller != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${_q.isNotEmpty ? '« $_q » · ' : ''}${'lst_count'.trParams({'n': '$_total'})}',
                    style: robotoBold.copyWith(color: LColors.green, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 10),
            ]),
          ),
        ),
        if (_featured.isNotEmpty && _error == null)
          SliverToBoxAdapter(
            child: _FeaturedRow(items: _featured, onTap: (it) => Get.to(() => ListingDetailScreen(id: it.id, config: widget.config))),
          ),
        if (_featured.isNotEmpty && (_items?.isNotEmpty ?? false))
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Text('lst_all_listings'.tr, style: robotoBold.copyWith(fontSize: 15)),
            ),
          ),
        if (_error != null)
          SliverToBoxAdapter(child: ListingEmpty(emoji: '📍', text: _error!))
        else if (_items == null)
          const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: LColors.green))))
        else if (_items!.isEmpty && _featured.isEmpty)
          SliverToBoxAdapter(child: ListingEmpty(emoji: '🔎', text: _sort == 'nearby' ? 'lst_none_nearby'.tr : 'lst_none'.tr))
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 220, mainAxisSpacing: 11, crossAxisSpacing: 11, childAspectRatio: 0.7),
              delegate: SliverChildBuilderDelegate(
                (_, i) => ListingCard(
                  item: _items![i],
                  onTap: () => Get.to(() => ListingDetailScreen(id: _items![i].id, config: widget.config)),
                ),
                childCount: _items!.length,
              ),
            ),
          ),
        if (_items != null && _items!.length < _total)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListingButton(text: _more ? 'lst_loading'.tr : 'lst_see_more'.tr, style: 'outline', busy: _more, onTap: _loadMore),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ]),
    );
  }

  Widget _chip(String icon, String label, bool on, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 72,
          margin: const EdgeInsets.only(right: 6),
          child: Column(children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? LColors.cream : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: on ? LColors.gold : LColors.line, width: on ? 2 : 1),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 25)),
            ),
            const SizedBox(height: 4),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: 11)),
          ]),
        ),
      );
}

/// "À la une": the paid, boosted listings, apart at the top with big photos.
class _FeaturedRow extends StatelessWidget {
  final List<ListingItem> items;
  final ValueChanged<ListingItem> onTap;
  const _FeaturedRow({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width * 0.64).clamp(200.0, 260.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.only(top: 14, bottom: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [LColors.cream, Color(0x00FBF3DC)]),
        border: Border(top: BorderSide(color: Color(0xFFF0E2B6))),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(children: [
            const Icon(Icons.star_rounded, color: LColors.goldDark, size: 20),
            const SizedBox(width: 4),
            Text('lst_featured'.tr, style: robotoBold.copyWith(fontSize: 17, color: LColors.goldDark)),
            const Spacer(),
            Text('lst_count'.trParams({'n': '${items.length}'}), style: robotoMedium.copyWith(fontSize: 12, color: LColors.muted)),
          ]),
        ),
        SizedBox(
          height: width * 3 / 4 + 62,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _FeaturedCard(item: items[i], width: width, onTap: () => onTap(items[i])),
          ),
        ),
      ]),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final ListingItem item;
  final double width;
  final VoidCallback onTap;
  const _FeaturedCard({required this.item, required this.width, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final where = listingKm(item.distanceKm) ?? item.city ?? item.category?.name ?? '';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [LColors.goldDark, LColors.goldLight, LColors.goldDark]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: LColors.goldDark.withValues(alpha: 0.18), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.white,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(fit: StackFit.expand, children: [
                  Container(color: const Color(0xFFF3ECD8)),
                  if (item.image != null) CustomImage(image: item.image!, fit: BoxFit.cover),
                  Positioned(left: 8, top: 8, child: ListingPill(text: '★ ${'lst_featured'.tr}', gold: true)),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: LColors.greenDark.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(10)),
                      child: Text(listingMoney(item.price), style: robotoBold.copyWith(color: Colors.white, fontSize: 15)),
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: 14)),
                  if (where.isNotEmpty)
                    Text('📍 $where', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: 11.5, color: LColors.muted)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
