import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_diagram_metrics.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_metrics.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/engine/diagram/text_metrics.dart';

int countEllipsizedTexts(DiagramScene scene) {
  var count = 0;
  for (final node in scene.nodes) {
    for (final line in node.lines) {
      if (line.contains('…') || line.endsWith('...')) {
        count += 1;
      }
    }
  }
  for (final edge in scene.edges) {
    final label = edge.label;
    if (label != null && (label.contains('…') || label.endsWith('...'))) {
      count += 1;
    }
  }
  return count;
}

int countTextOverflows(
  DiagramScene scene, {
  TextMetrics textMetrics = const TextMetrics(),
}) {
  var overflows = 0;
  const epsilon = 0.5;

  for (final node in scene.nodes) {
    if (node.lines.isEmpty) continue;
    if (node.shape == DiagramShape.classHeader) {
      final headerWidth = textMetrics.advanceUnits(node.lines.first) *
              DiagramMetrics.fontSize +
          ClassDiagramMetrics.boxPadding * 2;
      if (headerWidth > node.width + epsilon) {
        overflows += 1;
      }
    } else if (node.shape == DiagramShape.classRow) {
      for (final line in node.lines) {
        final rowWidth = textMetrics.advanceUnits(line) *
                DiagramMetrics.fontSize +
            ClassDiagramMetrics.boxPadding * 2 +
            ClassDiagramMetrics.visibilityColumn;
        if (rowWidth > node.width + epsilon) {
          overflows += 1;
        }
      }
    }
  }
  return overflows;
}

int countLineBoxCrossings(DiagramScene scene) {
  var crossings = 0;
  final frames =
      scene.nodes.where((n) => n.shape == DiagramShape.classFrame).toList();

  for (final edge in scene.edges) {
    for (var index = 0; index < edge.points.length - 1; index++) {
      final p1 = edge.points[index];
      final p2 = edge.points[index + 1];

      for (final frame in frames) {
        if (_segmentIntersectsFrameInterior(
            p1, p2, frame, edge.fromId, edge.toId)) {
          crossings += 1;
        }
      }
    }
  }
  return crossings;
}

bool _segmentIntersectsFrameInterior(
  DiagramPoint p1,
  DiagramPoint p2,
  DiagramNode frame,
  String fromId,
  String toId,
) {
  const epsilon = 0.5;
  final minX = frame.x + epsilon;
  final maxX = frame.x + frame.width - epsilon;
  final minY = frame.y + epsilon;
  final maxY = frame.y + frame.height - epsilon;

  final segMinX = math.min(p1.x, p2.x);
  final segMaxX = math.max(p1.x, p2.x);
  final segMinY = math.min(p1.y, p2.y);
  final segMaxY = math.max(p1.y, p2.y);

  if (segMaxX < minX || segMinX > maxX || segMaxY < minY || segMinY > maxY) {
    return false;
  }

  if (p1.x == p2.x) {
    final x = p1.x;
    if (x > minX && x < maxX) {
      final overlap =
          math.max(0.0, math.min(segMaxY, maxY) - math.max(segMinY, minY));
      if (overlap > epsilon) return true;
    }
  } else if (p1.y == p2.y) {
    final y = p1.y;
    if (y > minY && y < maxY) {
      final overlap =
          math.max(0.0, math.min(segMaxX, maxX) - math.max(segMinX, minX));
      if (overlap > epsilon) return true;
    }
  }

  return false;
}

int countOverlappingLabels(DiagramScene scene) {
  var overlaps = 0;
  const textMetrics = TextMetrics();
  final labeledEdges =
      scene.edges.where((e) => e.label != null && e.labelAnchor != null).toList();

  for (var i = 0; i < labeledEdges.length; i++) {
    final e1 = labeledEdges[i];
    final w1 = textMetrics.advanceUnits(e1.label!) * DiagramMetrics.fontSize +
        ClassDiagramMetrics.boxPadding;
    final r1Left = e1.labelAnchor!.x - w1 / 2;
    final r1Right = e1.labelAnchor!.x + w1 / 2;
    final r1Top = e1.labelAnchor!.y - 9.0;
    final r1Bottom = e1.labelAnchor!.y + 9.0;

    for (var j = i + 1; j < labeledEdges.length; j++) {
      final e2 = labeledEdges[j];
      final w2 = textMetrics.advanceUnits(e2.label!) * DiagramMetrics.fontSize +
          ClassDiagramMetrics.boxPadding;
      final r2Left = e2.labelAnchor!.x - w2 / 2;
      final r2Right = e2.labelAnchor!.x + w2 / 2;
      final r2Top = e2.labelAnchor!.y - 9.0;
      final r2Bottom = e2.labelAnchor!.y + 9.0;

      final overlapX =
          math.max(0.0, math.min(r1Right, r2Right) - math.max(r1Left, r2Left));
      final overlapY = math.max(
          0.0, math.min(r1Bottom, r2Bottom) - math.max(r1Top, r2Top));
      if (overlapX > 0.5 && overlapY > 0.5) {
        overlaps += 1;
      }
    }
  }
  return overlaps;
}

int countTotalLabelCollisions(DiagramScene scene) {
  var collisions = countOverlappingLabels(scene);
  const textMetrics = TextMetrics();
  final labeledEdges =
      scene.edges.where((e) => e.label != null && e.labelAnchor != null).toList();
  final frames =
      scene.nodes.where((n) => n.shape == DiagramShape.classFrame).toList();

  for (final edge in labeledEdges) {
    final width = textMetrics.advanceUnits(edge.label!) *
            DiagramMetrics.fontSize +
        ClassDiagramMetrics.boxPadding;
    final rLeft = edge.labelAnchor!.x - width / 2;
    final rRight = edge.labelAnchor!.x + width / 2;
    final rTop = edge.labelAnchor!.y - 9.0;
    final rBottom = edge.labelAnchor!.y + 9.0;

    for (final frame in frames) {
      final overlapX = math.max(
          0.0, math.min(rRight, frame.x + frame.width) - math.max(rLeft, frame.x));
      final overlapY = math.max(
          0.0, math.min(rBottom, frame.y + frame.height) - math.max(rTop, frame.y));
      if (overlapX > 0.5 && overlapY > 0.5) {
        collisions += 1;
      }
    }
  }
  return collisions;
}

double measureCollinearOverlapPx(
  DiagramScene scene, {
  bool allowSharedGeneralizationTrunk = true,
}) {
  var totalOverlap = 0.0;
  for (var i = 0; i < scene.edges.length; i++) {
    final e1 = scene.edges[i];
    for (var j = i + 1; j < scene.edges.length; j++) {
      final e2 = scene.edges[j];
      if (allowSharedGeneralizationTrunk &&
          e1.kind == DiagramEdgeKind.generalization &&
          e2.kind == DiagramEdgeKind.generalization &&
          e1.toId == e2.toId) {
        continue;
      }
      totalOverlap += _overlapBetweenEdges(e1, e2);
    }
  }
  return totalOverlap;
}

double _overlapBetweenEdges(DiagramEdge e1, DiagramEdge e2) {
  var overlap = 0.0;
  for (var i = 0; i < e1.points.length - 1; i++) {
    final a1 = e1.points[i];
    final a2 = e1.points[i + 1];
    for (var j = 0; j < e2.points.length - 1; j++) {
      final b1 = e2.points[j];
      final b2 = e2.points[j + 1];
      overlap += _overlapBetweenSegments(a1, a2, b1, b2);
    }
  }
  return overlap;
}

double _overlapBetweenSegments(
    DiagramPoint a1, DiagramPoint a2, DiagramPoint b1, DiagramPoint b2) {
  if ((a1.x - a2.x).abs() < 0.01 &&
      (b1.x - b2.x).abs() < 0.01 &&
      (a1.x - b1.x).abs() < 0.01) {
    final minY = math.max(math.min(a1.y, a2.y), math.min(b1.y, b2.y));
    final maxY = math.min(math.max(a1.y, a2.y), math.max(b1.y, b2.y));
    return math.max(0.0, maxY - minY);
  }
  if ((a1.y - a2.y).abs() < 0.01 &&
      (b1.y - b2.y).abs() < 0.01 &&
      (a1.y - b1.y).abs() < 0.01) {
    final minX = math.max(math.min(a1.x, a2.x), math.min(b1.x, b2.x));
    final maxX = math.min(math.max(a1.x, a2.x), math.max(b1.x, b2.x));
    return math.max(0.0, maxX - minX);
  }
  return 0.0;
}

int countEdgeEdgeCrossings(DiagramScene scene) {
  var crossings = 0;
  for (var i = 0; i < scene.edges.length; i++) {
    final e1 = scene.edges[i];
    for (var j = i + 1; j < scene.edges.length; j++) {
      final e2 = scene.edges[j];
      for (var a = 0; a < e1.points.length - 1; a++) {
        final p1 = e1.points[a];
        final p2 = e1.points[a + 1];
        for (var b = 0; b < e2.points.length - 1; b++) {
          final p3 = e2.points[b];
          final p4 = e2.points[b + 1];
          if (_segmentsCrossOrthogonally(p1, p2, p3, p4)) {
            crossings += 1;
          }
        }
      }
    }
  }
  return crossings;
}

bool _segmentsCrossOrthogonally(
  DiagramPoint a1,
  DiagramPoint a2,
  DiagramPoint b1,
  DiagramPoint b2,
) {
  const epsilon = 0.5;
  final aIsHorizontal = (a1.y - a2.y).abs() < 0.01;
  final aIsVertical = (a1.x - a2.x).abs() < 0.01;
  final bIsHorizontal = (b1.y - b2.y).abs() < 0.01;
  final bIsVertical = (b1.x - b2.x).abs() < 0.01;

  if (aIsHorizontal && bIsVertical) {
    final y = a1.y;
    final x = b1.x;
    final aMinX = math.min(a1.x, a2.x);
    final aMaxX = math.max(a1.x, a2.x);
    final bMinY = math.min(b1.y, b2.y);
    final bMaxY = math.max(b1.y, b2.y);
    return x > aMinX + epsilon &&
        x < aMaxX - epsilon &&
        y > bMinY + epsilon &&
        y < bMaxY - epsilon;
  }
  if (aIsVertical && bIsHorizontal) {
    final x = a1.x;
    final y = b1.y;
    final aMinY = math.min(a1.y, a2.y);
    final aMaxY = math.max(a1.y, a2.y);
    final bMinX = math.min(b1.x, b2.x);
    final bMaxX = math.max(b1.x, b2.x);
    return x > bMinX + epsilon &&
        x < bMaxX - epsilon &&
        y > aMinY + epsilon &&
        y < aMaxY - epsilon;
  }
  return false;
}

bool areScenesIdentical(DiagramScene a, DiagramScene b) {
  if (a.nodes.length != b.nodes.length ||
      a.edges.length != b.edges.length ||
      (a.width - b.width).abs() > 0.01 ||
      (a.height - b.height).abs() > 0.01) {
    return false;
  }
  for (var i = 0; i < a.nodes.length; i++) {
    final n1 = a.nodes[i];
    final n2 = b.nodes[i];
    if (n1.id != n2.id ||
        n1.shape != n2.shape ||
        (n1.x - n2.x).abs() > 0.01 ||
        (n1.y - n2.y).abs() > 0.01 ||
        (n1.width - n2.width).abs() > 0.01 ||
        (n1.height - n2.height).abs() > 0.01 ||
        n1.lines.length != n2.lines.length) {
      return false;
    }
  }
  for (var i = 0; i < a.edges.length; i++) {
    final e1 = a.edges[i];
    final e2 = b.edges[i];
    if (e1.fromId != e2.fromId ||
        e1.toId != e2.toId ||
        e1.kind != e2.kind ||
        e1.label != e2.label ||
        e1.points.length != e2.points.length) {
      return false;
    }
  }
  return true;
}

int countInvalidUmlDecorations(DiagramScene scene) {
  var invalid = 0;
  for (final edge in scene.edges) {
    if (edge.kind != DiagramEdgeKind.generalization &&
        edge.kind != DiagramEdgeKind.association) {
      invalid += 1;
    }
  }
  return invalid;
}

void expectZeroEllipsizedTexts(DiagramScene scene) {
  expect(countEllipsizedTexts(scene), 0, reason: 'Expected zero ellipsized texts');
}

void expectZeroTextOverflows(DiagramScene scene) {
  expect(countTextOverflows(scene), 0, reason: 'Expected zero text overflows');
}

void expectZeroLineBoxCrossings(DiagramScene scene) {
  expect(countLineBoxCrossings(scene), 0,
      reason: 'Expected zero line/box crossings');
}

void expectZeroOverlappingLabels(DiagramScene scene) {
  expect(countOverlappingLabels(scene), 0,
      reason: 'Expected zero overlapping labels');
}

void expectZeroLabelCollisions(DiagramScene scene) {
  expect(countTotalLabelCollisions(scene), 0,
      reason: 'Expected zero label collisions with boxes or other labels');
}

void expectZeroCollinearOverlap(DiagramScene scene) {
  expect(measureCollinearOverlapPx(scene), 0.0,
      reason: 'Expected zero collinear edge overlap');
}

void expectDeterministicScenes(DiagramScene a, DiagramScene b) {
  expect(areScenesIdentical(a, b), isTrue,
      reason: 'Expected identical deterministic scenes');
}
