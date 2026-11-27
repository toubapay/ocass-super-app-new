import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/noor_shop/noor_catalog.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

/// The short slide show at the top of a module's home (admin: Module home
/// slides manager), as ModuleSlides.jsx in the web app: 132 px high, swipe
/// or a new slide every 5 s, dots below. Draws nothing without a published
/// slide.
class NoorModuleSlides extends StatefulWidget {
  final int? moduleId;
  final EdgeInsets padding;

  /// A slide linked to a category of the open module (the module screen
  /// shows that category in place). Without it, nothing happens.
  final void Function(int categoryId)? onCategory;

  const NoorModuleSlides({super.key, required this.moduleId, this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 0), this.onCategory});

  @override
  State<NoorModuleSlides> createState() => _NoorModuleSlidesState();
}

class _NoorModuleSlidesState extends State<NoorModuleSlides> {
  static const _delay = Duration(seconds: 5);
  final _page = PageController();
  List<Map<String, dynamic>> _slides = [];
  int _index = 0;
  Timer? _timer;
  bool _touching = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant NoorModuleSlides old) {
    super.didUpdateWidget(old);
    if (old.moduleId != widget.moduleId) _load();
  }

  Future<void> _load() async {
    final id = widget.moduleId;
    if (id == null) return;
    try {
      final s = await NoorCatalog.moduleSlides(id);
      if (!mounted) return;
      setState(() {
        _slides = s;
        _index = 0;
      });
      _timer?.cancel();
      if (s.length > 1) _timer = Timer.periodic(_delay, (_) => _next());
    } catch (_) {}
  }

  void _next() {
    if (!mounted || _touching || !_page.hasClients || _slides.length < 2) return;
    _page.animateToPage((_index + 1) % _slides.length, duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  Future<void> _open(Map<String, dynamic> s) async {
    final value = '${s['link_value'] ?? ''}';
    final id = int.tryParse(value);
    switch (s['link_type']) {
      case 'url':
        final uri = Uri.tryParse(value);
        if (uri != null && uri.scheme == 'https') await launchUrl(uri, mode: LaunchMode.externalApplication);
        break;
      case 'store':
        if (id != null) NoorCatalog.openStore(id: id, moduleId: (s['module_id'] as num?)?.toInt() ?? widget.moduleId);
        break;
      case 'item':
        if (id != null) Get.toNamed(RouteHelper.getItemDetailsRoute(id, false));
        break;
      case 'category':
        if (id != null) widget.onCategory?.call(id);
        break;
    }
  }

  static Color _color(String? hex, Color fallback) {
    final h = (hex ?? '').replaceFirst('#', '');
    final v = int.tryParse(h, radix: 16);
    return h.length == 6 && v != null ? Color(0xFF000000 | v) : fallback;
  }

  @override
  Widget build(BuildContext context) {
    if (_slides.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: widget.padding,
      child: Column(children: [
        Listener(
          onPointerDown: (_) => _touching = true,
          onPointerUp: (_) => _touching = false,
          onPointerCancel: (_) => _touching = false,
          child: SizedBox(
            height: 132,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: PageView.builder(
                controller: _page,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _slide(_slides[i]),
              ),
            ),
          ),
        ),
        if (_slides.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (int i = 0; i < _slides.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _index ? NoorShopColors.green : const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ]),
          ),
      ]),
    );
  }

  Widget _slide(Map<String, dynamic> s) {
    final dark = s['text_color'] == 'dark';
    final fg = dark ? const Color(0xFF1C1C1E) : Colors.white;
    final image = '${s['image_full_url'] ?? ''}';
    final linked = s['link_type'] != null && s['link_type'] != 'none';
    final subtitle = '${s['subtitle'] ?? ''}';
    return GestureDetector(
      onTap: linked ? () => _open(s) : null,
      child: Container(
        color: _color(s['background'] as String?, NoorShopColors.green),
        child: Stack(children: [
          if (image.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.sizeOf(context).width * 0.42,
              child: CachedNetworkImage(
                // Web builds go through the server's image proxy (as CustomImage).
                imageUrl: kIsWeb ? '${AppConstants.baseUrl}/image-proxy?url=$image' : image,
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
                placeholder: (_, __) => const SizedBox.shrink(),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FractionallySizedBox(
              widthFactor: 0.6,
              alignment: Alignment.centerLeft,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${s['title'] ?? ''}', maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fg, fontSize: 22, fontWeight: FontWeight.w800, height: 1.12)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: fg.withValues(alpha: 0.9), fontSize: 14, height: 1.3)),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
