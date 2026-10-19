import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_program.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/flowchart_builder.dart';
import '../diagram/diagram_vocabulary.dart';
import '../diagram/layout_block.dart';
import '../diagram/node_factory.dart';
import '../diagram/node_sizing.dart';
import '../diagram/text_metrics.dart';
import 'rust_executable_unit_reader.dart';
import 'rust_flowchart_block_builder.dart';
import 'rust_program_view.dart';
import 'rust_program_view_source.dart';
import 'rust_transport.dart';

final class RustFlowchartBuilder implements FlowchartBuilder {
  final RustProgramViewSource _views;
  final RustExecutableUnitReader _units;

  RustFlowchartBuilder(RustTransport transport)
    : _views = RustProgramViewSource(transport),
      _units = const RustExecutableUnitReader();

  @override
  DiagramProgram buildDiagram({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final view = _views.load(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
    if (view == null) return const DiagramProgram.empty();
    final vocabulary = DiagramVocabulary.forLanguage(languageId);
    final entries = _units.read(view, vocabulary: vocabulary);
    final scenes = <String, DiagramScene>{};
    for (final entry in entries) {
      scenes[entry.unit.id] = _scene(entry, view, vocabulary);
    }
    return DiagramProgram(
      units: entries.map((entry) => entry.unit).toList(),
      scenes: scenes,
    );
  }

  DiagramScene _scene(
    RustExecutableUnit entry,
    RustProgramView view,
    DiagramVocabulary vocabulary,
  ) {
    final nodes = NodeFactory(const NodeSizing(TextMetrics()));
    final blocks = RustFlowchartBlockBuilder(
      view: view,
      nodes: nodes,
      vocabulary: vocabulary,
    );
    final start = _terminal(
      nodes,
      vocabulary.start,
      entry.node.range.startLine,
    );
    final statements = rustChildrenOf(
      view,
      entry.body,
    ).any((node) => node.syntaxKind == 'statement');
    final body = statements ? blocks.sequence(entry.body) : null;
    final end = _terminal(nodes, vocabulary.end, entry.node.range.endLine);
    return _toScene(LayoutBlock.stack([start, ?body, end]));
  }

  LayoutBlock _terminal(NodeFactory nodes, String text, int sourceLine) =>
      LayoutBlock.fromNode(
        nodes.create(
          shape: DiagramShape.startEnd,
          text: text,
          sourceLine: sourceLine,
        ),
      );

  DiagramScene _toScene(LayoutBlock block) {
    const margin = DiagramMetrics.canvasMargin;
    final placed = block.translate(margin, margin);
    return DiagramScene(
      nodes: placed.nodes,
      edges: placed.edges,
      width: block.width + margin * 2,
      height: block.height + margin * 2,
    );
  }
}
