import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/domain/model/analysis/analysis_report.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/bridge/frb_generated.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_analysis_api.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_analyzer.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

const String fibonacci =
    'Algoritmo P\nDefinir a, b, c, i Como Entero;\na <- 0;\nb <- 1;\n'
    'Para i <- 1 Hasta 20 Con Paso 1 Hacer\nc <- a + b;\na <- b;\nb <- c;\n'
    'FinPara\nEscribir a;\nFinAlgoritmo\n';

void main() {
  late RustTransport transport;

  setUpAll(() async {
    await RustLib.init(
      externalLibrary: ExternalLibrary.open(_nativeLibraryPath()),
    );
  });

  setUp(() => transport = openNativeTransport());
  tearDown(() => transport.close());

  Future<ExecutionState> run(String program, StepPace pace) async {
    final cubit = ExecutionCubit(execution: RustProgramExecution(transport));
    await cubit.advance(
      pace: pace,
      sourceCode: program,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    var guard = 0;
    while (!cubit.state.currentStep.isTerminal && guard++ < 500) {
      await cubit.advance(
        pace: pace,
        sourceCode: program,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
    }
    return cubit.state;
  }

  for (final pace in StepPace.values) {
    test('Fib(20) completes with pace ${pace.name}', () async {
      final state = await run(fibonacci, pace);
      expect(state.status, ExecutionStatus.finishedSuccess);
      expect(state.outputLines.map((line) => line.text), ['6765']);
    });
  }

  test(
    'nextStatement stops on each executable statement in source order',
    () async {
      final execution = RustProgramExecution(transport);
      final first = execution.startExecution(
        sourceCode: 'Algoritmo P\nEscribir 1;\nEscribir 2;\nFinAlgoritmo\n',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      expect(first.isTerminal, isFalse);
      final lines = <int>[];
      var step = execution.step();
      while (!step.isTerminal) {
        final line = step.focus?.startLine;
        if (line != null && (lines.isEmpty || lines.last != line)) {
          lines.add(line);
        }
        step = execution.step();
      }
      expect(lines, [2, 3]);
      expect(step.isFinished, isTrue);
      expect(execution.outputLines.map((line) => line.text), ['1', '2']);
      execution.stop();
    },
  );

  test('arrays are inspectable through paged state', () async {
    final execution = RustProgramExecution(transport);
    execution.startExecution(
      sourceCode:
          'Algoritmo P\nDimension a[3] Como Entero;\na[0] <- 7;\nFinAlgoritmo\n',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    var step = execution.step();
    var described = false;
    while (!step.isTerminal) {
      final rows = step.variables.where((item) => item.name == 'a');
      described =
          described ||
          rows.any(
            (row) => row.formattedValue == '[3]' && row.identityBadge != null,
          );
      step = execution.step();
    }
    expect(described, isTrue);
    execution.stop();
  });

  test('objects expose class and identity', () async {
    final execution = RustProgramExecution(transport);
    execution.startExecution(
      sourceCode:
          'Clase C\nPublico Definir value Como Entero;\nFinClase\n'
          'Algoritmo P\nDefinir x Como C;\nx <- Nuevo C();\nx.value <- 4;\nFinAlgoritmo\n',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    var step = execution.step();
    var objectRow = false;
    while (!step.isTerminal) {
      objectRow =
          objectRow ||
          step.variables.any((item) => item.formattedValue.startsWith('C#'));
      step = execution.step();
    }
    expect(objectRow, isTrue);
    execution.stop();
  });

  test('multidimensional arrays expose their shape', () async {
    final execution = RustProgramExecution(transport);
    execution.startExecution(
      sourceCode: 'Algoritmo P\nDimension m[2,3] Como Entero;\nFinAlgoritmo\n',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    var step = execution.step();
    var shape = false;
    while (!step.isTerminal) {
      shape =
          shape || step.variables.any((row) => row.formattedValue == '[2x3]');
      step = execution.step();
    }
    expect(shape, isTrue);
    execution.stop();
  });

  test('cyclic and aliased objects keep coherent identities', () async {
    final execution = RustProgramExecution(transport);
    execution.startExecution(
      sourceCode:
          'Clase N\nPublico Definir otro Como N;\nFinClase\n'
          'Algoritmo P\nDefinir a, b, c Como N;\na <- Nuevo N();\nb <- Nuevo N();\n'
          'a.otro <- b;\nb.otro <- a;\nc <- a;\nFinAlgoritmo\n',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    var step = execution.step();
    while (!step.isTerminal) {
      step = execution.step();
    }
    expect(step.isFinished, isTrue);
    final rows = {for (final row in step.variables) row.name: row};
    expect(rows['a']?.identityBadge, isNotNull);
    expect(rows['b']?.identityBadge, isNot(rows['a']?.identityBadge));
    expect(rows['c']?.identityBadge, rows['a']?.identityBadge);
    execution.stop();
  });

  test('values are formatted by their type', () async {
    final execution = RustProgramExecution(transport);
    execution.startExecution(
      sourceCode:
          'Algoritmo P\nDefinir t Como Cadena;\nDefinir k Como Caracter;\n'
          't <- "hola";\nk <- \'z\';\nFinAlgoritmo\n',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    var step = execution.step();
    while (!step.isTerminal) {
      step = execution.step();
    }
    final rows = {
      for (final row in step.variables) row.name: row.formattedValue,
    };
    expect(rows['t'], '"hola"');
    expect(rows['k'], "'z'");
    execution.stop();
  });

  test('diagnostics keep arguments and follow the interface language', () {
    final analyzer = RustProgramAnalyzer(RustAnalysisApi(transport));
    const program = 'Algoritmo P\nEscribir inexistente;\nFinAlgoritmo\n';
    final spanish = analyzer.analyze(
      sourceCode: program,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    final english = analyzer.analyze(
      sourceCode: program,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.english,
    );
    expect(spanish.diagnostics.first.arguments, isNotEmpty);
    expect(
      spanish.diagnostics.first.message,
      isNot(english.diagnostics.first.message),
    );
  });

  test('a non terminating loop is cancelled by stop', () async {
    final execution = RustProgramExecution(transport);
    execution.startExecution(
      sourceCode:
          'Algoritmo P\nMientras Verdadero Hacer\nEscribir 1;\nFinMientras\nFinAlgoritmo\n',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    for (var index = 0; index < 100; index++) {
      expect(execution.step().isTerminal, isFalse);
    }
    execution.stop();
    expect(execution.step().isFinished, isTrue);
  });

  test('input is requested, echoed and consumed', () async {
    final execution = RustProgramExecution(transport);
    execution.startExecution(
      sourceCode:
          'Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x;\nFinAlgoritmo\n',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    var step = execution.step();
    while (!step.isAwaitingInput && !step.isTerminal) {
      step = execution.step();
    }
    expect(step.isAwaitingInput, isTrue);
    expect(step.inputPrompt, 'x');
    step = execution.provideInput('5');
    while (!step.isTerminal) {
      step = execution.step();
    }
    expect(step.isFinished, isTrue);
    expect(execution.outputLines.map((line) => line.text), ['5', '5']);
  });

  test('runtime failures halt with a reason', () async {
    final execution = RustProgramExecution(transport);
    execution.startExecution(
      sourceCode:
          'Algoritmo P\nDefinir x Como Entero;\nx <- 0;\nEscribir 1 div x;\nFinAlgoritmo\n',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    var step = execution.step();
    while (!step.isTerminal) {
      step = execution.step();
    }
    expect(step.isHalted, isTrue);
    expect(step.haltReason, isNotEmpty);
    execution.stop();
  });

  test('analyzer reports diagnostics with source ranges', () {
    final analyzer = RustProgramAnalyzer(RustAnalysisApi(transport));
    final report = analyzer.analyze(
      sourceCode:
          'Algoritmo P\nDefinir a Como Entero;\na <- "texto";\nFinAlgoritmo\n',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    expect(report.isExecutable, isFalse);
    expect(report.hasErrors, isTrue);
    expect(
      report.diagnostics
          .firstWhere((diagnostic) => diagnostic.severity == AppSeverity.error)
          .primaryRange
          .startLine,
      3,
    );
    final valid = analyzer.analyze(
      sourceCode: 'Algoritmo P\nEscribir "🧩";\nFinAlgoritmo\n',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    expect(valid, isA<AnalysisReport>());
    expect(valid.isExecutable, isTrue);
  });

  test('closed sessions reject further calls', () {
    transport.close();
    transport.close();
    expect(
      () => transport.call('version', <String, Object?>{}),
      throwsA(isA<RustBridgeFailure>()),
    );
  });
}

String _nativeLibraryPath() {
  if (Platform.isMacOS) {
    return 'native/target/debug/libpseudolearn_bridge.dylib';
  }
  if (Platform.isWindows) {
    return 'native/target/debug/pseudolearn_bridge.dll';
  }
  return 'native/target/debug/libpseudolearn_bridge.so';
}
