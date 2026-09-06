import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../domain/model/diagram/class_diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';

final class ClassShapes {
  const ClassShapes._();

  static Path outlineOf(DiagramShape shape, Rect rect) => Path()..addRect(rect);

  static Path hollowArrowHead(DiagramPoint from, DiagramPoint tip) {
    const size = ClassDiagramMetrics.arrowSize;
    final dx = tip.x - from.x;
    final dy = tip.y - from.y;
    final length = math.max(math.sqrt(dx * dx + dy * dy), 1.0);
    final ux = dx / length;
    final uy = dy / length;
    final baseX = tip.x - ux * size;
    final baseY = tip.y - uy * size;
    return Path()
      ..moveTo(tip.x, tip.y)
      ..lineTo(baseX - uy * size / 2, baseY + ux * size / 2)
      ..lineTo(baseX + uy * size / 2, baseY - ux * size / 2)
      ..close();
  }
}
