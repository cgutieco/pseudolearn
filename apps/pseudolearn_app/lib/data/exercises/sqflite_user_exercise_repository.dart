import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../domain/model/exercises/user_exercise.dart';
import '../../domain/model/exercises/user_exercise_change.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/user_exercise_repository.dart';
import 'user_exercise_codec.dart';
import 'user_exercise_schema.dart';

final class SqfliteUserExerciseRepository implements UserExerciseRepository {
  final DatabaseExecutor _database;
  final Clock _clock;
  final StreamController<UserExerciseChange> _changes =
      StreamController<UserExerciseChange>.broadcast();

  SqfliteUserExerciseRepository(this._database, {required Clock clock})
    : _clock = clock;

  @override
  Stream<UserExerciseChange> get changes => _changes.stream;

  @override
  Future<List<UserExercise>> listExercises() async {
    final rows = await _database.query(
      UserExerciseSchema.table,
      where: '${UserExerciseSchema.deletedAt} IS NULL',
      orderBy: '${UserExerciseSchema.updatedAt} DESC',
    );
    return [
      for (final row in rows) ?_exerciseOf(row),
    ];
  }

  @override
  Future<UserExercise?> loadExercise(String id) async {
    final rows = await _database.query(
      UserExerciseSchema.table,
      where: '${UserExerciseSchema.id} = ? AND ${UserExerciseSchema.deletedAt} IS NULL',
      whereArgs: [id],
    );
    return rows.isEmpty ? null : _exerciseOf(rows.first);
  }

  @override
  Future<UserExercise> saveExercise(UserExercise exercise) async {
    await _database.insert(
      UserExerciseSchema.table,
      {
        UserExerciseSchema.id: exercise.id,
        UserExerciseSchema.payload: encodeUserExerciseDraft(exercise.draft),
        UserExerciseSchema.revision: exercise.revision,
        UserExerciseSchema.createdAt: exercise.createdAt.toIso8601String(),
        UserExerciseSchema.updatedAt: exercise.updatedAt.toIso8601String(),
        UserExerciseSchema.deletedAt: null,
        UserExerciseSchema.dirty: 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _changes.add(UserExerciseChange(exerciseId: exercise.id));
    return exercise;
  }

  @override
  Future<void> deleteExercise(String id) async {
    await _database.update(
      UserExerciseSchema.table,
      {
        UserExerciseSchema.deletedAt: _clock.now().toUtc().toIso8601String(),
        UserExerciseSchema.dirty: 1,
      },
      where: '${UserExerciseSchema.id} = ?',
      whereArgs: [id],
    );
    _changes.add(UserExerciseChange(exerciseId: id, deleted: true));
  }

  UserExercise? _exerciseOf(Map<String, Object?> row) => userExerciseOfRow(
    id: row[UserExerciseSchema.id] as String,
    payload: row[UserExerciseSchema.payload] as String,
    revision: row[UserExerciseSchema.revision] as int,
    createdAt: row[UserExerciseSchema.createdAt] as String,
    updatedAt: row[UserExerciseSchema.updatedAt] as String,
  );
}
