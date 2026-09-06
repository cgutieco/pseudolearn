import 'package:sqflite/sqflite.dart';
import '../../domain/model/progress/merge_progress.dart';
import '../../domain/model/progress/progress_entry.dart';
import '../../domain/ports/progress_sync_store.dart';
import '../index/index_schema.dart';
import '../progress/progress_row.dart';

final class SqliteProgressSyncStore implements ProgressSyncStore {
  final Database _database;

  const SqliteProgressSyncStore(this._database);

  @override
  Future<List<ProgressEntry>> readDirtyProgress() async {
    final rows = await _database.query(
      IndexSchema.progressTableName,
      where: '${IndexSchema.columnDirty} = 1',
    );
    return rows.map(progressEntryOfRow).toList();
  }

  @override
  Future<void> markClean(List<String> contentIds) async {
    if (contentIds.isEmpty) return;
    final placeholders = List.filled(contentIds.length, '?').join(',');
    await _database.rawUpdate(
      '''
      UPDATE ${IndexSchema.progressTableName}
      SET ${IndexSchema.columnDirty} = 0
      WHERE ${IndexSchema.columnContentId} IN ($placeholders)
      ''',
      contentIds,
    );
  }

  @override
  Future<void> mergeRemoteProgress(List<ProgressEntry> entries) async {
    for (final remote in entries) {
      final rows = await _database.query(
        IndexSchema.progressTableName,
        where: '${IndexSchema.columnContentId} = ?',
        whereArgs: [remote.contentId],
        limit: 1,
      );

      final local = rows.isNotEmpty ? progressEntryOfRow(rows.first) : null;
      final isLocalDirty =
          rows.isNotEmpty && (rows.first[IndexSchema.columnDirty] as int? ?? 0) == 1;
      final merged = mergeProgress(local: local, remote: remote);

      await _database.insert(
        IndexSchema.progressTableName,
        {
          IndexSchema.columnContentId: merged.contentId,
          IndexSchema.columnVisited: merged.visited ? 1 : 0,
          IndexSchema.columnCompleted: merged.completed ? 1 : 0,
          IndexSchema.columnFirstVisitedAt:
              merged.firstVisitedAt?.toIso8601String(),
          IndexSchema.columnFirstCompletedAt:
              merged.firstCompletedAt?.toIso8601String(),
          IndexSchema.columnDirty: isLocalDirty ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
