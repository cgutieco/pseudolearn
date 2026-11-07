import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/route_coverage_projection.dart';
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
    });

    test('a finished or empty route suggests nothing', () {
      expect(
        projectNextLesson(toc: const RouteToc.empty(), progress: const ContentProgress()),
        isNull,
      );
    });
  });
}
