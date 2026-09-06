import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import 'branch_geometry.dart';
import 'layout_block.dart';

final class BranchColumn {
  final LayoutBlock block;
  final String label;
  final DiagramEdgeKind kind;

  const BranchColumn({
    required this.block,
    required this.label,
    required this.kind,
  });
}

final class BranchBlocks {
  const BranchBlocks._();

  static LayoutBlock conditional({
    required DiagramNode decision,
    required List<BranchColumn> columns,
    required DiagramNode junction,
  }) {
    final placed = BranchGeometry.place(
      columns.map((column) => column.block).toList(),
      top: decision.height + DiagramMetrics.gapVertical,
      headerWidth: decision.width,
      minimumSpineSpan: decision.width + DiagramMetrics.gapHorizontal * 2,
    );
    final spine = placed.width / 2;
    final junctionCenterY = placed.bottom + DiagramMetrics.gapVertical + junction.height / 2;
    final header = decision.shifted(spine - decision.width / 2, 0.0);
    return _assemble(
      header: header,
      junction: junction.shifted(spine - junction.width / 2, junctionCenterY - junction.height / 2),
      placed: placed,
      spine: spine,
      edges: [
        for (var index = 0; index < columns.length; index++)
          ..._sidePortEdges(
            header: header,
            column: columns[index],
            block: placed.blocks[index],
            junctionCenterY: junctionCenterY,
            junctionId: junction.id,
            toLeft: index == 0,
            spine: spine,
            columnTop: placed.top,
          ),
      ],
    );
  }

  static LayoutBlock selection({
    required DiagramNode selector,
    required List<BranchColumn> columns,
    required DiagramNode junction,
  }) {
    final busY = selector.height + DiagramMetrics.gapVertical;
    final placed = BranchGeometry.place(
      columns.map((column) => column.block).toList(),
      top: busY + DiagramMetrics.gapVertical,
      headerWidth: selector.width,
      minimumSpineSpan: 0.0,
    );
    final spine = placed.width / 2;
    final junctionCenterY = placed.bottom + DiagramMetrics.gapVertical + junction.height / 2;
    final header = selector.shifted(spine - selector.width / 2, 0.0);
    return _assemble(
      header: header,
      junction: junction.shifted(spine - junction.width / 2, junctionCenterY - junction.height / 2),
      placed: placed,
      spine: spine,
      edges: [
        for (var index = 0; index < columns.length; index++)
          ..._busEdges(
            header: header,
            column: columns[index],
            block: placed.blocks[index],
            busY: busY,
            junctionCenterY: junctionCenterY,
            junctionId: junction.id,
            spine: spine,
            columnTop: placed.top,
          ),
      ],
    );
  }

  static LayoutBlock _assemble({
    required DiagramNode header,
    required DiagramNode junction,
    required PlacedColumns placed,
    required double spine,
    required List<DiagramEdge> edges,
  }) {
    return LayoutBlock(
      nodes: [header, for (final block in placed.blocks) ...block.nodes, junction],
      edges: [for (final block in placed.blocks) ...block.edges, ...edges],
      width: placed.width,
      height: junction.y + junction.height,
      spineX: spine,
      hasExit: true,
      entryId: header.id,
      exitId: junction.id,
    );
  }

  static List<DiagramEdge> _sidePortEdges({
    required DiagramNode header,
    required BranchColumn column,
    required LayoutBlock block,
    required double junctionCenterY,
    required String junctionId,
    required bool toLeft,
    required double spine,
    required double columnTop,
  }) {
    final portX = toLeft ? header.x : header.x + header.width;
    final portY = header.y + header.height / 2;
    return [
      DiagramEdge(
        fromId: header.id,
        toId: block.entryId ?? junctionId,
        label: column.label,
        kind: column.kind,
        labelAnchor: DiagramPoint(
          (portX + block.spineX) / 2,
          portY - DiagramMetrics.edgeLabelGap,
        ),
        points: _sidePortPoints(
          block: block,
          portX: portX,
          portY: portY,
          columnTop: columnTop,
          junctionCenterY: junctionCenterY,
          spine: spine,
        ),
      ),
      ..._exitEdges(
        block: block,
        junctionCenterY: junctionCenterY,
        junctionId: junctionId,
        spine: spine,
        columnTop: columnTop,
      ),
    ];
  }

  static List<DiagramPoint> _sidePortPoints({
    required LayoutBlock block,
    required double portX,
    required double portY,
    required double columnTop,
    required double junctionCenterY,
    required double spine,
  }) {
    if (block.entryId != null) {
      return [
        DiagramPoint(portX, portY),
        DiagramPoint(block.spineX, portY),
        DiagramPoint(block.spineX, columnTop),
      ];
    }
    return [
      DiagramPoint(portX, portY),
      DiagramPoint(block.spineX, portY),
      DiagramPoint(block.spineX, junctionCenterY),
      DiagramPoint(spine, junctionCenterY),
    ];
  }

  static List<DiagramEdge> _busEdges({
    required DiagramNode header,
    required BranchColumn column,
    required LayoutBlock block,
    required double busY,
    required double junctionCenterY,
    required String junctionId,
    required double spine,
    required double columnTop,
  }) {
    final columnSpine = block.spineX;
    final target = block.entryId ?? junctionId;
    final descent = block.entryId == null ? junctionCenterY : columnTop;
    return [
      DiagramEdge(
        fromId: header.id,
        toId: target,
        label: column.label,
        kind: column.kind,
        labelAnchor: DiagramPoint(columnSpine, (busY + columnTop) / 2),
        points: [
          DiagramPoint(spine, header.y + header.height),
          DiagramPoint(spine, busY),
          DiagramPoint(columnSpine, busY),
          DiagramPoint(columnSpine, descent),
          if (block.entryId == null) DiagramPoint(spine, junctionCenterY),
        ],
      ),
      ..._exitEdges(
        block: block,
        junctionCenterY: junctionCenterY,
        junctionId: junctionId,
        spine: spine,
        columnTop: columnTop,
      ),
    ];
  }

  static List<DiagramEdge> _exitEdges({
    required LayoutBlock block,
    required double junctionCenterY,
    required String junctionId,
    required double spine,
    required double columnTop,
  }) {
    if (!block.hasExit || block.exitId == null) return const [];
    return [
      DiagramEdge(
        fromId: block.exitId!,
        toId: junctionId,
        points: [
          DiagramPoint(block.spineX, columnTop + block.height),
          DiagramPoint(block.spineX, junctionCenterY),
          DiagramPoint(spine, junctionCenterY),
        ],
      ),
    ];
  }
}
