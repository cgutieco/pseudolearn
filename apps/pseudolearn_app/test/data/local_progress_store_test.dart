import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/progress/sqlite_local_progress_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('SqliteLocalProgressStore (CON-F8)', () {
    late Database db;
    late SqliteLocalProgressStore store;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await IndexSchema.createAllTables(db);
      store = SqliteLocalProgressStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('initial state returns false for unvisited and uncompleted items',
        () async {
      expect(await store.isModuleVisited('con-b1'), isFalse);
      expect(await store.isExerciseCompleted('con-b1-ej1'), isFalse);
      final progress = await store.readProgress();
      expect(progress.visitedModuleIds, isEmpty);
      expect(progress.completedExerciseIds, isEmpty);
    });

    test('markModuleVisited records visit and is queryable', () async {
      await store.markModuleVisited('con-b1');

      expect(await store.isModuleVisited('con-b1'), isTrue);
      expect(await store.isExerciseCompleted('con-b1'), isFalse);

      final progress = await store.readProgress();
      expect(progress.visitedModuleIds, contains('con-b1'));
      expect(progress.completedExerciseIds, isEmpty);
    });

    test('markExerciseCompleted records completion and is queryable', () async {
      await store.markExerciseCompleted('con-b1-ej1');

      expect(await store.isExerciseCompleted('con-b1-ej1'), isTrue);
      expect(await store.isModuleVisited('con-b1-ej1'), isFalse);

      final progress = await store.readProgress();
      expect(progress.completedExerciseIds, contains('con-b1-ej1'));
      expect(progress.visitedModuleIds, isEmpty);
    });

    test('preserving both visited and completed on same identifier', () async {
      await store.markModuleVisited('content-x');
      await store.markExerciseCompleted('content-x');

      expect(await store.isModuleVisited('content-x'), isTrue);
      expect(await store.isExerciseCompleted('content-x'), isTrue);

      final progress = await store.readProgress();
      expect(progress.isModuleVisited('content-x'), isTrue);
      expect(progress.isExerciseCompleted('content-x'), isTrue);
    });

    test('querying an unknown or deleted identifier returns false safely',
        () async {
      expect(await store.isModuleVisited('non-existent-module-id'), isFalse);
      expect(
          await store.isExerciseCompleted('non-existent-exercise-id'), isFalse);
    });

    test('handles edge cases: single character identifier and idempotency',
        () async {
      await store.markModuleVisited('a');
      await store.markModuleVisited('a');
      expect(await store.isModuleVisited('a'), isTrue);

      await store.markExerciseCompleted('b');
      await store.markExerciseCompleted('b');
      expect(await store.isExerciseCompleted('b'), isTrue);

      final progress = await store.readProgress();
      expect(progress.visitedModuleIds, {'a'});
      expect(progress.completedExerciseIds, {'b'});
    });

    test(
        'markModuleVisited writes first_visited_at once and never overwrites it',
        () async {
      await store.markModuleVisited('mod-ts');
      final rows1 = await db.query(
        IndexSchema.progressTableName,
        where: '${IndexSchema.columnContentId} = ?',
        whereArgs: ['mod-ts'],
      );
      final firstVisited =
          rows1.first[IndexSchema.columnFirstVisitedAt] as String?;
      expect(firstVisited, isNotNull);
      expect(rows1.first[IndexSchema.columnFirstCompletedAt], isNull);

      await store.markModuleVisited('mod-ts');
      final rows2 = await db.query(
        IndexSchema.progressTableName,
        where: '${IndexSchema.columnContentId} = ?',
        whereArgs: ['mod-ts'],
      );
      expect(rows2.first[IndexSchema.columnFirstVisitedAt], firstVisited);
    });

    test(
        'markExerciseCompleted writes first_completed_at once and never overwrites it',
        () async {
      await store.markExerciseCompleted('ex-ts');
      final rows1 = await db.query(
        IndexSchema.progressTableName,
        where: '${IndexSchema.columnContentId} = ?',
        whereArgs: ['ex-ts'],
      );
      final firstCompleted =
          rows1.first[IndexSchema.columnFirstCompletedAt] as String?;
      expect(firstCompleted, isNotNull);
      expect(rows1.first[IndexSchema.columnFirstVisitedAt], isNull);

      await store.markExerciseCompleted('ex-ts');
      final rows2 = await db.query(
        IndexSchema.progressTableName,
        where: '${IndexSchema.columnContentId} = ?',
        whereArgs: ['ex-ts'],
      );
      expect(rows2.first[IndexSchema.columnFirstCompletedAt], firstCompleted);
    });

    test(
        'combined module visit and exercise completion preserves both timestamps independently',
        () async {
      await store.markModuleVisited('content-combined');
      final rows1 = await db.query(
        IndexSchema.progressTableName,
        where: '${IndexSchema.columnContentId} = ?',
        whereArgs: ['content-combined'],
      );
      final visitedAt =
          rows1.first[IndexSchema.columnFirstVisitedAt] as String?;
      expect(visitedAt, isNotNull);
      expect(rows1.first[IndexSchema.columnFirstCompletedAt], isNull);

      await store.markExerciseCompleted('content-combined');
      final rows2 = await db.query(
        IndexSchema.progressTableName,
        where: '${IndexSchema.columnContentId} = ?',
        whereArgs: ['content-combined'],
      );
      expect(rows2.first[IndexSchema.columnFirstVisitedAt], visitedAt);
      expect(rows2.first[IndexSchema.columnFirstCompletedAt], isNotNull);
    });

    test('writes set dirty column to 1 in content_progress', () async {
      await store.markModuleVisited('mod-dirty');
      final rows1 = await db.query(
        IndexSchema.progressTableName,
        where: '${IndexSchema.columnContentId} = ?',
        whereArgs: ['mod-dirty'],
      );
      expect(rows1.first[IndexSchema.columnDirty], equals(1));

      await store.markExerciseCompleted('ex-dirty');
      final rows2 = await db.query(
        IndexSchema.progressTableName,
        where: '${IndexSchema.columnContentId} = ?',
        whereArgs: ['ex-dirty'],
      );
      expect(rows2.first[IndexSchema.columnDirty], equals(1));
    });
  });
}
