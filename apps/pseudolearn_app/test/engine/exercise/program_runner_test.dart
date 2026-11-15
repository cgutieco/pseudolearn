import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_outcome.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/exercise/program_runner.dart';
import '../../fakes/native_test_engine.dart';

ProgramRunner _runner({int stepLimit = ProgramRunner.defaultStepLimit}) => ProgramRunner(
  execution: nativeTestEngine.createProgramExecution(),
  analyzer: nativeTestEngine.analyzer,
  stepLimit: stepLimit,
);

const String _echo = 'Algoritmo Eco\n  Definir x Como Entero;\n  Leer x;\n  Escribir x * 2;\nFinAlgoritmo\n';

void main() {
  test('runs a program with its inputs and collects the output', () {
    final run = _runner().run(
      sourceCode: _echo,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
      inputs: const ['21'],
    );
    expect(run.anomaly, isNull);
    expect(run.outputs, ['42']);
  });

  test('stops when the inputs run out', () {
    final run = _runner().run(
      sourceCode: _echo,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
      inputs: const [],
    );
    expect(run.anomaly, ExerciseCheckOutcome.inputScriptExhausted);
  });

  test('stops an endless program at the step limit', () {
    final run = _runner(stepLimit: 50).run(
      sourceCode: 'Algoritmo Siempre\n  Mientras Verdadero Hacer\n    Escribir 1;\n  FinMientras\nFinAlgoritmo\n',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
      inputs: const [],
    );
    expect(run.anomaly, ExerciseCheckOutcome.stepLimitReached);
  });

  test('tells whether a program parses', () {
    final runner = _runner();
    expect(runner.parses(sourceCode: _echo, profileId: SyntaxProfileId.classicSpanish, languageId: UiLanguageId.spanish), isTrue);
    expect(runner.parses(sourceCode: 'Algoritmo', profileId: SyntaxProfileId.classicSpanish, languageId: UiLanguageId.spanish), isFalse);
  });
}
