import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'composition/cubit_scope.dart';
import 'composition/local_composition.dart';
import 'data/index/index_schema.dart';
import 'data/index/metadata_index.dart';
import 'data/platform/platform_database_factory.dart';
import 'data/progress/sqlite_local_progress_store.dart';
import 'engine/rust/native_rust_transport.dart';
import 'engine/rust/rust_transport.dart';

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
  RustTransport? openedTransport;
  try {
    await initializeNativeBridge();
    initializePlatformDatabaseFactory();
    final directory = await resolveDocumentsDirectory();
    final database = await openLocalDatabase(directory);
    final index = MetadataIndex(database);
    final progressStore = SqliteLocalProgressStore(database);
    final transport = openNativeTransport();
    openedTransport = transport;
    AppLifecycleListener(onDetach: () => closeAppTransport(transport));
    runApp(
      CubitScope(
        dependencies: buildLocalDependencies(
          documentsDirectory: directory,
          index: index,
          progressStore: progressStore,
          transport: transport,
        ),
      ),
    );
  } on Object catch (error, stack) {
    closeAppTransport(openedTransport);
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack),
    );
  }
}

void closeAppTransport(RustTransport? transport) {
  try {
    transport?.close();
  } on Object catch (error, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack),
    );
  }
}
