import '../../domain/model/diagram/diagram_notation.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/knowledge/content_block.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/class_diagram_builder.dart';
import '../../domain/ports/flowchart_builder.dart';
import '../../domain/ports/structogram_builder.dart';

final class DiagramBlockResolver {
  final FlowchartBuilder _flowchart;
  final StructogramBuilder _structogram;
  final ClassDiagramBuilder _classDiagram;

  const DiagramBlockResolver({
    required FlowchartBuilder flowchartBuilder,
    required StructogramBuilder structogramBuilder,
    required ClassDiagramBuilder classDiagramBuilder,
  })  : _flowchart = flowchartBuilder,
        _structogram = structogramBuilder,
        _classDiagram = classDiagramBuilder;

  List<ContentBlock> resolve(
    List<ContentBlock> blocks,
    SyntaxProfileId profileId,
    UiLanguageId languageId,
  ) {
    final resolved = <ContentBlock>[];
    for (final block in blocks) {
      resolved.add(switch (block) {
        final DiagramBlock b => DiagramBlock(
            code: b.code,
            notation: b.notation,
            scene: _sceneFor(b, profileId, languageId),
            title: b.title,
          ),
        _ => block,
      });
    }
    return resolved;
  }

  DiagramScene _sceneFor(
    DiagramBlock block,
    SyntaxProfileId profileId,
    UiLanguageId languageId,
  ) {
    return switch (block.notation) {
      DiagramNotation.flowchart => _flowchart
          .buildDiagram(sourceCode: block.code, profileId: profileId, languageId: languageId)
          .sceneFor(null),
      DiagramNotation.structogram => _structogram
          .buildDiagram(sourceCode: block.code, profileId: profileId, languageId: languageId)
          .sceneFor(null),
      DiagramNotation.classDiagram =>
        _classDiagram.buildDiagram(sourceCode: block.code, profileId: profileId),
    };
  }
}
