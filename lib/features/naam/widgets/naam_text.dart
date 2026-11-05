import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders Naam's small markdown subset: paragraphs, "- " bullets, **bold**
/// and [label](link). Naam writes links as web-app paths (/commandes,
/// /produit/12…); they open the matching screen of this app. Web links open
/// in the browser.
class NaamText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const NaamText({super.key, required this.text, required this.style});

  /// The app route for a web-app path, or null when this app has no such screen.
  static String? routeFor(String path) {
    final uri = Uri.tryParse(path);
    if (uri == null) return null;
    final seg = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final id = seg.length > 1 ? int.tryParse(seg[1]) : null;
    switch (seg.isEmpty ? '' : seg.first) {
      case '':
        return RouteHelper.getMainRoute('home');
      case 'boutique':
        return RouteHelper.getSearchRoute();
      case 'produit':
        return id != null ? RouteHelper.getItemDetailsRoute(id, false) : RouteHelper.getSearchRoute();
      case 'panier':
        return RouteHelper.getCartRoute();
      case 'commandes':
        return RouteHelper.getMainRoute('order');
      case 'commande':
        return id != null ? RouteHelper.getOrderDetailsRoute(id) : RouteHelper.getMainRoute('order');
      case 'portefeuille':
        return RouteHelper.getWalletRoute();
      case 'envoyer':
        return RouteHelper.getMobileMoneyRoute();
      case 'credit':
        return RouteHelper.getAirtimeRoute();
      case 'factures':
        return RouteHelper.getBillPaymentRoute();
      case 'assurance':
        return RouteHelper.getInsuranceRoute();
      case 'taxi':
        return RouteHelper.getRideRoute();
      case 'compte':
        return RouteHelper.getMainRoute('menu');
      case 'profil':
        return RouteHelper.getProfileRoute();
      case 'adresses':
        return RouteHelper.getAddressRoute();
      case 'points':
        return RouteHelper.getLoyaltyRoute();
      case 'parrainage':
        return RouteHelper.getReferAndEarnRoute();
      case 'coupons':
        return RouteHelper.getCouponRoute();
      case 'messages':
        return RouteHelper.getConversationRoute();
      case 'connexion':
        return RouteHelper.getSignInRoute(RouteHelper.naam);
    }
    return null;
  }

  static void open(String link) {
    if (link.startsWith('/')) {
      final route = routeFor(link);
      if (route != null) Get.toNamed(route);
      return;
    }
    final uri = Uri.tryParse(link);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http' || uri.scheme == 'tel' || uri.scheme == 'mailto')) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  State<NaamText> createState() => _NaamTextState();
}

class _NaamTextState extends State<NaamText> {
  final List<TapGestureRecognizer> _taps = [];
  static final _inline = RegExp(r'\*\*(.+?)\*\*|\[([^\]]+)\]\(([^)\s]+)\)');

  @override
  void dispose() {
    for (final t in _taps) {
      t.dispose();
    }
    super.dispose();
  }

  List<InlineSpan> _spans(String line) {
    final link = widget.style.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, decoration: TextDecoration.underline);
    final spans = <InlineSpan>[];
    var at = 0;
    for (final m in _inline.allMatches(line)) {
      if (m.start > at) spans.add(TextSpan(text: line.substring(at, m.start)));
      if (m.group(1) != null) {
        spans.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.w700)));
      } else {
        final target = m.group(3)!;
        final tap = TapGestureRecognizer()..onTap = () => NaamText.open(target);
        _taps.add(tap);
        spans.add(TextSpan(text: m.group(2), style: link, recognizer: tap));
      }
      at = m.end;
    }
    if (at < line.length) spans.add(TextSpan(text: line.substring(at)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    for (final t in _taps) {
      t.dispose();
    }
    _taps.clear();
    final blocks = <Widget>[];
    for (final raw in widget.text.trim().split('\n')) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) {
        if (blocks.isNotEmpty) blocks.add(const SizedBox(height: 6));
        continue;
      }
      final bullet = RegExp(r'^\s*([-*•]|\d+[.)])\s+').firstMatch(line);
      final body = bullet != null ? line.substring(bullet.end) : line.replaceFirst(RegExp(r'^#+\s*'), '');
      final rich = Text.rich(TextSpan(style: widget.style, children: _spans(body)));
      blocks.add(bullet == null
          ? rich
          : Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(bullet.group(1)!.length > 1 ? '${bullet.group(1)} ' : '•  ', style: widget.style),
                Expanded(child: rich),
              ]),
            ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: blocks);
  }
}
