import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/program/use_cases/check_program.dart';
import 'package:pseudolearn_app/application/program/use_cases/format_program.dart';
import 'package:pseudolearn_app/application/program/use_cases/run_program.dart';
import 'package:pseudolearn_app/application/program/use_cases/translate_program.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/program/program_run_report.dart';
import 'package:pseudolearn_app/domain/model/program/program_run_request.dart';
import 'package:pseudolearn_app/domain/model/program/program_text_result.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/program_batch_runner.dart';
import 'package:pseudolearn_app/domain/ports/program_formatter.dart';
import 'package:pseudolearn_app/domain/ports/program_translator.dart';
import '../../../fakes/native_test_engine.dart';

const String _program =
    'Algoritmo Principal\n  Definir total Como Entero <- 0;\n  total <- 10;\n  Escribir total;\nFinAlgoritmo\n';
const String _reading =
    'Algoritmo Principal\n  Definir x Como Entero;\n  Leer x;\n  Escribir x * 2;\nFinAlgoritmo\n';
const String _endless =
    'Algoritmo Principal\n  Mientras Verdadero Hacer\n  FinMientras\nFinAlgoritmo\n';

ProgramRunRequest _request(String source, {List<String> inputs = const [], int steps = 10000}) =>
    ProgramRunRequest(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
      inputs: inputs,
      stepLimit: steps,
    );

final class _ThrowingTools implements ProgramBatchRunner, ProgramTranslator, ProgramFormatter {
  @override
  ProgramRunReport run(ProgramRunRequest request) => throw StateError('engine');

  @override
  ProgramTextResult translate({required String sourceCode, required SyntaxProfileId targetProfile}) =>
      throw StateError('engine');

  @override
  ProgramTextResult format({required String sourceCode, required SyntaxProfileId profileId}) =>
      throw StateError('engine');
}

void main() {
  final engine = nativeTestEngine;
  final run = RunProgram(analyzer: engine.analyzer, runner: engine.programTools.runner);

  group('CheckProgram', () {
    final check = CheckProgram(analyzer: engine.analyzer);

    test('accepts a valid program', () {
      final report = check(
        sourceCode: _program,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      expect(report.hasErrors, isFalse);
    });

    test('reports errors on a broken program and on an empty one', () {
      final broken = check(
        sourceCode: 'Algoritmo Principal\n  Si x >\nFinAlgoritmo\n',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      expect(broken.hasErrors, isTrue);
      final empty = check(
        sourceCode: '',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      expect(empty.isExecutable && !empty.hasErrors, isFalse);
    });
  });

  group('RunProgram', () {
    test('runs to the end and collects outputs', () {
      final report = run(_request(_program));
      expect(report.outcome, ProgramRunOutcome.finished);
      expect(report.outputs, ['10']);
    });

    test('feeds inputs in order', () {
      final report = run(_request(_reading, inputs: ['21']));
      expect(report.outputs, ['42']);
    });

    test('reports exhausted inputs', () {
      expect(run(_request(_reading)).outcome, ProgramRunOutcome.inputsExhausted);
    });

    test('stops at the step limit, clamped to at least one step', () {
      expect(
        run(_request(_endless, steps: 0)).outcome,
        ProgramRunOutcome.stepLimitReached,
      );
    });

    test('refuses a program with errors without running it', () {
      final report = run(_request('Algoritmo Principal\n  Si x >\nFinAlgoritmo\n'));
      expect(report.outcome, ProgramRunOutcome.notExecutable);
      expect(report.errors, isNotEmpty);
    });

    test('turns a runner exception into a halted report', () {
      final report = RunProgram(analyzer: engine.analyzer, runner: _ThrowingTools())(
        _request(_program),
      );
      expect(report.outcome, ProgramRunOutcome.halted);
    });
  });

  group('TranslateProgram and FormatProgram', () {
    test('translates to English and back keeps a valid program', () {
      final translated = TranslateProgram(translator: engine.programTools.translator)(
        sourceCode: _program,
        targetProfile: SyntaxProfileId.english,
      );
      expect(translated, isA<ProgramTextProduced>());
      expect((translated as ProgramTextProduced).text, isNot(_program));
    });

    test('a broken program is refused by translation', () {
      final translated = TranslateProgram(translator: engine.programTools.translator)(
        sourceCode: 'Algoritmo Principal\n  Si x >\nFinAlgoritmo\n',
        targetProfile: SyntaxProfileId.english,
      );
      expect(translated, isA<ProgramTextRefused>());
    });

    test('formats an unformatted program and reports an already canonical one', () {
      final format = FormatProgram(formatter: engine.programTools.formatter);
      final formatted = format(
        sourceCode: 'algoritmo Principal\ndefinir x como entero <- 0;\nfinalgoritmo',
        profileId: SyntaxProfileId.classicSpanish,
      );
      expect(
        (formatted as ProgramTextProduced).text,
        'Algoritmo Principal\n  Definir x Como Entero <- 0;\nFinAlgoritmo\n',
      );
      final canonical = format(sourceCode: _program, profileId: SyntaxProfileId.classicSpanish);
      expect((canonical as ProgramTextRefused).failure, ProgramTextFailure.unchanged);
    });

    test('engine exceptions become refusals', () {
      expect(
        TranslateProgram(translator: _ThrowingTools())(
          sourceCode: '',
          targetProfile: SyntaxProfileId.english,
        ),
        isA<ProgramTextRefused>(),
      );
      expect(
        FormatProgram(formatter: _ThrowingTools())(
          sourceCode: '',
          profileId: SyntaxProfileId.english,
        ),
        isA<ProgramTextRefused>(),
      );
    });
  });
}
