import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/sync/sqlite_sync_queue.dart';
import 'package:pseudolearn_app/domain/model/sync/outbox_entry.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('SqliteSyncQueue', () {
    late Database db;
    late SqliteSyncQueue queue;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await IndexSchema.createAllTables(db);
      queue = SqliteSyncQueue(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('enqueues, retrieves pending entries, marks sent, and records failure', () async {
      final now = DateTime(2026, 9, 1, 10, 0);
      final entry = OutboxEntry(
        entryId: 'entry-1',
        entityType: 'document',
        entityId: 'doc-1',
        operation: 'upsert',
        enqueuedAt: now,
      );

      await queue.enqueue(entry);
      var pending = await queue.pendingEntries();
      expect(pending.length, equals(1));
      expect(pending.first.entityId, equals('doc-1'));
      expect(pending.first.attempts, equals(0));

      await queue.markFailed('entry-1', 'network timeout');
      pending = await queue.pendingEntries();
      expect(pending.first.attempts, equals(1));
      expect(pending.first.lastError, equals('network timeout'));

      await queue.markSent('entry-1');
      pending = await queue.pendingEntries();
      expect(pending, isEmpty);
    });
  });
}
