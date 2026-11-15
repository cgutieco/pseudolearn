import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/progress/progress_entry.dart';

void main() {
  group('ProgressEntry', () {
    test('constructs correctly with fields', () {
      final t1 = DateTime(2026, 9, 1, 10, 0);
      final t2 = DateTime(2026, 9, 1, 11, 0);
      final entry = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: true,
        firstVisitedAt: t1,
        firstCompletedAt: t2,
      );

      expect(entry.contentId, equals('mod-1'));
      expect(entry.visited, isTrue);
      expect(entry.completed, isTrue);
      expect(entry.firstVisitedAt, equals(t1));
      expect(entry.firstCompletedAt, equals(t2));
    });

    test('copyWith updates specified fields', () {
      final entry = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: false,
        firstVisitedAt: DateTime(2026, 9, 1, 10, 0),
      );

      final updated = entry.copyWith(completed: true);
      expect(updated.contentId, equals('mod-1'));
      expect(updated.visited, isTrue);
      expect(updated.completed, isTrue);
      expect(updated.firstVisitedAt, equals(entry.firstVisitedAt));
    });

    test('serializes to and deserializes from JSON', () {
      final t1 = DateTime(2026, 9, 1, 10, 0);
      final t2 = DateTime(2026, 9, 1, 11, 0);
      final entry = ProgressEntry(
        contentId: 'ex-1',
        visited: true,
        completed: true,
        firstVisitedAt: t1,
        firstCompletedAt: t2,
      );

      final json = entry.toJson();
      final restored = ProgressEntry.fromJson(json);

      expect(restored, equals(entry));
      expect(restored.hashCode, equals(entry.hashCode));
    });

    test('fromJson handles null timestamps and missing booleans', () {
      final json = {'content_id': 'ex-2'};
      final restored = ProgressEntry.fromJson(json);

      expect(restored.contentId, equals('ex-2'));
      expect(restored.visited, isFalse);
      expect(restored.completed, isFalse);
      expect(restored.firstVisitedAt, isNull);
      expect(restored.firstCompletedAt, isNull);
    });

    test('equality compares structural field values', () {
      final entryA = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: false,
        firstVisitedAt: DateTime(2026, 9, 1, 10, 0),
      );
      final entryB = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: false,
        firstVisitedAt: DateTime(2026, 9, 1, 10, 0),
      );
      const entryC = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: true,
      );

      expect(entryA, equals(entryB));
      expect(entryA, isNot(equals(entryC)));
    });
  });
}
