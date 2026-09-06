import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_projection.dart';
import 'package:pseudolearn_app/application/onboarding/demo/guided_demo_cubit.dart';
import 'package:pseudolearn_app/application/onboarding/demo/guided_demo_loader.dart';
import 'package:pseudolearn_app/application/onboarding/demo/guided_demo_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';
import 'package:pseudolearn_app/domain/model/execution/watch_row.dart';
import 'package:pseudolearn_app/domain/model/onboarding/guided_demo_surface.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../../../fakes/fake_diagram_builders.dart';
import '../../../fakes/fake_knowledge_repository.dart';
import '../../../fakes/fake_program_execution.dart';

const String _spanishPath = 'examples/guided_demo_es.pseudo';
const String _englishPath = 'examples/guided_demo_en.pseudo';
const String _demoCode = 'Proceso Demo\n  Escribir 1;\nFinProceso';

ExecutionStep _statementAt(int line, {Map<String, String> variables = const {}}) {
  final rows = <WatchRow>[];
  for (final entry in variables.entries) {
    rows.add(WatchRow(
      name: entry.key,
      formattedValue: entry.value,
      scopeName: 'global',
    ));
  }
  return ExecutionStep(
    stepNumber: line,
    scopeName: 'global',
    scopeDepth: 1,
    focus: ExecutionFocus(
      nodeId: ProgramNodeId(line),
      range: SourceRange(
        startOffset: line,
        endOffset: line + 1,
        startLine: line,
        startColumn: 1,
        endLine: line,
        endColumn: 2,
      ),
      kind: ExecutionFocusKind.statement,
    ),
    focusRevision: line,
    variables: rows,
  );
}

const ExecutionStep _finished = ExecutionStep(
  stepNumber: 99,
  scopeName: 'global',
  scopeDepth: 1,
  focusRevision: 99,
  isFinished: true,
);

GuidedDemoCubit _cubitWith({
  required FakeProgramExecution execution,
  Map<String, String> rawContent = const {_spanishPath: _demoCode},
  List<String> unitIds = const ['alg_A'],
  List<String> classNames = const ['Termometro'],
  bool repositoryThrows = false,
}) {
  return GuidedDemoCubit(
    loader: GuidedDemoLoader(
      repository: FakeKnowledgeRepository(
        rawContentByPath: rawContent,
        shouldThrow: repositoryThrows,
      ),
    ),
    execution: execution,
    diagrams: DiagramProjection(
      flowchartBuilder: FakeFlowchartBuilder(unitIds: unitIds),
      structogramBuilder: FakeStructogramBuilder(unitIds: unitIds),
      classDiagramBuilder: FakeClassDiagramBuilder(classNames: classNames),
    ),
  );
}

void main() {
  group('GuidedDemoCubit.start', () {
    test('loads the program and leaves it ready to step', () async {
      final cubit = _cubitWith(execution: FakeProgramExecution());

      await cubit.start(languageId: UiLanguageId.spanish);

      expect(cubit.state.status, GuidedDemoStatus.ready);
      expect(cubit.state.code, _demoCode);
      expect(cubit.state.diagram.hasValidAst, isTrue);
      expect(cubit.state.canStep, isTrue);
      expect(cubit.state.hasStarted, isFalse);
    });

    test('picks the english program for the english language', () async {
      final cubit = _cubitWith(
        execution: FakeProgramExecution(),
        rawContent: const {_englishPath: 'algorithm Demo endAlgorithm'},
      );

      await cubit.start(languageId: UiLanguageId.english);

      expect(cubit.state.code, 'algorithm Demo endAlgorithm');
    });

    test('reports unavailable when the asset is missing', () async {
      final cubit = _cubitWith(
        execution: FakeProgramExecution(),
        rawContent: const {},
      );

      await cubit.start(languageId: UiLanguageId.spanish);

      expect(cubit.state.status, GuidedDemoStatus.unavailable);
      expect(cubit.state.isUnavailable, isTrue);
      expect(cubit.state.canStep, isFalse);
    });

    test('reports unavailable when the repository throws', () async {
      final cubit = _cubitWith(
        execution: FakeProgramExecution(),
        repositoryThrows: true,
      );

      await cubit.start(languageId: UiLanguageId.spanish);

      expect(cubit.state.status, GuidedDemoStatus.unavailable);
    });

    test('reports unavailable when the program yields no diagram', () async {
      final cubit = _cubitWith(
        execution: FakeProgramExecution(),
        unitIds: const [],
        classNames: const [],
      );

      await cubit.start(languageId: UiLanguageId.spanish);

      expect(cubit.state.status, GuidedDemoStatus.unavailable);
    });
  });

  group('GuidedDemoCubit.step', () {
    test('advances one statement and records its trace row', () async {
      final execution = FakeProgramExecution(
        steps: [
          _statementAt(1),
          _statementAt(2, variables: const {'x': '1'}),
          _statementAt(3, variables: const {'x': '2'}),
        ],
      );
      final cubit = _cubitWith(execution: execution);
      await cubit.start(languageId: UiLanguageId.spanish);

      await cubit.step();

      expect(cubit.state.status, GuidedDemoStatus.stepping);
      expect(cubit.state.activeLine, 2);
      expect(cubit.state.statementCount, 1);
      expect(cubit.state.trace.rows.length, 1);
    });

    test('keeps advancing on each press until the program ends', () async {
      final execution = FakeProgramExecution(
        steps: [
          _statementAt(1),
          _statementAt(2, variables: const {'x': '1'}),
          _statementAt(3, variables: const {'x': '2'}),
        ],
      );
      final cubit = _cubitWith(execution: execution);
      await cubit.start(languageId: UiLanguageId.spanish);

      await cubit.step();
      await cubit.step();

      expect(cubit.state.activeLine, 3);
      expect(cubit.state.statementCount, 2);
      expect(cubit.state.trace.rows.length, 2);
    });

    test('finishes when the execution reports a terminal step', () async {
      final execution = FakeProgramExecution(
        steps: [_statementAt(1), _finished],
      );
      final cubit = _cubitWith(execution: execution);
      await cubit.start(languageId: UiLanguageId.spanish);

      await cubit.step();

      expect(cubit.state.status, GuidedDemoStatus.finished);
      expect(cubit.state.isFinished, isTrue);
      expect(cubit.state.canStep, isFalse);
      expect(cubit.state.focus, isNull);
    });

    test('a press after the end changes nothing', () async {
      final execution = FakeProgramExecution(
        steps: [_statementAt(1), _finished],
      );
      final cubit = _cubitWith(execution: execution);
      await cubit.start(languageId: UiLanguageId.spanish);
      await cubit.step();
      final settled = cubit.state;

      await cubit.step();

      expect(cubit.state, settled);
    });

    test('a press before loading anything changes nothing', () async {
      final cubit = _cubitWith(execution: FakeProgramExecution());

      await cubit.step();

      expect(cubit.state.status, GuidedDemoStatus.initial);
    });

    test('joins the output fragments into readable lines', () async {
      final execution = FakeProgramExecution(
        outputLinesList: const [
          OutputLine(text: 'Lectura ', kind: OutputLineKind.programOutput),
          OutputLine(text: '1', kind: OutputLineKind.programOutput),
          OutputLine(text: '\n', kind: OutputLineKind.programOutput),
        ],
        steps: [_statementAt(1), _statementAt(2)],
      );
      final cubit = _cubitWith(execution: execution);
      await cubit.start(languageId: UiLanguageId.spanish);

      await cubit.step();

      expect(cubit.state.outputLines, ['Lectura 1']);
    });
  });

  group('GuidedDemoCubit.restart', () {
    test('clears the trace and the counter but keeps the program', () async {
      final execution = FakeProgramExecution(
        steps: [_statementAt(1), _statementAt(2, variables: const {'x': '1'})],
      );
      final cubit = _cubitWith(execution: execution);
      await cubit.start(languageId: UiLanguageId.spanish);
      await cubit.step();

      cubit.restart();

      expect(cubit.state.status, GuidedDemoStatus.ready);
      expect(cubit.state.code, _demoCode);
      expect(cubit.state.statementCount, 0);
      expect(cubit.state.trace.rows, isEmpty);
      expect(cubit.state.outputLines, isEmpty);
      expect(execution.isStopped, isTrue);
    });

    test('does nothing when no program was ever loaded', () {
      final cubit = _cubitWith(execution: FakeProgramExecution());

      cubit.restart();

      expect(cubit.state.status, GuidedDemoStatus.initial);
    });

    test('keeps the surface the person had chosen', () async {
      final cubit = _cubitWith(execution: FakeProgramExecution());
      await cubit.start(languageId: UiLanguageId.spanish);
      cubit.selectSurface(GuidedDemoSurface.output);

      cubit.restart();

      expect(cubit.state.surface, GuidedDemoSurface.output);
    });
  });

  group('GuidedDemoCubit selections', () {
    test('selects a surface and ignores a repeated selection', () async {
      final cubit = _cubitWith(execution: FakeProgramExecution());
      await cubit.start(languageId: UiLanguageId.spanish);

      cubit.selectSurface(GuidedDemoSurface.trace);
      final afterFirst = cubit.state;
      cubit.selectSurface(GuidedDemoSurface.trace);

      expect(afterFirst.surface, GuidedDemoSurface.trace);
      expect(identical(cubit.state, afterFirst), isTrue);
    });

    test('selects a notation without rebuilding the scenes', () async {
      final cubit = _cubitWith(execution: FakeProgramExecution());
      await cubit.start(languageId: UiLanguageId.spanish);
      final scenes = cubit.state.diagram.flowchart;

      cubit.selectNotation(DiagramNotation.classDiagram);

      expect(cubit.state.diagram.notation, DiagramNotation.classDiagram);
      expect(cubit.state.diagram.flowchart, scenes);
    });
  });
}
