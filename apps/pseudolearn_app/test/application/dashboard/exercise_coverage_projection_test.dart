import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/exercise_coverage_projection.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'dashboard_fixtures.dart';

void main() {
  group('projectExerciseCoverage (PANT-06-F5)', () {
    final exercises = [
      exerciseEntry('CON-A2-E1', moduleId: 'CON-A2'),
      exerciseEntry(
        'CON-B3-E1',
        moduleId: 'CON-B3',
        level: ExerciseLevel.compose,
        kind: ExerciseKind.modify,
      ),
      exerciseEntry(
        'CON-B3-E2',
        moduleId: 'CON-B3',
        level: ExerciseLevel.compose,
        kind: ExerciseKind.create,
      ),
    ];
    const tracks = {
      'CON-A2': LearningTrack.foundations,
      'CON-B3': LearningTrack.imperative,
    };

    test('counts completions overall and by track, level and kind', () {
      final coverage = projectExerciseCoverage(
        exercises: exercises,
        trackByModuleId: tracks,
        completedIds: {'CON-B3-E1'},
      );

      expect(coverage.overall.done, 1);
      expect(coverage.overall.total, 3);
      expect(coverage.ofTrack(LearningTrack.imperative).done, 1);
      expect(coverage.ofTrack(LearningTrack.foundations).done, 0);
      expect(coverage.ofLevel(ExerciseLevel.compose).total, 2);
      expect(coverage.ofKind(ExerciseKind.modify).isComplete, isTrue);
    });

    test('an exercise whose module has no track still counts in the total', () {
      final coverage = projectExerciseCoverage(
        exercises: exercises,
        trackByModuleId: const {},
        completedIds: const {},
      );

      expect(coverage.overall.total, 3);
      expect(coverage.ofTrack(LearningTrack.imperative).total, 0);
    });

    test('an empty bank reports zero of zero for every grouping', () {
      final coverage = projectExerciseCoverage(
        exercises: const [],
        trackByModuleId: const {},
        completedIds: const {},
      );

      expect(coverage.overall.total, 0);
      expect(coverage.ofLevel(ExerciseLevel.design).total, 0);
      expect(coverage.ofKind(ExerciseKind.predict).total, 0);
    });

    test('a completion of an exercise outside the bank is ignored', () {
      final coverage = projectExerciseCoverage(
        exercises: exercises,
        trackByModuleId: tracks,
        completedIds: {'CON-Z9-E1'},
      );

      expect(coverage.overall.done, 0);
    });
  });
}
