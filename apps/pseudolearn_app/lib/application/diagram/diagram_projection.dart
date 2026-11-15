import '../../domain/model/diagram/diagram_program.dart';
import '../../domain/model/execution/execution_focus.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/class_diagram_builder.dart';
import '../../domain/ports/flowchart_builder.dart';
import '../../domain/ports/structogram_builder.dart';
import 'class_focus_projection.dart';
import 'diagram_state.dart';

final class DiagramProjection {
  final FlowchartBuilder _flowchart;
  final StructogramBuilder _structogram;
  final ClassDiagramBuilder _classDiagram;

  const DiagramProjection({
    required FlowchartBuilder flowchartBuilder,
    required StructogramBuilder structogramBuilder,
    required ClassDiagramBuilder classDiagramBuilder,
  })  : _flowchart = flowchartBuilder,
        _structogram = structogramBuilder,
        _classDiagram = classDiagramBuilder;

  DiagramState project({
    required DiagramState previous,
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final flowchart = _flowchart.buildDiagram(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
    final structogram = _structogram.buildDiagram(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
    final classDiagram = _classDiagram.buildDiagram(
      sourceCode: sourceCode,
      profileId: profileId,
    );

    return previous.copyWith(
      flowchart: flowchart,
      structogram: structogram,
      classDiagram: classDiagram,
      selectedUnitId: selectedUnitIdFor(flowchart, previous.selectedUnitId),
      hasValidAst: flowchart.isNotEmpty || classDiagram.isNotEmpty,
    );
  }

  static DiagramState followingFocus(
    DiagramState previous,
    ExecutionFocus? focus,
  ) {
    final member = ClassFocusProjection.memberOf(
      units: previous.flowchart.units,
      focus: focus,
    );
    final unitId = _focusedUnitId(previous, focus) ?? previous.selectedUnitId;
    if (member == previous.focusedMemberNodeId &&
        unitId == previous.selectedUnitId) {
      return previous;
    }
    return previous.withFocus(
      selectedUnitId: unitId,
      focusedMemberNodeId: member,
    );
  }

  static String? selectedUnitIdFor(
    DiagramProgram program,
    String? previousUnitId,
  ) {
    if (program.isEmpty) return null;
    if (previousUnitId != null &&
        program.units.any((u) => u.id == previousUnitId)) {
      return previousUnitId;
    }
    return program.defaultUnit?.id;
  }

  static String? _focusedUnitId(DiagramState previous, ExecutionFocus? focus) {
    final unitId = focus?.unitId;
    if (unitId == null) return null;
    for (final unit in previous.flowchart.units) {
      if (unit.id == unitId) return unitId;
    }
    return null;
  }
}
