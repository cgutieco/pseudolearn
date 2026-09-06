import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'composition/cubit_scope.dart';
import 'composition/local_composition.dart';
import 'data/index/index_schema.dart';
import 'data/index/metadata_index.dart';
import 'data/progress/sqlite_local_progress_store.dart';

Future<Directory> resolveDocumentsDirectory() async {
  return getApplicationDocumentsDirectory();
}

Future<Database> openLocalDatabase(Directory directory) async {
  final dbPath = p.join(directory.path, 'pseudolearn_index.db');
  return openDatabase(
    dbPath,
    version: IndexSchema.currentVersion,
    onCreate: (db, version) async {
      await IndexSchema.createAllTables(db);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      await IndexSchema.migrate(db, oldVersion, newVersion);
    },
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await resolveDocumentsDirectory();
  final database = await openLocalDatabase(directory);
  final index = MetadataIndex(database);
  final progressStore = SqliteLocalProgressStore(database);
  runApp(CubitScope(
    dependencies: buildLocalDependencies(
      documentsDirectory: directory,
      index: index,
      progressStore: progressStore,
    ),
  ));
}
