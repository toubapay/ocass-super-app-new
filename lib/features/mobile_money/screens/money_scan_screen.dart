import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sixam_mart/features/mobile_money/domain/models/mobile_money_models.dart';
import 'package:sixam_mart/util/styles.dart';

/// "Scanner pour envoyer": reads a Noor payment QR and pops with the
/// recipient's 9 local digits.
class MoneyScanScreen extends StatefulWidget {
  const MoneyScanScreen({super.key});

  @override
  State<MoneyScanScreen> createState() => _MoneyScanScreenState();
}

class _MoneyScanScreenState extends State<MoneyScanScreen> {
  final _controller = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final b in capture.barcodes) {
      final digits = phoneFromQr(b.rawValue);
      if (digits != null) {
        _done = true;
        Get.back(result: digits);
        return;
      }
    }
    setState(() => _error = 'mm_qr_not_noor'.tr);
  }

  @override
  Widget build(BuildContext context) {
    final frame = MediaQuery.of(context).size.width * 0.68;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          errorBuilder: (context, error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('mm_camera_denied'.tr, textAlign: TextAlign.center, style: robotoMedium.copyWith(color: Colors.white)),
            ),
          ),
        ),
        // Darkened surroundings with a clear square, as in Wave.
        Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _HolePainter(frame)))),
        Center(
          child: Container(
            width: frame,
            height: frame,
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF0C040), width: 3), borderRadius: BorderRadius.circular(24)),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: Colors.white24),
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: Text(
                _error ?? 'mm_scan_hint'.tr,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(color: Colors.white, fontSize: 17),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _HolePainter extends CustomPainter {
  final double side;
  _HolePainter(this.side);

  @override
  void paint(Canvas canvas, Size size) {
    final hole = RRect.fromRectAndRadius(Rect.fromCenter(center: size.center(Offset.zero), width: side, height: side), const Radius.circular(24));
    final path = Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), Path()..addRRect(hole));
    canvas.drawPath(path, Paint()..color = Colors.black54);
  }

  @override
  bool shouldRepaint(_HolePainter old) => old.side != side;
}
