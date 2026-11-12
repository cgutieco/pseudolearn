import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/diagram/class_diagram_metrics.dart';
import '../../domain/model/diagram/class_model.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import 'class_box_nodes.dart';
import 'class_box_placement.dart';
import 'relation_anchors.dart';
import 'relation_route_search.dart';
import 'routing_corridors.dart';
import 'routing_reservations.dart';

final class ClassRelationRouting {
  final Map<String, PlacedClassBox> _byName;
  final Map<int, PlacedClassBox> _byNode;
  final RoutingCorridors _corridors;
  final RoutingReservations _reservations;
  final RelationRouteSearch _search;

  ClassRelationRouting(List<PlacedClassBox> placed, {double boxGap = ClassDiagramMetrics.boxGapFloor})
      : this._(
          byName: {for (final box in placed) box.box.name: box},
          byNode: {for (final box in placed) box.box.nodeId.value: box},
          corridors: RoutingCorridors.of(placed, boxGap: boxGap),
          reservations: RoutingReservations(),
        );

  ClassRelationRouting._({
    required this._byName,
    required this._byNode,
    required RoutingCorridors corridors,
    required RoutingReservations reservations,
  })  : _corridors = corridors,
        _reservations = reservations,
        _search = RelationRouteSearch(
          corridors: corridors,
          reservations: reservations,
        );

  List<DiagramEdge> of(List<ClassRelation> relations) {
    final edges = <DiagramEdge>[];
    final generalizations = relations.where(_isHierarchical).toList();
    final associations = relations.where((r) => r.kind == ClassRelationKind.association).toList();

    for (final relation in generalizations) {
      final edge = _routeGeneralization(relation);
      if (edge != null) edges.add(edge);
    }

    final anchors = RelationAnchors.of(associations: associations, byName: _byName);

    for (final relation in associations) {
      final edge = _routeAssociation(relation, anchors);
      if (edge != null) edges.add(edge);
    }

    return List.unmodifiable(edges);
  }

  static bool _isHierarchical(ClassRelation relation) =>
      relation.kind == ClassRelationKind.generalization ||
      relation.kind == ClassRelationKind.realization ||
      relation.kind == ClassRelationKind.usage;

  static DiagramEdgeKind _edgeKindOf(ClassRelationKind kind) => switch (kind) {
        ClassRelationKind.generalization => DiagramEdgeKind.generalization,
        ClassRelationKind.realization => DiagramEdgeKind.realization,
        ClassRelationKind.usage => DiagramEdgeKind.usage,
        ClassRelationKind.association => DiagramEdgeKind.association,
      };

  PlacedClassBox? _endpoint(String name, ProgramNodeId? nodeId) =>
      (nodeId == null ? null : _byNode[nodeId.value]) ?? _byName[name];

  DiagramEdge? _routeGeneralization(ClassRelation relation) {
    final child = _endpoint(relation.fromClassName, relation.fromNodeId);
    final parent = _endpoint(relation.toClassName, relation.toNodeId);
    if (child == null || parent == null) return null;

    if (parent.levelIndex == child.levelIndex) {
      return _routeCyclicGeneralization(relation, child, parent);
    }

    final sharedKey = '${relation.kind.name}_${parent.box.nodeId.value}';
    final bandLevel = child.levelIndex - 1;
    final bandSub = _reservations.findHorizontalSublane(
      bandIndex: bandLevel,
      x1: child.centerX,
      x2: parent.centerX,
      sharedKey: sharedKey,
    );
    _reservations.commitHorizontal(
      bandIndex: bandLevel,
      sublane: bandSub,
      x1: child.centerX,
      x2: parent.centerX,
      sharedKey: sharedKey,
    );
    final middleY = _corridors.horizontalBandY(levelAfter: bandLevel, sublane: bandSub);

    final points = [
      DiagramPoint(child.centerX, child.top),
      DiagramPoint(child.centerX, middleY),
      DiagramPoint(parent.centerX, middleY),
      DiagramPoint(parent.centerX, parent.bottom),
    ];

    return _hierarchicalEdge(relation, child, parent, points: points);
  }

  DiagramEdge _hierarchicalEdge(
    ClassRelation relation,
    PlacedClassBox child,
    PlacedClassBox parent, {
    required List<DiagramPoint> points,
  }) =>
      DiagramEdge(
        fromId: ClassBoxNodes.frameIdOf(child),
        toId: ClassBoxNodes.frameIdOf(parent),
        points: points,
        kind: _edgeKindOf(relation.kind),
        label: relation.label,
        labelAnchor: relation.label == null ? null : _midpointOf(points),
        originNodeId: relation.originNodeId,
        diagnostics: relation.diagnostics,
      );

  static DiagramPoint _midpointOf(List<DiagramPoint> points) {
    final middle = points.length ~/ 2;
    final before = points[middle - 1];
    final after = points[middle];
    return DiagramPoint((before.x + after.x) / 2, (before.y + after.y) / 2);
  }

  DiagramEdge _routeCyclicGeneralization(
    ClassRelation relation,
    PlacedClassBox from,
    PlacedClassBox to,
  ) {
    final isLeftToRight = from.left < to.left;
    final fromX = isLeftToRight ? from.right : from.left;
    final toX = isLeftToRight ? to.left : to.right;
    final offset = isLeftToRight ? -ClassDiagramMetrics.relationLane : ClassDiagramMetrics.relationLane;
    final y = from.centerY + offset;

    return _hierarchicalEdge(relation, from, to, points: [
      DiagramPoint(fromX, y),
      DiagramPoint(toX, y),
    ]);
  }

  DiagramEdge? _routeAssociation(
    ClassRelation relation,
    Map<ClassRelation, (DiagramPoint, DiagramPoint)> anchors,
  ) {
    final from = _byName[relation.fromClassName];
    final to = _byName[relation.toClassName];
    if (from == null || to == null) return null;

    if (identical(from, to)) return _routeSelfLoop(relation, from);

    final pair = anchors[relation];
    final fromAnchor = pair?.$1 ?? DiagramPoint(from.right, from.centerY);
    final toAnchor = pair?.$2 ?? DiagramPoint(to.left, to.centerY);

    final points = _search.findAssociationRoute(
      fromBox: from,
      fromAnchor: fromAnchor,
      toBox: to,
      toAnchor: toAnchor,
    );

    return DiagramEdge(
      fromId: ClassBoxNodes.frameIdOf(from),
      toId: ClassBoxNodes.frameIdOf(to),
      points: points,
      label: relation.label,
      kind: DiagramEdgeKind.association,
      labelAnchor: _anchorForAssociation(points),
    );
  }

  DiagramEdge _routeSelfLoop(ClassRelation relation, PlacedClassBox box) {
    final sublane = _reservations.findVerticalSublane(corridorIndex: box.columnIndex, y1: box.top, y2: box.bottom);
    _reservations.commitVertical(corridorIndex: box.columnIndex, sublane: sublane, y1: box.top, y2: box.bottom);
    final x = box.right + ClassDiagramMetrics.relationLane * (sublane + 1);
    final y = box.top - ClassDiagramMetrics.selfLoopReach;

    final points = [
      DiagramPoint(box.right, box.centerY),
      DiagramPoint(x, box.centerY),
      DiagramPoint(x, y),
      DiagramPoint(box.centerX, y),
      DiagramPoint(box.centerX, box.top),
    ];

    return DiagramEdge(
      fromId: ClassBoxNodes.frameIdOf(box),
      toId: ClassBoxNodes.frameIdOf(box),
      points: points,
      label: relation.label,
      kind: DiagramEdgeKind.association,
      labelAnchor: DiagramPoint(x, (box.centerY + y) / 2),
    );
  }

  DiagramPoint _anchorForAssociation(List<DiagramPoint> points) {
    if (points.length >= 4) {
      final p1 = points[1];
      final p2 = points[2];
      return DiagramPoint(p1.x, (p1.y + p2.y) / 2);
    }
    final mid = points.length ~/ 2;
    return DiagramPoint(
      (points[mid - 1].x + points[mid].x) / 2,
      (points[mid - 1].y + points[mid].y) / 2,
    );
  }
}
