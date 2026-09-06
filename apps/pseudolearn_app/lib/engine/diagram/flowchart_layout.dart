import 'package:pseudolearn_core/pseudolearn_core.dart';

import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_program.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/flowchart_builder.dart';
import '../analysis/analysis_cache.dart';
import '../printing/pseudocode_printer.dart';
import 'block_builder.dart';
import 'diagram_vocabulary.dart';
import 'executable_units.dart';
import 'layout_block.dart';
import 'node_factory.dart';
import 'node_sizing.dart';
import 'statement_caption.dart';
import 'text_metrics.dart';

final class FlowchartLayout implements FlowchartBuilder {
  final AnalysisCache _analyses;

  FlowchartLayout({AnalysisCache? analyses})
      : _analyses = analyses ?? AnalysisCache();

  @override
  DiagramProgram buildDiagram({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final analysis = _analyses.of(sourceCode, profileId);
    final unit = analysis.sourceUnit;
    if (unit == null) return const DiagramProgram.empty();

    final vocabulary = DiagramVocabulary.forLanguage(languageId);
    final entries = ExecutableUnits.fromAst(unit, vocabulary: vocabulary);
    if (entries.isEmpty) return const DiagramProgram.empty();

    final scenes = <String, DiagramScene>{};
    for (final entry in entries) {
      scenes[entry.unit.id] = _composeUnitScene(
        entry,
        analysis.profile,
        vocabulary,
      );
    }

    return DiagramProgram(
      units: entries.map((e) => e.unit).toList(),
      scenes: scenes,
    );
  }

  DiagramScene _composeUnitScene(
    ExecutableUnitEntry entry,
    LanguageProfile profile,
    DiagramVocabulary vocabulary,
  ) {
    final nodes = NodeFactory(const NodeSizing(TextMetrics()));
    final builder = BlockBuilder(
      nodes: nodes,
      vocabulary: vocabulary,
      caption: StatementCaption(
        printer: PseudocodePrinter(profile),
        lexicon: profile,
        vocabulary: vocabulary,
      ),
    );
    final start = _terminal(nodes, vocabulary.start, entry.span.start.line);
    final body = entry.body.isEmpty
        ? null
        : LayoutBlock.stack(
            entry.body.map(builder.buildStatement).toList(),
          );
    final end = _terminal(nodes, vocabulary.end, entry.span.end.line);
    final block = LayoutBlock.stack([start, if (body != null) body, end]);
    return _toScene(block);
  }

  LayoutBlock _terminal(NodeFactory nodes, String text, int sourceLine) =>
      LayoutBlock.fromNode(nodes.create(
        shape: DiagramShape.startEnd,
        text: text,
        sourceLine: sourceLine,
      ));

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
