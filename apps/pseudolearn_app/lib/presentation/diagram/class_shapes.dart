import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../domain/model/diagram/class_diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';

final class ClassShapes {
  const ClassShapes._();

  static Path outlineOf(DiagramShape shape, Rect rect) => Path()..addRect(rect);

  static Path hollowArrowHead(DiagramPoint from, DiagramPoint tip) {
    final corners = _cornersOf(from, tip);
    return Path()
      ..moveTo(tip.x, tip.y)
      ..lineTo(corners.$1.dx, corners.$1.dy)
      ..lineTo(corners.$2.dx, corners.$2.dy)
      ..close();
  }

  static Path openArrowHead(DiagramPoint from, DiagramPoint tip) {
    final corners = _cornersOf(from, tip);
    return Path()
      ..moveTo(corners.$1.dx, corners.$1.dy)
      ..lineTo(tip.x, tip.y)
      ..lineTo(corners.$2.dx, corners.$2.dy);
  }

  static Path dashed(Path path, {required double dash, required double gap}) {
    final result = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        result.addPath(metric.extractPath(distance, end), Offset.zero);
        distance = end + gap;
      }
    }
    return result;
  }

  static (Offset, Offset) _cornersOf(DiagramPoint from, DiagramPoint tip) {
    const size = ClassDiagramMetrics.arrowSize;
    final dx = tip.x - from.x;
    final dy = tip.y - from.y;
    final length = math.max(math.sqrt(dx * dx + dy * dy), 1.0);
    final ux = dx / length;
    final uy = dy / length;
    final baseX = tip.x - ux * size;
    final baseY = tip.y - uy * size;
    return (
      Offset(baseX - uy * size / 2, baseY + ux * size / 2),
      Offset(baseX + uy * size / 2, baseY - ux * size / 2),
    );
  }
}
