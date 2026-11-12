import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/route_coverage_projection.dart';
import 'package:pseudolearn_app/domain/model/dashboard/coverage_count.dart';
import 'package:pseudolearn_app/domain/model/dashboard/lesson_mark.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_progress.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/route/route_toc.dart';
import '../../fakes/route_fixtures.dart';

void main() {
  group('projectPartCoverage', () {
    test('a lesson counts once every required exercise is solved', () {
      final parts = projectPartCoverage(
        toc: sampleToc,
        progress: ContentProgress(
          completedExerciseIds: {
            routeExerciseProgressId('inicio.primero.a'),
            routeExerciseProgressId('inicio.primero.b'),
          },
        ),
      );

      expect(parts.first.lessons.done, 1);
      expect(parts.first.title, 'Empezar de cero');
      expect(parts.last.lessons.done, 0);
    });

    test('marks every lesson with its stage and flags the suggested one', () {
      final parts = projectPartCoverage(
        toc: sampleToc,
        progress: ContentProgress(
          visitedModuleIds: {routeLessonProgressId('imperativo.segundo')},
          completedExerciseIds: {
            routeExerciseProgressId('inicio.primero.a'),
            routeExerciseProgressId('inicio.primero.b'),
          },
        ),
      );
      final first = parts.first.marks.single;
      final second = parts.last.marks.single;

      expect(first.stage, LessonStage.completed);
      expect(first.isNext, isFalse);
      expect(second.stage, LessonStage.inProgress);
      expect(second.isNext, isTrue);
      expect(parts.last.touchedLessons, 1);
    });

    test('a lesson opened without solving its required exercises stays in progress', () {
      final parts = projectPartCoverage(
        toc: sampleToc,
        progress: ContentProgress(
          visitedModuleIds: {routeLessonProgressId('inicio.primero')},
          completedExerciseIds: {routeExerciseProgressId('inicio.primero.a')},
        ),
      );

      expect(parts.first.marks.single.stage, LessonStage.inProgress);
      expect(parts.first.marks.single.isNext, isTrue);
      expect(parts.first.lessons.done, 0);
    });

    test('an untouched lesson is pending and an empty route has no marks', () {
      final parts = projectPartCoverage(toc: sampleToc, progress: const ContentProgress());

      expect(parts.last.marks.single.stage, LessonStage.pending);
      expect(parts.last.touchedLessons, 0);
      expect(
        projectPartCoverage(toc: const RouteToc.empty(), progress: const ContentProgress()),
        isEmpty,
      );
    });

    test('an optional exercise alone does not complete the lesson', () {
      final parts = projectPartCoverage(
        toc: sampleToc,
        progress: ContentProgress(
          completedExerciseIds: {routeExerciseProgressId('inicio.primero.c')},
        ),
      );

      expect(parts.first.lessons.done, 0);
    });
  });

  group('projectNextLesson', () {
    test('suggests the first lesson whose needs are complete', () {
      final next = projectNextLesson(
        toc: sampleToc,
        progress: ContentProgress(
          completedExerciseIds: {
            routeExerciseProgressId('inicio.primero.a'),
            routeExerciseProgressId('inicio.primero.b'),
          },
        ),
      );

      expect(next?.id, 'imperativo.segundo');
      expect(next?.partTitle, 'Imperativo');
      expect(next?.requiredExercises, const CoverageCount(done: 0, total: 1));
    });

    test('counts only required exercises of the suggested lesson', () {
      final next = projectNextLesson(
        toc: sampleToc,
        progress: ContentProgress(
          completedExerciseIds: {
            routeExerciseProgressId('inicio.primero.a'),
            routeExerciseProgressId('inicio.primero.c'),
          },
        ),
      );

      expect(next?.id, 'inicio.primero');
      expect(next?.requiredExercises, const CoverageCount(done: 1, total: 2));
    });

    test('a lesson without required exercises reports an empty requirement', () {
      final toc = RouteToc([
        RoutePartEntry(
          id: 'parte',
          number: '0',
          title: 'Parte',
          motto: '',
          summary: '',
          lessons: [lessonEntry('apertura')],
        ),
      ]);

      final next = projectNextLesson(toc: toc, progress: const ContentProgress());

      expect(next?.requiredExercises.total, 0);
    });

    test('a finished or empty route suggests nothing', () {
      expect(
        projectNextLesson(toc: const RouteToc.empty(), progress: const ContentProgress()),
        isNull,
      );
    });
  });
}
