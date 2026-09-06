import 'package:sqflite/sqflite.dart';
import '../../domain/model/sync/outbox_entry.dart';
import '../../domain/ports/sync_queue.dart';
import '../index/index_schema.dart';

final class SqliteSyncQueue implements SyncQueue {
  final Database _database;

  const SqliteSyncQueue(this._database);

  @override
  Future<void> enqueue(OutboxEntry entry) async {
    await _database.insert(
      IndexSchema.syncOutboxTableName,
      {
        IndexSchema.columnEntryId: entry.entryId,
        IndexSchema.columnEntityType: entry.entityType,
        IndexSchema.columnEntityId: entry.entityId,
        IndexSchema.columnOperation: entry.operation,
        IndexSchema.columnEnqueuedAt: entry.enqueuedAt.toIso8601String(),
        IndexSchema.columnAttempts: entry.attempts,
        IndexSchema.columnLastError: entry.lastError,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<OutboxEntry>> pendingEntries({int limit = 50}) async {
    final rows = await _database.query(
      IndexSchema.syncOutboxTableName,
      orderBy: '${IndexSchema.columnEnqueuedAt} ASC',
      limit: limit,
    );
    return rows.map(_mapRow).toList();
  }

  @override
  Future<void> markSent(String entryId) async {
    await _database.delete(
      IndexSchema.syncOutboxTableName,
      where: '${IndexSchema.columnEntryId} = ?',
      whereArgs: [entryId],
    );
  }

  @override
  Future<void> markFailed(String entryId, String error) async {
    await _database.rawUpdate(
      '''
      UPDATE ${IndexSchema.syncOutboxTableName}
      SET ${IndexSchema.columnAttempts} = ${IndexSchema.columnAttempts} + 1,
          ${IndexSchema.columnLastError} = ?
      WHERE ${IndexSchema.columnEntryId} = ?
      ''',
      [error, entryId],
    );
  }

  OutboxEntry _mapRow(Map<String, Object?> row) {
    return OutboxEntry(
      entryId: row[IndexSchema.columnEntryId] as String,
      entityType: row[IndexSchema.columnEntityType] as String,
      entityId: row[IndexSchema.columnEntityId] as String,
      operation: row[IndexSchema.columnOperation] as String,
      enqueuedAt: DateTime.parse(row[IndexSchema.columnEnqueuedAt] as String),
      attempts: (row[IndexSchema.columnAttempts] as int?) ?? 0,
      lastError: row[IndexSchema.columnLastError] as String?,
    );
  }
}
