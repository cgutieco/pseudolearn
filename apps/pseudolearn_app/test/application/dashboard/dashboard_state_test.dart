import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_state.dart';
import 'package:pseudolearn_app/domain/model/dashboard/coverage_count.dart';
import 'package:pseudolearn_app/domain/model/dashboard/lesson_mark.dart';
import 'package:pseudolearn_app/domain/model/dashboard/part_coverage.dart';

PartCoverage _part(String id, {required int done, required List<LessonStage> stages}) {
  return PartCoverage(
    partId: id,
    number: id,
    title: id,
    lessons: CoverageCount(done: done, total: stages.length),
    marks: [
      for (final (index, stage) in stages.indexed)
        LessonMark(lessonId: '$id.$index', number: '$index', stage: stage),
    ],
  );
}

void main() {
  group('DashboardState', () {
    test('adds the lessons of every part into one route count', () {
      final state = DashboardState(route: [
        _part('a', done: 1, stages: const [LessonStage.completed, LessonStage.pending]),
        _part('b', done: 0, stages: const [LessonStage.inProgress]),
      ]);

      expect(state.lessons, const CoverageCount(done: 1, total: 3));
    });

    test('an empty route counts zero lessons', () {
      expect(const DashboardState().lessons, const CoverageCount(done: 0, total: 0));
    });

    test('a lesson only opened is already something recorded', () {
      final state = DashboardState(route: [
        _part('a', done: 0, stages: const [LessonStage.inProgress]),
      ]);

      expect(state.hasNothingRecorded, isFalse);
    });

    test('pending lessons alone leave nothing recorded', () {
      final state = DashboardState(route: [
        _part('a', done: 0, stages: const [LessonStage.pending, LessonStage.pending]),
      ]);

      expect(state.hasNothingRecorded, isTrue);
    });
  });
}
