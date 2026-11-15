import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/route/bundled_route_repository.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/route/lesson_block.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_exercise.dart';
import 'package:pseudolearn_app/domain/model/route/route_lesson.dart';
import 'package:pseudolearn_app/domain/model/route/route_toc.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

const List<ReferenceEdition> _editions = [
  ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish),
  ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.english),
  ReferenceEdition(language: UiLanguageId.english, profile: SyntaxProfileId.classicSpanish),
  ReferenceEdition(language: UiLanguageId.english, profile: SyntaxProfileId.english),
];

BundledRouteRepository _fromDisk() => BundledRouteRepository(
  assetLoader: (path) => File(path).readAsString(),
);

BundledRouteRepository _fromMap(Map<String, String> files) => BundledRouteRepository(
  assetLoader: (path) async {
    final text = files[path];
    if (text == null) throw StateError('missing $path');
    return text;
  },
);

void main() {
  group('BundledRouteRepository on the versioned bundle', () {
    test('parses the index, every lesson and every exercise of the four editions', () async {
      final repository = _fromDisk();
      for (final edition in _editions) {
        final toc = await repository.loadToc(edition);
        expect(toc, isA<ContentLoaded<RouteToc>>(), reason: edition.directory);
        final value = (toc as ContentLoaded<RouteToc>).value;
        expect(value.lessons, isNotEmpty);
        for (final lesson in value.lessons) {
          final loaded = await repository.loadLesson(edition, lesson.id);
          expect(loaded, isA<ContentLoaded<RouteLesson>>(), reason: lesson.id);
          for (final exercise in lesson.exercises) {
            final parsed = await repository.loadExercise(edition, exercise.id);
            expect(parsed, isA<ContentLoaded<RouteExercise>>(), reason: exercise.id);
          }
        }
      }
    });

    test('the first lesson opens with its phrase and pairs the attempt', () async {
      final lesson = await _fromDisk().loadLesson(_editions.first, 'inicio.primer-problema');
      final blocks = (lesson as ContentLoaded<RouteLesson>).value.blocks;
      expect(blocks.first, isA<PhraseLessonBlock>());
      expect(blocks.whereType<AttemptLessonBlock>().single.answer, isNotEmpty);
      expect(blocks.whereType<PhaseHeadingLessonBlock>().length, 5);
    });

    test('publishes reverse links towards the specification', () async {
      final links = await _fromDisk().loadSpecLinks(_editions.first);
      final value = (links as ContentLoaded<Map<String, List<String>>>).value;
      expect(value['biblioteca.consola'], contains('inicio.primer-problema'));
    });

    test('a code exercise keeps its cases and its reference', () async {
      final exercise = await _fromDisk().loadExercise(
        _editions.first,
        'inicio.primer-problema.mesas',
      );
      final evaluation = (exercise as ContentLoaded<RouteExercise>).value.evaluation;
      expect(evaluation, isA<CasesEvaluation>());
      expect((evaluation as CasesEvaluation).visibleCases.single.expectedOutputs, ['6']);
      expect(evaluation.reference, contains('techo'));
    });
  });

  group('BundledRouteRepository failures', () {
    test('a missing file is reported as a missing asset', () async {
      final result = await _fromMap(const {}).loadToc(_editions.first);
      expect((result as ContentLoadFailed<RouteToc>).failure, ContentLoadFailure.assetMissing);
    });

    test('malformed JSON or an unknown block is a malformed route', () async {
      final repository = _fromMap({
        'assets/route/es/keywords-es/toc.json': '[{"id": 1}]',
        'assets/route/es/keywords-es/lessons/x.json':
            '{"id":"x","number":"1","part":"p","kind":"leccion","title":[],"minutes":1,"needs":[],"introduces":[],"blocks":[{"type":"pelicula"}]}',
        'assets/route/es/keywords-es/exercises/y.json': '{',
      });
      final toc = await repository.loadToc(_editions.first);
      final lesson = await repository.loadLesson(_editions.first, 'x');
      final exercise = await repository.loadExercise(_editions.first, 'y');
      expect((toc as ContentLoadFailed<RouteToc>).failure, ContentLoadFailure.malformedRoute);
      expect((lesson as ContentLoadFailed<RouteLesson>).failure, ContentLoadFailure.malformedRoute);
      expect((exercise as ContentLoadFailed<RouteExercise>).failure, ContentLoadFailure.malformedRoute);
    });

    test('an unknown exercise kind is rejected', () async {
      final repository = _fromMap({
        'assets/route/es/keywords-es/toc.json':
            '[{"id":"p","number":"0","title":"T","motto":"","summary":"","lessons":[{"id":"l","number":"0.1","kind":"leccion","title":[],"brief_problem":"","minutes":1,"levels":[],"needs":[],"exercises":[{"id":"e","kind":"adivinar","level":"semilla","required":true,"title":[]}]}]}]',
      });
      final toc = await repository.loadToc(_editions.first);
      expect(toc, isA<ContentLoadFailed<RouteToc>>());
    });
  });
}
