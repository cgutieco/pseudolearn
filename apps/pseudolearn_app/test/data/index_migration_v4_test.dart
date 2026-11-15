import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/exercises/user_exercise_schema.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('migrating from version 3 adds user exercises and keeps progress', () async {
    final database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await database.execute(
      'CREATE TABLE content_progress (content_id TEXT PRIMARY KEY, visited INTEGER NOT NULL DEFAULT 0, '
      'completed INTEGER NOT NULL DEFAULT 0, first_visited_at TEXT, first_completed_at TEXT, '
      'dirty INTEGER NOT NULL DEFAULT 0)',
    );
    await database.insert(IndexSchema.progressTableName, {
      IndexSchema.columnContentId: 'ruta.ejercicio:x',
      IndexSchema.columnVisited: 1,
      IndexSchema.columnCompleted: 1,
    });
    await IndexSchema.migrate(database, 3, 4);
    final progress = await database.query(IndexSchema.progressTableName);
    expect(progress.single[IndexSchema.columnAssisted], 0);
    expect(await database.query(UserExerciseSchema.table), isEmpty);
    await database.close();
  });

  test('migrating an already current database is a no-op', () async {
    final database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await IndexSchema.createAllTables(database);
    await IndexSchema.migrate(database, 4, 4);
    expect(await database.query(UserExerciseSchema.table), isEmpty);
    await database.close();
  });
}
