import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/sync/sqlite_sync_queue.dart';
import 'package:pseudolearn_app/data/sync/sync_drainer.dart';
import 'package:pseudolearn_app/data/sync/sync_metadata_store.dart';
import 'package:pseudolearn_app/data/sync/syncing_document_repository.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/sync/sync_drain_outcome.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../fakes/fake_auth_gateway.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/fake_identifier_generator.dart';
import '../../fakes/fake_remote_document_store.dart';
import '../../fakes/in_memory_document_repository.dart';

final class _TestDevice {
  final Database db;
  final SyncMetadataStore metadataStore;
  final SqliteSyncQueue queue;
  final InMemoryDocumentRepository fileRepo;
  final SyncingDocumentRepository syncingRepo;
  final SyncDrainer drainer;
  final FakeAuthGateway authGateway;

  _TestDevice({
    required this.db,
    required this.metadataStore,
    required this.queue,
    required this.fileRepo,
    required this.syncingRepo,
    required this.drainer,
    required this.authGateway,
  });

  static Future<_TestDevice> create({
    required FakeRemoteDocumentStore remoteStore,
    required String userId,
    required FakeClock clock,
    required FakeIdentifierGenerator identifiers,
  }) async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await IndexSchema.createAllTables(db);
    final metadataStore = SyncMetadataStore(db);
    final queue = SqliteSyncQueue(db);
    final fileRepo = InMemoryDocumentRepository();
    final syncingRepo = SyncingDocumentRepository(
      inner: fileRepo,
      queue: queue,
      identifiers: identifiers,
      clock: clock,
    );
    final authGateway = FakeAuthGateway(
      currentSession: AccountSession(
        userId: userId,
        email: '$userId@test.com',
        provider: AuthMethod.apple,
      ),
    );
    final drainer = SyncDrainer(
      authGateway: authGateway,
      remoteStore: remoteStore,
      queue: queue,
      metadataStore: metadataStore,
      repository: fileRepo,
      identifiers: identifiers,
      clock: clock,
    );
    return _TestDevice(
      db: db,
      metadataStore: metadataStore,
      queue: queue,
      fileRepo: fileRepo,
      syncingRepo: syncingRepo,
      drainer: drainer,
      authGateway: authGateway,
    );
  }

  Future<void> dispose() async {
    await db.close();
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('Multi-Device Document Synchronization', () {
    late FakeRemoteDocumentStore remoteStore;
    late FakeClock clock;
    late FakeIdentifierGenerator identifiers;
    late _TestDevice deviceA;
    late _TestDevice deviceB;

    setUp(() async {
      remoteStore = FakeRemoteDocumentStore(activeUserId: 'user-1');
      clock = FakeClock(DateTime(2026, 9, 1, 10, 0));
      identifiers = FakeIdentifierGenerator();

      deviceA = await _TestDevice.create(
        remoteStore: remoteStore,
        userId: 'user-1',
        clock: clock,
        identifiers: identifiers,
      );
      deviceB = await _TestDevice.create(
        remoteStore: remoteStore,
        userId: 'user-1',
        clock: clock,
        identifiers: identifiers,
      );
    });

    tearDown(() async {
      await deviceA.dispose();
      await deviceB.dispose();
    });

    test('Case 1 & 2: Local on A propagates cleanly to B through cloud',
        () async {
      final docA = Document(
        id: 'doc-1',
        title: 'Algoritmo Fibonacci',
        content: 'Escribir "Fibonacci"',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: clock.now(),
        updatedAt: clock.now(),
      );

      await deviceA.syncingRepo.saveDocument(docA);
      final drainAOutcome = await deviceA.drainer.drain();
      expect(drainAOutcome, equals(SyncDrainOutcome.success));

      final drainBOutcome = await deviceB.drainer.drain();
      expect(drainBOutcome, equals(SyncDrainOutcome.success));

      final docOnB = await deviceB.fileRepo.loadDocument('doc-1');
      expect(docOnB, isNotNull);
      expect(docOnB!.title, equals('Algoritmo Fibonacci'));
      expect(docOnB.content, equals('Escribir "Fibonacci"'));
    });

    test('Case 3: Concurrent edits on A and B preserve both via KeepBoth',
        () async {
      final initialDoc = Document(
        id: 'doc-conflict',
        title: 'Mi Algoritmo',
        content: 'Version Base',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: clock.now(),
        updatedAt: clock.now(),
      );
      await deviceA.syncingRepo.saveDocument(initialDoc);
      await deviceA.drainer.drain();
      await deviceB.drainer.drain();

      final editA = Document(
        id: 'doc-conflict',
        title: 'Mi Algoritmo',
        content: 'Version Modificada por A',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 2,
        createdAt: clock.now(),
        updatedAt: clock.now(),
      );
      final editB = Document(
        id: 'doc-conflict',
        title: 'Mi Algoritmo',
        content: 'Version Modificada por B',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 2,
        createdAt: clock.now(),
        updatedAt: clock.now(),
      );

      await deviceA.syncingRepo.saveDocument(editA);
      await deviceB.syncingRepo.saveDocument(editB);

      await deviceA.drainer.drain();

      await deviceB.drainer.drain();

      final docsOnB = await deviceB.fileRepo.listDocuments();
      expect(docsOnB.length, equals(2));

      final conflictCopy =
          docsOnB.firstWhere((d) => d.title.contains('(conflicto)'));
      expect(conflictCopy, isNotNull);

      final originalOnB = await deviceB.fileRepo.loadDocument('doc-conflict');
      expect(originalOnB!.content, equals('Version Modificada por A'));

      final copyContent = await deviceB.fileRepo.loadDocument(conflictCopy.id);
      expect(copyContent!.content, equals('Version Modificada por B'));
    });

    test('Idempotency: Re-enqueuing outbox entry does not duplicate documents',
        () async {
      final doc = Document(
        id: 'doc-idemp',
        title: 'Idempotente',
        content: 'test',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: clock.now(),
        updatedAt: clock.now(),
      );
      await deviceA.syncingRepo.saveDocument(doc);
      await deviceA.drainer.drain();

      await deviceA.syncingRepo.saveDocument(doc);
      await deviceA.drainer.drain();

      final remoteDocs = remoteStore.activeUserDocuments;
      expect(remoteDocs.where((d) => d.id == 'doc-idemp').length, equals(1));
    });

    test(
        'deleteAccount purges only active user documents and leaves other accounts intact',
        () async {
      final doc1 = Document(
        id: 'doc-u1',
        title: 'Doc User 1',
        content: '1',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: clock.now(),
        updatedAt: clock.now(),
      );
      await deviceA.syncingRepo.saveDocument(doc1);
      await deviceA.drainer.drain();

      final deviceC = await _TestDevice.create(
        remoteStore: remoteStore,
        userId: 'user-2',
        clock: clock,
        identifiers: identifiers,
      );
      remoteStore.activeUserId = 'user-2';
      final doc2 = Document(
        id: 'doc-u2',
        title: 'Doc User 2',
        content: '2',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: clock.now(),
        updatedAt: clock.now(),
      );
      await deviceC.syncingRepo.saveDocument(doc2);
      await deviceC.drainer.drain();

      expect(remoteStore.activeUserDocuments.length, equals(1));

      remoteStore.activeUserId = 'user-1';
      await remoteStore.deleteAccount();

      expect(remoteStore.activeUserDocuments, isEmpty);

      remoteStore.activeUserId = 'user-2';
      expect(remoteStore.activeUserDocuments.length, equals(1));
      expect(remoteStore.activeUserDocuments.first.id, equals('doc-u2'));

      await deviceC.dispose();
    });
  });
}
