import '../../domain/model/diagram/diagram_scene.dart';
import '../diagram/diagram_vocabulary.dart';
import '../diagram/layout_block.dart';
import '../diagram/node_factory.dart';
import '../diagram/side_block.dart';
import 'rust_caption_text.dart';
import 'rust_control_exits.dart';
import 'rust_flowchart_scope_blocks.dart';
import 'rust_program_view.dart';
import 'rust_statement_treatment.dart';
import 'rust_task_nodes.dart';

final class RustFlowchartExitBlocks {
  final RustProgramView _view;
  final NodeFactory _nodes;
  final ExitVocabulary _words;
  final RustControlExits _exits;

  RustFlowchartExitBlocks({
    required RustProgramView view,
    required this._nodes,
    required DiagramVocabulary vocabulary,
  }) : _view = view,
       _words = vocabulary.exits,
       _exits = RustControlExits(view);

  LayoutBlock breakBlock(RustViewNode wrapper, RustViewNode node) {
    final exit = _nodes.create(
      shape: DiagramShape.process,
      text: _words.withCleanups(
        rustCaptionOf(node),
        _exits.exitCleanupLines(node),
      ),
      sourceLine: node.range.startLine,
      nodeId: wrapper.id,
    );
    final targetLine = _exits.breakTargetLine(node);
    if (targetLine == null) return LayoutBlock.fromNode(exit, hasExit: false);
    final connector = rustLoopEndNode(_nodes, _words, targetLine);
    final joined = LayoutBlock.stack([
      LayoutBlock.fromNode(exit),
      LayoutBlock.fromNode(connector, hasExit: false),
    ]);
    return _withKind(joined, DiagramEdgeKind.breakExit);
  }

  LayoutBlock deferBlock(
    RustViewNode wrapper,
    RustViewNode node,
    LayoutBlock body,
  ) => SideBlock.compose(
    main: _nodes.create(
      shape: DiagramShape.preparation,
      text: rustHeaderLine(node),
      sourceLine: node.range.startLine,
      nodeId: wrapper.id,
    ),
    side: body,
    kind: DiagramEdgeKind.cleanupRegistration,
  );

  LayoutBlock withPropagation(RustViewNode node, DiagramNode step) {
    final propagation = rustFirstPropagation(_view, node);
    if (propagation == null) return LayoutBlock.fromNode(step);
    final terminal = _nodes.create(
      shape: DiagramShape.startEnd,
      text: _words.withCleanups(
        _words.propagatedFailure,
        _exits.exitCleanupLines(propagation),
      ),
      sourceLine: propagation.range.startLine,
      nodeId: propagation.id,
    );
    return SideBlock.compose(
      main: step,
      side: LayoutBlock.fromNode(terminal, hasExit: false),
      kind: DiagramEdgeKind.propagationExit,
    );
  }

  LayoutBlock returnBlock(RustViewNode node, DiagramNode terminal) =>
      _closed(withPropagation(node, terminal));

  LayoutBlock _withKind(LayoutBlock block, DiagramEdgeKind kind) => _closed(
    block,
    edges: [
      for (final edge in block.edges)
        DiagramEdge(
          fromId: edge.fromId,
          toId: edge.toId,
          points: edge.points,
          kind: kind,
        ),
    ],
  );

  LayoutBlock _closed(LayoutBlock block, {List<DiagramEdge>? edges}) =>
      LayoutBlock(
        nodes: block.nodes,
        edges: edges ?? block.edges,
        width: block.width,
        height: block.height,
        spineX: block.spineX,
        hasExit: false,
        entryId: block.entryId,
        exitId: null,
      );
}
