import 'dart:math' as math;

import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import 'layout_block.dart';

final class SideBlock {
  const SideBlock._();

  static LayoutBlock compose({
    required DiagramNode main,
    required LayoutBlock side,
    required DiagramEdgeKind kind,
  }) {
    final sideLeft = main.width + DiagramMetrics.gapHorizontal;
    final placedSide = side.translate(sideLeft, 0.0);
    final edges = [
      ...placedSide.edges,
      if (_entryOf(placedSide) case final DiagramNode entry)
        _link(main, entry, kind),
    ];
    return LayoutBlock(
      nodes: [main, ...placedSide.nodes],
      edges: edges,
      width: sideLeft + side.width,
      height: math.max(main.height, side.height),
      spineX: main.width / 2,
      hasExit: true,
      entryId: main.id,
      exitId: main.id,
    );
  }

  static DiagramNode? _entryOf(LayoutBlock block) {
    for (final node in block.nodes) {
      if (node.id == block.entryId) return node;
    }
    return null;
  }

  static DiagramEdge _link(
    DiagramNode main,
    DiagramNode entry,
    DiagramEdgeKind kind,
  ) {
    final startY = main.y + main.height / 2;
    final endY = entry.y + entry.height / 2;
    final turnX = main.x + main.width + DiagramMetrics.gapHorizontal / 2;
    return DiagramEdge(
      fromId: main.id,
      toId: entry.id,
      kind: kind,
      points: [
        DiagramPoint(main.x + main.width, startY),
        DiagramPoint(turnX, startY),
        DiagramPoint(turnX, endY),
        DiagramPoint(entry.x, endY),
      ],
    );
  }
}
