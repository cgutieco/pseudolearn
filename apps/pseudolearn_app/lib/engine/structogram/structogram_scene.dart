import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/diagram/structogram_metrics.dart';
import 'cell_arrange.dart';
import 'cell_measure.dart';
import 'structogram_cell.dart';

final class StructogramScene {
  final List<DiagramNode> _nodes = [];
  int _sequence = 0;

  StructogramScene._();

  static DiagramScene of(StructogramCell root) {
    const margin = StructogramMetrics.canvasMargin;
    final placed = const CellArrange().arrange(
      const CellMeasure().measure(root),
      left: margin,
      top: margin,
    );
    final scene = StructogramScene._().._emit(placed);
    return DiagramScene(
      nodes: List.unmodifiable(scene._nodes),
      edges: const [],
      width: placed.width + margin * 2,
      height: placed.height + margin * 2,
    );
  }

  void _emit(PlacedCell placed) {
    switch (placed.cell) {
      case final StructogramLeaf leaf:
        _emitLeaf(leaf, placed);
      case StructogramStack():
        break;
      case final StructogramBranch branch:
        _emitBranch(branch, placed);
      case final StructogramLoop loop:
        _emitLoop(loop, placed);
    }
    for (final child in placed.children) {
      _emit(child);
    }
  }

  void _emitLeaf(StructogramLeaf leaf, PlacedCell placed) => _add(
        shape: switch (leaf.kind) {
          StructogramLeafKind.process => DiagramShape.cellProcess,
          StructogramLeafKind.call => DiagramShape.cellCall,
          StructogramLeafKind.exit => DiagramShape.cellExit,
          StructogramLeafKind.empty => DiagramShape.cellEmpty,
        },
        lines: leaf.lines,
        left: placed.left,
        top: placed.top,
        width: placed.width,
        height: placed.height,
        nodeId: leaf.nodeId,
        sourceLine: leaf.sourceLine,
      );

  void _emitBranch(StructogramBranch branch, PlacedCell placed) {
    _add(
      shape: branch.isBinary ? DiagramShape.cellCondition : DiagramShape.cellCase,
      lines: branch.headerLines,
      left: placed.left,
      top: placed.top,
      width: placed.width,
      height: placed.headerHeight,
      nodeId: branch.nodeId,
      sourceLine: branch.sourceLine,
    );
    for (var index = 0; index < placed.children.length; index++) {
      _add(
        shape: DiagramShape.cellLabel,
        lines: [branch.columns[index].label],
        left: placed.children[index].left,
        top: placed.top + placed.headerHeight - StructogramMetrics.branchLabelBand,
        width: placed.children[index].width,
        height: StructogramMetrics.branchLabelBand,
      );
    }
  }

  void _emitLoop(StructogramLoop loop, PlacedCell placed) {
    final isHeaderOnTop = loop.position == StructogramLoopPosition.header;
    final bodyHeight = placed.height - placed.headerHeight;
    _add(
      shape: DiagramShape.cellLoopHeader,
      lines: loop.headerLines,
      left: placed.left,
      top: isHeaderOnTop ? placed.top : placed.bottom - placed.headerHeight,
      width: placed.width,
      height: placed.headerHeight,
      nodeId: loop.nodeId,
      sourceLine: loop.sourceLine,
    );
    _add(
      shape: DiagramShape.cellLoopStrip,
      lines: const [],
      left: placed.left,
      top: isHeaderOnTop ? placed.top + placed.headerHeight : placed.top,
      width: StructogramMetrics.loopIndent,
      height: bodyHeight,
    );
  }

  void _add({
    required DiagramShape shape,
    required List<String> lines,
    required double left,
    required double top,
    required double width,
    required double height,
    ProgramNodeId? nodeId,
    int? sourceLine,
  }) {
    _sequence += 1;
    _nodes.add(DiagramNode(
      id: 's$_sequence',
      shape: shape,
      lines: lines,
      x: left,
      y: top,
      width: width,
      height: height,
      sourceLine: sourceLine,
      nodeId: nodeId,
    ));
  }
}
