import 'dart:math';
import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  const DashedLinePainter({
    required this.direction,
    required this.color,
    this.gapColor = Colors.transparent,
    this.dashSize = 1.0,
    this.gapSize = 1.0,
    this.strokeWidth = 1.0,
    this.strokeCap = StrokeCap.square,
  })  : assert(dashSize >= 1),
        assert(gapSize >= 0),
        assert(strokeWidth >= 0);

  final Axis direction;
  final Color color;
  final Color gapColor;
  final double dashSize;
  final double gapSize;
  final double strokeWidth;
  final StrokeCap strokeCap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap
      ..style = PaintingStyle.stroke;

    var offset = _DashOffset(
      containerSize: size,
      strokeWidth: strokeWidth,
      dashSize: dashSize,
      gapSize: gapSize,
      axis: direction,
    );

    while (offset.hasNext) {
      paint.color = color;
      canvas.drawLine(
        offset,
        offset.translateDashSize(),
        paint,
      );
      offset = offset.translateDashSize();

      if (gapColor != Colors.transparent) {
        paint.color = gapColor;
        canvas.drawLine(
          offset,
          offset.translateGapSize(),
          paint,
        );
      }
      offset = offset.translateGapSize();
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) {
    return direction != oldDelegate.direction ||
        color != oldDelegate.color ||
        gapColor != oldDelegate.gapColor ||
        dashSize != oldDelegate.dashSize ||
        gapSize != oldDelegate.gapSize ||
        strokeWidth != oldDelegate.strokeWidth ||
        strokeCap != oldDelegate.strokeCap;
  }
}

class _DashOffset extends Offset {
  factory _DashOffset({
    required Size containerSize,
    required double strokeWidth,
    required double dashSize,
    required double gapSize,
    required Axis axis,
  }) {
    return _DashOffset._(
      dx: axis == Axis.vertical ? containerSize.width / 2 : 0,
      dy: axis == Axis.vertical ? 0 : containerSize.height / 2,
      strokeWidth: strokeWidth,
      containerSize: containerSize,
      dashSize: dashSize,
      gapSize: gapSize,
      axis: axis,
    );
  }

  const _DashOffset._({
    required double dx,
    required double dy,
    required this.strokeWidth,
    required this.containerSize,
    required this.dashSize,
    required this.gapSize,
    required this.axis,
  }) : super(dx, dy);

  final Size containerSize;
  final double strokeWidth;
  final double dashSize;
  final double gapSize;
  final Axis axis;

  double get offset => axis == Axis.vertical ? dy : dx;

  bool get hasNext => axis == Axis.vertical
      ? offset < containerSize.height
      : offset < containerSize.width;

  _DashOffset translateDashSize() => _translateDirectionally(dashSize);

  _DashOffset translateGapSize() => _translateDirectionally(gapSize + strokeWidth);

  _DashOffset _translateDirectionally(double offset) {
    return axis == Axis.vertical
        ? translate(0, offset) as _DashOffset
        : translate(offset, 0) as _DashOffset;
  }

  @override
  Offset translate(double translateX, double translateY) {
    double dx = axis == Axis.vertical ? this.dx : this.dx + translateX;
    double dy = axis == Axis.vertical ? this.dy + translateY : this.dy;

    return copyWith(
      dx: min(dx, containerSize.width),
      dy: min(dy, containerSize.height),
    );
  }

  _DashOffset copyWith({
    double? dx,
    double? dy,
    Size? containerSize,
    double? strokeWidth,
    double? dashSize,
    double? gapSize,
    Axis? axis,
  }) {
    return _DashOffset._(
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      containerSize: containerSize ?? this.containerSize,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      dashSize: dashSize ?? this.dashSize,
      gapSize: gapSize ?? this.gapSize,
      axis: axis ?? this.axis,
    );
  }
}
