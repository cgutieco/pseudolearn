import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/documents/file_document_repository.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/index/metadata_index.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('FileDocumentRepository', () {
    late Directory tempDir;
    late Database db;
    late MetadataIndex index;
    late FileDocumentRepository repo;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('doc_repo_test_');
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await IndexSchema.createAllTables(db);
      index = MetadataIndex(db);
      repo = FileDocumentRepository(directory: tempDir, index: index);
    });

    tearDown(() async {
      await db.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('saves and loads document correctly with and without exerciseId',
        () async {
      final now = DateTime(2026, 8, 15, 12, 0);
      final unlinked = Document(
        id: 'doc-abc',
        title: 'Mi Algoritmo',
        content: 'algoritmo Test\n  escribir "Hola"\nfin',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: now,
        updatedAt: now,
      );
      final linked = Document(
        id: 'doc-linked',
        title: 'Ejercicio Suma',
        content: 'algoritmo Suma fin',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: now,
        updatedAt: now,
        exerciseId: 'con-b1-ej1',
      );

      await repo.saveDocument(unlinked);
      await repo.saveDocument(linked);

      final loadedUnlinked = await repo.loadDocument('doc-abc');
      expect(loadedUnlinked, isNotNull);
      expect(loadedUnlinked!.title, 'Mi Algoritmo');
      expect(loadedUnlinked.exerciseId, isNull);

      final loadedLinked = await repo.loadDocument('doc-linked');
      expect(loadedLinked, isNotNull);
      expect(loadedLinked!.title, 'Ejercicio Suma');
      expect(loadedLinked.exerciseId, 'con-b1-ej1');

      final list = await repo.listDocuments();
      expect(list.length, 2);
    });

    test(
        'deleteDocument removes file from disk but preserves row with tombstone in index (TEST-BOTH-PATHS)',
        () async {
      final now = DateTime(2026, 8, 15, 12, 0);
      final doc = Document(
        id: 'doc-xyz',
        title: 'Borrar',
        content: 'algoritmo Borrar fin',
        profileId: SyntaxProfileId.english,
        revision: 1,
        createdAt: now,
        updatedAt: now,
        exerciseId: 'con-b1-ej2',
      );

      await repo.saveDocument(doc);
      final file = File('${tempDir.path}/${doc.id}.pseudo');
      expect(file.existsSync(), isTrue);
      expect(await repo.loadDocument('doc-xyz'), isNotNull);

      await repo.deleteDocument('doc-xyz');

      expect(file.existsSync(), isFalse);
      expect(await repo.loadDocument('doc-xyz'), isNull);

      expect(await repo.listDocuments(), isEmpty);

      final tombstones = await index.listTombstones();
      expect(tombstones, hasLength(1));
      expect(tombstones.first.id, 'doc-xyz');

      final raw = await db
          .query('documents_index', where: 'id = ?', whereArgs: ['doc-xyz']);
      expect(raw, hasLength(1));
      expect(raw.first['deleted_at'], isNotNull);
    });

    test(
        'saving document twice advances revision in index, not only in file (TEST-BOTH-PATHS)',
        () async {
      final now = DateTime(2026, 8, 15, 12, 0);
      final docV1 = Document(
        id: 'doc-adv',
        title: 'Algoritmo Revision',
        content: 'algoritmo Rev fin',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveDocument(docV1);
      var indexed = await index.get('doc-adv');
      expect(indexed, isNotNull);
      expect(indexed!.revision, 1);

      var file = File('${tempDir.path}/doc-adv.pseudo');
      expect(file.readAsStringSync(), contains('revision: 1'));

      final docV2 = docV1.copyWith(
        revision: 2,
        updatedAt: DateTime(2026, 8, 15, 12, 5),
      );
      await repo.saveDocument(docV2);

      indexed = await index.get('doc-adv');
      expect(indexed, isNotNull);
      expect(indexed!.revision, 2);

      file = File('${tempDir.path}/doc-adv.pseudo');
      expect(file.readAsStringSync(), contains('revision: 2'));
    });

    test(
        'rebuildIndex discovers orphan files and updates index preserving exercise links',
        () async {
      final now = DateTime(2026, 8, 15, 12, 0);
      final doc1 = Document(
        id: 'doc-1',
        title: 'Uno',
        content: 'algoritmo Uno fin',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: now,
        updatedAt: now,
      );
      final doc2 = Document(
        id: 'doc-2',
        title: 'Dos con Ejercicio',
        content: 'algoritmo Dos fin',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: now,
        updatedAt: now,
        exerciseId: 'con-b1-ej1',
      );
      await repo.saveDocument(doc1);
      await repo.saveDocument(doc2);

      await IndexSchema.clear(index.database);
      expect(await index.listAll(), isEmpty);

      await repo.rebuildIndex();
      final rebuiltList = await repo.listDocuments();
      expect(rebuiltList.length, 2);

      final summary1 = rebuiltList.firstWhere((d) => d.id == 'doc-1');
      expect(summary1.exerciseId, isNull);

      final summary2 = rebuiltList.firstWhere((d) => d.id == 'doc-2');
      expect(summary2.exerciseId, 'con-b1-ej1');
    });

    test('corrupted file returns null when parsed', () {
      final corruptedFile = File('${tempDir.path}/bad.pseudo');
      corruptedFile.writeAsStringSync('corrupted non-yaml file');

      final result = parseDocumentFile(corruptedFile);
      expect(result, isNull);
    });
  });
}
