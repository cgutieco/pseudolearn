import 'package:sqflite/sqflite.dart';

final class IndexSchema {
  static const int currentVersion = 3;

  static const String tableName = 'documents_index';
  static const String progressTableName = 'content_progress';
  static const String syncOutboxTableName = 'sync_outbox';
  static const String syncStateTableName = 'sync_state';

  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnProfileId = 'profile_id';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnCreatedAt = 'created_at';
  static const String columnRevision = 'revision';
  static const String columnSynced = 'synced';
  static const String columnExerciseId = 'exercise_id';

  static const String columnInstitutionId = 'institution_id';
  static const String columnClassId = 'class_id';
  static const String columnMembershipId = 'membership_id';
  static const String columnSubmissionId = 'submission_id';

  static const String columnDeletedAt = 'deleted_at';
  static const String columnServerRevision = 'server_revision';
  static const String columnLastSyncedRevision = 'last_synced_revision';

  static const String columnContentId = 'content_id';
  static const String columnVisited = 'visited';
  static const String columnCompleted = 'completed';
  static const String columnFirstVisitedAt = 'first_visited_at';
  static const String columnFirstCompletedAt = 'first_completed_at';
  static const String columnDirty = 'dirty';

  static const String columnEntryId = 'entry_id';
  static const String columnEntityType = 'entity_type';
  static const String columnEntityId = 'entity_id';
  static const String columnOperation = 'operation';
  static const String columnEnqueuedAt = 'enqueued_at';
  static const String columnAttempts = 'attempts';
  static const String columnLastError = 'last_error';

  static const String columnKey = 'key';
  static const String columnValue = 'value';

  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnTitle TEXT NOT NULL,
      $columnProfileId TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnCreatedAt TEXT NOT NULL,
      $columnRevision INTEGER NOT NULL,
      $columnSynced INTEGER NOT NULL,
      $columnExerciseId TEXT,
      $columnInstitutionId TEXT,
      $columnClassId TEXT,
      $columnMembershipId TEXT,
      $columnSubmissionId TEXT,
      $columnDeletedAt TEXT,
      $columnServerRevision INTEGER,
      $columnLastSyncedRevision INTEGER
    )
  ''';

  static const String createProgressTableSql = '''
    CREATE TABLE IF NOT EXISTS $progressTableName (
      $columnContentId TEXT PRIMARY KEY,
      $columnVisited INTEGER NOT NULL DEFAULT 0,
      $columnCompleted INTEGER NOT NULL DEFAULT 0,
      $columnFirstVisitedAt TEXT,
      $columnFirstCompletedAt TEXT,
      $columnDirty INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String createSyncOutboxTableSql = '''
    CREATE TABLE IF NOT EXISTS $syncOutboxTableName (
      $columnEntryId TEXT PRIMARY KEY,
      $columnEntityType TEXT NOT NULL,
      $columnEntityId TEXT NOT NULL,
      $columnOperation TEXT NOT NULL,
      $columnEnqueuedAt TEXT NOT NULL,
      $columnAttempts INTEGER NOT NULL DEFAULT 0,
      $columnLastError TEXT
    )
  ''';

  static const String createSyncStateTableSql = '''
    CREATE TABLE IF NOT EXISTS $syncStateTableName (
      $columnKey TEXT PRIMARY KEY,
      $columnValue TEXT NOT NULL
    )
  ''';

  static Future<void> createAllTables(DatabaseExecutor db) async {
    await db.execute(createTableSql);
    await db.execute(createProgressTableSql);
    await db.execute(createSyncOutboxTableSql);
    await db.execute(createSyncStateTableSql);
  }

  static Future<void> clear(DatabaseExecutor db) async {
    await db.delete(tableName);
  }

  static Future<void> migrate(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db
          .execute('ALTER TABLE $tableName ADD COLUMN $columnExerciseId TEXT;');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $progressTableName (
          $columnContentId TEXT PRIMARY KEY,
          $columnVisited INTEGER NOT NULL DEFAULT 0,
          $columnCompleted INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
    if (oldVersion < 3) {
      await db
          .execute('ALTER TABLE $tableName ADD COLUMN $columnDeletedAt TEXT;');
      await db.execute(
          'ALTER TABLE $tableName ADD COLUMN $columnServerRevision INTEGER;');
      await db.execute(
          'ALTER TABLE $tableName ADD COLUMN $columnLastSyncedRevision INTEGER;');

      await db.execute(
          'ALTER TABLE $progressTableName ADD COLUMN $columnFirstVisitedAt TEXT;');
      await db.execute(
          'ALTER TABLE $progressTableName ADD COLUMN $columnFirstCompletedAt TEXT;');
      await db.execute(
          'ALTER TABLE $progressTableName ADD COLUMN $columnDirty INTEGER NOT NULL DEFAULT 0;');

      await db.execute(createSyncOutboxTableSql);
      await db.execute(createSyncStateTableSql);
    }
  }
}
