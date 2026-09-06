import 'dart:math' as math;

import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';

final class LayoutBlock {
  final List<DiagramNode> nodes;
  final List<DiagramEdge> edges;
  final double width;
  final double height;
  final double spineX;
  final bool hasExit;
  final String? entryId;
  final String? exitId;

  const LayoutBlock({
    required this.nodes,
    required this.edges,
    required this.width,
    required this.height,
    required this.spineX,
    required this.hasExit,
    required this.entryId,
    required this.exitId,
  });

  const LayoutBlock.lane(this.width)
      : nodes = const [],
        edges = const [],
        height = 0.0,
        spineX = width / 2,
        hasExit = true,
        entryId = null,
        exitId = null;

  factory LayoutBlock.fromNode(DiagramNode node, {bool hasExit = true}) =>
      LayoutBlock(
        nodes: [node],
        edges: const [],
        width: node.width,
        height: node.height,
        spineX: node.width / 2,
        hasExit: hasExit,
        entryId: node.id,
        exitId: hasExit ? node.id : null,
      );

  LayoutBlock translate(double dx, double dy) => LayoutBlock(
        nodes: nodes.map((node) => node.shifted(dx, dy)).toList(),
        edges: edges.map((edge) => edge.shifted(dx, dy)).toList(),
        width: width,
        height: height,
        spineX: spineX + dx,
        hasExit: hasExit,
        entryId: entryId,
        exitId: exitId,
      );

  static LayoutBlock stack(List<LayoutBlock> blocks) {
    if (blocks.isEmpty) {
      return const LayoutBlock.lane(DiagramMetrics.gapHorizontal);
    }
    final spine = blocks.map((block) => block.spineX).reduce(math.max);
    final tops = _verticalOffsets(blocks);
    final placed = <LayoutBlock>[
      for (var index = 0; index < blocks.length; index++)
        blocks[index].translate(spine - blocks[index].spineX, tops[index]),
    ];
    return LayoutBlock(
      nodes: [for (final block in placed) ...block.nodes],
      edges: [
        for (final block in placed) ...block.edges,
        ..._joinEdges(blocks, tops, spine)
      ],
      width: blocks
          .map((block) => spine - block.spineX + block.width)
          .reduce(math.max),
      height: tops.last + blocks.last.height,
      spineX: spine,
      hasExit: blocks.last.hasExit,
      entryId: blocks.first.entryId,
      exitId: blocks.last.exitId,
    );
  }

  static List<double> _verticalOffsets(List<LayoutBlock> blocks) {
    final offsets = <double>[];
    var top = 0.0;
    for (final block in blocks) {
      offsets.add(top);
      top += block.height + DiagramMetrics.gapVertical;
    }
    return offsets;
  }

  static List<DiagramEdge> _joinEdges(
    List<LayoutBlock> blocks,
    List<double> tops,
    double spine,
  ) {
    final edges = <DiagramEdge>[];
    for (var index = 1; index < blocks.length; index++) {
      final previous = blocks[index - 1];
      final current = blocks[index];
      if (!previous.hasExit ||
          previous.exitId == null ||
          current.entryId == null) {
        continue;
      }
      edges.add(DiagramEdge(
        fromId: previous.exitId!,
        toId: current.entryId!,
        points: [
          DiagramPoint(spine, tops[index - 1] + previous.height),
          DiagramPoint(spine, tops[index]),
        ],
      ));
    }
    return edges;
  }
}
