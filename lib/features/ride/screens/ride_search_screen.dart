import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/ride/controllers/ride_controller.dart';
import 'package:sixam_mart/features/ride/domain/ride_models.dart';
import 'package:sixam_mart/util/styles.dart';

/// Result of the address search: a place, or "choose on the map".
class RideSearchResult {
  final RidePlace? place;
  final bool onMap;
  const RideSearchResult.place(this.place) : onMap = false;
  const RideSearchResult.map()
      : place = null,
        onMap = true;
}

/// Address search for the pick-up or the destination, like Yango's
/// "Où allez-vous ?" screen: suggestions, recent places, my position, map.
class RideSearchScreen extends StatefulWidget {
  final bool forPickup;
  const RideSearchScreen({super.key, required this.forPickup});

  @override
  State<RideSearchScreen> createState() => _RideSearchScreenState();
}

class _RideSearchScreenState extends State<RideSearchScreen> {
  final _text = TextEditingController();
  Timer? _debounce;
  List<PlaceSuggestion> _results = [];
  bool _busy = false;

  RideController get _c => Get.find<RideController>();

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final r = await _c.search(value.trim());
      if (mounted && _text.text == value) setState(() => _results = r);
    });
  }

  Future<void> _choose(PlaceSuggestion s) async {
    setState(() => _busy = true);
    final p = await _c.placeDetails(s.placeId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (p != null) Get.back(result: RideSearchResult.place(p.address.isEmpty ? p.withAddress(s.main) : p));
  }

  Future<void> _here() async {
    setState(() => _busy = true);
    final p = await _c.currentPlace();
    if (!mounted) return;
    setState(() => _busy = false);
    if (p != null) Get.back(result: RideSearchResult.place(p));
  }

  @override
  Widget build(BuildContext context) {
    final other = widget.forPickup ? _c.destination : _c.pickup;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
              Expanded(
                child: Column(children: [
                  if (!widget.forPickup)
                    _FieldBox(dot: _Dot.green, child: Text(other?.short.isNotEmpty == true ? other!.short : 'ride_pickup'.tr, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (!widget.forPickup) const SizedBox(height: 8),
                  _FieldBox(
                    dot: widget.forPickup ? _Dot.green : _Dot.red,
                    active: true,
                    child: TextField(
                      controller: _text,
                      autofocus: true,
                      onChanged: _onChanged,
                      decoration: InputDecoration.collapsed(hintText: widget.forPickup ? 'ride_pickup'.tr : 'ride_where_to'.tr),
                      style: robotoMedium.copyWith(fontSize: 16),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
          if (_busy) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
              if (widget.forPickup) _ResultTile(icon: Icons.my_location, title: 'ride_my_position'.tr, onTap: _busy ? null : _here),
              _ResultTile(icon: Icons.place_outlined, title: 'ride_choose_on_map'.tr, onTap: () => Get.back(result: const RideSearchResult.map())),
              if (_results.isNotEmpty)
                ..._results.map((s) => _ResultTile(icon: Icons.search, title: s.main, subtitle: s.secondary, onTap: _busy ? null : () => _choose(s)))
              else if (_text.text.trim().length < 3)
                ..._c.recent.map((p) => _ResultTile(icon: Icons.history, title: p.short, subtitle: p.address, onTap: () => Get.back(result: RideSearchResult.place(p)))),
            ]),
          ),
        ]),
      ),
    );
  }
}

enum _Dot { green, red }

class _FieldBox extends StatelessWidget {
  final _Dot dot;
  final bool active;
  final Widget child;
  const _FieldBox({required this.dot, required this.child, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: active ? Colors.white : const Color(0xFFF1F1F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? const Color(0xFF1C1C1E) : Colors.transparent, width: 2),
      ),
      child: Row(children: [
        RideDot(red: dot == _Dot.red),
        const SizedBox(width: 10),
        Expanded(child: child),
      ]),
    );
  }
}

/// Green round dot for the pick-up, red square for the destination.
class RideDot extends StatelessWidget {
  final bool red;
  const RideDot({super.key, this.red = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: red ? const Color(0xFFC81E1E) : const Color(0xFF16A34A),
        shape: red ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: red ? BorderRadius.circular(3) : null,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 1)],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _ResultTile({required this.icon, required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA)))),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(color: Color(0xFFF1F1F3), shape: BoxShape.circle),
            child: Icon(icon, size: 19, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(color: Colors.black54, fontSize: 13)),
            ]),
          ),
        ]),
      ),
    );
  }
}
