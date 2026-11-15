import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/sync/sync_drainer.dart';
import 'package:pseudolearn_app/data/sync/sync_metadata_store.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/progress/progress_entry.dart';
import 'package:pseudolearn_app/domain/model/sync/document_snapshot.dart';
import 'package:pseudolearn_app/domain/model/sync/outbox_entry.dart';
import 'package:pseudolearn_app/domain/model/sync/sync_drain_outcome.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../fakes/fake_auth_gateway.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/fake_identifier_generator.dart';
import '../../fakes/fake_progress_sync_store.dart';
import '../../fakes/fake_remote_document_store.dart';
import '../../fakes/fake_remote_progress_store.dart';
import '../../fakes/fake_sync_queue.dart';
import '../../fakes/in_memory_document_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('SyncDrainer', () {
    late Database db;
    late SyncMetadataStore metadataStore;
    late FakeAuthGateway authGateway;
    late FakeRemoteDocumentStore remoteStore;
    late FakeSyncQueue queue;
    late InMemoryDocumentRepository repository;
    late FakeIdentifierGenerator identifiers;
    late FakeClock clock;
    late SyncDrainer drainer;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await IndexSchema.createAllTables(db);
      metadataStore = SyncMetadataStore(db);
      authGateway = FakeAuthGateway();
      remoteStore = FakeRemoteDocumentStore();
      queue = FakeSyncQueue();
      repository = InMemoryDocumentRepository();
      identifiers = FakeIdentifierGenerator();
      clock = FakeClock(DateTime(2026, 9, 1, 10, 0));
      drainer = SyncDrainer(
        authGateway: authGateway,
        remoteStore: remoteStore,
        queue: queue,
        metadataStore: metadataStore,
        repository: repository,
        identifiers: identifiers,
        clock: clock,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('returns unauthenticated when there is no active session', () async {
      final outcome = await drainer.drain();
      expect(outcome, equals(SyncDrainOutcome.unauthenticated));
    });

    test('pulls remote document and adopts it locally when unauthenticated',
        () async {
      authGateway.session = const AccountSession(
        userId: 'user-1',
        email: 'u1@test.com',
        provider: AuthMethod.apple,
      );
      remoteStore.activeUserId = 'user-1';

      final remoteDoc = DocumentSnapshot(
        id: 'doc-remote',
        revision: 1,
        updatedAt: clock.now(),
        content: 'Escribir "Desde nube"',
        title: 'Nube Doc',
        profileId: SyntaxProfileId.classicSpanish,
      );
      await remoteStore.pushDocuments([remoteDoc]);

      final outcome = await drainer.drain();
      expect(outcome, equals(SyncDrainOutcome.success));

      final adopted = await repository.loadDocument('doc-remote');
      expect(adopted, isNotNull);
      expect(adopted!.title, equals('Nube Doc'));

      final globalState = await metadataStore.getGlobalState();
      expect(globalState.cursor, equals(1));
      expect(globalState.lastSyncAt, isNotNull);
    });

    test('pushes local outbox entry and updates revisions', () async {
      authGateway.session = const AccountSession(
        userId: 'user-1',
        email: 'u1@test.com',
        provider: AuthMethod.apple,
      );
      remoteStore.activeUserId = 'user-1';

      final doc = Document(
        id: 'doc-local-1',
        title: 'Local Doc',
        content: 'Inicio\nFin',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: clock.now(),
        updatedAt: clock.now(),
      );
      await repository.saveDocument(doc);
      await queue.enqueue(OutboxEntry(
        entryId: 'e-1',
        entityType: 'document',
        entityId: 'doc-local-1',
        operation: 'upsert',
        enqueuedAt: clock.now(),
      ));

      final outcome = await drainer.drain();
      expect(outcome, equals(SyncDrainOutcome.success));

      final pending = await queue.pendingEntries();
      expect(pending, isEmpty);

      final remoteDocs = remoteStore.activeUserDocuments;
      expect(remoteDocs.length, equals(1));
      expect(remoteDocs.first.id, equals('doc-local-1'));
      expect(remoteDocs.first.revision, equals(1));
    });

    test('coordinates both document and progress draining seamlessly',
        () async {
      authGateway.session = const AccountSession(
        userId: 'user-1',
        email: 'u1@test.com',
        provider: AuthMethod.apple,
      );
      final fakeRemoteProgress =
          FakeRemoteProgressStore(activeUserId: 'user-1');
      final fakeProgressStore = FakeProgressSyncStore();

      final fullDrainer = SyncDrainer(
        authGateway: authGateway,
        remoteStore: remoteStore,
        queue: queue,
        metadataStore: metadataStore,
        repository: repository,
        identifiers: identifiers,
        clock: clock,
        remoteProgressStore: fakeRemoteProgress,
        progressSyncStore: fakeProgressStore,
      );

      fakeProgressStore.seedEntry(
        const ProgressEntry(
          contentId: 'mod-1',
          visited: true,
          completed: true,
        ),
        dirty: true,
      );

      await fakeRemoteProgress.pushProgress([
        const ProgressEntry(
          contentId: 'mod-remote',
          visited: true,
          completed: false,
        ),
      ]);

      final outcome = await fullDrainer.drain();
      expect(outcome, equals(SyncDrainOutcome.success));

      expect(fakeProgressStore.entries['mod-1']!.dirty, isFalse);

      expect(fakeProgressStore.entries['mod-remote'], isNotNull);
      expect(fakeProgressStore.entries['mod-remote']!.entry.visited, isTrue);

      final state = await metadataStore.getGlobalState();
      expect(state.lastSyncAt, isNotNull);
    });
  });
}
