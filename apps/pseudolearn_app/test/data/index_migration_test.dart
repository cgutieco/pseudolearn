import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/index/metadata_index.dart';
import 'package:pseudolearn_app/data/progress/sqlite_local_progress_store.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('IndexSchema Migration (v1 -> v2) (CON-F8)', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    });

    tearDown(() async {
      await db.close();
    });

    test(
        'migrates v1 schema to v2 preserving existing documents and institutional nulls',
        () async {
      const v1CreateSql = '''
        CREATE TABLE documents_index (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          profile_id TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          created_at TEXT NOT NULL,
          revision INTEGER NOT NULL,
          synced INTEGER NOT NULL,
          institution_id TEXT,
          class_id TEXT,
          membership_id TEXT,
          submission_id TEXT
        )
      ''';
      await db.execute(v1CreateSql);

      await db.insert('documents_index', {
        'id': 'doc-legacy-1',
        'title': 'Algoritmo Preexistente',
        'profile_id': 'classicSpanish',
        'updated_at': '2026-08-01T10:00:00.000',
        'created_at': '2026-08-01T10:00:00.000',
        'revision': 1,
        'synced': 1,
        'institution_id': null,
        'class_id': null,
        'membership_id': null,
        'submission_id': null,
      });

      await IndexSchema.migrate(db, 1, 2);

      final index = MetadataIndex(db);
      final legacy = await index.get('doc-legacy-1');
      expect(legacy, isNotNull);
      expect(legacy!.title, 'Algoritmo Preexistente');
      expect(legacy.exerciseId, isNull);

      final newDoc = DocumentSummary(
        id: 'doc-from-exercise',
        title: 'Ejercicio Resuelto',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: DateTime(2026, 8, 23, 12, 0),
        updatedAt: DateTime(2026, 8, 23, 12, 0),
        exerciseId: 'con-b1-ej1',
      );
      await index.upsert(newDoc);

      final retrievedNew = await index.get('doc-from-exercise');
      expect(retrievedNew, isNotNull);
      expect(retrievedNew!.exerciseId, 'con-b1-ej1');
      expect(retrievedNew.revision, 1);

      final progressStore = SqliteLocalProgressStore(db);
      expect(await progressStore.isModuleVisited('con-b1'), isFalse);
      await progressStore.markModuleVisited('con-b1');
      expect(await progressStore.isModuleVisited('con-b1'), isTrue);
    });
  });

  group('IndexSchema Migration (v2 -> v3) (Phase F0)', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    });

    tearDown(() async {
      await db.close();
    });

    test(
        'migrates v2 schema to v3 preserving existing documents and progress data',
        () async {
      const v2DocumentsSql = '''
        CREATE TABLE documents_index (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          profile_id TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          created_at TEXT NOT NULL,
          revision INTEGER NOT NULL,
          synced INTEGER NOT NULL,
          exercise_id TEXT,
          institution_id TEXT,
          class_id TEXT,
          membership_id TEXT,
          submission_id TEXT
        )
      ''';
      const v2ProgressSql = '''
        CREATE TABLE content_progress (
          content_id TEXT PRIMARY KEY,
          visited INTEGER NOT NULL DEFAULT 0,
          completed INTEGER NOT NULL DEFAULT 0
        )
      ''';
      await db.execute(v2DocumentsSql);
      await db.execute(v2ProgressSql);

      await db.insert('documents_index', {
        'id': 'doc-v2-existing',
        'title': 'Algoritmo Existente',
        'profile_id': 'classicSpanish',
        'updated_at': '2026-08-20T14:30:00.000',
        'created_at': '2026-08-10T09:00:00.000',
        'revision': 5,
        'synced': 1,
        'exercise_id': 'con-b1-ej2',
        'institution_id': null,
        'class_id': null,
        'membership_id': null,
        'submission_id': null,
      });

      await db.insert('content_progress', {
        'content_id': 'con-b1',
        'visited': 1,
        'completed': 0,
      });

      await db.insert('content_progress', {
        'content_id': 'con-b1-ej2',
        'visited': 1,
        'completed': 1,
      });

      await IndexSchema.migrate(db, 2, 3);

      final index = MetadataIndex(db);
      final doc = await index.get('doc-v2-existing');
      expect(doc, isNotNull);
      expect(doc!.title, 'Algoritmo Existente');
      expect(doc.revision, 5);
      expect(doc.createdAt, DateTime.parse('2026-08-10T09:00:00.000'));
      expect(doc.exerciseId, 'con-b1-ej2');

      final rawDocRows = await db.query(
        'documents_index',
        where: 'id = ?',
        whereArgs: ['doc-v2-existing'],
      );
      expect(rawDocRows.first['deleted_at'], isNull);
      expect(rawDocRows.first['server_revision'], isNull);
      expect(rawDocRows.first['last_synced_revision'], isNull);

      final rawProgressRows =
          await db.query('content_progress', orderBy: 'content_id ASC');
      expect(rawProgressRows.length, 2);

      final modRow =
          rawProgressRows.firstWhere((r) => r['content_id'] == 'con-b1');
      expect(modRow['visited'], 1);
      expect(modRow['completed'], 0);
      expect(modRow['first_visited_at'], isNull);
      expect(modRow['first_completed_at'], isNull);
      expect(modRow['dirty'], 0);

      final ejRow =
          rawProgressRows.firstWhere((r) => r['content_id'] == 'con-b1-ej2');
      expect(ejRow['visited'], 1);
      expect(ejRow['completed'], 1);
      expect(ejRow['first_visited_at'], isNull);
      expect(ejRow['first_completed_at'], isNull);
      expect(ejRow['dirty'], 0);

      final outboxRows = await db.query('sync_outbox');
      expect(outboxRows, isEmpty);

      final stateRows = await db.query('sync_state');
      expect(stateRows, isEmpty);

      await index.markDeleted('doc-v2-existing');
      expect(await index.get('doc-v2-existing'), isNull);
      expect(await index.listAll(), isEmpty);

      final tombstones = await index.listTombstones();
      expect(tombstones.length, 1);
      expect(tombstones.first.id, 'doc-v2-existing');
    });

    test('migrates v1 schema directly to v3', () async {
      const v1CreateSql = '''
        CREATE TABLE documents_index (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          profile_id TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          created_at TEXT NOT NULL,
          revision INTEGER NOT NULL,
          synced INTEGER NOT NULL,
          institution_id TEXT,
          class_id TEXT,
          membership_id TEXT,
          submission_id TEXT
        )
      ''';
      await db.execute(v1CreateSql);

      await db.insert('documents_index', {
        'id': 'doc-v1',
        'title': 'From V1',
        'profile_id': 'classicSpanish',
        'updated_at': '2026-08-01T10:00:00.000',
        'created_at': '2026-08-01T10:00:00.000',
        'revision': 1,
        'synced': 1,
        'institution_id': null,
        'class_id': null,
        'membership_id': null,
        'submission_id': null,
      });

      await IndexSchema.migrate(db, 1, 3);

      final index = MetadataIndex(db);
      final doc = await index.get('doc-v1');
      expect(doc, isNotNull);
      expect(doc!.title, 'From V1');

      final progressStore = SqliteLocalProgressStore(db);
      await progressStore.markModuleVisited('m-1');
      expect(await progressStore.isModuleVisited('m-1'), isTrue);
    });
  });
}
