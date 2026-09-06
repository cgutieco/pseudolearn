import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/application/diagram/focus_frame_projection.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/diagram/flowchart_layout.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_layout.dart';

const String _loopProgram = '''
Proceso Termostato
    Definir temperatura Como Entero;
    temperatura <- 30;
    Mientras temperatura > 24 Hacer
        temperatura <- temperatura - 3;
    FinMientras
    Escribir "Confort alcanzado";
FinProceso
''';

const SourceRange _range = SourceRange(
  startOffset: 0,
  endOffset: 1,
  startLine: 1,
  startColumn: 1,
  endLine: 1,
  endColumn: 2,
);

ExecutionFocus _focusOn(ProgramNodeId nodeId) => ExecutionFocus(
      nodeId: nodeId,
      range: _range,
      kind: ExecutionFocusKind.statement,
    );

DiagramState _stateOf(
  String source, {
  DiagramNotation notation = DiagramNotation.flowchart,
  DiagramScene classDiagram = const DiagramScene.empty(),
  ProgramNodeId? focusedMemberNodeId,
}) =>
    DiagramState(
      flowchart: FlowchartLayout().buildDiagram(
        sourceCode: source,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      ),
      structogram: StructogramLayout().buildDiagram(
        sourceCode: source,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      ),
      classDiagram: classDiagram,
      notation: notation,
      focusedMemberNodeId: focusedMemberNodeId,
      hasValidAst: true,
    );

DiagramNode _firstNodeWithId(DiagramScene scene) {
  for (final node in scene.nodes) {
    if (node.nodeId != null) return node;
  }
  throw StateError('the scene has no node carrying a program node id');
}

DiagramScene _classSceneWith(ProgramNodeId member) => DiagramScene(
      nodes: [
        DiagramNode(
          id: 'frame',
          shape: DiagramShape.classFrame,
          lines: const ['C'],
          x: 0,
          y: 0,
          width: 200,
          height: 120,
          nodeId: member,
        ),
        DiagramNode(
          id: 'row',
          shape: DiagramShape.classRow,
          lines: const ['Hacer()'],
          x: 8,
          y: 60,
          width: 184,
          height: 24,
          nodeId: member,
        ),
      ],
      edges: const [],
      width: 200,
      height: 120,
    );

void main() {
  group('FocusFrameProjection · flowchart and structogram', () {
    test('answers with the measurements of the focused node', () {
      final state = _stateOf(_loopProgram);
      final node = _firstNodeWithId(state.scene);

      final frame = FocusFrameProjection.frameOf(
        state: state,
        focus: _focusOn(node.nodeId!),
      );

      expect(frame, isNotNull);
      expect(frame!.x, node.x);
      expect(frame.y, node.y);
      expect(frame.width, node.width);
      expect(frame.height, node.height);
    });

    test('the structogram answers with its own cell for the same node', () {
      final flowchartState = _stateOf(_loopProgram);
      final structogramState =
          _stateOf(_loopProgram, notation: DiagramNotation.structogram);
      final nodeId = _firstNodeWithId(structogramState.scene).nodeId!;

      final cell = FocusFrameProjection.frameOf(
        state: structogramState,
        focus: _focusOn(nodeId),
      );
      final symbol = FocusFrameProjection.frameOf(
        state: flowchartState,
        focus: _focusOn(nodeId),
      );

      expect(cell, isNotNull);
      expect(symbol, isNotNull);
      expect(cell, isNot(equals(symbol)));
    });

    test('answers with nothing when there is no focus', () {
      final frame = FocusFrameProjection.frameOf(
        state: _stateOf(_loopProgram),
        focus: null,
      );

      expect(frame, isNull);
    });

    test('answers with nothing when the focused node is not drawn', () {
      final frame = FocusFrameProjection.frameOf(
        state: _stateOf(_loopProgram),
        focus: _focusOn(const ProgramNodeId(999999)),
      );

      expect(frame, isNull);
    });

    test('answers with nothing when the scene is empty', () {
      final frame = FocusFrameProjection.frameOf(
        state: const DiagramState.initial(),
        focus: _focusOn(const ProgramNodeId(1)),
      );

      expect(frame, isNull);
    });
  });

  group('FocusFrameProjection · class diagram', () {
    const member = ProgramNodeId(42);

    test('answers with the row of the focused member, not with its frame', () {
      final state = _stateOf(
        _loopProgram,
        notation: DiagramNotation.classDiagram,
        classDiagram: _classSceneWith(member),
        focusedMemberNodeId: member,
      );

      final frame = FocusFrameProjection.frameOf(
        state: state,
        focus: _focusOn(member),
      );

      expect(frame, isNotNull);
      expect(frame!.x, 8);
      expect(frame.y, 60);
      expect(frame.height, 24);
    });

    test('answers with nothing when no member is focused', () {
      final state = _stateOf(
        _loopProgram,
        notation: DiagramNotation.classDiagram,
        classDiagram: _classSceneWith(member),
      );

      final frame = FocusFrameProjection.frameOf(
        state: state,
        focus: _focusOn(member),
      );

      expect(frame, isNull);
    });
  });
}
