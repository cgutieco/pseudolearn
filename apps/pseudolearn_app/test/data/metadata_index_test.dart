import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/index/metadata_index.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('MetadataIndex', () {
    late Database db;
    late MetadataIndex index;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await IndexSchema.createAllTables(db);
      index = MetadataIndex(db);
    });

    tearDown(() async {
      await db.close();
    });

    test(
        'upsert and retrieve document summary with real revision and createdAt',
        () async {
      final created = DateTime(2026, 8, 10, 9, 30);
      final updated = DateTime(2026, 8, 15, 10, 0);
      final unlinked = DocumentSummary(
        id: 'doc-1',
        title: 'Algoritmo Test',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 3,
        createdAt: created,
        updatedAt: updated,
      );
      final linked = DocumentSummary(
        id: 'doc-2',
        title: 'Ejercicio Suma',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: created,
        updatedAt: updated,
        exerciseId: 'con-b1-ej1',
      );

      await index.upsert(unlinked);
      await index.upsert(linked);

      final retrievedUnlinked = await index.get('doc-1');
      expect(retrievedUnlinked, isNotNull);
      expect(retrievedUnlinked!.id, 'doc-1');
      expect(retrievedUnlinked.title, 'Algoritmo Test');
      expect(retrievedUnlinked.revision, 3);
      expect(retrievedUnlinked.createdAt, created);
      expect(retrievedUnlinked.updatedAt, updated);
      expect(retrievedUnlinked.exerciseId, isNull);

      final retrievedLinked = await index.get('doc-2');
      expect(retrievedLinked, isNotNull);
      expect(retrievedLinked!.id, 'doc-2');
      expect(retrievedLinked.title, 'Ejercicio Suma');
      expect(retrievedLinked.revision, 1);
      expect(retrievedLinked.exerciseId, 'con-b1-ej1');

      final all = await index.listAll();
      expect(all.length, 2);

      final raw = await db
          .query('documents_index', where: 'id = ?', whereArgs: ['doc-1']);
      expect(raw.first['synced'], 0);
    });

    test('markDeleted sets tombstone and filters document from listAll and get',
        () async {
      final summary = DocumentSummary(
        id: 'doc-2',
        title: 'Algoritmo 2',
        profileId: SyntaxProfileId.english,
        revision: 2,
        createdAt: DateTime(2026, 8, 10),
        updatedAt: DateTime(2026, 8, 15),
        exerciseId: 'con-b1-ej2',
      );

      await index.upsert(summary);
      expect(await index.get('doc-2'), isNotNull);
      expect(await index.listAll(), hasLength(1));
      expect(await index.listTombstones(), isEmpty);

      final deleteTime = DateTime(2026, 8, 20, 18, 0);
      await index.markDeleted('doc-2', deletedAt: deleteTime);

      expect(await index.get('doc-2'), isNull);
      expect(await index.listAll(), isEmpty);

      final tombstones = await index.listTombstones();
      expect(tombstones, hasLength(1));
      expect(tombstones.first.id, 'doc-2');

      final raw = await db
          .query('documents_index', where: 'id = ?', whereArgs: ['doc-2']);
      expect(raw, hasLength(1));
      expect(raw.first['deleted_at'], deleteTime.toIso8601String());
    });

    test('upserting a previously deleted document clears tombstone', () async {
      final summary = DocumentSummary(
        id: 'doc-restored',
        title: 'Recreado',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: DateTime(2026, 8, 1),
        updatedAt: DateTime(2026, 8, 2),
      );

      await index.upsert(summary);
      await index.markDeleted('doc-restored');
      expect(await index.get('doc-restored'), isNull);

      final updatedSummary = DocumentSummary(
        id: 'doc-restored',
        title: 'Recreado Nuevo',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 2,
        createdAt: DateTime(2026, 8, 1),
        updatedAt: DateTime(2026, 8, 10),
      );
      await index.upsert(updatedSummary);

      final restored = await index.get('doc-restored');
      expect(restored, isNotNull);
      expect(restored!.title, 'Recreado Nuevo');
      expect(restored.revision, 2);
      expect(await index.listTombstones(), isEmpty);
    });

    test('IndexSchema.clear removes all entries', () async {
      await index.upsert(DocumentSummary(
        id: '1',
        title: 'A',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await index.upsert(DocumentSummary(
        id: '2',
        title: 'B',
        profileId: SyntaxProfileId.english,
        revision: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        exerciseId: 'ex-2',
      ));

      expect((await index.listAll()).length, 2);

      await IndexSchema.clear(index.database);
      expect((await index.listAll()), isEmpty);
    });
  });
}
