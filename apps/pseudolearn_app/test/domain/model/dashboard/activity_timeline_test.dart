import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/dashboard/activity_timeline.dart';
import 'package:pseudolearn_app/domain/model/dashboard/activity_week.dart';

ActivityWeek _week(int day, {int visited = 0, int solved = 0, int created = 0}) => ActivityWeek(
  weekStart: DateTime(2026, 9, day),
  modulesVisited: visited,
  exercisesCompleted: solved,
  documentsCreated: created,
);

void main() {
  group('ActivityTimeline.of', () {
    test('keeps the peak of the stacked total, not of a single series', () {
      final timeline = ActivityTimeline.of([
        _week(1, visited: 2, solved: 1, created: 1),
        _week(8, created: 3),
      ]);

      expect(timeline.peakTotalEvents, 4);
      expect(timeline.peakLearningEvents, 3);
      expect(timeline.peakDocumentsCreated, 3);
      expect(timeline.activeWeeks, 2);
      expect(timeline.hasActivity, isTrue);
    });

    test('weeks without events are not active', () {
      final timeline = ActivityTimeline.of([_week(1), _week(8, solved: 1), _week(15)]);

      expect(timeline.activeWeeks, 1);
    });

    test('no weeks means no activity and zero peaks', () {
      final timeline = ActivityTimeline.of(const []);

      expect(timeline.peakTotalEvents, 0);
      expect(timeline.activeWeeks, 0);
      expect(timeline.hasActivity, isFalse);
    });
  });

  group('ActivityWeek', () {
    test('adds learning and creations into its total', () {
      final week = _week(1, visited: 1, solved: 2, created: 3);

      expect(week.learningEvents, 3);
      expect(week.totalEvents, 6);
      expect(week.isEmpty, isFalse);
    });

    test('a week with only creations is not empty', () {
      expect(_week(1, created: 1).isEmpty, isFalse);
    });
  });
}
