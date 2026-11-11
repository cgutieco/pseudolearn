import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/sync/sync_drainer.dart';
import 'package:pseudolearn_app/data/sync/sync_metadata_store.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/sync/outbox_entry.dart';
import 'package:pseudolearn_app/domain/model/sync/sync_drain_outcome.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../fakes/fake_auth_gateway.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/fake_identifier_generator.dart';
import '../../fakes/fake_local_account_data_purger.dart';
import '../../fakes/fake_remote_document_store.dart';
import '../../fakes/fake_sync_queue.dart';
import '../../fakes/in_memory_document_repository.dart';

const _first = AccountSession(
  userId: 'user-1',
  email: 'u1@test.com',
  provider: AuthMethod.apple,
);
const _second = AccountSession(
  userId: 'user-2',
  email: 'u2@test.com',
  provider: AuthMethod.apple,
);

void main() {
  setUpAll(sqfliteFfiInit);

  group('SyncDrainer account ownership', () {
    late Database db;
    late SyncMetadataStore metadataStore;
    late FakeAuthGateway authGateway;
    late FakeRemoteDocumentStore remoteStore;
    late FakeSyncQueue queue;
    late FakeLocalAccountDataPurger purger;
    late FakeClock clock;

    SyncDrainer build({bool withPurger = true}) => SyncDrainer(
      authGateway: authGateway,
      remoteStore: remoteStore,
      queue: queue,
      metadataStore: metadataStore,
      repository: InMemoryDocumentRepository(),
      identifiers: FakeIdentifierGenerator(),
      clock: clock,
      accountDataPurger: withPurger ? purger : null,
    );

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await IndexSchema.createAllTables(db);
      metadataStore = SyncMetadataStore(db);
      authGateway = FakeAuthGateway();
      remoteStore = FakeRemoteDocumentStore();
      queue = FakeSyncQueue();
      purger = FakeLocalAccountDataPurger();
      clock = FakeClock(DateTime(2026, 9, 1, 10, 0));
    });

    tearDown(() async => db.close());

    test('the first account that syncs becomes the owner', () async {
      authGateway.session = _first;
      remoteStore.activeUserId = 'user-1';
      expect(await build().drain(), SyncDrainOutcome.success);
      expect(await metadataStore.getOwnerUserId(), 'user-1');
      expect(purger.purgeCalls, 0);
    });

    test('the same account keeps its pending edits', () async {
      authGateway.session = _first;
      remoteStore.activeUserId = 'user-1';
      await metadataStore.setOwnerUserId('user-1');
      await queue.enqueue(_entry());
      await build().drain();
      expect(purger.purgeCalls, 0);
    });

    test('another account never receives the previous edits', () async {
      await metadataStore.setOwnerUserId('user-1');
      await queue.enqueue(_entry());
      authGateway.session = _second;
      remoteStore.activeUserId = 'user-2';
      expect(await build().drain(), SyncDrainOutcome.success);
      expect(purger.purgeCalls, 1);
      expect(await metadataStore.getOwnerUserId(), 'user-2');
    });

    test('without a purger a foreign account is refused', () async {
      await metadataStore.setOwnerUserId('user-1');
      authGateway.session = _second;
      remoteStore.activeUserId = 'user-2';
      expect(await build(withPurger: false).drain(), SyncDrainOutcome.failure);
      expect(await metadataStore.getOwnerUserId(), 'user-1');
    });
  });
}

OutboxEntry _entry() => OutboxEntry(
  entryId: 'e-1',
  entityType: 'document',
  entityId: 'doc-1',
  operation: 'upsert',
  enqueuedAt: DateTime(2026, 9, 1),
);
