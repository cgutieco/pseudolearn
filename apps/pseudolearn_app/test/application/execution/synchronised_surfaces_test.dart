import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/application/export/export_cubit.dart';
import 'package:pseudolearn_app/application/trace/trace_cubit.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/analysis/analysis_cache.dart';
import 'package:pseudolearn_app/engine/classdiagram/core_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/diagram/flowchart_layout.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_layout.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';
import 'package:pseudolearn_app/engine/export/core_program_exporter.dart';

const _factorial = '''
Proceso Factorial
	Definir n Como Entero;
	Definir f Como Entero;
	Definir i Como Entero;
	n <- 5;
	f <- 1;
	Para i <- 1 Hasta n Con Paso 1 Hacer
		f <- f * i;
	FinPara
	Escribir "Factorial: ", f;
FinProceso
''';

void main() {
  group('the four surfaces share one focus', () {
    late AnalysisCache analyses;
    late ExecutionCubit execution;
    late DiagramCubit diagram;
    late ExportCubit export;
    late TraceCubit trace;

    setUp(() {
      analyses = AnalysisCache();
      execution = ExecutionCubit(execution: CoreProgramExecution(analyses: analyses));
      diagram = DiagramCubit(
        flowchartBuilder: FlowchartLayout(analyses: analyses),
        structogramBuilder: StructogramLayout(analyses: analyses),
        classDiagramBuilder: CoreClassDiagramBuilder(analyses: analyses),
      );
      export = ExportCubit(
        exporter: CoreProgramExporter(analyses: analyses),
        executionStates: execution.stream,
      );
      trace = TraceCubit(executionStates: execution.stream);

      diagram.updateDiagram(
        sourceCode: _factorial,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      export.updateSource(sourceCode: _factorial, profileId: SyntaxProfileId.classicSpanish);
    });

    tearDown(() async {
      await trace.close();
      await export.close();
      await diagram.close();
      await execution.close();
    });

    Future<ExecutionFocus?> step() async {
      await execution.advance(
        pace: StepPace.nextStatement,
        sourceCode: _factorial,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      await Future<void>.delayed(Duration.zero);
      return execution.state.currentStep.focus;
    }

    bool sceneHolds(ProgramNodeId nodeId) {
      for (final node in diagram.state.scene.nodes) {
        if (node.nodeId == nodeId) return true;
      }
      return false;
    }

    test('every focused statement has a symbol in the flowchart', () async {
      for (var i = 0; i < 12; i++) {
        final focus = await step();
        if (execution.state.currentStep.isTerminal) break;
        if (focus == null) continue;
        expect(sceneHolds(focus.nodeId), isTrue,
            reason: 'line ${focus.startLine} has no symbol carrying its node identity');
      }
    });

    test('the focused statement lights lines in the equivalent code', () async {
      var lit = 0;
      for (var i = 0; i < 12; i++) {
        await step();
        if (execution.state.currentStep.isTerminal) break;
        if (export.state.focusedLines.isNotEmpty) lit++;
      }
      expect(lit, greaterThan(0), reason: 'no focused statement mapped to a generated line');
    });

    test('the trace records the lines the editor walked, in order', () async {
      final walked = <int>[];
      for (var i = 0; i < 12; i++) {
        final focus = await step();
        if (execution.state.currentStep.isTerminal) break;
        if (focus != null) walked.add(focus.startLine);
      }

      expect(walked, isNotEmpty);
      expect(trace.state.rows, isNotEmpty);
      for (final row in trace.state.rows) {
        expect(walked, contains(row.lineNumber));
      }
    });

    test('running the loop returns the focus to the body line more than once', () async {
      await execution.advance(
        pace: StepPace.toEnd,
        sourceCode: _factorial,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(execution.state.status, ExecutionStatus.finishedSuccess);
      expect(execution.state.outputLines.map((line) => line.text), contains('Factorial: 120'));
      expect(trace.state.rows.length, greaterThan(5));
    });

    test('a second run starts the table from scratch', () async {
      await execution.advance(
        pace: StepPace.toEnd,
        sourceCode: _factorial,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      final first = trace.state.rows.length;

      await execution.advance(
        pace: StepPace.toEnd,
        sourceCode: _factorial,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(trace.state.rows.length, first);
    });
  });
}
