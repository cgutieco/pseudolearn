import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/data/documents/file_document_repository.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/index/metadata_index.dart';
import 'package:pseudolearn_app/data/progress/sqlite_local_progress_store.dart';
import 'package:pseudolearn_app/data/sync/local_account_data_purger_adapter.dart';
import 'package:pseudolearn_app/data/sync/sqlite_sync_queue.dart';
import 'package:pseudolearn_app/data/sync/sync_metadata_store.dart';
import 'package:pseudolearn_app/data/sync/syncing_document_repository.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../fakes/fake_clock.dart';
import '../../fakes/fake_identifier_generator.dart';

Document _document(String id) {
  return Document(
    id: id,
    title: 'Algoritmo $id',
    content: 'inicio fin',
    profileId: SyntaxProfileId.classicSpanish,
    revision: 1,
    createdAt: DateTime(2026, 9, 1),
    updatedAt: DateTime(2026, 9, 1),
  );
}

Future<int> _rowCount(Database db, String table) async {
  final rows = await db.rawQuery('SELECT COUNT(*) AS total FROM $table');
  return rows.first['total'] as int;
}

void main() {
  setUpAll(sqfliteFfiInit);

  group('LocalAccountDataPurgerAdapter', () {
    late Database db;
    late Directory directory;
    late SyncingDocumentRepository repository;
    late LocalAccountDataPurgerAdapter purger;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await IndexSchema.createAllTables(db);
      directory = await Directory.systemTemp.createTemp('purger_test_');
      repository = SyncingDocumentRepository(
        inner: FileDocumentRepository(directory: directory, index: MetadataIndex(db)),
        queue: SqliteSyncQueue(db),
        identifiers: FakeIdentifierGenerator(),
        clock: FakeClock(DateTime(2026, 9, 1)),
      );
      purger = LocalAccountDataPurgerAdapter(database: db, documentsDirectory: directory);
    });

    tearDown(() async {
      await db.close();
      if (directory.existsSync()) directory.deleteSync(recursive: true);
    });

    test('removes documents, progress, outbox and sync cursors without enqueuing tombstones', () async {
      await repository.saveDocument(_document('doc-1'));
      await repository.saveDocument(_document('doc-2'));
      await SqliteLocalProgressStore(db).markModuleVisited('module-1');
      await SyncMetadataStore(db).setGlobalState(cursor: 7, progressCursor: 3);

      await purger.purgeAccountData();

      expect(await repository.listDocuments(), isEmpty);
      expect(await _rowCount(db, IndexSchema.tableName), 0);
      expect(await _rowCount(db, IndexSchema.progressTableName), 0);
      expect(await _rowCount(db, IndexSchema.syncOutboxTableName), 0);
      expect((await SyncMetadataStore(db).getGlobalState()).cursor, 0);
      expect(directory.listSync().whereType<File>().where((f) => f.path.endsWith('.pseudo')), isEmpty);
    });

    test('preserves files that are not documents, such as preferences', () async {
      final preferences = File(p.join(directory.path, 'preferences.json'))..writeAsStringSync('{}');
      await repository.saveDocument(_document('doc-1'));

      await purger.purgeAccountData();

      expect(preferences.existsSync(), isTrue);
    });

    test('removes interrupted temporary document writes', () async {
      final temporary = File(p.join(directory.path, 'doc-9.pseudo.tmp'))..writeAsStringSync('partial');

      await purger.purgeAccountData();

      expect(temporary.existsSync(), isFalse);
    });

    test('completes on an empty device', () async {
      await expectLater(purger.purgeAccountData(), completes);
    });

    test('completes when the documents directory no longer exists', () async {
      directory.deleteSync(recursive: true);

      await expectLater(purger.purgeAccountData(), completes);
    });

    test('rolls back every table and keeps the files when the database purge fails', () async {
      await repository.saveDocument(_document('doc-1'));
      await db.execute('DROP TABLE ${IndexSchema.tableName}');

      await expectLater(purger.purgeAccountData(), throwsA(isA<DatabaseException>()));

      expect(await _rowCount(db, IndexSchema.syncOutboxTableName), 1);
      expect(File(p.join(directory.path, 'doc-1.pseudo')).existsSync(), isTrue);
    });
  });

  group('isDocumentFilePath', () {
    test('accepts documents and their temporary writes only', () {
      expect(isDocumentFilePath('/a/doc.pseudo'), isTrue);
      expect(isDocumentFilePath('/a/doc.pseudo.tmp'), isTrue);
      expect(isDocumentFilePath('/a/preferences.json'), isFalse);
      expect(isDocumentFilePath('/a/pseudo'), isFalse);
      expect(isDocumentFilePath(''), isFalse);
    });
  });
}
