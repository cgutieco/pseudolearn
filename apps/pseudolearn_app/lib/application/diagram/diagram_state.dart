import 'package:equatable/equatable.dart';
import '../../domain/model/analysis/program_dependency.dart';
import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/diagram/diagram_accessible_element.dart';
import '../../domain/model/diagram/diagram_notation.dart';
import '../../domain/model/diagram/diagram_program.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/diagram/diagram_unit.dart';
import 'class_diagram_accessibility.dart';

final class DiagramState extends Equatable {
  final DiagramProgram flowchart;
  final DiagramProgram structogram;
  final DiagramScene classDiagram;
  final DiagramNotation notation;
  final String? selectedUnitId;
  final ProgramNodeId? focusedMemberNodeId;
  final bool hasValidAst;

  const DiagramState({
    required this.flowchart,
    required this.structogram,
    required this.classDiagram,
    this.notation = DiagramNotation.flowchart,
    this.selectedUnitId,
    this.focusedMemberNodeId,
    required this.hasValidAst,
  });

  const DiagramState.initial()
      : flowchart = const DiagramProgram.empty(),
        structogram = const DiagramProgram.empty(),
        classDiagram = const DiagramScene.empty(),
        notation = DiagramNotation.flowchart,
        selectedUnitId = null,
        focusedMemberNodeId = null,
        hasValidAst = false;

  DiagramScene get scene => switch (notation) {
        DiagramNotation.flowchart => flowchart.sceneFor(selectedUnitId),
        DiagramNotation.structogram => structogram.sceneFor(selectedUnitId),
        DiagramNotation.classDiagram => classDiagram,
      };

  List<DiagramUnit> get units => switch (notation) {
        DiagramNotation.flowchart => flowchart.units,
        DiagramNotation.structogram => structogram.units,
        DiagramNotation.classDiagram => const [],
      };

  List<String> get unsupportedKinds => switch (notation) {
        DiagramNotation.flowchart => flowchart.unsupportedKinds,
        DiagramNotation.structogram => structogram.unsupportedKinds,
        DiagramNotation.classDiagram => const [],
      };

  List<ProgramDependency> get dependencies => flowchart.dependencies;

  bool get hasClasses => classDiagram.isNotEmpty;

  List<DiagramAccessibleElement> get accessibleElements =>
      notation == DiagramNotation.classDiagram
          ? ClassDiagramAccessibility(classDiagram).elements()
          : const [];

  DiagramState copyWith({
    DiagramProgram? flowchart,
    DiagramProgram? structogram,
    DiagramScene? classDiagram,
    DiagramNotation? notation,
    String? selectedUnitId,
    ProgramNodeId? focusedMemberNodeId,
    bool? hasValidAst,
  }) {
    return DiagramState(
      flowchart: flowchart ?? this.flowchart,
      structogram: structogram ?? this.structogram,
      classDiagram: classDiagram ?? this.classDiagram,
      notation: notation ?? this.notation,
      selectedUnitId: selectedUnitId ?? this.selectedUnitId,
      focusedMemberNodeId: focusedMemberNodeId ?? this.focusedMemberNodeId,
      hasValidAst: hasValidAst ?? this.hasValidAst,
    );
  }

  DiagramState withFocus({
    required String? selectedUnitId,
    required ProgramNodeId? focusedMemberNodeId,
  }) {
    return DiagramState(
      flowchart: flowchart,
      structogram: structogram,
      classDiagram: classDiagram,
      notation: notation,
      selectedUnitId: selectedUnitId,
      focusedMemberNodeId: focusedMemberNodeId,
      hasValidAst: hasValidAst,
    );
  }

  @override
  List<Object?> get props => [
        flowchart,
        structogram,
        classDiagram,
        notation,
        selectedUnitId,
        focusedMemberNodeId,
        hasValidAst,
      ];
}
