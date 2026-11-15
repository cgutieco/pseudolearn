import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/index/metadata_index.dart';
import 'package:pseudolearn_app/data/sync/sync_metadata_store.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('SyncMetadataStore', () {
    late Database db;
    late MetadataIndex index;
    late SyncMetadataStore store;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await IndexSchema.createAllTables(db);
      index = MetadataIndex(db);
      store = SyncMetadataStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('manages global cursor and lastSyncAt', () async {
      final initial = await store.getGlobalState();
      expect(initial.cursor, equals(0));
      expect(initial.lastSyncAt, isNull);

      final now = DateTime(2026, 9, 1, 10, 30);
      await store.setGlobalState(cursor: 42, lastSyncAt: now);

      final updated = await store.getGlobalState();
      expect(updated.cursor, equals(42));
      expect(updated.lastSyncAt, equals(now));
    });

    test('updates and reads document sync revisions', () async {
      final doc = DocumentSummary(
        id: 'doc-abc',
        title: 'Title',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      );
      await index.upsert(doc);

      await store.updateDocumentRevisions('doc-abc', serverRevision: 5, lastSyncedRevision: 5);
      final revisions = await store.getDocumentRevisions('doc-abc');

      expect(revisions, isNotNull);
      expect(revisions!.serverRevision, equals(5));
      expect(revisions.lastSyncedRevision, equals(5));
    });
  });
}
