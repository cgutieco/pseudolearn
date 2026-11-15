import 'dart:math' as math;
import 'package:flutter/rendering.dart';

Offset radarPointOf({
  required Offset center,
  required double radius,
  required int index,
  required int count,
}) {
  final angle = -math.pi / 2 + 2 * math.pi * index / count;
  return center + Offset(math.cos(angle), math.sin(angle)) * radius;
}

final class RadarPainter extends CustomPainter {
  final List<double> ratios;
  final double inset;
  final int rings;
  final Color gridColor;
  final Color fillColor;
  final double progress;

  const RadarPainter({
    required this.ratios,
    required this.inset,
    required this.rings,
    required this.gridColor,
    required this.fillColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (ratios.length < 3) return;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - inset;
    _paintGrid(canvas, center, radius);
    _paintShape(canvas, center, radius);
  }

  void _paintGrid(Canvas canvas, Offset center, double radius) {
    final grid = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var ring = 1; ring <= rings; ring++) {
      canvas.drawPath(_polygon(center, radius * ring / rings, (_) => 1), grid);
    }
    for (var index = 0; index < ratios.length; index++) {
      canvas.drawLine(center, _point(center, radius, index), grid);
    }
  }

  void _paintShape(Canvas canvas, Offset center, double radius) {
    final shape = _polygon(
      center,
      radius,
      (index) => ratios[index].clamp(0, 1) * progress,
    );
    canvas.drawPath(shape, Paint()..color = fillColor.withValues(alpha: 0.24));
    canvas.drawPath(
      shape,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  Path _polygon(Offset center, double radius, double Function(int) scaleOf) {
    final path = Path();
    for (var index = 0; index < ratios.length; index++) {
      final point = _point(center, radius * scaleOf(index), index);
      index == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  Offset _point(Offset center, double radius, int index) => radarPointOf(
    center: center,
    radius: radius,
    index: index,
    count: ratios.length,
  );

  @override
  bool shouldRepaint(RadarPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.ratios != ratios ||
      oldDelegate.fillColor != fillColor;
}
