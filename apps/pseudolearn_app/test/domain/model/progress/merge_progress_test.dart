import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/progress/merge_progress.dart';
import 'package:pseudolearn_app/domain/model/progress/progress_entry.dart';

void main() {
  group('mergeProgress (D4 Monotonic Union)', () {
    final t1 = DateTime(2026, 9, 1, 10, 0);
    final t2 = DateTime(2026, 9, 1, 11, 0);
    final t3 = DateTime(2026, 9, 1, 12, 0);

    test('returns remote when local is null', () {
      final remote = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: false,
        firstVisitedAt: t1,
      );

      final merged = mergeProgress(local: null, remote: remote);
      expect(merged, equals(remote));
    });

    test('unions visited and completed flags independently', () {
      final local = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: false,
        firstVisitedAt: t1,
      );
      final remote = ProgressEntry(
        contentId: 'mod-1',
        visited: false,
        completed: true,
        firstCompletedAt: t2,
      );

      final merged = mergeProgress(local: local, remote: remote);
      expect(merged.contentId, equals('mod-1'));
      expect(merged.visited, isTrue);
      expect(merged.completed, isTrue);
      expect(merged.firstVisitedAt, equals(t1));
      expect(merged.firstCompletedAt, equals(t2));
    });

    test('selects earliest firstVisitedAt between local and remote', () {
      final local = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: false,
        firstVisitedAt: t2,
      );
      final remote = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: false,
        firstVisitedAt: t1,
      );

      final merged = mergeProgress(local: local, remote: remote);
      expect(merged.firstVisitedAt, equals(t1));
    });

    test('selects earliest firstCompletedAt between local and remote', () {
      final local = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: true,
        firstCompletedAt: t1,
      );
      final remote = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: true,
        firstCompletedAt: t3,
      );

      final merged = mergeProgress(local: local, remote: remote);
      expect(merged.firstCompletedAt, equals(t1));
    });

    test('handles null timestamps gracefully by choosing available timestamp',
        () {
      const local = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: false,
      );
      final remote = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: false,
        firstVisitedAt: t2,
      );

      final merged = mergeProgress(local: local, remote: remote);
      expect(merged.firstVisitedAt, equals(t2));
      expect(merged.firstCompletedAt, isNull);
    });

    test('is mathematically idempotent: merge(a, a) == a', () {
      final entry = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: true,
        firstVisitedAt: t1,
        firstCompletedAt: t2,
      );

      final mergedOnce = mergeProgress(local: entry, remote: entry);
      final mergedTwice = mergeProgress(local: mergedOnce, remote: entry);

      expect(mergedOnce, equals(entry));
      expect(mergedTwice, equals(entry));
    });

    test('is mathematically associative', () {
      final a = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: false,
        firstVisitedAt: t2,
      );
      final b = ProgressEntry(
        contentId: 'mod-1',
        visited: false,
        completed: true,
        firstCompletedAt: t3,
      );
      final c = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: false,
        firstVisitedAt: t1,
      );

      final mergedAbThenC = mergeProgress(
        local: mergeProgress(local: a, remote: b),
        remote: c,
      );
      final mergedAThenBc = mergeProgress(
        local: a,
        remote: mergeProgress(local: b, remote: c),
      );

      expect(mergedAbThenC, equals(mergedAThenBc));
      expect(mergedAbThenC.firstVisitedAt, equals(t1));
      expect(mergedAbThenC.firstCompletedAt, equals(t3));
      expect(mergedAbThenC.visited, isTrue);
      expect(mergedAbThenC.completed, isTrue);
    });
  });
}
