import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/sync/sqlite_progress_sync_store.dart';
import 'package:pseudolearn_app/domain/model/progress/progress_entry.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('SqliteProgressSyncStore', () {
    late Database db;
    late SqliteProgressSyncStore store;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await IndexSchema.createAllTables(db);
      store = SqliteProgressSyncStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('readDirtyProgress returns only rows where dirty == 1', () async {
      await db.insert(IndexSchema.progressTableName, {
        IndexSchema.columnContentId: 'clean-1',
        IndexSchema.columnVisited: 1,
        IndexSchema.columnCompleted: 0,
        IndexSchema.columnDirty: 0,
      });
      await db.insert(IndexSchema.progressTableName, {
        IndexSchema.columnContentId: 'dirty-1',
        IndexSchema.columnVisited: 1,
        IndexSchema.columnCompleted: 1,
        IndexSchema.columnDirty: 1,
      });

      final dirtyEntries = await store.readDirtyProgress();
      expect(dirtyEntries.length, equals(1));
      expect(dirtyEntries.first.contentId, equals('dirty-1'));
      expect(dirtyEntries.first.visited, isTrue);
      expect(dirtyEntries.first.completed, isTrue);
    });

    test('markClean updates dirty flag to 0 for specified content IDs',
        () async {
      await db.insert(IndexSchema.progressTableName, {
        IndexSchema.columnContentId: 'dirty-1',
        IndexSchema.columnVisited: 1,
        IndexSchema.columnCompleted: 1,
        IndexSchema.columnDirty: 1,
      });
      await db.insert(IndexSchema.progressTableName, {
        IndexSchema.columnContentId: 'dirty-2',
        IndexSchema.columnVisited: 1,
        IndexSchema.columnCompleted: 0,
        IndexSchema.columnDirty: 1,
      });

      await store.markClean(['dirty-1']);

      final rows1 = await db.query(
        IndexSchema.progressTableName,
        where: '${IndexSchema.columnContentId} = ?',
        whereArgs: ['dirty-1'],
      );
      expect(rows1.first[IndexSchema.columnDirty], equals(0));

      final rows2 = await db.query(
        IndexSchema.progressTableName,
        where: '${IndexSchema.columnContentId} = ?',
        whereArgs: ['dirty-2'],
      );
      expect(rows2.first[IndexSchema.columnDirty], equals(1));
    });

    test('mergeRemoteProgress adopts new entries with dirty = 0', () async {
      final t1 = DateTime(2026, 9, 1, 10, 0);
      final remote = ProgressEntry(
        contentId: 'remote-1',
        visited: true,
        completed: true,
        firstVisitedAt: t1,
        firstCompletedAt: t1,
      );

      await store.mergeRemoteProgress([remote]);

      final rows = await db.query(
        IndexSchema.progressTableName,
        where: '${IndexSchema.columnContentId} = ?',
        whereArgs: ['remote-1'],
      );
      expect(rows.length, equals(1));
      expect(rows.first[IndexSchema.columnVisited], equals(1));
      expect(rows.first[IndexSchema.columnCompleted], equals(1));
      expect(rows.first[IndexSchema.columnDirty], equals(0));
    });

    test('mergeRemoteProgress preserves dirty = 1 when local was dirty',
        () async {
      final t1 = DateTime(2026, 9, 1, 10, 0);
      final t2 = DateTime(2026, 9, 1, 12, 0);

      await db.insert(IndexSchema.progressTableName, {
        IndexSchema.columnContentId: 'shared-1',
        IndexSchema.columnVisited: 1,
        IndexSchema.columnCompleted: 0,
        IndexSchema.columnFirstVisitedAt: t1.toIso8601String(),
        IndexSchema.columnDirty: 1,
      });

      final remote = ProgressEntry(
        contentId: 'shared-1',
        visited: false,
        completed: true,
        firstCompletedAt: t2,
      );

      await store.mergeRemoteProgress([remote]);

      final rows = await db.query(
        IndexSchema.progressTableName,
        where: '${IndexSchema.columnContentId} = ?',
        whereArgs: ['shared-1'],
      );
      expect(rows.length, equals(1));
      expect(rows.first[IndexSchema.columnVisited], equals(1));
      expect(rows.first[IndexSchema.columnCompleted], equals(1));
      expect(rows.first[IndexSchema.columnDirty], equals(1));
    });
  });
}
