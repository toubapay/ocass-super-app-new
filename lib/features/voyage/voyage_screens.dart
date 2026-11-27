import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/noor_shop/noor_module_slides.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/theme/light_theme.dart';

/// Je Voyage, customer side: trips between cities posted by Noor Pro
/// drivers. Browse (the 5 latest trips, search by cities and date), book
/// seats paid by wallet or cash, follow the car on the map, Mes voyages.

const _teal = Color(0xFF0E7490);
const _tealSoft = Color(0xFFECFEFF);
const _okGreen = Color(0xFF22C55E);

String _money(dynamic v) => PriceConverter.convertPrice(v is num ? v.toDouble() : double.tryParse('$v') ?? 0, forDM: true);
int _i(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
double? _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}');

/// Calls to /api/v1/voyage (public) and /api/v1/customer/voyage (signed in).
class VoyageApi {
  static ApiClient get _api => Get.find<ApiClient>();

  static dynamic _body(Response r) {
    if (r.statusCode == 200 || r.statusCode == 201) return r.body;
    String msg = 'Une erreur est survenue. Réessaie.';
    final b = r.body;
    if (b is Map && b['errors'] is List && (b['errors'] as List).isNotEmpty) msg = '${b['errors'][0]['message']}';
    if (r.statusCode == 1 || r.statusCode == null) msg = 'Pas de connexion internet.';
    throw msg;
  }

  static Future<dynamic> config() async => _body(await _api.getData('/api/v1/voyage/config', handleError: false));
  static Future<dynamic> latest() async => _body(await _api.getData('/api/v1/voyage/trips/latest', handleError: false));
  static Future<dynamic> search({int? from, int? to, String? date}) async => _body(await _api.getData('/api/v1/voyage/trips',
      query: {if (from != null) 'from': '$from', if (to != null) 'to': '$to', if (date != null) 'date': date}, handleError: false));
  static Future<dynamic> trip(int id) async => _body(await _api.getData('/api/v1/voyage/trips/$id', handleError: false));
  static Future<dynamic> book(int id, int seats, String method) async =>
      _body(await _api.postData('/api/v1/customer/voyage/trips/$id/book', {'seats': seats, 'payment_method': method}, handleError: false));
  static Future<dynamic> bookings() async => _body(await _api.getData('/api/v1/customer/voyage/bookings', handleError: false));
  static Future<dynamic> cancel(int id) async => _body(await _api.postData('/api/v1/customer/voyage/bookings/$id/cancel', {}, handleError: false));
  static Future<dynamic> rate(int id, int stars) async =>
      _body(await _api.postData('/api/v1/customer/voyage/bookings/$id/rate', {'rating': stars}, handleError: false));
}

void _toast(Object e) => Get.snackbar('Je Voyage', '$e', snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));

bool get _loggedIn => Get.find<AuthController>().isLoggedIn();

const _days = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
const _months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];

/// "Aujourd'hui", "Demain" or "mar. 25 nov.".
String voyageDay(dynamic date) {
  final d = DateTime.tryParse('${date ?? ''}');
  if (d == null) return '';
  final today = DateTime.now();
  final diff = DateTime(d.year, d.month, d.day).difference(DateTime(today.year, today.month, today.day)).inDays;
  if (diff == 0) return 'Aujourd’hui';
  if (diff == 1) return 'Demain';
  return '${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';
}

String voyageTime(dynamic t) => '${t ?? ''}'.replaceAll(':', 'h');

const _statusLabels = {
  'scheduled': 'Places disponibles',
  'full': 'Complet',
  'boarding': 'Embarquement',
  'in_progress': 'En route',
  'completed': 'Arrivé',
  'cancelled': 'Annulé',
  'confirmed': 'Confirmée',
  'boarded': 'À bord',
  'no_show': 'Absent',
};

Color _statusColor(String? s) => switch (s) {
      'scheduled' || 'confirmed' || 'completed' => const Color(0xFF15803D),
      'full' || 'cancelled' || 'no_show' => NoorTheme.danger,
      'boarding' => const Color(0xFF92400E),
      'in_progress' || 'boarded' => const Color(0xFF0369A1),
      _ => NoorTheme.muted,
    };

class _Chip extends StatelessWidget {
  final String? status;
  const _Chip(this.status);
  @override
  Widget build(BuildContext context) {
    final c = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(_statusLabels[status] ?? '$status', style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12.5)),
    );
  }
}

/// Seats left: green while open, red and flashing on the last seat, grey when full.
class VoyageSeatBar extends StatefulWidget {
  final Map trip;
  final bool compact;
  const VoyageSeatBar({super.key, required this.trip, this.compact = false});
  @override
  State<VoyageSeatBar> createState() => _VoyageSeatBarState();
}

class _VoyageSeatBarState extends State<VoyageSeatBar> with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant VoyageSeatBar old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.trip['seat_state'] == 'last') {
      if (!_blink.isAnimating) _blink.repeat(reverse: true);
    } else {
      _blink.stop();
      _blink.value = 0;
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _i(widget.trip['total_seats']);
    final left = _i(widget.trip['available_seats']);
    final booked = total - left;
    final state = widget.trip['seat_state'];
    final size = widget.compact ? 11.0 : 14.0;
    final text = state == 'full' ? 'Complet' : state == 'last' ? 'Dernière place !' : '$left places restantes sur $total';
    final color = state == 'full' ? NoorTheme.muted : state == 'last' ? NoorTheme.danger : const Color(0xFF15803D);
    return AnimatedBuilder(
      animation: _blink,
      builder: (ctx, child) {
        final fade = state == 'last' ? 1 - _blink.value * 0.75 : 1.0;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Wrap(spacing: 4, runSpacing: 4, children: [
            for (var i = 0; i < total.clamp(0, 16); i++)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: i < booked ? const Color(0xFFD4D4D8) : (state == 'last' ? NoorTheme.danger.withValues(alpha: fade) : _okGreen),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ]),
          const SizedBox(height: 5),
          Opacity(opacity: fade, child: Text(text, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: color))),
        ]);
      },
    );
  }
}

Widget _card({required Widget child, VoidCallback? onTap, EdgeInsets padding = const EdgeInsets.all(16), Color? border}) => Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: border ?? NoorTheme.line, width: border != null ? 2 : 1)),
          child: child,
        ),
      ),
    );

PreferredSizeWidget _appBar(String title, {List<Widget>? actions}) => AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 19, color: Colors.white)),
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0B5D73), _teal]))),
      backgroundColor: _teal,
      elevation: 0,
      actions: actions,
    );

/// One trip in a list: route, day and time, seats, price, Réserver.
class VoyageTripCard extends StatelessWidget {
  final Map trip;
  final VoidCallback onOpen;
  final VoidCallback onBook;
  const VoyageTripCard({super.key, required this.trip, required this.onOpen, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final open = trip['status'] == 'scheduled' && _i(trip['available_seats']) > 0;
    final rating = _d(trip['driver']?['rating']) ?? 0;
    return _card(
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '${trip['origin']?['name']}'),
              const WidgetSpan(child: Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.arrow_forward, size: 16))),
              TextSpan(text: '${trip['destination']?['name']}'),
            ]), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ),
          Text(_money(trip['price_per_seat']), style: const TextStyle(fontWeight: FontWeight.w800, color: _teal, fontSize: 16)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.schedule, size: 15, color: NoorTheme.muted),
          const SizedBox(width: 4),
          Text('${voyageDay(trip['departure_date'])} · ', style: const TextStyle(color: NoorTheme.muted)),
          Text(voyageTime(trip['departure_time']), style: const TextStyle(fontWeight: FontWeight.w800)),
          const Spacer(),
          const Icon(Icons.star_rounded, size: 17, color: Color(0xFFF5B301)),
          Text(rating > 0 ? rating.toStringAsFixed(1) : 'Nouveau', style: const TextStyle(fontSize: 13.5)),
        ]),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: VoyageSeatBar(trip: trip, compact: true)),
          const SizedBox(width: 10),
          if (trip['my_booking'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(999)),
              child: const Text('Réservé', style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w800)),
            )
          else
            ElevatedButton(
              onPressed: open ? onBook : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                elevation: 0,
              ),
              child: Text(open ? 'Réserver' : 'Complet', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
        ]),
      ]),
    );
  }
}

/// Seats and payment, then one tap. In the quick booking sheet and on the trip page.
class VoyageBookingForm extends StatefulWidget {
  final Map trip;
  final Map? config;
  final ValueChanged<Map> onBooked;
  const VoyageBookingForm({super.key, required this.trip, required this.config, required this.onBooked});
  @override
  State<VoyageBookingForm> createState() => _VoyageBookingFormState();
}

class _VoyageBookingFormState extends State<VoyageBookingForm> {
  int _seats = 1;
  String? _method;
  bool _busy = false;

  List<String> get _methods => List<String>.from(widget.config?['payment_methods'] ?? ['cash']);
  double get _balance => Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0;

  @override
  void initState() {
    super.initState();
    final price = _d(widget.trip['price_per_seat']) ?? 0;
    _method = _methods.contains('wallet') && _balance >= price ? 'wallet' : (_methods.isNotEmpty ? _methods.first : 'cash');
  }

  Future<void> _book() async {
    if (!_loggedIn) {
      Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.voyage));
      return;
    }
    setState(() => _busy = true);
    try {
      final r = await VoyageApi.book(_i(widget.trip['id']), _seats, _method!);
      Get.find<ProfileController>().getUserInfo();
      widget.onBooked(Map.from(r['booking'] ?? {}));
    } catch (e) {
      _toast(e);
    }
    if (mounted) setState(() => _busy = false);
  }

  Widget _payOption(String method, IconData icon, String title, String sub) {
    final active = _method == method;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _method = method),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? _tealSoft : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: active ? _teal : NoorTheme.line, width: 1.5),
          ),
          child: Row(children: [
            Icon(icon, color: active ? _teal : NoorTheme.text),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(sub, style: const TextStyle(color: NoorTheme.muted, fontSize: 12)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = _d(widget.trip['price_per_seat']) ?? 0;
    final max = _i(widget.trip['available_seats']).clamp(0, _i(widget.config?['max_seats_per_booking'] ?? 6));
    final total = price * _seats;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        const Icon(Icons.people_outline),
        const SizedBox(width: 8),
        const Text('Places', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const Spacer(),
        IconButton.outlined(onPressed: _seats > 1 ? () => setState(() => _seats--) : null, icon: const Icon(Icons.remove)),
        SizedBox(width: 34, child: Text('$_seats', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
        IconButton.outlined(onPressed: _seats < max ? () => setState(() => _seats++) : null, icon: const Icon(Icons.add)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        if (_methods.contains('wallet')) _payOption('wallet', Icons.account_balance_wallet_outlined, 'Portefeuille Noor', 'Solde : ${_money(_balance)}'),
        if (_methods.length > 1) const SizedBox(width: 8),
        if (_methods.contains('cash')) _payOption('cash', Icons.payments_outlined, 'Espèces', 'À payer au chauffeur'),
      ]),
      if (_method == 'wallet' && _loggedIn && _balance < total)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('Solde insuffisant : recharge ton portefeuille ou paie en espèces.', style: TextStyle(color: NoorTheme.danger)),
        ),
      const SizedBox(height: 14),
      SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: _busy || max < 1 ? null : _book,
          style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white, shape: const StadiumBorder(), elevation: 0),
          child: _busy
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
              : Text('Réserver $_seats place(s) · ${_money(total)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ),
      ),
    ]);
  }
}

Future<Map?> _quickBook(BuildContext context, Map trip, Map? config) => showModalBottomSheet<Map>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, 24 + MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text('${trip['origin']?['name']} → ${trip['destination']?['name']}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            ),
            IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
          ]),
          Text('${voyageDay(trip['departure_date'])} · ${voyageTime(trip['departure_time'])} · ${_money(trip['price_per_seat'])} par place',
              style: const TextStyle(color: NoorTheme.muted)),
          const SizedBox(height: 12),
          VoyageSeatBar(trip: trip),
          const SizedBox(height: 16),
          VoyageBookingForm(trip: trip, config: config, onBooked: (b) => Navigator.pop(ctx, b)),
        ]),
      ),
    );

/// Je Voyage home: search, then the 5 latest trips (or the results).
class VoyageHomeScreen extends StatefulWidget {
  const VoyageHomeScreen({super.key});
  @override
  State<VoyageHomeScreen> createState() => _VoyageHomeScreenState();
}

class _VoyageHomeScreenState extends State<VoyageHomeScreen> {
  Map? _config;
  List<Map> _latest = [];
  List<Map>? _results;
  bool _loading = true;
  int? _from;
  int? _to;
  DateTime? _date;
  Map? _booked;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final c = await VoyageApi.config();
      final l = await VoyageApi.latest();
      if (!mounted) return;
      setState(() {
        _config = Map.from(c);
        _latest = List<Map>.from(l['trips'] ?? []);
      });
      if (_results != null) await _search();
    } catch (e) {
      _toast(e);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _search() async {
    setState(() => _results = null);
    try {
      final r = await VoyageApi.search(from: _from, to: _to, date: _date == null ? null : DateFormat('yyyy-MM-dd').format(_date!));
      if (mounted) setState(() => _results = List<Map>.from(r['trips'] ?? []));
    } catch (e) {
      _toast(e);
      if (mounted) setState(() => _results = []);
    }
  }

  bool get _searching => _from != null || _to != null || _date != null;

  Future<void> _book(Map trip) async {
    final b = await _quickBook(context, trip, _config);
    if (b != null) {
      setState(() => _booked = b);
      _load();
    }
  }

  void _open(Map trip) async {
    await Get.to(() => VoyageTripScreen(tripId: _i(trip['id'])));
    _load();
  }

  Widget _cityPicker(String hint, int? value, Color pin, ValueChanged<int?> onChanged) => Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(border: Border.all(color: NoorTheme.line, width: 1.5), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(Icons.location_on_outlined, color: pin),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: value,
                isExpanded: true,
                hint: Text(hint),
                items: [
                  DropdownMenuItem<int?>(value: null, child: Text(hint, style: const TextStyle(color: NoorTheme.muted))),
                  for (final c in List<Map>.from(_config?['cities'] ?? [])) DropdownMenuItem<int?>(value: _i(c['id']), child: Text('${c['name']}')),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final list = _searching && _results != null ? _results! : _latest;
    return Scaffold(
      backgroundColor: NoorTheme.bg,
      appBar: _appBar('Je Voyage', actions: [
        if (_loggedIn)
          TextButton.icon(
            onPressed: () => Get.to(() => const VoyageBookingsScreen()),
            icon: const Icon(Icons.confirmation_number_outlined, color: Colors.white),
            label: const Text('Mes voyages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                // Je Voyage's slide show (admin: Module home slides manager).
                NoorModuleSlides(moduleId: Get.find<SplashController>().voyageModule?.id, padding: const EdgeInsets.only(bottom: 14)),
                if (_config?['enabled'] == false)
                  const Padding(padding: EdgeInsets.only(bottom: 12), child: Text('Je Voyage est momentanément indisponible.', style: TextStyle(color: NoorTheme.danger))),
                _card(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    if ((_config?['tagline'] ?? '').toString().isNotEmpty)
                      Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('${_config!['tagline']}', style: const TextStyle(color: NoorTheme.muted))),
                    Stack(children: [
                      Column(children: [
                        _cityPicker('Ville de départ', _from, const Color(0xFF16A34A), (v) => setState(() => _from = v)),
                        const SizedBox(height: 8),
                        _cityPicker('Ville d’arrivée', _to, NoorTheme.danger, (v) => setState(() => _to = v)),
                      ]),
                      Positioned(
                        right: 40,
                        top: 39,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(side: BorderSide(color: NoorTheme.line, width: 1.5)),
                          child: IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => setState(() {
                              final f = _from;
                              _from = _to;
                              _to = f;
                            }),
                            icon: const Icon(Icons.swap_vert, color: _teal),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            final d = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)), initialDate: _date ?? DateTime.now());
                            setState(() => _date = d);
                          },
                          child: Container(
                            height: 54,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(border: Border.all(color: NoorTheme.line, width: 1.5), borderRadius: BorderRadius.circular(14)),
                            child: Row(children: [
                              const Icon(Icons.calendar_today_outlined, color: NoorTheme.muted, size: 20),
                              const SizedBox(width: 8),
                              Text(_date == null ? 'Toutes les dates' : voyageDay(_date!.toIso8601String())),
                            ]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _search,
                          style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                          icon: const Icon(Icons.search),
                          label: const Text('Rechercher', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ]),
                  ]),
                ),
                if (_booked != null) ...[
                  const SizedBox(height: 12),
                  _card(
                    border: const Color(0xFF86EFAC),
                    onTap: () => _open(Map.from(_booked!['trip'] ?? {})),
                    child: Row(children: [
                      const Icon(Icons.check_circle, color: Color(0xFF15803D)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Place réservée ! ${_booked!['trip']?['origin']?['name']} → ${_booked!['trip']?['destination']?['name']}. '
                          '${_booked!['payment_method'] == 'cash' ? 'Tu paies le chauffeur au départ.' : 'Payé par portefeuille.'}',
                          style: const TextStyle(color: Color(0xFF14532D)),
                        ),
                      ),
                    ]),
                  ),
                ],
                const SizedBox(height: 18),
                Row(children: [
                  Text(_searching && _results != null ? 'Trajets trouvés' : 'Derniers trajets publiés', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  if (_searching)
                    TextButton(
                      onPressed: () => setState(() {
                        _from = null;
                        _to = null;
                        _date = null;
                        _results = null;
                      }),
                      child: const Text('Effacer', style: TextStyle(color: _teal)),
                    ),
                ]),
                const SizedBox(height: 8),
                if (_searching && _results == null && _loading) const Center(child: CircularProgressIndicator()),
                if (list.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Column(children: [
                      Icon(Icons.directions_bus_outlined, size: 44, color: NoorTheme.muted),
                      SizedBox(height: 8),
                      Text('Aucun trajet pour le moment', style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('Les chauffeurs Noor Pro publient leurs départs ici.', style: TextStyle(color: NoorTheme.muted)),
                    ]),
                  ),
                for (final t in list)
                  Padding(padding: const EdgeInsets.only(bottom: 10), child: VoyageTripCard(trip: t, onOpen: () => _open(t), onBook: () => _book(t))),
              ]),
            ),
    );
  }
}

/// A trip: route and time, seats, driver and car, map, booking; once booked,
/// the driver's phone and plate, the live position and cancellation.
class VoyageTripScreen extends StatefulWidget {
  final int tripId;
  const VoyageTripScreen({super.key, required this.tripId});
  @override
  State<VoyageTripScreen> createState() => _VoyageTripScreenState();
}

class _VoyageTripScreenState extends State<VoyageTripScreen> {
  Map? _trip;
  Map? _config;
  bool _busy = false;
  bool _justBooked = false;
  Timer? _poll;
  GoogleMapController? _map;

  @override
  void initState() {
    super.initState();
    _load();
    VoyageApi.config().then((c) => mounted ? setState(() => _config = Map.from(c)) : null).catchError((_) => null);
    // On the road: the car's position every 15 s.
    _poll = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_trip?['live'] != null || ['boarding', 'in_progress'].contains(_trip?['status'])) _load();
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final r = await VoyageApi.trip(widget.tripId);
      if (!mounted) return;
      setState(() => _trip = Map.from(r['trip']));
      final live = _trip!['live'];
      if (live != null) _map?.animateCamera(CameraUpdate.newLatLng(LatLng(_d(live['lat'])!, _d(live['lng'])!)));
    } catch (e) {
      _toast(e);
    }
  }

  Future<void> _cancel(Map mine) async {
    final ok = await Get.dialog<bool>(AlertDialog(
      content: const Text('Annuler ta réservation ? Si tu as payé par portefeuille, tu es remboursé tout de suite.'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Non')),
        TextButton(onPressed: () => Get.back(result: true), child: const Text('Oui, annuler', style: TextStyle(color: NoorTheme.danger))),
      ],
    ));
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await VoyageApi.cancel(_i(mine['id']));
      Get.find<ProfileController>().getUserInfo();
      await _load();
    } catch (e) {
      _toast(e);
    }
    if (mounted) setState(() => _busy = false);
  }

  Widget _section(IconData icon, String title, List<Widget> children, {Color? border}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _card(
          border: border,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5))]),
            const SizedBox(height: 10),
            ...children,
          ]),
        ),
      );

  Widget _mapView(Map t) {
    final origin = t['meeting_lat'] != null
        ? LatLng(_d(t['meeting_lat'])!, _d(t['meeting_lng'])!)
        : (t['origin']?['lat'] != null ? LatLng(_d(t['origin']['lat'])!, _d(t['origin']['lng'])!) : null);
    final dest = t['destination']?['lat'] != null ? LatLng(_d(t['destination']['lat'])!, _d(t['destination']['lng'])!) : null;
    final live = t['live'];
    final car = live != null ? LatLng(_d(live['lat'])!, _d(live['lng'])!) : null;
    final center = car ?? origin ?? dest;
    if (center == null) return const SizedBox.shrink();
    final markers = <Marker>{
      if (origin != null) Marker(markerId: const MarkerId('from'), position: origin, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), infoWindow: InfoWindow(title: '${t['origin']?['name']}')),
      if (dest != null) Marker(markerId: const MarkerId('to'), position: dest, infoWindow: InfoWindow(title: '${t['destination']?['name']}')),
      if (car != null) Marker(markerId: const MarkerId('car'), position: car, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), rotation: _d(live['heading']) ?? 0, infoWindow: const InfoWindow(title: 'Ton chauffeur')),
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 220,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: center, zoom: car != null ? 11 : 9),
          markers: markers,
          polylines: {
            if (origin != null && dest != null)
              Polyline(polylineId: const PolylineId('route'), points: [origin, if (car != null) car, dest], color: _teal, width: 4, patterns: [PatternItem.dash(18), PatternItem.gap(10)]),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (m) {
            _map = m;
            if (origin != null && dest != null && car == null) {
              final b = LatLngBounds(
                southwest: LatLng(origin.latitude < dest.latitude ? origin.latitude : dest.latitude, origin.longitude < dest.longitude ? origin.longitude : dest.longitude),
                northeast: LatLng(origin.latitude > dest.latitude ? origin.latitude : dest.latitude, origin.longitude > dest.longitude ? origin.longitude : dest.longitude),
              );
              Future.delayed(const Duration(milliseconds: 300), () => m.animateCamera(CameraUpdate.newLatLngBounds(b, 40)));
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _trip;
    if (t == null) return Scaffold(appBar: _appBar('Trajet'), body: const Center(child: CircularProgressIndicator()));
    final d = Map.from(t['driver'] ?? {});
    final mine = t['my_booking'] as Map?;
    final bookable = mine == null && t['status'] == 'scheduled' && _i(t['available_seats']) > 0;
    final rating = _d(d['rating']) ?? 0;

    return Scaffold(
      backgroundColor: NoorTheme.bg,
      appBar: _appBar('${t['origin']?['name']} → ${t['destination']?['name']}'),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          if (_justBooked)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _card(
                border: const Color(0xFF86EFAC),
                child: const Row(children: [
                  Icon(Icons.check_circle, color: Color(0xFF15803D)),
                  SizedBox(width: 10),
                  Expanded(child: Text('Place réservée ! Le chauffeur est prévenu. Tu recevras une notification à l’embarquement.')),
                ]),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _card(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.circle, size: 12, color: Color(0xFF16A34A)),
                        const SizedBox(width: 8),
                        Text('${t['origin']?['name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      ]),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text('${voyageDay(t['departure_date'])} · ${voyageTime(t['departure_time'])}', style: const TextStyle(color: NoorTheme.muted)),
                      ),
                      const Icon(Icons.arrow_downward, size: 16, color: NoorTheme.muted),
                      Row(children: [
                        const Icon(Icons.square_rounded, size: 12, color: NoorTheme.danger),
                        const SizedBox(width: 8),
                        Text('${t['destination']?['name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      ]),
                    ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(_money(t['price_per_seat']), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _teal)),
                    const Text('par place', style: TextStyle(color: NoorTheme.muted)),
                    const SizedBox(height: 6),
                    _Chip(t['status']),
                  ]),
                ]),
                const SizedBox(height: 12),
                VoyageSeatBar(trip: t),
              ]),
            ),
          ),
          if (mine != null)
            _section(Icons.verified_user_outlined, 'Ma réservation · ${_statusLabels[mine['status']] ?? mine['status']}', [
              Text('${mine['seats']} place(s) · ${_money(mine['total'])} · '
                  '${mine['payment_method'] == 'cash' ? 'espèces, à payer au chauffeur' : mine['payment_status'] == 'refunded' ? 'remboursé' : 'payé par portefeuille'}'),
              Text('Référence ${mine['reference']}', style: const TextStyle(color: NoorTheme.muted, fontSize: 12.5)),
              if (mine['can_cancel'] == true) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _cancel(mine),
                    style: OutlinedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Annuler ma réservation'),
                  ),
                ),
              ],
            ], border: _teal),
          _section(Icons.place_outlined, t['live'] != null ? 'Le trajet en direct' : 'Départ', [
            if ((t['meeting_point'] ?? '').toString().isNotEmpty)
              Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('Rendez-vous : ${t['meeting_point']}', style: const TextStyle(color: NoorTheme.muted))),
            _mapView(t),
            if (t['live']?['updated_at'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Position mise à jour à ${DateFormat('HH:mm').format(DateTime.parse(t['live']['updated_at']).toLocal())}',
                    style: const TextStyle(color: NoorTheme.muted, fontSize: 12.5)),
              ),
          ]),
          _section(Icons.person_outline, 'Le chauffeur', [
            Row(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: _tealSoft,
                backgroundImage: d['image'] != null ? NetworkImage('${d['image']}') : null,
                child: d['image'] == null ? const Icon(Icons.person, color: _teal) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${d['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 17, color: Color(0xFFF5B301)),
                    Text(' ${rating > 0 ? '${rating.toStringAsFixed(1)} (${d['rating_count']})' : 'Nouveau chauffeur'} · ${d['total_trips'] ?? 0} trajet(s)'),
                  ]),
                ]),
              ),
            ]),
            if (d['phone'] != null) ...[
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => launchUrl(Uri.parse('tel:${d['phone']}')),
                    icon: const Icon(Icons.phone),
                    label: const Text('Appeler'),
                    style: OutlinedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse('https://wa.me/${'${d['phone']}'.replaceAll(RegExp(r'\D'), '')}?text=${Uri.encodeComponent('Bonjour, j’ai réservé sur ton trajet ${t['origin']?['name']} → ${t['destination']?['name']} (Noor Je Voyage).')}'),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('WhatsApp'),
                    style: OutlinedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ]),
            ],
          ]),
          _section(Icons.directions_car_outlined, 'Le véhicule', [
            if (d['vehicle_photo'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network('${d['vehicle_photo']}', height: 190, width: double.infinity, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => const SizedBox.shrink()),
                ),
              ),
            Text(
              [
                [d['vehicle_make'], d['vehicle_model']].where((e) => e != null && '$e'.isNotEmpty).join(' '),
                d['vehicle_color'],
                d['category'],
              ].where((e) => e != null && '$e'.isNotEmpty).join(' · '),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            if (d['plate_number'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(border: Border.all(width: 2), borderRadius: BorderRadius.circular(6)),
                child: Text('${d['plate_number']}', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              )
            else
              const Text('La plaque s’affiche après la réservation.', style: TextStyle(color: NoorTheme.muted)),
          ]),
          _section(Icons.info_outline, 'Bon à savoir', [
            Text('Réservation possible jusqu’à ${_config?['booking_cutoff_minutes'] ?? 15} min avant le départ.', style: const TextStyle(color: NoorTheme.muted)),
            Text('Annulation gratuite jusqu’à ${((_i(_config?['free_cancel_minutes'] ?? 120)) / 60).round()} h avant le départ.', style: const TextStyle(color: NoorTheme.muted)),
            if ((t['notes'] ?? '').toString().isNotEmpty) Text('${t['notes']}'),
          ]),
          if (bookable)
            _section(Icons.event_seat_outlined, 'Réserver', [
              VoyageBookingForm(
                trip: t,
                config: _config,
                onBooked: (_) async {
                  setState(() => _justBooked = true);
                  await _load();
                },
              ),
            ]),
        ]),
      ),
    );
  }
}

/// "Mes voyages": upcoming bookings, then past ones (rate the driver).
class VoyageBookingsScreen extends StatefulWidget {
  const VoyageBookingsScreen({super.key});
  @override
  State<VoyageBookingsScreen> createState() => _VoyageBookingsScreenState();
}

class _VoyageBookingsScreenState extends State<VoyageBookingsScreen> {
  List<Map>? _upcoming;
  List<Map> _past = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await VoyageApi.bookings();
      if (!mounted) return;
      setState(() {
        _upcoming = List<Map>.from(r['upcoming'] ?? []);
        _past = List<Map>.from(r['past'] ?? []);
      });
    } catch (e) {
      _toast(e);
      if (mounted) setState(() => _upcoming = []);
    }
  }

  Widget _row(Map b) {
    final t = Map.from(b['trip'] ?? {});
    final shown = b['status'] == 'confirmed' ? t['status'] : b['status'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _card(
        onTap: () async {
          await Get.to(() => VoyageTripScreen(tripId: _i(t['id'])));
          _load();
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('${t['origin']?['name']} → ${t['destination']?['name']}', style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800))),
            _Chip(shown),
          ]),
          const SizedBox(height: 4),
          Text('${voyageDay(t['departure_date'])} · ${voyageTime(t['departure_time'])} · ${b['seats']} place(s) · ${_money(b['total'])}',
              style: const TextStyle(color: NoorTheme.muted)),
          if (b['status'] == 'completed') ...[
            const SizedBox(height: 6),
            b['rating'] != null
                ? Text('Ta note : ${'★' * _i(b['rating'])}', style: const TextStyle(color: Color(0xFFF5B301)))
                : Row(children: [
                    const Text('Note le chauffeur :'),
                    for (var n = 1; n <= 5; n++)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () async {
                          try {
                            await VoyageApi.rate(_i(b['id']), n);
                            _load();
                          } catch (e) {
                            _toast(e);
                          }
                        },
                        icon: const Icon(Icons.star_border_rounded, color: Color(0xFFF5B301)),
                      ),
                  ]),
          ],
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.bg,
      appBar: _appBar('Mes voyages'),
      body: _upcoming == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                if (_upcoming!.isEmpty && _past.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(children: [
                      const Icon(Icons.directions_bus_outlined, size: 48, color: NoorTheme.muted),
                      const SizedBox(height: 8),
                      const Text('Aucun voyage pour le moment', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white, shape: const StadiumBorder()),
                        child: const Text('Trouver un trajet'),
                      ),
                    ]),
                  ),
                if (_upcoming!.isNotEmpty) const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('À venir', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                for (final b in _upcoming!) _row(b),
                if (_past.isNotEmpty) const Padding(padding: EdgeInsets.only(bottom: 8, top: 8), child: Text('Passés', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                for (final b in _past) _row(b),
              ]),
            ),
    );
  }
}
