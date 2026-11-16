import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

const _green = Color(0xFF0E4D3A);
const _red = Color(0xFFBE123C);

/// "Offres du moment" on the home screen, right after the services: label,
/// title, the discount on the animated gift's tag, button text and link
/// (promo codes, a store or a product), all set by the admin
/// (Admin > Boutiques à la une, /api/v1/offer-banner).
class OfferBannerSection extends StatefulWidget {
  const OfferBannerSection({super.key});

  @override
  State<OfferBannerSection> createState() => _OfferBannerSectionState();
}

class _OfferBannerSectionState extends State<OfferBannerSection> {
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await Get.find<ApiClient>().getData(AppConstants.offerBannerUri, handleError: false);
    if (!mounted || r.statusCode != 200 || r.body is! Map || r.body['enabled'] != true) return;
    setState(() => _data = Map<String, dynamic>.from(r.body));
  }

  void _open() {
    final d = _data!;
    final id = (d['link_id'] as num?)?.toInt();
    switch (d['link_type']) {
      case 'store':
        if (id != null) {
          Get.toNamed(RouteHelper.getStoreRoute(id: id, page: 'store'));
          return;
        }
        break;
      case 'item':
        if (id != null) {
          Get.toNamed(RouteHelper.getItemDetailsRoute(id, false));
          return;
        }
        break;
    }
    Get.toNamed(RouteHelper.getCouponRoute());
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    if (d == null) return const SizedBox.shrink();
    final pill = (d['pill'] ?? '').toString();
    final cta = (d['cta'] ?? '').toString();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _open,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 6, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.10), blurRadius: 18, offset: const Offset(0, 4))],
            ),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (pill.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(6)),
                      child: Text(pill, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                  const SizedBox(height: 7),
                  Text((d['title'] ?? '').toString(), style: const TextStyle(fontSize: 19, height: 1.2, fontWeight: FontWeight.w900, color: Color(0xFF111111))),
                  if (cta.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text('$cta ›', style: const TextStyle(color: _green, fontSize: 13.5, fontWeight: FontWeight.w800)),
                  ],
                ]),
              ),
              AnimatedGift(tag: (d['tag'] ?? '').toString()),
            ]),
          ),
        ),
      ),
    );
  }
}

/// The animated gift: the lid pops with a golden glow, the red tag swings,
/// and sparkles twinkle. Drawn from small SVG layers (no download); still
/// when the phone asks for reduced motion.
class AnimatedGift extends StatefulWidget {
  final String tag;
  final double width;
  const AnimatedGift({super.key, required this.tag, this.width = 128});

  @override
  State<AnimatedGift> createState() => _AnimatedGiftState();
}

class _AnimatedGiftState extends State<AnimatedGift> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // Value of a keyframed track at loop position t (0..1): [[t, value], ...].
  static double _track(double t, List<List<double>> k) {
    if (t <= k.first[0]) return k.first[1];
    for (var i = 1; i < k.length; i++) {
      if (t <= k[i][0]) {
        final a = k[i - 1], b = k[i];
        final f = Curves.easeInOut.transform((t - a[0]) / (b[0] - a[0]));
        return a[1] + (b[1] - a[1]) * f;
      }
    }
    return k.last[1];
  }

  // Alignment of a point of the 160x150 drawing.
  static Alignment _at(double x, double y) => Alignment(x / 80 - 1, y / 75 - 1);

  static const _vb = 'viewBox="0 0 160 150" xmlns="http://www.w3.org/2000/svg"';
  static const _base = '<svg $_vb><defs>'
      '<linearGradient id="b" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#f6d77a"/><stop offset=".55" stop-color="#e2b54a"/><stop offset="1" stop-color="#b8901f"/></linearGradient>'
      '<linearGradient id="s" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#c99a2e"/><stop offset="1" stop-color="#97731a"/></linearGradient></defs>'
      '<ellipse cx="74" cy="138" rx="50" ry="7" fill="#0e4d3a" opacity=".12"/>'
      '<path d="M30 76 L74 90 L74 134 L30 120Z" fill="url(#b)"/><path d="M74 90 L118 76 L118 120 L74 134Z" fill="url(#s)"/>'
      '<path d="M48 81.6 L58 84.8 L58 129 L48 125.8Z" fill="#0e4d3a"/><path d="M96 83 L104 80.5 L104 124.6 L96 127.1Z" fill="#0b3d2e"/></svg>';
  static const _glow = '<svg $_vb><defs><radialGradient id="g"><stop offset="0" stop-color="#fff7d1" stop-opacity=".95"/>'
      '<stop offset="1" stop-color="#fff7d1" stop-opacity="0"/></radialGradient></defs><circle cx="74" cy="66" r="40" fill="url(#g)"/></svg>';
  static const _lid = '<svg $_vb><path d="M24 66 L74 81 L124 66 L74 52Z" fill="#f8de8e"/><path d="M24 66 L74 81 L74 90 L24 75Z" fill="#e7bd52"/>'
      '<path d="M74 81 L124 66 L124 75 L74 90Z" fill="#c4962c"/><path d="M44 60 L54 63 L104 69.4 L94 72.5Z" fill="#0e4d3a" opacity=".9"/>'
      '<path d="M44 72 L54 75 L54 84 L44 81Z" fill="#0e4d3a"/><path d="M74 64 C60 46 50 52 58 62 C62 67 70 66 74 64Z" fill="#15803d"/>'
      '<path d="M74 64 C88 46 98 52 90 62 C86 67 78 66 74 64Z" fill="#0e4d3a"/><circle cx="74" cy="63" r="4" fill="#0b3d2e"/></svg>';
  static const _tag = '<svg $_vb><defs><linearGradient id="t" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#f43f5e"/><stop offset="1" stop-color="#be123c"/></linearGradient></defs>'
      '<path d="M118 74 C126 60 128 48 122 38" stroke="#5b4510" stroke-width="2" fill="none" stroke-linecap="round"/>'
      '<g transform="translate(96 4) rotate(18)"><path d="M8 0 H60 a6 6 0 0 1 6 6 V30 a6 6 0 0 1 -6 6 H8 L-4 18Z" fill="url(#t)"/><circle cx="4" cy="18" r="3" fill="#fff"/></g></svg>';
  static String _spark(double x, double y, double r, String color) =>
      '<svg $_vb><path d="M$x ${y - r} L${x + r * .3} ${y - r * .3} L${x + r} $y L${x + r * .3} ${y + r * .3} L$x ${y + r} '
      'L${x - r * .3} ${y + r * .3} L${x - r} $y L${x - r * .3} ${y - r * .3}Z" fill="$color"/></svg>';

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    final h = w * 150 / 160;
    final k = w / 160;
    final still = MediaQuery.of(context).disableAnimations;
    Widget layer(String svg) => SvgPicture.string(svg, width: w, height: h);
    return SizedBox(
      width: w,
      height: h,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = still ? 0.0 : _c.value;
          final lidY = _track(t, [[0, 0], [.55, 0], [.65, -10], [.75, -4], [.85, 0], [1, 0]]);
          final lidA = _track(t, [[0, 0], [.55, 0], [.65, -6], [.75, 3], [.85, 0], [1, 0]]);
          final tagA = _track(t, [[0, 0], [.25, -7], [.5, 4], [.75, -3], [1, 0]]);
          final glowO = _track(t, [[0, .2], [.5, .2], [.68, 1], [1, .2]]);
          final glowS = _track(t, [[0, .7], [.5, .7], [.68, 1.15], [1, .7]]);
          double spark(double delay) {
            final p = (t - delay) % 1.0;
            return _track(p < 0 ? p + 1 : p, [[0, 0], [.4, 1], [.7, 0], [1, 0]]);
          }

          return Stack(clipBehavior: Clip.none, children: [
            Opacity(opacity: glowO, child: Transform.scale(scale: glowS, alignment: _at(74, 66), child: layer(_glow))),
            layer(_base),
            Transform.translate(
              offset: Offset(0, lidY * k),
              child: Transform.rotate(angle: lidA * math.pi / 180, alignment: _at(74, 90), child: layer(_lid)),
            ),
            Transform.rotate(
              angle: tagA * math.pi / 180,
              alignment: _at(118, 74),
              child: Stack(children: [
                layer(_tag),
                // The discount, on the tag (centre of the tag in the drawing: 120, 31).
                Positioned(
                  left: 120 * k - 30 * k,
                  top: 31 * k - 9 * k,
                  width: 60 * k,
                  height: 18 * k,
                  child: Transform.rotate(
                    angle: 18 * math.pi / 180,
                    child: FittedBox(
                      child: Text(widget.tag, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                  ),
                ),
              ]),
            ),
            Opacity(opacity: spark(0), child: layer(_spark(23, 50, 10, '#e2b54a'))),
            Opacity(opacity: spark(.2), child: layer(_spark(134, 107, 7, '#e2b54a'))),
            Opacity(opacity: spark(.4), child: layer(_spark(62, 28, 6, '#15803d'))),
          ]);
        },
      ),
    );
  }
}

/// The wave under the gold services area (as in Glovo).
class ServicesWave extends StatelessWidget {
  final Color top;
  final Color bottom;
  const ServicesWave({super.key, required this.top, required this.bottom});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 46, width: double.infinity, child: CustomPaint(painter: _WavePainter(top, bottom)));
  }
}

class _WavePainter extends CustomPainter {
  final Color top;
  final Color bottom;
  _WavePainter(this.top, this.bottom);

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 400, sy = size.height / 46;
    canvas.drawRect(Offset.zero & size, Paint()..color = top);
    Path wave(double y0, double c1, double c2, double m, double s1, double y1) => Path()
      ..moveTo(0, y0 * sy)
      ..cubicTo(90 * sx, c1 * sy, 170 * sx, c2 * sy, 240 * sx, m * sy)
      ..cubicTo(310 * sx, (2 * m - c2) * sy, 360 * sx, s1 * sy, 400 * sx, y1 * sy)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave(18, 2, 2, 14, 34, 20), Paint()..color = Colors.white.withValues(alpha: 0.35));
    canvas.drawPath(wave(30, 8, 10, 24, 40, 30), Paint()..color = bottom);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.top != top || old.bottom != bottom;
}
