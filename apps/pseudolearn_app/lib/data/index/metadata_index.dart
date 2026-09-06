import 'package:sqflite/sqflite.dart';
import '../../domain/model/documents/document.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import 'index_schema.dart';

final class MetadataIndex {
  final Database _database;

  const MetadataIndex(this._database);

  Database get database => _database;

  Future<void> upsert(DocumentSummary summary) async {
    await _database.insert(
      IndexSchema.tableName,
      {
        IndexSchema.columnId: summary.id,
        IndexSchema.columnTitle: summary.title,
        IndexSchema.columnProfileId: summary.profileId.name,
        IndexSchema.columnUpdatedAt: summary.updatedAt.toIso8601String(),
        IndexSchema.columnCreatedAt: summary.createdAt.toIso8601String(),
        IndexSchema.columnRevision: summary.revision,
        IndexSchema.columnSynced: 0,
        IndexSchema.columnExerciseId: summary.exerciseId,
        IndexSchema.columnDeletedAt: null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> markDeleted(String id, {DateTime? deletedAt}) async {
    final timestamp = (deletedAt ?? DateTime.now()).toIso8601String();
    await _database.update(
      IndexSchema.tableName,
      {
        IndexSchema.columnDeletedAt: timestamp,
      },
      where: '${IndexSchema.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<DocumentSummary>> listAll() async {
    final rows = await _database.query(
      IndexSchema.tableName,
      where: '${IndexSchema.columnDeletedAt} IS NULL',
      orderBy: '${IndexSchema.columnUpdatedAt} DESC',
    );
    return rows.map(_mapRow).toList();
  }

  Future<List<DocumentSummary>> listTombstones() async {
    final rows = await _database.query(
      IndexSchema.tableName,
      where: '${IndexSchema.columnDeletedAt} IS NOT NULL',
      orderBy: '${IndexSchema.columnUpdatedAt} DESC',
    );
    return rows.map(_mapRow).toList();
  }

  Future<DocumentSummary?> get(String id) async {
    final rows = await _database.query(
      IndexSchema.tableName,
      where: '${IndexSchema.columnId} = ? AND ${IndexSchema.columnDeletedAt} IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _mapRow(rows.first);
  }

  DocumentSummary _mapRow(Map<String, Object?> row) {
    final profileName = row[IndexSchema.columnProfileId] as String;
    final profileId = SyntaxProfileId.values.firstWhere(
      (p) => p.name == profileName,
      orElse: () => SyntaxProfileId.classicSpanish,
    );
    return DocumentSummary(
      id: row[IndexSchema.columnId] as String,
      title: row[IndexSchema.columnTitle] as String,
      profileId: profileId,
      revision: row[IndexSchema.columnRevision] as int,
      createdAt: DateTime.parse(row[IndexSchema.columnCreatedAt] as String),
      updatedAt: DateTime.parse(row[IndexSchema.columnUpdatedAt] as String),
      exerciseId: row[IndexSchema.columnExerciseId] as String?,
    );
  }
}
