import 'package:flutter/material.dart';
import '../../../domain/model/agent/flowchart.dart';
import '../../../domain/model/diagram/diagram_metrics.dart';
import '../../../domain/model/diagram/diagram_scene.dart';
import '../../diagram/flowchart_shapes.dart';

const Map<FlowchartShape, DiagramShape> _sharedShapes = {
  FlowchartShape.rectangle: DiagramShape.process,
  FlowchartShape.rounded: DiagramShape.startEnd,
  FlowchartShape.stadium: DiagramShape.startEnd,
  FlowchartShape.circle: DiagramShape.connector,
  FlowchartShape.diamond: DiagramShape.decision,
  FlowchartShape.hexagon: DiagramShape.preparation,
  FlowchartShape.parallelogram: DiagramShape.inputOutput,
  FlowchartShape.subroutine: DiagramShape.subprogram,
};

Path replyFlowchartOutline(FlowchartShape shape, Rect rect) {
  final shared = _sharedShapes[shape];
  if (shared != null) return FlowchartShapes.outlineOf(shared, rect);
  return switch (shape) {
    FlowchartShape.trapezoid => _trapezoid(rect),
    FlowchartShape.cylinder => _cylinder(rect),
    _ => _flag(rect),
  };
}

List<Path> replyFlowchartDecorations(FlowchartShape shape, Rect rect) {
  final shared = _sharedShapes[shape];
  if (shared != null) return FlowchartShapes.decorationsOf(shared, rect);
  if (shape != FlowchartShape.cylinder) return const [];
  final lid = rect.height * _cylinderLidRatio;
  return [Path()..addArc(Rect.fromLTWH(rect.left, rect.top, rect.width, lid * 2), 0, _halfTurn)];
}

const double _cylinderLidRatio = 0.12;
const double _halfTurn = 3.141592653589793;

Path _trapezoid(Rect rect) {
  const skew = DiagramMetrics.inputOutputSkew;
  return Path()
    ..moveTo(rect.left + skew, rect.top)
    ..lineTo(rect.right - skew, rect.top)
    ..lineTo(rect.right, rect.bottom)
    ..lineTo(rect.left, rect.bottom)
    ..close();
}

Path _cylinder(Rect rect) {
  final lid = rect.height * _cylinderLidRatio;
  return Path()
    ..addOval(Rect.fromLTWH(rect.left, rect.top, rect.width, lid * 2))
    ..moveTo(rect.left, rect.top + lid)
    ..lineTo(rect.left, rect.bottom - lid)
    ..arcTo(Rect.fromLTWH(rect.left, rect.bottom - lid * 2, rect.width, lid * 2), _halfTurn, -_halfTurn, false)
    ..lineTo(rect.right, rect.top + lid);
}

Path _flag(Rect rect) {
  final notch = rect.height / 2;
  return Path()
    ..moveTo(rect.left, rect.top)
    ..lineTo(rect.right, rect.top)
    ..lineTo(rect.right, rect.bottom)
    ..lineTo(rect.left, rect.bottom)
    ..lineTo(rect.left + notch / 2, rect.center.dy)
    ..close();
}
