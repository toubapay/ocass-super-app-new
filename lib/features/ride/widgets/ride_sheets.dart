import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/ride/controllers/ride_controller.dart';
import 'package:sixam_mart/features/ride/domain/ride_models.dart';
import 'package:sixam_mart/features/ride/screens/ride_search_screen.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/service_icon_helper.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

const _yellow = Color(0xFFF5B301);
const _soft = Color(0xFFF4F4F5);
const _ink = Color(0xFF1C1C1E);

String _money(double v) => PriceConverter.convertPrice(v, forDM: true);

/// The bottom sheet under the map, one layout per step of the ride.
class RideSheet extends StatelessWidget {
  final RideController controller;
  final VoidCallback onSearchPickup;
  final VoidCallback onSearchDestination;
  const RideSheet({super.key, required this.controller, required this.onSearchPickup, required this.onSearchDestination});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    Widget body;
    switch (c.step) {
      case RideStep.mapPick:
        body = _MapPickSheet(c: c);
        break;
      case RideStep.options:
        body = _OptionsSheet(c: c, onEditRoute: onSearchDestination);
        break;
      case RideStep.ride:
        body = c.trip == null ? const SizedBox() : _RideStatusSheet(c: c, trip: c.trip!);
        break;
      case RideStep.history:
        body = _HistorySheet(c: c);
        break;
      default:
        body = _HomeSheet(c: c, onSearchPickup: onSearchPickup, onSearchDestination: onSearchDestination);
    }
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.62),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x24000000), blurRadius: 24, offset: Offset(0, -6))],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFD8D8DC), borderRadius: BorderRadius.circular(3)))),
            const SizedBox(height: 12),
            body,
          ]),
        ),
      ),
    );
  }
}

class _HomeSheet extends StatelessWidget {
  final RideController c;
  final VoidCallback onSearchPickup;
  final VoidCallback onSearchDestination;
  const _HomeSheet({required this.c, required this.onSearchPickup, required this.onSearchDestination});

  @override
  Widget build(BuildContext context) {
    final p = c.pickup;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      InkWell(
        onTap: onSearchPickup,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            const RideDot(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(p != null && p.address.isNotEmpty ? p.short : 'ride_move_map_hint'.tr,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium),
            ),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
      const SizedBox(height: 10),
      Material(
        color: const Color(0xFFF1F1F3),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onSearchDestination,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Icon(Icons.search, size: 26),
              const SizedBox(width: 12),
              Text('ride_where_to'.tr, style: robotoBold.copyWith(fontSize: 19)),
            ]),
          ),
        ),
      ),
      ...c.recent.map((r) => InkWell(
            onTap: () => c.setPlace(r, forPickup: false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA)))),
              child: Row(children: [
                Container(width: 38, height: 38, decoration: const BoxDecoration(color: Color(0xFFF1F1F3), shape: BoxShape.circle), child: const Icon(Icons.history, size: 19)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.short, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold),
                    Text(r.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(color: Colors.black54, fontSize: 13)),
                  ]),
                ),
              ]),
            ),
          )),
    ]);
  }
}

class _MapPickSheet extends StatelessWidget {
  final RideController c;
  const _MapPickSheet({required this.c});

  @override
  Widget build(BuildContext context) {
    final p = c.mapPoint;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(c.mapPickForPickup ? 'ride_pickup'.tr : 'ride_destination'.tr, style: robotoRegular.copyWith(color: Colors.black54)),
      const SizedBox(height: 4),
      Text(p != null && p.address.isNotEmpty ? p.short : 'ride_move_map'.tr, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: 20)),
      const SizedBox(height: 14),
      CustomButton(buttonText: 'ride_confirm_point'.tr, onPressed: p == null ? null : c.confirmMapPoint),
    ]);
  }
}

class _OptionsSheet extends StatelessWidget {
  final RideController c;
  final VoidCallback onEditRoute;
  const _OptionsSheet({required this.c, required this.onEditRoute});

  @override
  Widget build(BuildContext context) {
    final e = c.estimate;
    final sel = c.selected;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Material(
        color: const Color(0xFFF1F1F3),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onEditRoute,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              const Column(children: [RideDot(), SizedBox(height: 12), RideDot(red: true)]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.pickup?.short ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(c.destination?.short ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold),
                ]),
              ),
              if (e != null)
                Text('${e.distanceKm} km · ${e.durationMin} min', textDirection: TextDirection.ltr, style: robotoRegular.copyWith(color: Colors.black54, fontSize: 13)),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 12),
      if (e == null)
        const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
      else ...[
        if (e.surgeMultiplier > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              const Icon(Icons.schedule, size: 16, color: Color(0xFF8A5A00)),
              const SizedBox(width: 6),
              Text('${e.surgeLabel ?? ''} : ${'ride_rate'.tr} ×${e.surgeMultiplier}', style: robotoBold.copyWith(color: const Color(0xFF8A5A00), fontSize: 14)),
            ]),
          ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: e.options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _TariffCard(option: e.options[i], selected: e.options[i].category.id == c.categoryId, onTap: () => c.selectCategory(e.options[i].category.id)),
          ),
        ),
        if (sel != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${sel.category.description}${sel.driversNearby ? '' : ' · ${'ride_few_drivers'.tr}'}',
              style: robotoRegular.copyWith(color: Colors.black54, fontSize: 13),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: (c.config?.paymentMethods ?? [])
              .map((m) => Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: _PayOption(
                        method: m,
                        selected: c.payment == m,
                        balance: c.config?.walletBalance ?? 0,
                        onTap: () => c.selectPayment(m),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _yellow,
              foregroundColor: _ink,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: sel == null || c.busy ? null : c.order,
            child: c.busy
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: _ink))
                : Row(children: [
                    Expanded(child: Text('${'ride_order'.tr} ${sel?.category.name ?? ''}', style: robotoBold.copyWith(fontSize: 18))),
                    if (sel != null) Text(_money(sel.fare), style: robotoBold.copyWith(fontSize: 18)),
                  ]),
          ),
        ),
      ],
    ]);
  }
}

class _TariffCard extends StatelessWidget {
  final RideOption option;
  final bool selected;
  final VoidCallback onTap;
  const _TariffCard({required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 118,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF8E1) : _soft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _yellow : Colors.transparent, width: 2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(option.etaMin != null ? '${option.etaMin} min' : '—', style: robotoRegular.copyWith(fontSize: 12, color: Colors.black54)),
          Center(child: SvgPicture.asset(ServiceIcons.forVehicle(option.category.vehicleType), width: 54, height: 54)),
          const Spacer(),
          Text(option.category.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold),
          Text(_money(option.fare), maxLines: 1, style: robotoBlack.copyWith(fontSize: 16)),
        ]),
      ),
    );
  }
}

class _PayOption extends StatelessWidget {
  final String method;
  final bool selected;
  final double balance;
  final VoidCallback onTap;
  const _PayOption({required this.method, required this.selected, required this.balance, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final wallet = method == 'wallet';
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _ink : const Color(0xFFE5E5EA), width: 2),
        ),
        child: Row(children: [
          Icon(wallet ? Icons.account_balance_wallet_outlined : Icons.payments_outlined, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(wallet ? 'ride_wallet'.tr : 'ride_cash'.tr, style: robotoBold),
              if (wallet) Text(_money(balance), style: robotoRegular.copyWith(fontSize: 12, color: Colors.black54)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _RideStatusSheet extends StatefulWidget {
  final RideController c;
  final RideTrip trip;
  const _RideStatusSheet({required this.c, required this.trip});

  @override
  State<_RideStatusSheet> createState() => _RideStatusSheetState();
}

class _RideStatusSheetState extends State<_RideStatusSheet> {
  int _stars = 5;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _confirmCancel() async {
    final t = widget.trip;
    final late = t.acceptedAt != null && DateTime.now().difference(t.acceptedAt!).inMinutes >= 2;
    final ok = await Get.dialog<bool>(AlertDialog(
      title: Text('ride_cancel_question'.tr),
      content: late ? Text('ride_cancel_fee_warning'.tr) : null,
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text('ride_keep'.tr)),
        TextButton(onPressed: () => Get.back(result: true), child: Text('ride_cancel'.tr, style: const TextStyle(color: Color(0xFFC81E1E)))),
      ],
    ));
    if (ok == true) widget.c.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final c = widget.c;
    switch (t.status) {
      case 'searching':
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const _Pulse(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ride_searching'.tr, style: robotoBold.copyWith(fontSize: 20)),
                const SizedBox(height: 4),
                Text('${t.category?.name ?? ''} · ${_money(t.estimatedFare)}', style: robotoRegular.copyWith(color: Colors.black54)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          const LinearProgressIndicator(minHeight: 4, color: _yellow, backgroundColor: Color(0xFFEEEEEE)),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: c.busy ? null : _confirmCancel, child: Text('ride_cancel'.tr)),
        ]);
      case 'no_driver':
      case 'cancelled':
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(t.status == 'no_driver' ? 'ride_no_driver'.tr : 'ride_cancelled'.tr, textAlign: TextAlign.center, style: robotoBold.copyWith(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            t.status == 'no_driver'
                ? 'ride_no_driver_hint'.tr
                : t.cancellationFee > 0
                    ? '${'ride_cancel_fee_applied'.tr} ${_money(t.cancellationFee)}'
                    : 'ride_cancelled_hint'.tr,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          CustomButton(buttonText: 'ride_new_ride'.tr, onPressed: c.newRide),
        ]);
      case 'completed':
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const CircleAvatar(radius: 23, backgroundColor: Color(0xFF16A34A), child: Icon(Icons.check, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ride_arrived_destination'.tr, style: robotoBold.copyWith(fontSize: 20)),
                Text(t.destination?.short ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(color: Colors.black54)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _soft, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              _row('ride_fare'.tr, _money(t.fare), bold: true),
              if (t.waitingFee > 0) _row('ride_waiting_included'.tr, _money(t.waitingFee)),
              _row('ride_payment'.tr, t.paymentMethod == 'wallet' ? 'ride_wallet_noor'.tr : 'ride_cash_to_driver'.tr),
              _row('ride_distance'.tr, '${t.distanceKm} km · ${t.durationMin} min'),
            ]),
          ),
          const SizedBox(height: 14),
          if (t.riderRating != null)
            Text('ride_thanks_rating'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(color: Colors.black54))
          else ...[
            Text('${'ride_rate_question'.tr} ${t.driver?.name ?? ''} ?', textAlign: TextAlign.center, style: robotoBold),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => IconButton(
                    iconSize: 36,
                    onPressed: () => setState(() => _stars = i + 1),
                    icon: Icon(i < _stars ? Icons.star_rounded : Icons.star_outline_rounded, color: _yellow),
                  )),
            ),
            TextField(
              controller: _comment,
              maxLength: 300,
              decoration: InputDecoration(hintText: 'ride_comment_hint'.tr, counterText: '', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
            ),
            const SizedBox(height: 10),
            CustomButton(buttonText: 'ride_send_rating'.tr, isLoading: c.busy, onPressed: () => c.rate(_stars, _comment.text.trim())),
          ],
          const SizedBox(height: 10),
          OutlinedButton(onPressed: c.newRide, child: Text('ride_new_ride'.tr)),
        ]);
      default: // accepted | arrived | in_progress
        final title = {'accepted': 'ride_driver_coming'.tr, 'arrived': 'ride_driver_arrived'.tr, 'in_progress': 'ride_on_the_way'.tr}[t.status] ?? '';
        final sub = {
              'accepted': '${'ride_meet_at'.tr} ${t.pickup?.short ?? ''}',
              'arrived': 'ride_driver_waiting'.tr,
              'in_progress': t.destination?.short ?? '',
            }[t.status] ??
            '';
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(title, style: robotoBold.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(sub, style: robotoRegular.copyWith(color: Colors.black54)),
          const SizedBox(height: 12),
          if (t.driver != null) _DriverCard(trip: t),
          const SizedBox(height: 12),
          Row(children: [
            Icon(t.paymentMethod == 'wallet' ? Icons.account_balance_wallet_outlined : Icons.payments_outlined, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(t.paymentMethod == 'wallet' ? 'ride_wallet_noor'.tr : 'ride_cash_to_driver'.tr)),
            Text(_money(t.estimatedFare), style: robotoBold),
          ]),
          if (t.status != 'in_progress')
            TextButton(
              onPressed: c.busy ? null : _confirmCancel,
              child: Text('ride_cancel'.tr, style: robotoBold.copyWith(color: const Color(0xFFC81E1E))),
            ),
        ]);
    }
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Expanded(child: Text(label)),
          Text(value, style: bold ? robotoBold : robotoRegular),
        ]),
      );
}

class _DriverCard extends StatelessWidget {
  final RideTrip trip;
  const _DriverCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final d = trip.driver!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _soft, borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        Row(children: [
          ClipOval(
            child: SizedBox(
              width: 48,
              height: 48,
              child: d.imageUrl != null && d.imageUrl!.isNotEmpty
                  ? CustomImage(image: d.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: _ink,
                      alignment: Alignment.center,
                      child: Text(d.name.isEmpty ? '?' : d.name[0], style: robotoBold.copyWith(color: _yellow, fontSize: 20)),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.name, style: robotoBold.copyWith(fontSize: 16)),
              Row(children: [
                const Icon(Icons.star_rounded, size: 16, color: _yellow),
                Text(' ${d.rating.toStringAsFixed(1)} · ${d.totalTrips} ${'ride_trips'.tr}', style: robotoRegular.copyWith(color: Colors.black54, fontSize: 13)),
              ]),
            ]),
          ),
          if (d.phone != null && d.phone!.isNotEmpty)
            Material(
              color: const Color(0xFF16A34A),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'ride_call_driver'.tr,
                icon: const Icon(Icons.call, color: Colors.white),
                onPressed: () => launchUrl(Uri.parse('tel:${d.phone}')),
              ),
            ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Text('${d.color} · ${d.vehicle}', style: robotoMedium)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _ink, width: 2), borderRadius: BorderRadius.circular(6)),
            child: Text(d.plate, textDirection: TextDirection.ltr, style: robotoBold.copyWith(letterSpacing: 1, fontFamily: 'monospace')),
          ),
        ]),
        if (trip.otp != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Expanded(child: Text('ride_start_code'.tr, style: robotoRegular.copyWith(fontSize: 13))),
              Text(trip.otp!.split('').join(' '), textDirection: TextDirection.ltr, style: robotoBlack.copyWith(fontSize: 24, letterSpacing: 2)),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _HistorySheet extends StatelessWidget {
  final RideController c;
  const _HistorySheet({required this.c});

  static const _status = {
    'completed': 'ride_status_completed',
    'cancelled': 'ride_status_cancelled',
    'no_driver': 'ride_status_no_driver',
  };

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('ride_my_rides'.tr, style: robotoBold.copyWith(fontSize: 20)),
      const SizedBox(height: 8),
      if (c.history.isEmpty)
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('ride_no_rides'.tr, style: robotoRegular.copyWith(color: Colors.black54)))
      else
        ...c.history.map((t) {
          final when = t.createdAt;
          final date = when == null ? '' : '${when.day.toString().padLeft(2, '0')}/${when.month.toString().padLeft(2, '0')} ${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}';
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA)))),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.destination?.short.isNotEmpty == true ? t.destination!.short : t.reference, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold),
                  Text('$date · ${t.category?.name ?? ''} · ${(_status[t.status] ?? 'ride_status_ongoing').tr}',
                      style: robotoRegular.copyWith(color: Colors.black54, fontSize: 13)),
                ]),
              ),
              Text(_money(t.fare), style: robotoBold),
            ]),
          );
        }),
    ]);
  }
}

/// The yellow pulse while looking for a driver.
class _Pulse extends StatefulWidget {
  const _Pulse();

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: AnimatedBuilder(
        animation: _a,
        builder: (_, __) => Stack(alignment: Alignment.center, children: [
          Transform.scale(
            scale: 1 + _a.value * 0.9,
            child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: _yellow.withValues(alpha: 0.5 * (1 - _a.value)))),
          ),
          Container(width: 40, height: 40, decoration: const BoxDecoration(shape: BoxShape.circle, color: _yellow)),
        ]),
      ),
    );
  }
}
