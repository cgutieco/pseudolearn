import 'package:sqflite/sqflite.dart';

abstract final class UserExerciseSchema {
  static const String table = 'user_exercises';
  static const String id = 'id';
  static const String payload = 'payload';
  static const String revision = 'revision';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String deletedAt = 'deleted_at';
  static const String dirty = 'dirty';
  static const String serverRevision = 'server_revision';

  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $table (
      $id TEXT PRIMARY KEY,
      $payload TEXT NOT NULL,
      $revision INTEGER NOT NULL,
      $createdAt TEXT NOT NULL,
      $updatedAt TEXT NOT NULL,
      $deletedAt TEXT,
      $dirty INTEGER NOT NULL DEFAULT 0,
      $serverRevision INTEGER
    )
  ''';

  static Future<void> create(DatabaseExecutor database) =>
      database.execute(createTableSql);
}
