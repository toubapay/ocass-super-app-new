import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/listing/listing_api.dart';
import 'package:sixam_mart/features/listing/screens/listing_home_screen.dart';
import 'package:sixam_mart/features/listing/screens/listing_messages_screen.dart';
import 'package:sixam_mart/features/listing/widgets/listing_ui.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// One listing: photos, price, seller, description, place, and the ways to
/// reach the seller (WhatsApp, call, SMS, chat).
class ListingDetailScreen extends StatefulWidget {
  final int id;
  final ListingConfig? config;
  const ListingDetailScreen({super.key, required this.id, this.config});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  ListingItem? _item;
  String? _error;
  int _photo = 0;

  @override
  void initState() {
    super.initState();
    ListingApi.item(widget.id).then((r) {
      if (!mounted) return;
      setState(() {
        if (r.statusCode == 200 && r.body is Map) {
          _item = ListingItem.fromJson(r.body);
        } else {
          _error = ListingApi.error(r);
        }
      });
    });
  }

  String get _link => '${AppConstants.baseUrl}/listing/produit/${widget.id}';

  Future<void> _open(String type, Uri uri) async {
    ListingApi.contact(widget.id, type);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(appBar: ListingBar(title: 'lst_title'.tr), body: ListingEmpty(emoji: '🙁', text: _error!));
    }
    final item = _item;
    if (item == null) {
      return Scaffold(appBar: ListingBar(title: 'lst_title'.tr), body: const Center(child: CircularProgressIndicator(color: LColors.green)));
    }
    final seller = item.seller ?? {};
    final contacts = (seller['contacts'] is Map ? seller['contacts'] : {}) as Map;
    final phone = seller['phone'] != null ? listingIntlPhone('${seller['phone']}') : null;
    final message = 'lst_contact_message'.trParams({'title': item.title, 'price': listingMoney(item.price), 'link': _link});
    final photos = item.images.isEmpty ? <String>[] : item.images;
    final individual = seller['kind'] == 'user';

    return Scaffold(
      backgroundColor: LColors.bg,
      appBar: ListingBar(title: item.title, actions: [
        ListingIconButton(
          icon: Icons.share_outlined,
          tooltip: 'lst_share'.tr,
          onTap: () => SharePlus.instance.share(ShareParams(text: '${item.title} — ${listingMoney(item.price)}\n$_link')),
        ),
      ]),
      body: ListView(padding: EdgeInsets.zero, children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(children: [
            Positioned.fill(
              child: Container(
                color: const Color(0xFFEEF3EF),
                child: photos.isEmpty
                    ? const Center(child: Text('📦', style: TextStyle(fontSize: 80)))
                    : PageView.builder(
                        itemCount: photos.length,
                        onPageChanged: (i) => setState(() => _photo = i),
                        itemBuilder: (_, i) => CustomImage(image: photos[i], fit: BoxFit.contain),
                      ),
              ),
            ),
            if (photos.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < photos.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: i == _photo ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: i == _photo ? 1 : 0.6), borderRadius: BorderRadius.circular(4)),
                    ),
                ]),
              ),
            if (item.featured) Positioned(left: 14, bottom: 14, child: ListingPill(text: 'lst_featured'.tr, gold: true)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(listingMoney(item.price), style: robotoBold.copyWith(fontSize: 24, color: LColors.green)),
            const SizedBox(height: 2),
            Text(item.title, style: robotoBold.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                child: Text(
                  '${item.category != null ? '${item.category!.icon} ${item.category!.name} · ' : ''}${'lst_views'.trParams({'n': '${item.views}'})}',
                  style: robotoRegular.copyWith(fontSize: 12.5, color: LColors.muted),
                ),
              ),
              Text(listingAgo(item.createdAt), style: robotoRegular.copyWith(fontSize: 12.5, color: LColors.muted)),
            ]),
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: seller['key'] == null
                    ? null
                    : () => Get.to(() => Scaffold(
                          backgroundColor: LColors.bg,
                          appBar: ListingBar(title: '${seller['name']}'),
                          body: ListingBrowse(config: widget.config, seller: '${seller['key']}'),
                        )),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border.all(color: LColors.line), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: LColors.greenLight,
                      backgroundImage: seller['logo'] != null ? NetworkImage('${seller['logo']}') : null,
                      onBackgroundImageError: seller['logo'] != null ? (_, __) {} : null,
                      child: seller['logo'] == null ? Text(_initials('${seller['name'] ?? ''}'), style: robotoBold.copyWith(color: LColors.green)) : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${seller['name'] ?? ''}', style: robotoBold.copyWith(fontSize: 14.5)),
                        Text(
                          '${individual ? 'lst_individual'.tr : 'lst_shop'.tr} · ${'lst_count'.trParams({'n': '${seller['listings'] ?? 0}'})}',
                          style: robotoRegular.copyWith(fontSize: 12, color: LColors.muted),
                        ),
                      ]),
                    ),
                    const Icon(Icons.chevron_right, color: LColors.muted),
                  ]),
                ),
              ),
            ),
            if ((item.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(item.description!, style: robotoRegular.copyWith(fontSize: 14, height: 1.6)),
            ],
            if (item.lat != null && item.lng != null) ...[
              const SizedBox(height: 14),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => launchUrl(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${item.lat},${item.lng}'), mode: LaunchMode.externalApplication),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: LColors.line), borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: LColors.greenLight, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.map_outlined, color: LColors.green),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.address ?? 'lst_seller_place'.tr, style: robotoBold.copyWith(fontSize: 13.5)),
                          Text('lst_open_maps'.tr, style: robotoRegular.copyWith(fontSize: 12, color: LColors.muted)),
                        ]),
                      ),
                      const Icon(Icons.near_me_outlined, color: LColors.green, size: 20),
                    ]),
                  ),
                ),
              ),
            ] else if ((item.address ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('📍 ${item.address}', style: robotoMedium.copyWith(color: LColors.green)),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(color: LColors.cream, borderRadius: BorderRadius.circular(12)),
              child: Text('lst_safety'.tr, style: robotoRegular.copyWith(fontSize: 12, color: LColors.muted)),
            ),
          ]),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: LColors.line))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            if (contacts['whatsapp'] == true && phone != null)
              _contact('WhatsApp', LColors.whatsapp, Colors.white,
                  () => _open('whatsapp', Uri.parse('https://wa.me/${phone.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}'))),
            if (contacts['call'] == true && phone != null) _contact('lst_call'.tr, LColors.green, Colors.white, () => _open('call', Uri.parse('tel:$phone'))),
            if (contacts['sms'] == true && phone != null)
              _contact('SMS', LColors.greenLight, LColors.green, () => _open('sms', Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}'))),
            if (contacts['chat'] == true) _contact('Chat', LColors.cream, LColors.goldDark, () => _startChat(item)),
          ]),
        ),
      ),
    );
  }

  Widget _contact(String label, Color bg, Color fg, VoidCallback onTap) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: SizedBox(
                height: 46,
                child: Center(child: Text(label, style: robotoBold.copyWith(fontSize: 13, color: fg))),
              ),
            ),
          ),
        ),
      );

  Future<void> _startChat(ListingItem item) async {
    // Already talking about this listing: open the conversation.
    final existing = await ListingApi.buyerChats();
    if (existing.statusCode == 200 && existing.body is Map) {
      for (final c in existing.body['chats'] ?? []) {
        if (c['listing']?['id'] == item.id) {
          Get.to(() => ListingChatScreen(id: c['id'], seller: false));
          return;
        }
      }
    }
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => _StartChatSheet(item: item),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2);
    final s = parts.map((w) => w[0]).join().toUpperCase();
    return s.isEmpty ? 'N' : s;
  }
}

class _StartChatSheet extends StatefulWidget {
  final ListingItem item;
  const _StartChatSheet({required this.item});

  @override
  State<_StartChatSheet> createState() => _StartChatSheetState();
}

class _StartChatSheetState extends State<_StartChatSheet> {
  final _name = TextEditingController();
  late final _text = TextEditingController(text: 'lst_still_available'.tr);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_name.text.trim().isEmpty || _text.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ListingApi.startChat(widget.item.id, _name.text.trim(), _text.text.trim());
    if (!mounted) return;
    if (r.statusCode == 200 && r.body is Map) {
      Navigator.of(context).pop();
      Get.to(() => ListingChatScreen(id: r.body['chat']['id'], seller: false));
    } else {
      setState(() {
        _busy = false;
        _error = ListingApi.error(r);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 18, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('lst_write_seller'.tr, style: robotoBold.copyWith(fontSize: 17)),
        const SizedBox(height: 4),
        Text('lst_no_account_needed'.tr, style: robotoRegular.copyWith(color: LColors.muted, fontSize: 13)),
        const SizedBox(height: 12),
        TextField(controller: _name, maxLength: 60, decoration: InputDecoration(labelText: 'lst_your_name'.tr, counterText: '', border: const OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: _text, maxLines: 3, maxLength: 1000, decoration: InputDecoration(labelText: 'lst_message'.tr, counterText: '', border: const OutlineInputBorder())),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: robotoMedium.copyWith(color: Colors.red))),
        const SizedBox(height: 12),
        ListingButton(text: 'lst_send'.tr, style: 'green', busy: _busy, onTap: _send),
      ]),
    );
  }
}
