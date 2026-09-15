import 'dart:io';
import 'package:sqflite/sqflite.dart';
import '../../domain/ports/local_account_data_purger.dart';
import '../index/index_schema.dart';

const String pseudoDocumentExtension = '.pseudo';

final class LocalAccountDataPurgerAdapter implements LocalAccountDataPurger {
  final Database _database;
  final Directory _documentsDirectory;

  const LocalAccountDataPurgerAdapter({
    required Database database,
    required Directory documentsDirectory,
  })  : _database = database,
        _documentsDirectory = documentsDirectory;

  @override
  Future<void> purgeAccountData() async {
    await _database.transaction((transaction) async {
      await transaction.delete(IndexSchema.syncOutboxTableName);
      await transaction.delete(IndexSchema.syncStateTableName);
      await transaction.delete(IndexSchema.progressTableName);
      await transaction.delete(IndexSchema.tableName);
    });
    _deleteDocumentFiles();
  }

  void _deleteDocumentFiles() {
    if (!_documentsDirectory.existsSync()) return;
    for (final entity in _documentsDirectory.listSync()) {
      if (entity is File && isDocumentFilePath(entity.path)) {
        entity.deleteSync();
      }
    }
  }
}

bool isDocumentFilePath(String path) {
  return path.endsWith(pseudoDocumentExtension) ||
      path.endsWith('$pseudoDocumentExtension.tmp');
}
