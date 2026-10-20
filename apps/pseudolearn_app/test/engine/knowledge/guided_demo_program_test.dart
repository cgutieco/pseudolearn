import '../../fakes/native_test_engine.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

String _sourceOf(String fileName) =>
    File('assets/knowledge/examples/$fileName').readAsStringSync();

List<String> _runToCompletion(
  String source,
  SyntaxProfileId profileId,
  UiLanguageId languageId,
) {
  final execution = nativeTestEngine.createProgramExecution();
  execution.startExecution(
    sourceCode: source,
    profileId: profileId,
    languageId: languageId,
  );
  var step = execution.step();
  var guard = 0;
  while (!step.isTerminal && guard < 500) {
    step = execution.step();
    guard++;
  }
  return execution.outputLines.map((line) => line.text).toList();
}

void main() {
  group('guided demo program', () {
    test('spanish program reaches comfort after two readings', () {
      final output = _runToCompletion(
        _sourceOf('guided_demo_es.pseudo'),
        SyntaxProfileId.classicSpanish,
        UiLanguageId.spanish,
      );

      expect(output, [
        'Lectura 1: 27 grados',
        'Lectura 2: 24 grados',
        'Confort alcanzado tras 2 lecturas',
      ]);
    });

    test('english program produces the mirrored output', () {
      final output = _runToCompletion(
        _sourceOf('guided_demo_en.pseudo'),
        SyntaxProfileId.english,
        UiLanguageId.english,
      );

      expect(output, [
        'Reading 1: 27 degrees',
        'Reading 2: 24 degrees',
        'Comfort reached after 2 readings',
      ]);
    });

    test(
      'spanish program feeds procedural notations with a non-empty scene',
      () {
        final source = _sourceOf('guided_demo_es.pseudo');
        final report = nativeTestEngine.analyzer.analyze(
          sourceCode: source,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: UiLanguageId.spanish,
        );
        final flowchart = nativeTestEngine.flowchartBuilder.buildDiagram(
          sourceCode: source,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: UiLanguageId.spanish,
        );
        final structogram = nativeTestEngine.structogramBuilder.buildDiagram(
          sourceCode: source,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: UiLanguageId.spanish,
        );
        final classes = nativeTestEngine.classDiagramBuilder.buildDiagram(
          sourceCode: source,
          profileId: SyntaxProfileId.classicSpanish,
        );

        expect(report.isExecutable, isTrue);
        expect(report.hasErrors, isFalse);
        expect(flowchart.isNotEmpty, isTrue);
        expect(structogram.isNotEmpty, isTrue);
        expect(classes.isEmpty, isTrue);
      },
    );

    test('stepping reports a focus before the program terminates', () {
      final execution = nativeTestEngine.createProgramExecution();
      execution.startExecution(
        sourceCode: _sourceOf('guided_demo_es.pseudo'),
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      final first = execution.step();

      expect(first.isTerminal, isFalse);
      expect(first.focus, isNotNull);
    });

    test('an empty program halts instead of throwing', () {
      final execution = nativeTestEngine.createProgramExecution();
      final started = execution.startExecution(
        sourceCode: '',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(started.isTerminal, isTrue);
    });
  });
}
