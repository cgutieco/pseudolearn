import 'package:sqflite/sqflite.dart';
import '../index/index_schema.dart';

final class SyncDocumentRevisions {
  final int? serverRevision;
  final int? lastSyncedRevision;

  const SyncDocumentRevisions({
    this.serverRevision,
    this.lastSyncedRevision,
  });
}

final class SyncGlobalState {
  final int cursor;
  final int progressCursor;
  final DateTime? lastSyncAt;

  const SyncGlobalState({
    this.cursor = 0,
    this.progressCursor = 0,
    this.lastSyncAt,
  });
}

final class SyncMetadataStore {
  final Database _database;

  const SyncMetadataStore(this._database);

  Future<SyncGlobalState> getGlobalState() async {
    final rows = await _database.query(IndexSchema.syncStateTableName);
    var cursor = 0;
    var progressCursor = 0;
    DateTime? lastSyncAt;

    for (final row in rows) {
      final key = row[IndexSchema.columnKey] as String?;
      final value = row[IndexSchema.columnValue] as String?;
      if (value == null) continue;

      switch (key) {
        case 'cursor':
          cursor = int.tryParse(value) ?? 0;
        case 'progress_cursor':
          progressCursor = int.tryParse(value) ?? 0;
        case 'last_sync_at':
          lastSyncAt = DateTime.tryParse(value);
      }
    }
    return SyncGlobalState(
      cursor: cursor,
      progressCursor: progressCursor,
      lastSyncAt: lastSyncAt,
    );
  }

  Future<void> setGlobalState({
    int? cursor,
    int? progressCursor,
    DateTime? lastSyncAt,
  }) async {
    if (cursor != null) {
      await _database.insert(
        IndexSchema.syncStateTableName,
        {
          IndexSchema.columnKey: 'cursor',
          IndexSchema.columnValue: cursor.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    if (progressCursor != null) {
      await _database.insert(
        IndexSchema.syncStateTableName,
        {
          IndexSchema.columnKey: 'progress_cursor',
          IndexSchema.columnValue: progressCursor.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    if (lastSyncAt != null) {
      await _database.insert(
        IndexSchema.syncStateTableName,
        {
          IndexSchema.columnKey: 'last_sync_at',
          IndexSchema.columnValue: lastSyncAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> updateDocumentRevisions(
    String documentId, {
    int? serverRevision,
    int? lastSyncedRevision,
  }) async {
    final values = <String, Object?>{};
    if (serverRevision != null) {
      values[IndexSchema.columnServerRevision] = serverRevision;
    }
    if (lastSyncedRevision != null) {
      values[IndexSchema.columnLastSyncedRevision] = lastSyncedRevision;
    }
    if (values.isEmpty) return;

    await _database.update(
      IndexSchema.tableName,
      values,
      where: '${IndexSchema.columnId} = ?',
      whereArgs: [documentId],
    );
  }

  Future<SyncDocumentRevisions?> getDocumentRevisions(String documentId) async {
    final rows = await _database.query(
      IndexSchema.tableName,
      columns: [
        IndexSchema.columnServerRevision,
        IndexSchema.columnLastSyncedRevision,
      ],
      where: '${IndexSchema.columnId} = ?',
      whereArgs: [documentId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return SyncDocumentRevisions(
      serverRevision: row[IndexSchema.columnServerRevision] as int?,
      lastSyncedRevision: row[IndexSchema.columnLastSyncedRevision] as int?,
    );
  }
}
