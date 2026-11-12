import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/exercise_coverage_projection.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_progress.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/route/route_toc.dart';
import '../../fakes/route_fixtures.dart';

void main() {
  group('projectExerciseCoverage', () {
    test('counts done exercises by part, level and kind', () {
      final coverage = projectExerciseCoverage(
        toc: sampleToc,
        progress: ContentProgress(
          completedExerciseIds: {routeExerciseProgressId('imperativo.segundo.a')},
        ),
      );

      expect(coverage.overall.total, 4);
      expect(coverage.overall.done, 1);
      expect(coverage.ofPart('parte-imperativo').done, 1);
      expect(coverage.ofPart('parte-inicio').total, 3);
      expect(coverage.ofLevel(RouteLevel.tree).done, 1);
      expect(coverage.ofKind(RouteExerciseKind.solve).total, 2);
    });

    test('an absent bucket reads as an empty count', () {
      final coverage = projectExerciseCoverage(
        toc: const RouteToc.empty(),
        progress: const ContentProgress(),
      );

      expect(coverage.overall.total, 0);
      expect(coverage.ofPart('nada').total, 0);
      expect(coverage.ofKind(RouteExerciseKind.trace).done, 0);
    });
  });
}
