import 'dart:math' as math;
import 'package:flutter/rendering.dart';

final class DonutSlice {
  final int value;
  final Color color;

  const DonutSlice({required this.value, required this.color});
}

final class DonutPainter extends CustomPainter {
  final List<DonutSlice> slices;
  final Color trackColor;
  final double stroke;
  final double progress;

  const DonutPainter({
    required this.slices,
    required this.trackColor,
    required this.stroke,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - stroke / 2;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, paint..color = trackColor);
    final total = _totalOf(slices);
    if (total == 0) return;
    var start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = 2 * math.pi * slice.value / total * progress;
      canvas.drawArc(bounds, start, sweep, false, paint..color = slice.color);
      start += sweep;
    }
  }

  static int _totalOf(List<DonutSlice> slices) {
    var total = 0;
    for (final slice in slices) {
      total += slice.value;
    }
    return total;
  }

  @override
  bool shouldRepaint(DonutPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.slices != slices ||
      oldDelegate.trackColor != trackColor;
}
