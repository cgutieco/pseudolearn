import 'package:sqflite/sqflite.dart';
import '../../domain/model/knowledge/content_progress.dart';
import '../../domain/ports/local_progress_store.dart';
import '../index/index_schema.dart';

final class SqliteLocalProgressStore implements LocalProgressStore {
  final Database _database;

  const SqliteLocalProgressStore(this._database);

  @override
  Future<bool> isModuleVisited(String moduleId) async {
    final rows = await _database.query(
      IndexSchema.progressTableName,
      where: '${IndexSchema.columnContentId} = ?',
      whereArgs: [moduleId],
      limit: 1,
    );
    if (rows.isEmpty) return false;
    final value = rows.first[IndexSchema.columnVisited] as int?;
    return value == 1;
  }

  @override
  Future<void> markModuleVisited(String moduleId) async {
    final rows = await _database.query(
      IndexSchema.progressTableName,
      where: '${IndexSchema.columnContentId} = ?',
      whereArgs: [moduleId],
      limit: 1,
    );
    final row = rows.isNotEmpty ? rows.first : null;
    final completed = row != null ? (row[IndexSchema.columnCompleted] as int? ?? 0) : 0;
    final existingFirstVisited = row != null ? row[IndexSchema.columnFirstVisitedAt] as String? : null;
    final existingFirstCompleted = row != null ? row[IndexSchema.columnFirstCompletedAt] as String? : null;
    final nowIso = DateTime.now().toIso8601String();

    await _database.insert(
      IndexSchema.progressTableName,
      {
        IndexSchema.columnContentId: moduleId,
        IndexSchema.columnVisited: 1,
        IndexSchema.columnCompleted: completed,
        IndexSchema.columnFirstVisitedAt: existingFirstVisited ?? nowIso,
        IndexSchema.columnFirstCompletedAt: existingFirstCompleted,
        IndexSchema.columnDirty: 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool> isExerciseCompleted(String exerciseId) async {
    final rows = await _database.query(
      IndexSchema.progressTableName,
      where: '${IndexSchema.columnContentId} = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );
    if (rows.isEmpty) return false;
    final value = rows.first[IndexSchema.columnCompleted] as int?;
    return value == 1;
  }

  @override
  Future<void> markExerciseCompleted(String exerciseId) async {
    final rows = await _database.query(
      IndexSchema.progressTableName,
      where: '${IndexSchema.columnContentId} = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );
    final row = rows.isNotEmpty ? rows.first : null;
    final visited = row != null ? (row[IndexSchema.columnVisited] as int? ?? 0) : 0;
    final existingFirstVisited = row != null ? row[IndexSchema.columnFirstVisitedAt] as String? : null;
    final existingFirstCompleted = row != null ? row[IndexSchema.columnFirstCompletedAt] as String? : null;
    final nowIso = DateTime.now().toIso8601String();

    await _database.insert(
      IndexSchema.progressTableName,
      {
        IndexSchema.columnContentId: exerciseId,
        IndexSchema.columnVisited: visited,
        IndexSchema.columnCompleted: 1,
        IndexSchema.columnFirstVisitedAt: existingFirstVisited,
        IndexSchema.columnFirstCompletedAt: existingFirstCompleted ?? nowIso,
        IndexSchema.columnDirty: 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<ContentProgress> readProgress() async {
    final rows = await _database.query(IndexSchema.progressTableName);
    final visited = <String>{};
    final completed = <String>{};

    for (final row in rows) {
      final id = row[IndexSchema.columnContentId] as String;
      if (row[IndexSchema.columnVisited] == 1) {
        visited.add(id);
      }
      if (row[IndexSchema.columnCompleted] == 1) {
        completed.add(id);
      }
    }

    return ContentProgress(
      visitedModuleIds: visited,
      completedExerciseIds: completed,
    );
  }
}
