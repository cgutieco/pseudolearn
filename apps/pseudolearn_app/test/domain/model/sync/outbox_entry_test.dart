import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/sync/outbox_entry.dart';

void main() {
  group('OutboxEntry', () {
    test('supports value equality and copyWith', () {
      final now = DateTime(2026, 9, 1, 10, 0);
      final entry1 = OutboxEntry(
        entryId: 'e1',
        entityType: 'document',
        entityId: 'd1',
        operation: 'upsert',
        enqueuedAt: now,
      );
      final entry2 = OutboxEntry(
        entryId: 'e1',
        entityType: 'document',
        entityId: 'd1',
        operation: 'upsert',
        enqueuedAt: now,
      );

      expect(entry1, equals(entry2));
      expect(entry1.hashCode, equals(entry2.hashCode));

      final failed = entry1.copyWith(attempts: 1, lastError: 'network error');
      expect(failed.attempts, equals(1));
      expect(failed.lastError, equals('network error'));
      expect(failed, isNot(equals(entry1)));
    });
  });
}
