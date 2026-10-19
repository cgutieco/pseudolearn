import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/bridge/frb_generated.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';
import 'package:pseudolearn_app/data/knowledge/exercise_document_parser.dart';

final class _ReferenceExercise {
  final SyntaxProfileId profileId;
  final UiLanguageId languageId;
  final Exercise exercise;
  final String sourceCode;

  const _ReferenceExercise({
    required this.profileId,
    required this.languageId,
    required this.exercise,
    required this.sourceCode,
  });
}

void main() {
  final exercises = _referenceExercises();
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

  group('Rust executes knowledge reference solutions', () {
    for (final reference in exercises) {
      test('${reference.profileId.name} ${reference.exercise.id}', () {
        final exercise = reference.exercise;
        final analysis = services.analyzer.analyze(
          sourceCode: reference.sourceCode,
          profileId: reference.profileId,
          languageId: reference.languageId,
        );
        late final ExerciseCheckResult result;
        try {
          result = services.exerciseChecker.check(
            sourceCode: reference.sourceCode,
            profileId: reference.profileId,
            languageId: reference.languageId,
            visibleCases: exercise.visibleCases,
            hiddenCases: exercise.hiddenCases,
            assertions: exercise.assertions,
          );
        } on Object catch (error) {
          fail(
            '${exercise.id}: checker threw $error; analysis diagnostics: '
            '${analysis.diagnostics.map((diagnostic) => diagnostic.code)}',
          );
        }
        final failure = result.firstFailure;
        final diagnostics = result.isSolved
            ? const <String>[]
            : services.analyzer
                  .analyze(
                    sourceCode: reference.sourceCode,
                    profileId: reference.profileId,
                    languageId: reference.languageId,
                  )
                  .diagnostics
                  .map((diagnostic) => diagnostic.code)
                  .toList();

        expect(
          result.isSolved,
          isTrue,
          reason:
              '${exercise.id}: ${result.outcome.name}, '
              '${result.passedCases}/${result.totalCases} cases passed, '
              '${result.unmetAssertions.length} assertions unmet, '
              'failure: ${failure == null ? 'none' : '${failure.inputs} => '
                        '${failure.actualOutputs}, expected ${failure.expectedOutputs}'}, '
              'diagnostics: $diagnostics',
        );
      });
    }
  });
}

List<_ReferenceExercise> _referenceExercises() {
  final profiles = {
    'es': (SyntaxProfileId.classicSpanish, UiLanguageId.spanish),
    'en': (SyntaxProfileId.english, UiLanguageId.english),
  };
  final exercises = <_ReferenceExercise>[];
  for (final entry in profiles.entries) {
    final manifest = _jsonObject(
      File('assets/knowledge/manifest_${entry.key}.json').readAsStringSync(),
    );
    final entries = manifest['exercises'];
    if (entries is! List<Object?>) {
      throw StateError('Missing exercise list in ${entry.key} manifest');
    }
    for (final manifestEntry in entries) {
      if (manifestEntry is! Map<String, Object?>) {
        throw StateError('Invalid exercise entry in ${entry.key} manifest');
      }
      final path = manifestEntry['path'];
      if (path is! String) {
        throw StateError('Missing exercise path in ${entry.key} manifest');
      }
      final document = _jsonObject(
        File('assets/knowledge/$path').readAsStringSync(),
      );
      final parsed = const ExerciseDocumentParser().parse(jsonEncode(document));
      if (parsed is! ContentLoaded<Exercise>) {
        throw StateError('Exercise ${document['id']} did not parse');
      }
      final sourceCode = document['referenceSolution'];
      if (sourceCode is! String || sourceCode.isEmpty) {
        throw StateError(
          'Exercise ${parsed.value.id} has no reference solution',
        );
      }
      exercises.add(
        _ReferenceExercise(
          profileId: entry.value.$1,
          languageId: entry.value.$2,
          exercise: parsed.value,
          sourceCode: sourceCode,
        ),
      );
    }
  }
  return exercises;
}

Map<String, Object?> _jsonObject(String source) {
  final value = jsonDecode(source);
  if (value is Map<String, Object?>) return value;
  throw const FormatException('Expected a JSON object');
}
