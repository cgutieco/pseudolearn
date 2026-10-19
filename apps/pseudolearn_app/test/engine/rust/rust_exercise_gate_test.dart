import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/data/knowledge/exercise_document_parser.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_outcome.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/bridge/frb_generated.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

enum ExerciseClass { behavioural, mixed, notExecutable }

final class GateExercise {
  final String path;
  final Exercise exercise;
  final String solution;
  final SyntaxProfileId profile;
  final UiLanguageId language;

  const GateExercise(
    this.path,
    this.exercise,
    this.solution,
    this.profile,
    this.language,
  );

  ExerciseClass get classification {
    final hasCases = exercise.visibleCases.isNotEmpty || exercise.hiddenCases.isNotEmpty;
    if (!hasCases || solution.isEmpty) return ExerciseClass.notExecutable;
    return exercise.assertions.isEmpty ? ExerciseClass.behavioural : ExerciseClass.mixed;
  }
}

List<GateExercise> _load() {
  final files = Directory('assets/knowledge/exercises')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final file in files)
      _gateOf(file),
  ];
}

GateExercise _gateOf(File file) {
  final document = file.readAsStringSync();
  final parsed = const ExerciseDocumentParser().parse(document);
  final isEnglish = file.path.endsWith('_en.json');
  return GateExercise(
    file.uri.pathSegments.last,
    (parsed as ContentLoaded<Exercise>).value,
    (jsonDecode(document) as Map<String, Object?>)['referenceSolution'] as String,
    isEnglish ? SyntaxProfileId.english : SyntaxProfileId.classicSpanish,
    isEnglish ? UiLanguageId.english : UiLanguageId.spanish,
  );
}

void main() {
  final exercises = _load();
  RustTransport? transport;
  late RustEngineServices services;

  setUpAll(() async {
    await initializeNativeBridge();
    transport = openNativeTransport();
    services = buildRustEngineServices(transport!);
  });

  tearDownAll(() {
    transport?.close();
    RustLib.dispose();
  });

  test('the corpus is fully classified with no executable exercise left out', () {
    final counts = <ExerciseClass, int>{};
    for (final entry in exercises) {
      counts.update(entry.classification, (value) => value + 1, ifAbsent: () => 1);
    }

    expect(exercises, hasLength(190));
    expect(counts[ExerciseClass.notExecutable] ?? 0, 0);
    expect(counts[ExerciseClass.behavioural], 58);
    expect(counts[ExerciseClass.mixed], 132);
    expect(exercises.where((e) => e.profile == SyntaxProfileId.english), hasLength(95));
  });

  for (final entry in exercises) {
    test('${entry.classification.name} ${entry.path} is solved through Rust', () {
      final result = services.exerciseChecker.check(
        sourceCode: entry.solution,
        profileId: entry.profile,
        languageId: entry.language,
        visibleCases: entry.exercise.visibleCases,
        hiddenCases: entry.exercise.hiddenCases,
        assertions: entry.exercise.assertions,
      );

      expect(result.outcome, ExerciseCheckOutcome.allCasesPassed);
      expect(result.passedCases, result.totalCases);
      expect(result.totalCases, greaterThan(0));
      expect(result.unmetAssertions, isEmpty);
    });
  }

  test('a wrong program fails the same exercises it should', () {
    final entry = exercises.firstWhere((e) => e.classification == ExerciseClass.mixed);

    final result = services.exerciseChecker.check(
      sourceCode: entry.profile == SyntaxProfileId.english
          ? 'algorithm P\nendAlgorithm\n'
          : 'Algoritmo P\nFinAlgoritmo\n',
      profileId: entry.profile,
      languageId: entry.language,
      visibleCases: entry.exercise.visibleCases,
      hiddenCases: entry.exercise.hiddenCases,
      assertions: entry.exercise.assertions,
    );

    expect(result.isSolved, isFalse);
  });
}
