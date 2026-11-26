import 'package:sixam_mart/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/features/listing/listing_api.dart';
import 'package:sixam_mart/features/listing/screens/listing_detail_screen.dart';
import 'package:sixam_mart/features/listing/screens/listing_packs_screen.dart';
import 'package:sixam_mart/features/listing/screens/listing_post_screen.dart';
import 'package:sixam_mart/features/listing/widgets/listing_ui.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/styles.dart';

/// The customer's own listings: sold / back on sale, boost, delete.
class ListingMineScreen extends StatefulWidget {
  const ListingMineScreen({super.key});

  @override
  State<ListingMineScreen> createState() => _ListingMineScreenState();
}

class _ListingMineScreenState extends State<ListingMineScreen> {
  List<ListingItem>? _items;
  Map? _me;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!AuthHelper.isLoggedIn()) return;
    final results = await Future.wait([ListingApi.me(), ListingApi.myItems()]);
    if (!mounted) return;
    setState(() {
      if (results[0].statusCode == 200) _me = results[0].body;
      if (results[1].statusCode == 200 && results[1].body is Map) {
        _items = [for (final j in results[1].body['items'] ?? []) ListingItem.fromJson(j)];
      } else {
        _error = ListingApi.error(results[1]);
      }
    });
  }

  Future<void> _run(Future<Response> Function() call) async {
    final r = await call();
    final code = r.statusCode ?? 0;
    if (code >= 200 && code < 300) {
      await _load();
    } else {
      showCustomSnackBar(ListingApi.error(r));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthHelper.isLoggedIn()) {
      return Scaffold(appBar: ListingBar(title: 'lst_my_listings'.tr), body: NotLoggedInScreen(callBack: (_) => setState(() => _load())));
    }
    final quota = (_me?['quota'] ?? {}) as Map;
    return Scaffold(
      backgroundColor: LColors.bg,
      appBar: ListingBar(title: 'lst_my_listings'.tr),
      body: RefreshIndicator(
        color: LColors.green,
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Expanded(
              child: ListingButton(
                text: 'lst_post'.tr,
                icon: Icons.add,
                onTap: () async {
                  await Get.to(() => const ListingPostScreen());
                  _load();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ListingButton(
                text: 'lst_packs'.tr,
                style: 'outline',
                onTap: () async {
                  await Get.to(() => const ListingPacksScreen());
                  _load();
                },
              ),
            ),
          ]),
          if (quota.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Text(
                quota['subscription'] != null
                    ? '${quota['subscription']['name']} · ${'lst_boosts_left'.trParams({'n': '${quota['subscription']['featured_left']}'})}'
                    : 'lst_quota_free'.trParams({'left': '${quota['free_left']}', 'total': '${quota['free_total']}'}),
                style: robotoRegular.copyWith(fontSize: 12.5, color: LColors.muted),
              ),
            ),
          const SizedBox(height: 8),
          if (_error != null)
            ListingEmpty(emoji: '🙁', text: _error!)
          else if (_items == null)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: LColors.green)))
          else if (_items!.isEmpty)
            ListingEmpty(emoji: '🛍️', text: 'lst_no_listing_yet'.tr)
          else
            for (final item in _items!) _row(item),
        ]),
      ),
    );
  }

  Widget _row(ListingItem item) {
    final (label, bg, fg) = switch (item.status) {
      'active' => ('lst_status_active'.tr, const Color(0xFFDCF5E6), const Color(0xFF11743D)),
      'pending' => ('lst_status_pending'.tr, const Color(0xFFFFF3D6), const Color(0xFF9A6A00)),
      'rejected' => ('lst_status_rejected'.tr, const Color(0xFFFDE2E2), const Color(0xFFB42318)),
      'sold' => ('lst_status_sold'.tr, const Color(0xFFECEFF1), const Color(0xFF546E7A)),
      _ => ('lst_status_expired'.tr, const Color(0xFFECEFF1), const Color(0xFF546E7A)),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: LColors.line)),
      child: Column(children: [
        InkWell(
          onTap: item.status == 'active' ? () => Get.to(() => ListingDetailScreen(id: item.id)) : null,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(width: 74, height: 74, child: item.image != null ? CustomImage(image: item.image!, fit: BoxFit.cover) : Container(color: const Color(0xFFEEF3EF))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: 14)),
                  Text(listingMoney(item.price), style: robotoBold.copyWith(color: LColors.green)),
                  const SizedBox(height: 4),
                  Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    ListingPill(text: label, color: bg, textColor: fg),
                    if (item.featured) ListingPill(text: 'lst_featured'.tr, gold: true),
                    Text('👁 ${item.views} · 📞 ${item.contacts}', style: robotoRegular.copyWith(fontSize: 11.5, color: LColors.muted)),
                  ]),
                  if (item.status == 'rejected' && (item.adminNote ?? '').isNotEmpty)
                    Text(item.adminNote!, style: robotoRegular.copyWith(fontSize: 11.5, color: const Color(0xFFB42318))),
                ]),
              ),
            ]),
          ),
        ),
        const Divider(height: 1, color: LColors.line),
        Row(children: [
          if (item.status == 'active') ...[
            _action('lst_mark_sold'.tr, Icons.check_circle_outline, () => _run(() => ListingApi.update(item.id, {'status': 'sold'}))),
            _action('lst_boost'.tr, Icons.star_outline, () => _boost(item), color: LColors.goldDark),
          ],
          if (item.status == 'sold') _action('lst_back_on_sale'.tr, Icons.replay, () => _run(() => ListingApi.update(item.id, {'status': 'active'}))),
          _action('lst_delete'.tr, Icons.delete_outline, () => _confirmDelete(item), color: const Color(0xFFB42318)),
        ]),
      ]),
    );
  }

  Widget _action(String label, IconData icon, VoidCallback onTap, {Color color = LColors.green}) => Expanded(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: 12.5, color: color))),
            ]),
          ),
        ),
      );

  void _confirmDelete(ListingItem item) {
    Get.dialog(AlertDialog(
      title: Text('lst_delete_title'.tr),
      content: Text(item.title),
      actions: [
        TextButton(onPressed: Get.back, child: Text('lst_cancel'.tr)),
        TextButton(
          onPressed: () {
            Get.back();
            _run(() => ListingApi.remove(item.id));
          },
          child: Text('lst_delete'.tr, style: const TextStyle(color: Color(0xFFB42318))),
        ),
      ],
    ));
  }

  /// Boost: one included in the package, or paid by the day.
  void _boost(ListingItem item) {
    final quota = (_me?['quota'] ?? {}) as Map;
    final included = (quota['subscription']?['featured_left'] ?? 0) as int;
    final settings = (_me?['settings'] ?? {}) as Map;
    final pay = (settings['payments'] ?? {}) as Map;
    final perDay = (settings['boost_price_per_day'] ?? 0) as num;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheet) {
        var days = 7;
        var busy = false;
        return StatefulBuilder(builder: (context, setSheet) {
          Future<void> pay0(String method) async {
            setSheet(() => busy = true);
            final r = await ListingApi.pay({'kind': 'boost', 'listing_id': item.id, 'days': days, 'method': method});
            if (r.statusCode == 200 && r.body is Map && (r.body['redirect_link'] ?? '').toString().isNotEmpty) {
              await listingCheckout(r.body['redirect_link']);
            } else if (r.statusCode != 200) {
              showCustomSnackBar(ListingApi.error(r));
            }
            if (sheet.mounted) Navigator.of(sheet).pop();
            _load();
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('lst_boost_title'.tr, style: robotoBold.copyWith(fontSize: 17)),
                const SizedBox(height: 4),
                Text('lst_boost_hint'.tr, style: robotoRegular.copyWith(color: LColors.muted, fontSize: 13)),
                const SizedBox(height: 12),
                if (included > 0) ...[
                  ListingButton(
                    text: 'lst_use_included_boost'.trParams({'n': '$included'}),
                    busy: busy,
                    onTap: () async {
                      setSheet(() => busy = true);
                      final r = await ListingApi.boostIncluded(item.id);
                      if (r.statusCode != 200) showCustomSnackBar(ListingApi.error(r));
                      if (sheet.mounted) Navigator.of(sheet).pop();
                      _load();
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                Row(children: [
                  for (final d in [3, 7, 14, 30])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          label: SizedBox(width: double.infinity, child: Text('lst_n_days'.trParams({'n': '$d'}), textAlign: TextAlign.center)),
                          selected: days == d,
                          showCheckmark: false,
                          selectedColor: LColors.green,
                          labelStyle: robotoBold.copyWith(fontSize: 12.5, color: days == d ? Colors.white : Colors.black87),
                          onSelected: (_) => setSheet(() => days = d),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(height: 10),
                Text('${'lst_to_pay'.tr} : ${listingMoney(perDay * days)}', textAlign: TextAlign.center, style: robotoBold.copyWith(fontSize: 15)),
                const SizedBox(height: 10),
                Row(children: [
                  if (pay['paydunya'] == true) Expanded(child: ListingButton(text: 'lst_pay_mobile'.tr, style: 'green', busy: busy, onTap: () => pay0('paydunya'))),
                  if (!AppConstants.playSafe && pay['paydunya'] == true && pay['wallet'] == true) const SizedBox(width: 8),
                  if (!AppConstants.playSafe && pay['wallet'] == true) Expanded(child: ListingButton(text: 'lst_pay_wallet'.tr, style: 'outline', busy: busy, onTap: () => pay0('wallet'))),
                ]),
              ]),
            ),
          );
        });
      },
    );
  }
}
