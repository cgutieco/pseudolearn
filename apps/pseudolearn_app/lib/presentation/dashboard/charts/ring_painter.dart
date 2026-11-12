import 'dart:math' as math;
import 'package:flutter/rendering.dart';

final class RingTrack {
  final double ratio;
  final Color color;

  const RingTrack({required this.ratio, required this.color});
}

final class ConcentricRingsPainter extends CustomPainter {
  final List<RingTrack> rings;
  final Color trackColor;
  final double stroke;
  final double gap;
  final double progress;

  const ConcentricRingsPainter({
    required this.rings,
    required this.trackColor,
    required this.stroke,
    required this.gap,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    var radius = size.shortestSide / 2 - stroke / 2;
    for (final ring in rings) {
      _paintRing(canvas, Rect.fromCircle(center: center, radius: radius), ring);
      radius -= stroke + gap;
    }
  }

  void _paintRing(Canvas canvas, Rect bounds, RingTrack ring) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(
      bounds.center,
      bounds.width / 2,
      paint..color = trackColor,
    );
    final sweep = 2 * math.pi * ring.ratio.clamp(0, 1) * progress;
    if (sweep <= 0) return;
    canvas.drawArc(
      bounds,
      -math.pi / 2,
      sweep,
      false,
      paint..color = ring.color,
    );
  }

  @override
  bool shouldRepaint(ConcentricRingsPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.rings != rings ||
      oldDelegate.trackColor != trackColor;
}
