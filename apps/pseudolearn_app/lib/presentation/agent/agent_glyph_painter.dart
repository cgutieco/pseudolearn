import 'dart:math' as math;
import 'package:flutter/rendering.dart';

enum AgentGlyphState { idle, thinking, newReply, noCredits }

final class AgentGlyphPainter extends CustomPainter {
  static const double grid = 24;

  final AgentGlyphState state;
  final Color color;
  final double turn;

  const AgentGlyphPainter({required this.state, required this.color, this.turn = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / grid;
    canvas.save();
    canvas.scale(scale);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide <= 16 ? 1.25 / scale : 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    _paintNode(canvas, stroke);
    _paintSparkle(canvas, stroke);
    canvas.restore();
  }

  void _paintNode(Canvas canvas, Paint stroke) {
    canvas.drawCircle(const Offset(9, 15), 5, stroke);
    final eyes = Paint()..color = color;
    canvas.drawCircle(const Offset(7.25, 14.5), 0.9, eyes);
    canvas.drawCircle(const Offset(10.75, 14.5), 0.9, eyes);
    final connector = Path()
      ..moveTo(9, 10)
      ..lineTo(9, 6.5)
      ..lineTo(13.5, 6.5);
    canvas.drawPath(connector, stroke);
  }

  void _paintSparkle(Canvas canvas, Paint stroke) {
    canvas.save();
    canvas.translate(18, 6.5);
    canvas.rotate(turn * math.pi / 2);
    final sparkle = Path()
      ..moveTo(0, -4)
      ..quadraticBezierTo(0.6, -0.6, 4, 0)
      ..quadraticBezierTo(0.6, 0.6, 0, 4)
      ..quadraticBezierTo(-0.6, 0.6, -4, 0)
      ..quadraticBezierTo(-0.6, -0.6, 0, -4)
      ..close();
    final fill = Paint()
      ..color = color
      ..style = state == AgentGlyphState.noCredits ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = stroke.strokeWidth
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(sparkle, fill);
    canvas.restore();
    if (state == AgentGlyphState.newReply) {
      canvas.drawCircle(const Offset(20.5, 18), 2, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(AgentGlyphPainter oldDelegate) =>
      oldDelegate.state != state || oldDelegate.color != color || oldDelegate.turn != turn;
}
