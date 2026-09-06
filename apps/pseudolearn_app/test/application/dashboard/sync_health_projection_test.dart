import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/sync_health_projection.dart';
import 'dashboard_fixtures.dart';

void main() {
  group('projectSyncHealth (PANT-06-F5)', () {
    final now = DateTime(2026, 9, 2, 12);

    test('reports the queue size and the age of its oldest entry', () {
      final health = projectSyncHealth(
        pending: [
          outboxEntry('a', enqueuedAt: DateTime(2026, 8, 30, 12)),
          outboxEntry('b', enqueuedAt: DateTime(2026, 9, 1, 12)),
        ],
        conflictCount: 2,
        now: now,
      );

      expect(health.pendingCount, 2);
      expect(health.oldestPendingAgeInDays, 3);
      expect(health.conflictCount, 2);
      expect(health.hasPendingWork, isTrue);
    });

    test('an empty queue has no age to report', () {
      final health = projectSyncHealth(
        pending: const [],
        conflictCount: 0,
        now: now,
      );

      expect(health.pendingCount, 0);
      expect(health.oldestPendingAgeInDays, isNull);
      expect(health.hasPendingWork, isFalse);
    });

    test('an entry enqueued today is zero days old, never negative', () {
      final health = projectSyncHealth(
        pending: [outboxEntry('a', enqueuedAt: DateTime(2026, 9, 2, 23))],
        conflictCount: 0,
        now: now,
      );

      expect(health.oldestPendingAgeInDays, 0);
    });
  });
}
