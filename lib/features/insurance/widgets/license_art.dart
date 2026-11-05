import 'package:flutter/material.dart';

/// Drawings of a Senegalese driving licence (ECOWAS card) for the scan steps,
/// as in the web app: front, back (categories table), and the scanning line.
const _line = Color(0xFFCBBFA8);

Widget _bar(double w, {double h = 6}) => Container(width: w, height: h, decoration: BoxDecoration(color: _line, borderRadius: BorderRadius.circular(3)));

class LicenseFrontArt extends StatelessWidget {
  final double width;
  const LicenseFrontArt({super.key, this.width = 300});

  @override
  Widget build(BuildContext context) {
    final u = width / 340; // drawing unit
    return Container(
      width: width,
      height: 214 * u,
      padding: EdgeInsets.all(16 * u),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18 * u),
        border: Border.all(color: const Color(0xFFE5C9A6), width: 2),
        gradient: const LinearGradient(colors: [Color(0xFFFDEEDD), Color(0xFFEEF4FB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          for (final c in const [Color(0x994CAF50), Color(0xB3F4E04D), Color(0x99E35D5D)]) Container(width: 14 * u, height: 26 * u, color: c),
          SizedBox(width: 12 * u),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PERMIS DE CONDUIRE', style: TextStyle(fontSize: 14 * u, fontWeight: FontWeight.w800, letterSpacing: 1, color: const Color(0xFF8A5A2B))),
              Text('RÉPUBLIQUE DU SÉNÉGAL · CEDEAO', style: TextStyle(fontSize: 9 * u, color: const Color(0xFFA98B6A))),
            ]),
          ),
          Text('SN', style: TextStyle(fontSize: 22 * u, fontWeight: FontWeight.w800, color: const Color(0xFF8A7444))),
        ]),
        SizedBox(height: 12 * u),
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 84 * u,
              decoration: BoxDecoration(color: const Color(0xFFE3E8EF), borderRadius: BorderRadius.circular(10 * u)),
              child: Icon(Icons.person, size: 70 * u, color: const Color(0xFFC3CCD8)),
            ),
            SizedBox(width: 16 * u),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                for (final (i, w) in const [('1.', 120.0), ('2.', 96.0), ('3.', 140.0), ('4a.', 70.0), ('5.', 110.0)])
                  Row(children: [
                    SizedBox(width: 22 * u, child: Text(i, style: TextStyle(fontSize: 9 * u, color: const Color(0xFFB09C80)))),
                    _bar(w * u * 0.85, h: 5 * u),
                  ]),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

class LicenseBackArt extends StatelessWidget {
  final double width;
  const LicenseBackArt({super.key, this.width = 300});

  @override
  Widget build(BuildContext context) {
    final u = width / 340;
    return Container(
      width: width,
      height: 214 * u,
      padding: EdgeInsets.fromLTRB(20 * u, 14 * u, 20 * u, 10 * u),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(18 * u),
        border: Border.all(color: const Color(0xFFDFE5EC), width: 2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('9. CATÉGORIES', style: TextStyle(fontSize: 12 * u, fontWeight: FontWeight.w700, color: const Color(0xFF8A7A62))),
        SizedBox(height: 6 * u),
        for (final (i, c) in const ['A1', 'A', 'B', 'C', 'D', 'E'].indexed)
          Container(
            height: 20 * u,
            color: i.isOdd ? const Color(0xFFEEF2F7) : const Color(0xFFE6ECF3),
            padding: EdgeInsets.symmetric(horizontal: 8 * u),
            child: Row(children: [
              SizedBox(width: 36 * u, child: Text(c, style: TextStyle(fontSize: 11 * u, fontWeight: FontWeight.w700, color: const Color(0xFF6F6250)))),
              _bar(70 * u, h: 5 * u),
              SizedBox(width: 30 * u),
              _bar(70 * u, h: 5 * u),
            ]),
          ),
        const Spacer(),
        Center(
          child: Text('DLSEN123456<<<0000',
              style: TextStyle(fontFamily: 'monospace', fontSize: 14 * u, fontWeight: FontWeight.w700, letterSpacing: 2, color: const Color(0xFF7A6A48))),
        ),
      ]),
    );
  }
}

/// The licence with a phone framing it (front step).
class PhoneOverLicenseArt extends StatelessWidget {
  final double width;
  const PhoneOverLicenseArt({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    final phoneW = width * 0.34;
    return SizedBox(
      width: width,
      height: width * 0.86,
      child: Stack(children: [
        LicenseFrontArt(width: width * 0.86),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: phoneW,
            height: phoneW * 1.75,
            padding: EdgeInsets.fromLTRB(8, phoneW * 0.18, 8, phoneW * 0.28),
            decoration: BoxDecoration(color: const Color(0xFF232A31), borderRadius: BorderRadius.circular(16)),
            child: Container(color: const Color(0xFFCFE9FB), alignment: Alignment.center, child: LicenseFrontArt(width: phoneW - 22)),
          ),
        ),
      ]),
    );
  }
}

/// Front, a curved arrow, then the back (back step).
class FlipLicenseArt extends StatelessWidget {
  final double width;
  const FlipLicenseArt({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 0.78,
      child: Stack(children: [
        LicenseFrontArt(width: width * 0.58),
        Positioned(
          left: width * 0.46,
          top: width * 0.12,
          child: Transform.rotate(angle: 0.4, child: Icon(Icons.redo_rounded, size: width * 0.22, color: const Color(0xFFEE6A2C))),
        ),
        Positioned(right: 0, bottom: 0, child: LicenseBackArt(width: width * 0.66)),
      ]),
    );
  }
}

/// The front with a light line sweeping over it while the AI reads the photos.
class ScanningLicenseArt extends StatefulWidget {
  final double width;
  const ScanningLicenseArt({super.key, required this.width});

  @override
  State<ScanningLicenseArt> createState() => _ScanningLicenseArtState();
}

class _ScanningLicenseArtState extends State<ScanningLicenseArt> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = 214 * widget.width / 340;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Stack(children: [
        Opacity(opacity: 0.75 + 0.25 * (1 - _anim.value), child: child),
        Positioned(
          left: 6,
          right: 6,
          top: 8 + (h - 16) * Curves.easeInOut.transform(_anim.value),
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4))],
            ),
          ),
        ),
      ]),
      child: LicenseFrontArt(width: widget.width),
    );
  }
}
