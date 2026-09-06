import 'package:sqflite/sqflite.dart';
import '../../domain/model/progress/progress_entry.dart';
import '../../domain/ports/progress_history.dart';
import '../index/index_schema.dart';
import 'progress_row.dart';

final class SqliteProgressHistory implements ProgressHistory {
  final Database _database;

  const SqliteProgressHistory(this._database);

  @override
  Future<List<ProgressEntry>> readEntries() async {
    final rows = await _database.query(IndexSchema.progressTableName);
    return rows.map(progressEntryOfRow).toList();
  }
}
