import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_unit.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/class_diagram_builder.dart';
import 'package:pseudolearn_app/domain/ports/flowchart_builder.dart';
import 'package:pseudolearn_app/domain/ports/structogram_builder.dart';

DiagramProgram stubProgram({
  required List<String> unitIds,
  required DiagramShape shape,
}) {
  if (unitIds.isEmpty) return const DiagramProgram.empty();
  final units = <DiagramUnit>[];
  final scenes = <String, DiagramScene>{};
  for (var index = 0; index < unitIds.length; index++) {
    units.add(_unitOf(unitIds[index], index));
    scenes[unitIds[index]] = DiagramScene(
      nodes: [
        DiagramNode(
          id: 'n${index + 1}',
          shape: shape,
          lines: [unitIds[index]],
          x: 0.0,
          y: 0.0,
          width: 100.0,
          height: 40.0,
          sourceLine: index + 1,
          nodeId: ProgramNodeId(index + 1),
        ),
      ],
      edges: const [],
      width: 100.0,
      height: 40.0,
    );
  }
  return DiagramProgram(units: units, scenes: scenes);
}

DiagramUnit _unitOf(String unitId, int index) {
  final parts = unitId.split('_');
  final isMethod = parts.first == 'method' && parts.length >= 3;
  return DiagramUnit(
    id: unitId,
    displayName: unitId,
    kind: isMethod ? DiagramUnitKind.method : DiagramUnitKind.algorithm,
    className: isMethod ? parts[1] : null,
    name: isMethod ? parts[2] : unitId,
    sourceLine: index + 1,
    nodeId: ProgramNodeId(index + 1),
  );
}

final class FakeFlowchartBuilder implements FlowchartBuilder {
  List<String> unitIds;
  int buildCount = 0;

  FakeFlowchartBuilder({this.unitIds = const ['alg_A', 'sub_B']});

  @override
  DiagramProgram buildDiagram({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    buildCount += 1;
    return stubProgram(unitIds: unitIds, shape: DiagramShape.process);
  }
}

final class FakeStructogramBuilder implements StructogramBuilder {
  List<String> unitIds;
  int buildCount = 0;

  FakeStructogramBuilder({this.unitIds = const ['alg_A', 'sub_B']});

  @override
  DiagramProgram buildDiagram({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    buildCount += 1;
    return stubProgram(unitIds: unitIds, shape: DiagramShape.cellProcess);
  }
}

final class FakeClassDiagramBuilder implements ClassDiagramBuilder {
  List<String> classNames;
  int buildCount = 0;

  FakeClassDiagramBuilder({this.classNames = const []});

  @override
  DiagramScene buildDiagram({
    required String sourceCode,
    required SyntaxProfileId profileId,
  }) {
    buildCount += 1;
    return stubClassScene(classNames);
  }
}

DiagramScene stubClassScene(List<String> classNames) {
  if (classNames.isEmpty) return const DiagramScene.empty();
  final nodes = <DiagramNode>[];
  for (var index = 0; index < classNames.length; index++) {
    nodes.add(DiagramNode(
      id: 'box$index',
      shape: DiagramShape.classFrame,
      lines: const [],
      x: 0.0,
      y: index * 120.0,
      width: 160.0,
      height: 100.0,
      sourceLine: index + 1,
      nodeId: ProgramNodeId(100 + index),
    ));
    nodes.add(DiagramNode(
      id: 'box${index}_header',
      shape: DiagramShape.classHeader,
      lines: [classNames[index]],
      x: 0.0,
      y: index * 120.0,
      width: 160.0,
      height: 28.0,
      sourceLine: index + 1,
      nodeId: ProgramNodeId(100 + index),
    ));
  }
  return DiagramScene(
    nodes: nodes,
    edges: const [],
    width: 160.0,
    height: classNames.length * 120.0,
  );
}
