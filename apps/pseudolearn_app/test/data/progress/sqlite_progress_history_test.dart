import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/progress/sqlite_local_progress_store.dart';
import 'package:pseudolearn_app/data/progress/sqlite_progress_history.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('SqliteProgressHistory (PANT-06-F5)', () {
    late Database db;
    late SqliteProgressHistory history;
    late SqliteLocalProgressStore store;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await IndexSchema.createAllTables(db);
      history = SqliteProgressHistory(db);
      store = SqliteLocalProgressStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('an untouched device has no history at all', () async {
      expect(await history.readEntries(), isEmpty);
    });

    test('carries the first-visit and first-completion marks of each row', () async {
      await store.markModuleVisited('CON-A1');
      await store.markExerciseCompleted('CON-A1-E1');

      final entries = await history.readEntries();
      final module = entries.firstWhere((e) => e.contentId == 'CON-A1');
      final exercise = entries.firstWhere((e) => e.contentId == 'CON-A1-E1');

      expect(entries.length, 2);
      expect(module.visited, isTrue);
      expect(module.firstVisitedAt, isNotNull);
      expect(module.firstCompletedAt, isNull);
      expect(exercise.completed, isTrue);
      expect(exercise.firstCompletedAt, isNotNull);
    });

    test('a row without timestamps is read with null marks, not with today', () async {
      await db.insert(IndexSchema.progressTableName, {
        IndexSchema.columnContentId: 'CON-B1',
        IndexSchema.columnVisited: 1,
        IndexSchema.columnCompleted: 0,
        IndexSchema.columnDirty: 0,
      });

      final entry = (await history.readEntries()).single;

      expect(entry.contentId, 'CON-B1');
      expect(entry.firstVisitedAt, isNull);
    });

    test('revisiting does not move the first-visit mark', () async {
      await store.markModuleVisited('CON-A1');
      final first = (await history.readEntries()).single.firstVisitedAt;

      await store.markModuleVisited('CON-A1');
      final second = (await history.readEntries()).single.firstVisitedAt;

      expect(second, first);
    });
  });
}
