import 'package:sqflite/sqflite.dart';
import '../../domain/model/exercises/user_exercise.dart';
import '../index/index_schema.dart';
import 'user_exercise_codec.dart';
import 'user_exercise_schema.dart';

final class LocalUserExerciseRow {
  final String id;
  final UserExercise? exercise;
  final DateTime updatedAt;
  final bool dirty;

  const LocalUserExerciseRow({
    required this.id,
    required this.exercise,
    required this.updatedAt,
    required this.dirty,
  });
}

final class UserExerciseSyncState {
  static const String cursorKey = 'user_exercises_cursor';

  final DatabaseExecutor _database;

  const UserExerciseSyncState(this._database);

  Future<int> cursor() async {
    final rows = await _database.query(
      IndexSchema.syncStateTableName,
      where: '${IndexSchema.columnKey} = ?',
      whereArgs: [cursorKey],
    );
    if (rows.isEmpty) return 0;
    return int.tryParse(rows.first[IndexSchema.columnValue] as String) ?? 0;
  }

  Future<void> saveCursor(int value) => _database.insert(
    IndexSchema.syncStateTableName,
    {IndexSchema.columnKey: cursorKey, IndexSchema.columnValue: '$value'},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  Future<List<LocalUserExerciseRow>> dirtyRows() async {
    final rows = await _database.query(
      UserExerciseSchema.table,
      where: '${UserExerciseSchema.dirty} = 1',
    );
    return [for (final row in rows) _dirtyOf(row)];
  }

  Future<LocalUserExerciseRow?> localRow(String id) async {
    final rows = await _database.query(
      UserExerciseSchema.table,
      where: '${UserExerciseSchema.id} = ?',
      whereArgs: [id],
    );
    return rows.isEmpty ? null : _dirtyOf(rows.first);
  }

  Future<void> markClean(String id, {int? serverRevision}) => _database.update(
    UserExerciseSchema.table,
    {
      UserExerciseSchema.dirty: 0,
      UserExerciseSchema.serverRevision: ?serverRevision,
    },
    where: '${UserExerciseSchema.id} = ?',
    whereArgs: [id],
  );

  LocalUserExerciseRow _dirtyOf(Map<String, Object?> row) {
    final deleted = row[UserExerciseSchema.deletedAt] != null;
    final updated =
        DateTime.tryParse(row[UserExerciseSchema.updatedAt] as String) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    return LocalUserExerciseRow(
      id: row[UserExerciseSchema.id] as String,
      exercise: deleted
          ? null
          : userExerciseOfRow(
              id: row[UserExerciseSchema.id] as String,
              payload: row[UserExerciseSchema.payload] as String,
              revision: row[UserExerciseSchema.revision] as int,
              createdAt: row[UserExerciseSchema.createdAt] as String,
              updatedAt: row[UserExerciseSchema.updatedAt] as String,
            ),
      updatedAt: updated,
      dirty: row[UserExerciseSchema.dirty] == 1,
    );
  }
}
