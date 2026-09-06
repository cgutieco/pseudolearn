import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_cubit.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_unit.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/engine/classdiagram/core_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/diagram/flowchart_layout.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_layout.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';

import '../../fakes/fake_diagram_builders.dart';

const String _referenceOOP = '''
Clase Vehiculo
    Publico Definir marca Como Cadena
    Publico Definir velocidad Como Entero

    Metodo Constructor(m Como Cadena)
        Este.marca <- m
        Este.velocidad <- 0
    FinMetodo

    Metodo Acelerar(delta Como Entero)
        Este.velocidad <- Este.velocidad + delta
    FinMetodo

    Metodo Describir()
        Escribir Este.marca, " a ", Este.velocidad, " km/h"
    FinMetodo
FinClase

Clase Motocicleta Hereda De Vehiculo
    Publico Definir cilindrada Como Entero

    Metodo Constructor(m Como Cadena, cc Como Entero)
        Super.Constructor(m)
        Este.cilindrada <- cc
    FinMetodo

    Metodo Describir()
        Super.Describir()
        Escribir "(", Este.cilindrada, "cc)"
    FinMetodo
FinClase

Proceso PruebaVehiculos
    Definir moto Como Motocicleta
    moto <- Nuevo Motocicleta("Honda", 250)
    moto.Acelerar(75)
    moto.Describir()
FinProceso
''';

void main() {
  group('DiagramCubit', () {
    late DiagramCubit cubit;

    setUp(() {
      cubit = DiagramCubit(
        flowchartBuilder: FlowchartLayout(),
        structogramBuilder: StructogramLayout(),
        classDiagramBuilder: CoreClassDiagramBuilder(),
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('updateDiagram with simple algorithm produces 1 unit', () {
      const source = '''
Algoritmo DiagTest
  Definir a Como Entero
  a <- 1
FinAlgoritmo
''';
      cubit.updateDiagram(
        sourceCode: source,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(cubit.state.hasValidAst, isTrue);
      expect(cubit.state.units, hasLength(1));
      expect(cubit.state.units.first.kind, DiagramUnitKind.algorithm);
      expect(cubit.state.scene.nodes, isNotEmpty);

      cubit.clear();
      expect(cubit.state.hasValidAst, isFalse);
      expect(cubit.state.units, isEmpty);
      expect(cubit.state.scene.nodes, isEmpty);
    });

    test('updateDiagram with OOP program produces 6 executable units', () {
      cubit.updateDiagram(
        sourceCode: _referenceOOP,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(cubit.state.hasValidAst, isTrue);
      expect(cubit.state.units, hasLength(6));

      final kinds = cubit.state.units.map((u) => u.kind).toList();
      expect(kinds, [
        DiagramUnitKind.algorithm,
        DiagramUnitKind.constructor,
        DiagramUnitKind.method,
        DiagramUnitKind.method,
        DiagramUnitKind.constructor,
        DiagramUnitKind.method,
      ]);
      expect(cubit.state.selectedUnitId, 'alg_PruebaVehiculos');
    });

    test('selectUnit updates active unit and displays its scene', () {
      cubit.updateDiagram(
        sourceCode: _referenceOOP,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      cubit.selectUnit('method_Vehiculo_Acelerar');
      expect(cubit.state.selectedUnitId, 'method_Vehiculo_Acelerar');
      expect(cubit.state.scene.nodes, isNotEmpty);
    });

    test('syncWithFocus automatically switches active unit when focus changes',
        () {
      cubit.updateDiagram(
        sourceCode: _referenceOOP,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      const focusInAcelerar = ExecutionFocus(
        nodeId: ProgramNodeId(10),
        range: SourceRange(
          startOffset: 0,
          endOffset: 10,
          startLine: 12,
          startColumn: 1,
          endLine: 12,
          endColumn: 10,
        ),
        kind: ExecutionFocusKind.statement,
        unitId: 'method_Vehiculo_Acelerar',
      );

      cubit.syncWithFocus(focusInAcelerar);
      expect(cubit.state.selectedUnitId, 'method_Vehiculo_Acelerar');

      const focusBackInAlgo = ExecutionFocus(
        nodeId: ProgramNodeId(1),
        range: SourceRange(
          startOffset: 0,
          endOffset: 10,
          startLine: 35,
          startColumn: 1,
          endLine: 35,
          endColumn: 10,
        ),
        kind: ExecutionFocusKind.statement,
        unitId: 'alg_PruebaVehiculos',
      );

      cubit.syncWithFocus(focusBackInAlgo);
      expect(cubit.state.selectedUnitId, 'alg_PruebaVehiculos');
    });

    test('invalid source produces empty diagram state with hasValidAst false',
        () {
      cubit.updateDiagram(
        sourceCode: 'Algoritmo !!! @@ ##',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(cubit.state.hasValidAst, isFalse);
      expect(cubit.state.units, isEmpty);
      expect(cubit.state.scene.nodes, isEmpty);
    });
  });

  group('DiagramCubit notation, against hand-written port doubles', () {
    late FakeFlowchartBuilder flowchart;
    late FakeStructogramBuilder structogram;
    late FakeClassDiagramBuilder classDiagram;
    late DiagramCubit cubit;

    void update() => cubit.updateDiagram(
          sourceCode: 'cualquiera',
          profileId: SyntaxProfileId.classicSpanish,
          languageId: UiLanguageId.spanish,
        );

    setUp(() {
      flowchart = FakeFlowchartBuilder();
      structogram = FakeStructogramBuilder();
      classDiagram = FakeClassDiagramBuilder();
      cubit = DiagramCubit(
        flowchartBuilder: flowchart,
        structogramBuilder: structogram,
        classDiagramBuilder: classDiagram,
      );
    });

    tearDown(() => cubit.close());

    test('starts on the flowchart', () {
      expect(cubit.state.notation, DiagramNotation.flowchart);
    });

    test('changing the source rebuilds both notations exactly once', () {
      update();
      expect(flowchart.buildCount, 1);
      expect(structogram.buildCount, 1);
      expect(cubit.state.flowchart.isNotEmpty, isTrue);
      expect(cubit.state.structogram.isNotEmpty, isTrue);
    });

    test('both notations see the same program node identifiers', () {
      update();
      cubit.selectUnit('sub_B');
      final flowchartFocus = cubit.state.scene.nodes.single.nodeId;
      cubit.selectNotation(DiagramNotation.structogram);
      expect(cubit.state.scene.nodes.single.nodeId, flowchartFocus);
    });

    test('changing notation changes what is drawn', () {
      update();
      expect(cubit.state.scene.nodes.single.shape, DiagramShape.process);
      cubit.selectNotation(DiagramNotation.structogram);
      expect(cubit.state.scene.nodes.single.shape, DiagramShape.cellProcess);
    });

    test('changing notation keeps the selected unit', () {
      update();
      cubit.selectUnit('sub_B');
      cubit.selectNotation(DiagramNotation.structogram);
      expect(cubit.state.selectedUnitId, 'sub_B');
      expect(cubit.state.units, hasLength(2));
    });

    test('changing notation keeps the unit the execution focus imposed', () {
      update();
      cubit.syncWithFocus(const ExecutionFocus(
        nodeId: ProgramNodeId(2),
        range: SourceRange(
          startOffset: 0,
          endOffset: 1,
          startLine: 2,
          startColumn: 1,
          endLine: 2,
          endColumn: 2,
        ),
        kind: ExecutionFocusKind.statement,
        unitId: 'sub_B',
      ));
      cubit.selectNotation(DiagramNotation.structogram);
      expect(cubit.state.selectedUnitId, 'sub_B');
    });

    test('selecting the notation already selected emits no new state', () {
      update();
      var emissions = 0;
      final subscription = cubit.stream.listen((_) => emissions += 1);
      cubit.selectNotation(DiagramNotation.flowchart);
      expect(emissions, 0);
      subscription.cancel();
    });

    test('a program with errors leaves both notations empty', () {
      flowchart.unitIds = const [];
      structogram.unitIds = const [];
      update();
      expect(cubit.state.hasValidAst, isFalse);
      expect(cubit.state.flowchart.isEmpty, isTrue);
      expect(cubit.state.structogram.isEmpty, isTrue);
      cubit.selectNotation(DiagramNotation.structogram);
      expect(cubit.state.scene.nodes, isEmpty);
    });

    test('clear returns to the default notation', () {
      update();
      cubit.selectNotation(DiagramNotation.structogram);
      cubit.clear();
      expect(cubit.state.notation, DiagramNotation.flowchart);
      expect(cubit.state.selectedUnitId, isNull);
    });
  });
}
