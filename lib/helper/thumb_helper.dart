import 'dart:math' as math;

import 'package:sixam_mart/util/app_constants.dart';

/// Small WebP copies of our pictures, from the server's `/img/{width}` route
/// (15-30 KB instead of the 200 KB - 1 MB originals): lighter on mobile data.
/// Other links (icons, other sites, SVG) are returned unchanged.
class ThumbHelper {
  static const List<int> _widths = [120, 200, 360, 600];

  /// [logicalWidth]: the picture's width on screen; [pixelRatio]: the screen
  /// density (capped at 2, more is not visible on a phone).
  static String url(String? image, {double? logicalWidth, double pixelRatio = 2}) {
    if (image == null || image.isEmpty) return image ?? '';
    final lower = image.toLowerCase();
    if (!lower.startsWith('http') || image.contains('/img/') || lower.split('?').first.endsWith('.svg')) return image;
    final wanted = (logicalWidth == null || !logicalWidth.isFinite ? 180 : logicalWidth) * math.min(pixelRatio, 2);
    final width = _widths.firstWhere((w) => w >= wanted, orElse: () => _widths.last);
    return '${AppConstants.baseUrl}/img/$width?u=${Uri.encodeComponent(image)}';
  }
}
