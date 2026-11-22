import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/noor_shop/noor_catalog.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';

/// The slides at the top of the home screen, as in the web app: the admin's
/// banners of the first shop module, full width (2:1), swiping on their own.
class NoorBannerSlider extends StatefulWidget {
  final int moduleId;
  final EdgeInsets padding;
  const NoorBannerSlider({super.key, required this.moduleId, this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 4)});

  @override
  State<NoorBannerSlider> createState() => _NoorBannerSliderState();
}

class _NoorBannerSliderState extends State<NoorBannerSlider> {
  final _page = PageController();
  List<Map<String, dynamic>> _banners = [];
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant NoorBannerSlider old) {
    super.didUpdateWidget(old);
    if (old.moduleId != widget.moduleId) _load();
  }

  Future<void> _load() async {
    try {
      final b = await NoorCatalog.banners(widget.moduleId);
      if (!mounted) return;
      setState(() {
        _banners = b;
        _index = 0;
      });
      _timer?.cancel();
      if (b.length > 1) {
        _timer = Timer.periodic(const Duration(seconds: 5), (_) {
          if (!_page.hasClients || _banners.isEmpty) return;
          _page.animateToPage((_index + 1) % _banners.length, duration: const Duration(milliseconds: 450), curve: Curves.easeOut);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  void _open(Map<String, dynamic> b) {
    final id = int.tryParse('${b['data'] ?? ''}');
    if (b['type'] == 'store_wise' && id != null) {
      NoorCatalog.openStore(id: id, moduleId: widget.moduleId);
    } else if (b['type'] == 'item_wise' && id != null) {
      Get.toNamed(RouteHelper.getItemDetailsRoute(id, false));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_banners.isEmpty) return const SizedBox.shrink();
    final width = MediaQuery.sizeOf(context).width - widget.padding.horizontal;
    return Padding(
      padding: widget.padding,
      child: Column(children: [
        SizedBox(
          height: width / 2,
          child: PageView.builder(
            controller: _page,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _open(_banners[i]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomImage(image: '${_banners[i]['image_full_url']}', width: width, height: width / 2, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        if (_banners.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (int i = 0; i < _banners.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _index ? NoorShopColors.green : const Color(0xFFD5DCD9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ]),
          ),
      ]),
    );
  }
}

/// Section title with "Tout voir", as .section-head in the web app.
class NoorSectionHead extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final Widget? leading;
  final Widget? trailing;
  const NoorSectionHead({super.key, required this.title, this.onSeeAll, this.leading, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 10, 8),
      child: Row(children: [
        if (leading != null) ...[leading!, const SizedBox(width: 6)],
        Expanded(
          child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        ),
        if (trailing != null) trailing!,
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text('noor_see_all'.tr, style: const TextStyle(color: NoorShopColors.green, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
      ]),
    );
  }
}

/// A product as .product-card in the web app: picture, discount badge,
/// name, shop and price (old price struck through).
class NoorProductCard extends StatelessWidget {
  final Item item;
  final bool campaign;
  final bool flash;
  const NoorProductCard({super.key, required this.item, this.campaign = false, this.flash = false});

  @override
  Widget build(BuildContext context) {
    final price = item.price ?? 0;
    final discount = item.discount ?? 0;
    final sale = PriceConverter.convertWithDiscount(price, discount, item.discountType) ?? price;
    final hasDiscount = sale < price;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => NoorCatalog.openItem(item, context, campaign: campaign),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: NoorShopColors.line), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(fit: StackFit.expand, children: [
                (item.imageFullUrl ?? '').isEmpty ? NoorInitialTile(name: item.name) : CustomImage(image: item.imageFullUrl!, fit: BoxFit.cover),
                if (flash || hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: flash ? const Color(0xFFF5A623) : const Color(0xFFE53935), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        flash ? 'noor_flash'.tr : '-${discount.toStringAsFixed(0)}${item.discountType == 'percent' ? '%' : ''}',
                        style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.25)),
                if ((item.storeName ?? '').isNotEmpty)
                  Text(item.storeName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: NoorShopColors.muted)),
                const SizedBox(height: 4),
                Text(PriceConverter.convertPrice(sale), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: NoorShopColors.green)),
                if (hasDiscount)
                  Text(PriceConverter.convertPrice(price),
                      style: const TextStyle(fontSize: 11.5, color: NoorShopColors.muted, decoration: TextDecoration.lineThrough)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// A titled row of products scrolling sideways (ProductRow in the web app).
/// An empty row disappears.
class NoorProductRow extends StatefulWidget {
  final String title;
  final Future<List<Item>> Function() load;
  final VoidCallback? onSeeAll;
  final bool campaign;
  final Widget? leading;
  final Widget? trailing;
  final bool flash;
  const NoorProductRow({super.key, required this.title, required this.load, this.onSeeAll, this.campaign = false, this.leading, this.trailing, this.flash = false});

  @override
  State<NoorProductRow> createState() => _NoorProductRowState();
}

class _NoorProductRowState extends State<NoorProductRow> {
  List<Item>? _items;

  @override
  void initState() {
    super.initState();
    widget.load().then((v) {
      if (mounted) setState(() => _items = v.take(10).toList());
    }).catchError((_) {
      if (mounted) setState(() => _items = []);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items != null && _items!.isEmpty) return const SizedBox.shrink();
    final w = (MediaQuery.sizeOf(context).width - 32) / 2.4;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      NoorSectionHead(title: widget.title, onSeeAll: widget.onSeeAll, leading: widget.leading, trailing: widget.trailing),
      SizedBox(
        height: w + 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _items?.length ?? 3,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => SizedBox(
            width: w,
            child: _items == null
                ? Container(decoration: BoxDecoration(color: const Color(0xFFEDEFEE), borderRadius: BorderRadius.circular(16)))
                : NoorProductCard(item: _items![i], campaign: widget.campaign, flash: widget.flash),
          ),
        ),
      ),
    ]);
  }
}

/// Products two per row (the .grid of the web app), inside a sliver list.
class NoorProductGrid extends StatelessWidget {
  final List<Item> items;
  const NoorProductGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.62),
      itemBuilder: (_, i) => NoorProductCard(item: items[i]),
    );
  }
}

/// A shop as .store-card in the web app: cover, logo, name, rating, time.
class NoorStoreCard extends StatelessWidget {
  final Store store;
  const NoorStoreCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final closed = store.open == 0 || store.active == false;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => NoorCatalog.openStore(id: store.id!, name: store.name, moduleId: store.moduleId),
          child: Opacity(
            opacity: closed ? 0.6 : 1,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AspectRatio(aspectRatio: 2.6, child: CustomImage(image: store.coverPhotoFullUrl ?? '', fit: BoxFit.cover)),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: CustomImage(image: store.logoFullUrl ?? '', width: 46, height: 46, fit: BoxFit.cover)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(store.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Row(children: [
                        if ((store.avgRating ?? 0) > 0) ...[
                          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF5A623)),
                          Text(' ${store.avgRating!.toStringAsFixed(1)} · ', style: const TextStyle(fontSize: 12.5, color: NoorShopColors.muted)),
                        ],
                        const Icon(Icons.schedule, size: 14, color: NoorShopColors.muted),
                        Text(' ${store.deliveryTime ?? '—'}', style: const TextStyle(fontSize: 12.5, color: NoorShopColors.muted)),
                      ]),
                    ]),
                  ),
                  if (closed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFFDECEA), borderRadius: BorderRadius.circular(10)),
                      child: Text('noor_closed'.tr, style: const TextStyle(color: Color(0xFFC62828), fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Empty / loading states.
class NoorEmpty extends StatelessWidget {
  final String title;
  final String? text;
  const NoorEmpty({super.key, required this.title, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(children: [
        const Icon(Icons.manage_search_rounded, size: 46, color: NoorShopColors.muted),
        const SizedBox(height: 10),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        if (text != null) ...[
          const SizedBox(height: 4),
          Text(text!, textAlign: TextAlign.center, style: const TextStyle(color: NoorShopColors.muted)),
        ],
      ]),
    );
  }
}

class NoorLoading extends StatelessWidget {
  const NoorLoading({super.key});

  @override
  Widget build(BuildContext context) =>
      const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: NoorShopColors.green)));
}

/// A product without picture: a Noor tile with the name's initial (as in
/// the web app) rather than an empty or broken picture.
class NoorInitialTile extends StatelessWidget {
  final String? name;
  final double fontSize;
  const NoorInitialTile({super.key, this.name, this.fontSize = 44});

  @override
  Widget build(BuildContext context) {
    final n = (name ?? '').trim();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8EDCC), Color(0xFFF3E6BF), Color(0xFFE4F1EA)],
          stops: [0, 0.45, 1],
        ),
      ),
      alignment: Alignment.center,
      child: n.isEmpty
          ? const Icon(Icons.shopping_bag_outlined, color: NoorShopColors.gold, size: 36)
          : Text(n.characters.first.toUpperCase(),
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: NoorShopColors.gold.withValues(alpha: 0.85))),
    );
  }
}
