import 'package:sqflite/sqflite.dart';
import '../../domain/ports/assisted_progress_store.dart';
import '../index/index_schema.dart';

final class SqliteAssistedProgressStore implements AssistedProgressStore {
  final DatabaseExecutor _database;

  const SqliteAssistedProgressStore(this._database);

  @override
  Future<void> markAssisted(String progressId) async {
    await _database.rawInsert(
      'INSERT INTO ${IndexSchema.progressTableName} '
      '(${IndexSchema.columnContentId}, ${IndexSchema.columnAssisted}, ${IndexSchema.columnDirty}) '
      'VALUES (?, 1, 1) ON CONFLICT(${IndexSchema.columnContentId}) DO UPDATE SET '
      '${IndexSchema.columnAssisted} = 1, ${IndexSchema.columnDirty} = 1',
      [progressId],
    );
  }

  @override
  Future<Set<String>> assistedIds() async {
    final rows = await _database.query(
      IndexSchema.progressTableName,
      columns: [IndexSchema.columnContentId],
      where: '${IndexSchema.columnAssisted} = 1',
    );
    return {for (final row in rows) row[IndexSchema.columnContentId] as String};
  }
}
