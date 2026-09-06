import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_cubit.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../../fakes/fake_diagram_builders.dart';

const SourceRange _range = SourceRange(
  startOffset: 0,
  endOffset: 1,
  startLine: 1,
  startColumn: 1,
  endLine: 1,
  endColumn: 2,
);

ExecutionFocus _focusOn(String? unitId) => ExecutionFocus(
      nodeId: const ProgramNodeId(500),
      range: _range,
      kind: ExecutionFocusKind.statement,
      unitId: unitId,
    );

void main() {
  group('DiagramCubit · class diagram notation', () {
    late FakeFlowchartBuilder flowchart;
    late FakeStructogramBuilder structogram;
    late FakeClassDiagramBuilder classDiagram;
    late DiagramCubit cubit;

    void update() => cubit.updateDiagram(
          sourceCode: 'Clase C FinClase',
          profileId: SyntaxProfileId.classicSpanish,
          languageId: UiLanguageId.spanish,
        );

    setUp(() {
      flowchart = FakeFlowchartBuilder();
      structogram = FakeStructogramBuilder();
      classDiagram = FakeClassDiagramBuilder(classNames: const ['C']);
      cubit = DiagramCubit(
        flowchartBuilder: flowchart,
        structogramBuilder: structogram,
        classDiagramBuilder: classDiagram,
      );
    });

    tearDown(() => cubit.close());

    test('the three notations are built from the same update', () {
      update();

      expect(flowchart.buildCount, 1);
      expect(structogram.buildCount, 1);
      expect(classDiagram.buildCount, 1);
      expect(cubit.state.hasClasses, isTrue);
    });

    test('each notation answers with its own scene', () {
      update();

      cubit.selectNotation(DiagramNotation.flowchart);
      final flowchartScene = cubit.state.scene;
      cubit.selectNotation(DiagramNotation.classDiagram);
      final classScene = cubit.state.scene;

      expect(flowchartScene.nodes.first.shape,
          isNot(classScene.nodes.first.shape));
    });

    test('the class diagram offers no unit to select', () {
      update();
      cubit.selectNotation(DiagramNotation.classDiagram);

      expect(cubit.state.units, isEmpty);
      expect(cubit.state.scene.isNotEmpty, isTrue);
    });

    test('a document without classes leaves the other two notations intact', () {
      classDiagram.classNames = const [];
      update();

      expect(cubit.state.hasClasses, isFalse);
      expect(cubit.state.flowchart.isNotEmpty, isTrue);
      expect(cubit.state.structogram.isNotEmpty, isTrue);
      expect(cubit.state.hasValidAst, isTrue);
    });

    test('executing a method moves the focus to its member row', () {
      flowchart.unitIds = const ['alg_A', 'method_C_Hacer'];
      update();

      cubit.syncWithFocus(_focusOn('method_C_Hacer'));

      expect(cubit.state.focusedMemberNodeId, isNotNull);
      expect(cubit.state.selectedUnitId, 'method_C_Hacer');
    });

    test('executing the main algorithm highlights no class', () {
      flowchart.unitIds = const ['alg_A', 'method_C_Hacer'];
      update();
      cubit.syncWithFocus(_focusOn('method_C_Hacer'));

      cubit.syncWithFocus(_focusOn('alg_A'));

      expect(cubit.state.focusedMemberNodeId, isNull);
    });

    test('a focus without unit keeps the previous selection', () {
      update();
      final before = cubit.state.selectedUnitId;

      cubit.syncWithFocus(_focusOn(null));

      expect(cubit.state.selectedUnitId, before);
      expect(cubit.state.focusedMemberNodeId, isNull);
    });

    test('switching to the class diagram and back keeps unit and focus', () {
      flowchart.unitIds = const ['alg_A', 'method_C_Hacer'];
      update();
      cubit.selectUnit('method_C_Hacer');
      cubit.syncWithFocus(_focusOn('method_C_Hacer'));
      final member = cubit.state.focusedMemberNodeId;

      cubit.selectNotation(DiagramNotation.classDiagram);
      cubit.selectNotation(DiagramNotation.flowchart);

      expect(cubit.state.selectedUnitId, 'method_C_Hacer');
      expect(cubit.state.focusedMemberNodeId, member);
    });
  });
}
