import '../../domain/model/diagram/diagram_scene.dart';
import '../diagram/diagram_vocabulary.dart';
import '../diagram/node_factory.dart';
import 'rust_caption_text.dart';
import 'rust_control_exits.dart';
import 'rust_diagram_captions.dart';
import 'rust_program_view.dart';
import 'rust_task_nodes.dart';

final class RustFlowchartNodes {
  final RustProgramView _view;
  final NodeFactory _nodes;
  final DiagramVocabulary _vocabulary;
  final RustDiagramCaptions _captions;
  final RustControlExits _exits;

  RustFlowchartNodes({
    required RustProgramView view,
    required NodeFactory nodes,
    required DiagramVocabulary vocabulary,
    required RustDiagramCaptions captions,
  }) : _view = view,
       _nodes = nodes,
       _vocabulary = vocabulary,
       _captions = captions,
       _exits = RustControlExits(view);

  DiagramNode decision(RustViewNode owner, RustViewNode? condition) =>
      _nodes.create(
        shape: DiagramShape.decision,
        text: _vocabulary.asQuestion(rustCaptionOf(condition)),
        sourceLine: owner.range.startLine,
        nodeId: owner.id,
      );

  DiagramNode selector(RustViewNode owner, RustViewNode? selector) =>
      _nodes.create(
        shape: DiagramShape.decision,
        text: _captions.selector(rustCaptionOf(selector)),
        sourceLine: owner.range.startLine,
        nodeId: owner.id,
      );

  DiagramNode simple(RustViewNode wrapper, RustViewNode node) => _nodes.create(
    shape: _shape(node),
    text: _vocabulary.exits.withCleanups(
      rustCaptionOf(node),
      _exits.exitCleanupLines(node),
    ),
    sourceLine: node.range.startLine,
    nodeId: wrapper.id,
  );

  String header(RustViewNode node) {
    final parts = rustChildrenForRole(_view, node, 'loop_header');
    if (parts.isEmpty) return rustCaptionOf(node);
    return _captions.loopHeader(parts.map(rustCaptionOf).toList());
  }

  DiagramShape _shape(RustViewNode node) => switch (node.syntaxKind) {
    'input' || 'output' => DiagramShape.inputOutput,
    'call_statement' => DiagramShape.subprogram,
    'return_statement' => DiagramShape.startEnd,
    _ when rustNodeIsTaskOperation(_view, node) => DiagramShape.subprogram,
    _ => DiagramShape.process,
  };
}
