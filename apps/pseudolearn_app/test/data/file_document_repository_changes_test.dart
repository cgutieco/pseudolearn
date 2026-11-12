import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/documents/file_document_repository.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/index/metadata_index.dart';
import 'package:pseudolearn_app/data/sync/syncing_document_repository.dart';
import 'package:pseudolearn_app/domain/model/documents/document_change.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../fakes/document_fixtures.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_identifier_generator.dart';
import '../fakes/fake_sync_queue.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late Directory directory;
  late Database database;
  late FileDocumentRepository repository;

  setUp(() async {
    directory = Directory.systemTemp.createTempSync('doc_changes_');
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await IndexSchema.createAllTables(database);
    repository = FileDocumentRepository(directory: directory, index: MetadataIndex(database));
  });

  tearDown(() async {
    await database.close();
    directory.deleteSync(recursive: true);
  });

  test('save, delete and reindex are announced in order', () async {
    final changes = <DocumentChange>[];
    final subscription = repository.changes.listen(changes.add);
    await repository.saveDocument(documentFixture(revision: 3));
    await repository.deleteDocument('doc-1');
    await repository.rebuildIndex();
    await Future<void>.delayed(Duration.zero);
    expect(changes, const [
      DocumentChange.saved(documentId: 'doc-1', revision: 3),
      DocumentChange.deleted(documentId: 'doc-1'),
      DocumentChange.reindexed(),
    ]);
    await subscription.cancel();
  });

  test('deleting a missing document is still announced', () async {
    final first = repository.changes.first;
    await repository.deleteDocument('ghost');
    expect(await first, const DocumentChange.deleted(documentId: 'ghost'));
  });

  test('the syncing decorator forwards the inner announcements', () async {
    final syncing = SyncingDocumentRepository(
      inner: repository,
      queue: FakeSyncQueue(),
      identifiers: FakeIdentifierGenerator(),
      clock: FakeClock(),
    );
    final first = syncing.changes.first;
    await syncing.saveDocument(documentFixture());
    expect((await first).documentId, 'doc-1');
  });

  test('a change concerns its document or every document when global', () {
    expect(const DocumentChange.deleted(documentId: 'a').concerns('a'), isTrue);
    expect(const DocumentChange.deleted(documentId: 'a').concerns('b'), isFalse);
    expect(const DocumentChange.reindexed().concerns('b'), isTrue);
  });
}
