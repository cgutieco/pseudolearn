import 'package:sqflite/sqflite.dart';
import '../index/index_schema.dart';

final class SyncOwnerStore {
  static const String _ownerKey = 'owner_user_id';

  final Database _database;

  const SyncOwnerStore(this._database);

  Future<String?> read() async {
    final rows = await _database.query(
      IndexSchema.syncStateTableName,
      where: '${IndexSchema.columnKey} = ?',
      whereArgs: [_ownerKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first[IndexSchema.columnValue] as String?;
  }

  Future<void> write(String userId) async {
    await _database.insert(
      IndexSchema.syncStateTableName,
      {
        IndexSchema.columnKey: _ownerKey,
        IndexSchema.columnValue: userId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
