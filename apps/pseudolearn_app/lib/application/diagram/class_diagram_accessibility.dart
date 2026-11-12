import 'dart:math' as math;

import '../../domain/model/diagram/class_diagram_metrics.dart';
import '../../domain/model/diagram/diagram_accessible_element.dart';
import '../../domain/model/diagram/diagram_scene.dart';

const Set<DiagramEdgeKind> _relationKinds = {
  DiagramEdgeKind.generalization,
  DiagramEdgeKind.association,
  DiagramEdgeKind.realization,
  DiagramEdgeKind.usage,
};

final class ClassDiagramAccessibility {
  final DiagramScene _scene;
  final Map<String, DiagramNode> _framesById;
  final Map<String, String> _namesByFrame;

  ClassDiagramAccessibility(DiagramScene scene)
    : _scene = scene,
      _framesById = {
        for (final node in scene.nodes)
          if (node.shape == DiagramShape.classFrame) node.id: node,
      },
      _namesByFrame = {
        for (final node in scene.nodes)
          if (node.shape == DiagramShape.classHeader)
            node.id.replaceFirst('_header', ''): node.lines.last,
      };

  List<DiagramAccessibleElement> elements() => [
    for (final node in _scene.nodes)
      if (node.shape == DiagramShape.classHeader)
        _element(DiagramAccessibleRole.box, node)
      else if (node.shape == DiagramShape.classRow)
        _element(DiagramAccessibleRole.row, node),
    for (final edge in _scene.edges)
      if (_relationKinds.contains(edge.kind)) _relation(edge),
  ];

  DiagramAccessibleElement _element(DiagramAccessibleRole role, DiagramNode node) =>
      DiagramAccessibleElement(
        role: role,
        text: node.lines.join(' '),
        bounds: DiagramAccessibleBounds(
          left: node.x,
          top: node.y,
          width: node.width,
          height: node.height,
        ),
        range: _scene.rangeOf(node.nodeId),
      );

  DiagramAccessibleElement _relation(DiagramEdge edge) =>
      DiagramAccessibleElement(
        role: DiagramAccessibleRole.relation,
        text: edge.label ?? '',
        relationKind: edge.kind,
        fromName: _namesByFrame[edge.fromId] ?? '',
        toName: _namesByFrame[edge.toId] ?? '',
        diagnostics: edge.diagnostics,
        bounds: _hitBoundsOf(edge),
        range:
            _scene.rangeOf(edge.originNodeId) ??
            _scene.rangeOf(_framesById[edge.fromId]?.nodeId),
      );

  DiagramAccessibleBounds _hitBoundsOf(DiagramEdge edge) {
    final middle = edge.points.length ~/ 2;
    final first = edge.points[math.max(middle - 1, 0)];
    final second = edge.points[middle];
    const size = ClassDiagramMetrics.relationHitSize;
    return DiagramAccessibleBounds(
      left: (first.x + second.x) / 2 - size / 2,
      top: (first.y + second.y) / 2 - size / 2,
      width: size,
      height: size,
    );
  }
}
