import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/activity_projection.dart';
import 'dashboard_fixtures.dart';

void main() {
  group('projectActivityWeeks (PANT-06-F5)', () {
    final now = DateTime(2026, 9, 2, 10);

    test('places each event in the week that contains its first mark', () {
      final timeline = projectActivityWeeks(
        progress: [
          visitedEntry('CON-A1', at: DateTime(2026, 9, 1)),
          completedEntry('CON-A1-E1', at: DateTime(2026, 8, 25)),
        ],
        moduleIds: {'CON-A1'},
        documents: [summaryOf('doc', createdAt: DateTime(2026, 9, 2))],
        now: now,
      );
      final current = timeline.weeks.last;
      final previous = timeline.weeks[timeline.weeks.length - 2];

      expect(current.weekStart, DateTime(2026, 8, 31));
      expect(current.modulesVisited, 1);
      expect(current.documentsCreated, 1);
      expect(previous.exercisesCompleted, 1);
    });

    test('always emits the fixed window, empty weeks included', () {
      final timeline = projectActivityWeeks(
        progress: const [],
        moduleIds: const {},
        documents: const [],
        now: now,
      );

      expect(timeline.weeks.length, defaultActivityWeeks);
      expect(timeline.hasActivity, isFalse);
      for (final week in timeline.weeks) {
        expect(week.isEmpty, isTrue);
      }
    });

    test('events older than the window are dropped, not folded into week one', () {
      final timeline = projectActivityWeeks(
        progress: [visitedEntry('CON-A1', at: DateTime(2025, 1, 1))],
        moduleIds: {'CON-A1'},
        documents: const [],
        now: now,
      );

      expect(timeline.weeks.first.modulesVisited, 0);
      expect(timeline.peakLearningEvents, 0);
    });

    test('progress without timestamps contributes nothing', () {
      final timeline = projectActivityWeeks(
        progress: [visitedEntry('CON-A1'), completedEntry('CON-A1-E1')],
        moduleIds: {'CON-A1'},
        documents: const [],
        now: now,
      );

      expect(timeline.hasActivity, isFalse);
    });

    test('a visited content that is not a module counts only as completion', () {
      final timeline = projectActivityWeeks(
        progress: [visitedEntry('CON-A1-E1', at: DateTime(2026, 9, 1))],
        moduleIds: const {},
        documents: const [],
        now: now,
      );

      expect(timeline.weeks.last.modulesVisited, 0);
      expect(timeline.weeks.last.exercisesCompleted, 0);
    });

    test('the peaks are the largest weekly value of each series', () {
      final timeline = projectActivityWeeks(
        progress: [
          visitedEntry('CON-A1', at: DateTime(2026, 9, 1)),
          completedEntry('CON-A1-E1', at: DateTime(2026, 9, 1)),
        ],
        moduleIds: {'CON-A1'},
        documents: [
          summaryOf('one', createdAt: DateTime(2026, 9, 1)),
          summaryOf('two', createdAt: DateTime(2026, 9, 1)),
        ],
        now: now,
      );

      expect(timeline.peakLearningEvents, 2);
      expect(timeline.peakDocumentsCreated, 2);
    });
  });
}
