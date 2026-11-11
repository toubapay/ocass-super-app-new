import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Map icons for the ride, drawn in code (no image assets): a car seen from
/// above, nose up, so the marker's rotation turns it along the road as in
/// Yango. Yellow for the rider's driver, white for the free cars around.
class RideMapIcons {
  static BitmapDescriptor? driverCar;
  static BitmapDescriptor? freeCar;

  static Future<void> load(double pixelRatio) async {
    if (driverCar != null && freeCar != null) return;
    driverCar = await _car(const Color(0xFFF5B301), 22, 40, pixelRatio);
    freeCar = await _car(Colors.white, 17, 31, pixelRatio);
  }

  static Future<BitmapDescriptor> _car(Color body, double w, double h, double ratio) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(ratio);
    // Soft shadow under the car.
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawRRect(RRect.fromLTRBR(2, 3, w, h, Radius.circular(w * 0.32)), shadow);
    // Body with a dark outline.
    final rect = RRect.fromLTRBR(1, 1, w - 1, h - 2, Radius.circular(w * 0.32));
    canvas.drawRRect(rect, Paint()..color = body);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = const Color(0xFF1C1C1E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Windscreen (front, at the top) and rear window.
    final glass = Paint()..color = const Color(0xFF1C1C1E);
    final front = Path()
      ..moveTo(w * 0.2, h * 0.3)
      ..quadraticBezierTo(w * 0.5, h * 0.24, w * 0.8, h * 0.3)
      ..lineTo(w * 0.74, h * 0.44)
      ..quadraticBezierTo(w * 0.5, h * 0.41, w * 0.26, h * 0.44)
      ..close();
    canvas.drawPath(front, glass);
    final rear = Path()
      ..moveTo(w * 0.25, h * 0.76)
      ..quadraticBezierTo(w * 0.5, h * 0.79, w * 0.75, h * 0.76)
      ..lineTo(w * 0.79, h * 0.84)
      ..quadraticBezierTo(w * 0.5, h * 0.88, w * 0.21, h * 0.84)
      ..close();
    canvas.drawPath(rear, glass..color = const Color(0xFF1C1C1E).withValues(alpha: 0.8));
    final image = await recorder.endRecording().toImage((w * ratio).ceil(), (h * ratio).ceil());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List(), imagePixelRatio: ratio);
  }
}
