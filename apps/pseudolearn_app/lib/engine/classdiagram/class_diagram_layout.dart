import 'dart:math' as math;

import '../../domain/model/diagram/class_diagram_metrics.dart';
import '../../domain/model/diagram/class_model.dart';
import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../diagram/text_metrics.dart';
import 'class_box_nodes.dart';
import 'class_box_placement.dart';
import 'class_relation_routing.dart';

final class _Bounds {
  double left = double.infinity;
  double top = double.infinity;
  double right = double.negativeInfinity;
  double bottom = double.negativeInfinity;

  void include(double x, double y) {
    left = math.min(left, x);
    top = math.min(top, y);
    right = math.max(right, x);
    bottom = math.max(bottom, y);
  }

  double get width => right - left;

  double get height => bottom - top;
}

final class ClassDiagramLayout {
  final ClassBoxPlacement _placement;
  final ClassBoxNodes _nodes;
  final TextMetrics _text;

  const ClassDiagramLayout({
    ClassBoxPlacement placement = const ClassBoxPlacement(),
    ClassBoxNodes nodes = const ClassBoxNodes(),
    TextMetrics text = const TextMetrics(),
  })  : _placement = placement,
        _nodes = nodes,
        _text = text;

  DiagramScene of(ClassModel model) {
    if (model.isEmpty) return const DiagramScene.empty();
    final boxGap = _boxGapOf(model.relations);
    final placed = _placement.of(model.classes, boxGap: boxGap);
    final nodes = <DiagramNode>[];
    for (final box in placed) {
      nodes.addAll(_nodes.of(box));
    }
    final edges = ClassRelationRouting(placed, boxGap: boxGap).of(model.relations);
    return _framed(nodes, edges);
  }

  double _boxGapOf(List<ClassRelation> relations) {
    var widest = 0.0;
    for (final relation in relations) {
      final label = relation.label;
      if (label == null || label.isEmpty) continue;
      final labelWidth = _text.advanceUnits(label) * DiagramMetrics.fontSize +
          ClassDiagramMetrics.boxPadding * 2;
      widest = math.max(widest, labelWidth);
    }
    return ClassDiagramMetrics.computeBoxGap(widest);
  }

  DiagramScene _framed(List<DiagramNode> nodes, List<DiagramEdge> edges) {
    final bounds = _boundsOf(nodes, edges);
    const margin = ClassDiagramMetrics.canvasMargin;
    final dx = margin - bounds.left;
    final dy = margin - bounds.top;
    return DiagramScene(
      nodes: List.unmodifiable([
        for (final node in nodes) node.shifted(dx, dy),
      ]),
      edges: List.unmodifiable([
        for (final edge in edges) edge.shifted(dx, dy),
      ]),
      width: bounds.width + margin * 2,
      height: bounds.height + margin * 2,
    );
  }

  _Bounds _boundsOf(List<DiagramNode> nodes, List<DiagramEdge> edges) {
    final bounds = _Bounds();
    for (final node in nodes) {
      bounds.include(node.x, node.y);
      bounds.include(node.x + node.width, node.y + node.height);
    }
    for (final edge in edges) {
      for (final point in edge.points) {
        bounds.include(point.x, point.y);
      }
    }
    return bounds;
  }
}

