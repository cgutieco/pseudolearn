import '../../domain/model/diagram/diagram_scene.dart';
import '../diagram/diagram_vocabulary.dart';
import '../diagram/layout_block.dart';
import '../diagram/node_factory.dart';
import 'rust_control_exits.dart';
import 'rust_program_view.dart';

DiagramNode rustLoopEndNode(
  NodeFactory nodes,
  ExitVocabulary words,
  int loopLine,
) => nodes.create(
  shape: DiagramShape.exitConnector,
  text: words.loopExit(loopLine),
  sourceLine: loopLine,
);

final class RustFlowchartScopeBlocks {
  final NodeFactory _nodes;
  final ExitVocabulary _words;
  final RustControlExits _exits;

  RustFlowchartScopeBlocks({
    required RustProgramView view,
    required NodeFactory nodes,
    required DiagramVocabulary vocabulary,
  }) : _nodes = nodes,
       _words = vocabulary.exits,
       _exits = RustControlExits(view);

  LayoutBlock closeScope(RustViewNode body, LayoutBlock sequence) {
    final lines = _exits.normalCleanupLines(body);
    if (lines.isEmpty || !sequence.hasExit) return sequence;
    final cleanups = _nodes.create(
      shape: DiagramShape.subprogram,
      text: _words.cleanupsAtEndOf(lines),
      sourceLine: lines.first,
      nodeId: body.id,
    );
    return LayoutBlock.stack([sequence, LayoutBlock.fromNode(cleanups)]);
  }

  LayoutBlock closeLoop(RustViewNode node, LayoutBlock loop) {
    if (!_exits.isBreakTarget(node)) return loop;
    return LayoutBlock.stack([
      loop,
      LayoutBlock.fromNode(
        rustLoopEndNode(_nodes, _words, node.range.startLine),
      ),
    ]);
  }
}
