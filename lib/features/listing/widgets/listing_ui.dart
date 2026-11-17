import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/listing/listing_api.dart';
import 'package:sixam_mart/util/styles.dart';

/// Noor colours for the Annonces screens (green, metallic gold, cream).
class LColors {
  static const green = Color(0xFF0E4D3A);
  static const greenDark = Color(0xFF0B3D2E);
  static const greenLight = Color(0xFFE4F1EA);
  static const gold = Color(0xFFB8901F);
  static const goldDark = Color(0xFF9A7209);
  static const goldLight = Color(0xFFD4AF37);
  static const cream = Color(0xFFFBF3DC);
  static const muted = Color(0xFF6B7A73);
  static const line = Color(0xFFE6EBE8);
  static const bg = Color(0xFFF6F7F5);
  static const whatsapp = Color(0xFF25D366);
  static const goldGradient = LinearGradient(colors: [goldDark, goldLight]);
}

/// Green header with the gold curve, as in the other Noor screens.
class ListingBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool back;
  final PreferredSizeWidget? bottom;
  const ListingBar({super.key, required this.title, this.subtitle, this.actions = const [], this.back = true, this.bottom});

  @override
  Size get preferredSize => Size.fromHeight(64 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: LColors.green,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: back,
      toolbarHeight: 64,
      titleSpacing: back && Navigator.of(context).canPop() ? 0 : 16,
      title: Row(children: [
        if (!back) ...[
          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/image/logo.png', width: 36, height: 36, errorBuilder: (_, __, ___) => const Icon(Icons.sell, color: LColors.goldLight))),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(color: Colors.white, fontSize: 18)),
            if (subtitle != null) Text(subtitle!, style: robotoMedium.copyWith(color: Colors.white70, fontSize: 12)),
          ]),
        ),
      ]),
      actions: [...actions, const SizedBox(width: 6)],
      shape: const Border(bottom: BorderSide(color: LColors.goldLight, width: 3)),
      bottom: bottom,
    );
  }
}

class ListingIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badge;
  final String tooltip;
  const ListingIconButton({super.key, required this.icon, required this.onTap, this.badge = 0, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Tooltip(
            message: tooltip,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
                Icon(icon, color: Colors.white, size: 21),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: const Color(0xFFE84D4F), borderRadius: BorderRadius.circular(9)),
                      child: Text('$badge', style: robotoBold.copyWith(color: Colors.white, fontSize: 10)),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// A listing in the grid: photo, price, title, place and time.
class ListingCard extends StatelessWidget {
  final ListingItem item;
  final VoidCallback onTap;
  const ListingCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final where = listingKm(item.distanceKm) ?? item.city ?? item.category?.name ?? '';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: LColors.line), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(fit: StackFit.expand, children: [
                Container(color: const Color(0xFFEEF3EF)),
                if (item.image != null) CustomImage(image: item.image!, fit: BoxFit.cover),
                if (item.featured)
                  Positioned(left: 8, top: 8, child: ListingPill(text: 'lst_featured'.tr, gold: true)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(listingMoney(item.price), style: robotoBold.copyWith(color: LColors.green, fontSize: 15)),
                const SizedBox(height: 2),
                Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium.copyWith(fontSize: 12.5)),
                const SizedBox(height: 4),
                Row(children: [
                  if (where.isNotEmpty) ...[
                    const Icon(Icons.place_outlined, size: 11, color: LColors.muted),
                    const SizedBox(width: 2),
                    Expanded(child: Text(where, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: 10.5, color: LColors.muted))),
                  ] else
                    const Spacer(),
                  Text(listingAgo(item.createdAt), style: robotoRegular.copyWith(fontSize: 10.5, color: LColors.muted)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class ListingPill extends StatelessWidget {
  final String text;
  final bool gold;
  final Color? color;
  final Color? textColor;
  const ListingPill({super.key, required this.text, this.gold = false, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: gold ? LColors.goldGradient : null,
        color: gold ? null : (color ?? LColors.greenLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: robotoBold.copyWith(fontSize: 10.5, color: gold ? Colors.white : (textColor ?? LColors.green))),
    );
  }
}

/// Big rounded button: gold (main action), green, or outlined.
class ListingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final String style; // gold | green | outline
  final bool busy;
  const ListingButton({super.key, required this.text, this.onTap, this.icon, this.style = 'gold', this.busy = false});

  @override
  Widget build(BuildContext context) {
    final outline = style == 'outline';
    final enabled = onTap != null && !busy;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: style == 'gold' ? LColors.goldGradient : null,
            color: style == 'green' ? LColors.green : (outline ? Colors.white : null),
            border: outline ? Border.all(color: LColors.green, width: 1.5) : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (busy)
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: outline ? LColors.green : Colors.white))
                else if (icon != null)
                  Icon(icon, size: 19, color: outline ? LColors.green : Colors.white),
                if (busy || icon != null) const SizedBox(width: 8),
                Flexible(child: Text(text, textAlign: TextAlign.center, style: robotoBold.copyWith(fontSize: 15, color: outline ? LColors.green : Colors.white))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class ListingEmpty extends StatelessWidget {
  final String emoji;
  final String text;
  final Widget? action;
  const ListingEmpty({super.key, required this.emoji, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 46)),
        const SizedBox(height: 10),
        Text(text, textAlign: TextAlign.center, style: robotoRegular.copyWith(color: LColors.muted, height: 1.5)),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ]),
    );
  }
}
