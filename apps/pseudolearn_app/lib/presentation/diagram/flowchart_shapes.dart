import 'package:flutter/material.dart';
import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../theme/tokens/editor_metrics.dart';
import 'class_shapes.dart';
import 'structogram_shapes.dart';

final class FlowchartShapes {
  const FlowchartShapes._();

  static Path outlineOf(DiagramShape shape, Rect rect) {
    return switch (shape) {
      DiagramShape.startEnd => _rounded(rect, rect.height / 2),
      DiagramShape.process => _rounded(rect, EditorMetricsTokens.flowNodeRadiusProcess),
      DiagramShape.subprogram => _rounded(rect, EditorMetricsTokens.flowNodeRadiusProcess),
      DiagramShape.decision => _diamond(rect),
      DiagramShape.inputOutput => _parallelogram(rect),
      DiagramShape.preparation => _hexagon(rect),
      DiagramShape.connector => Path()..addOval(rect),
      DiagramShape.cellProcess ||
      DiagramShape.cellCall ||
      DiagramShape.cellExit ||
      DiagramShape.cellEmpty ||
      DiagramShape.cellCondition ||
      DiagramShape.cellCase ||
      DiagramShape.cellLabel ||
      DiagramShape.cellLoopHeader ||
      DiagramShape.cellLoopStrip =>
        StructogramShapes.outlineOf(shape, rect),
      DiagramShape.classFrame ||
      DiagramShape.classHeader ||
      DiagramShape.classCompartment ||
      DiagramShape.classRow =>
        ClassShapes.outlineOf(shape, rect),
    };
  }

  static List<Path> decorationsOf(DiagramShape shape, Rect rect) {
    if (shape != DiagramShape.subprogram) return const [];
    const inset = DiagramMetrics.nodePadding;
    return [
      Path()
        ..moveTo(rect.left + inset, rect.top)
        ..lineTo(rect.left + inset, rect.bottom),
      Path()
        ..moveTo(rect.right - inset, rect.top)
        ..lineTo(rect.right - inset, rect.bottom),
    ];
  }

  static Path _rounded(Rect rect, double radius) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

  static Path _diamond(Rect rect) => Path()
    ..moveTo(rect.center.dx, rect.top)
    ..lineTo(rect.right, rect.center.dy)
    ..lineTo(rect.center.dx, rect.bottom)
    ..lineTo(rect.left, rect.center.dy)
    ..close();

  static Path _parallelogram(Rect rect) {
    const skew = DiagramMetrics.inputOutputSkew;
    return Path()
      ..moveTo(rect.left + skew, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right - skew, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }

  static Path _hexagon(Rect rect) {
    final cut = rect.height * DiagramMetrics.preparationCornerRatio;
    return Path()
      ..moveTo(rect.left + cut, rect.top)
      ..lineTo(rect.right - cut, rect.top)
      ..lineTo(rect.right, rect.center.dy)
      ..lineTo(rect.right - cut, rect.bottom)
      ..lineTo(rect.left + cut, rect.bottom)
      ..lineTo(rect.left, rect.center.dy)
      ..close();
  }
}
