import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/progress/sqlite_local_progress_store.dart';
import 'package:pseudolearn_app/data/sync/sqlite_progress_sync_store.dart';
import 'package:pseudolearn_app/data/sync/sqlite_sync_queue.dart';
import 'package:pseudolearn_app/data/sync/sync_drainer.dart';
import 'package:pseudolearn_app/data/sync/sync_metadata_store.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/progress/progress_entry.dart';
import 'package:pseudolearn_app/domain/model/sync/sync_drain_outcome.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../fakes/fake_auth_gateway.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/fake_identifier_generator.dart';
import '../../fakes/fake_remote_document_store.dart';
import '../../fakes/fake_remote_progress_store.dart';
import '../../fakes/in_memory_document_repository.dart';

final class _ProgressTestDevice {
  final Database db;
  final SqliteLocalProgressStore localStore;
  final SqliteProgressSyncStore syncStore;
  final SyncDrainer drainer;

  _ProgressTestDevice({
    required this.db,
    required this.localStore,
    required this.syncStore,
    required this.drainer,
  });

  static Future<_ProgressTestDevice> create({
    required FakeRemoteDocumentStore remoteDocStore,
    required FakeRemoteProgressStore remoteProgressStore,
    required String userId,
    required FakeClock clock,
    required FakeIdentifierGenerator identifiers,
  }) async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await IndexSchema.createAllTables(db);
    final metadataStore = SyncMetadataStore(db);
    final queue = SqliteSyncQueue(db);
    final fileRepo = InMemoryDocumentRepository();
    final localStore = SqliteLocalProgressStore(db);
    final syncStore = SqliteProgressSyncStore(db);
    final authGateway = FakeAuthGateway(
      currentSession: AccountSession(
        userId: userId,
        email: '$userId@test.com',
        provider: AuthMethod.apple,
      ),
    );
    final drainer = SyncDrainer(
      authGateway: authGateway,
      remoteStore: remoteDocStore,
      remoteProgressStore: remoteProgressStore,
      progressSyncStore: syncStore,
      queue: queue,
      metadataStore: metadataStore,
      repository: fileRepo,
      identifiers: identifiers,
      clock: clock,
    );

    return _ProgressTestDevice(
      db: db,
      localStore: localStore,
      syncStore: syncStore,
      drainer: drainer,
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

  group('Multi-Device Progress Synchronization (D4 Monotonic Union)', () {
    late FakeRemoteDocumentStore remoteDocStore;
    late FakeRemoteProgressStore remoteProgressStore;
    late FakeClock clock;
    late FakeIdentifierGenerator identifiers;
    late _ProgressTestDevice deviceA;
    late _ProgressTestDevice deviceB;

    setUp(() async {
      remoteDocStore = FakeRemoteDocumentStore(activeUserId: 'user-1');
      remoteProgressStore = FakeRemoteProgressStore(activeUserId: 'user-1');
      clock = FakeClock(DateTime(2026, 9, 1, 10, 0));
      identifiers = FakeIdentifierGenerator();

      deviceA = await _ProgressTestDevice.create(
        remoteDocStore: remoteDocStore,
        remoteProgressStore: remoteProgressStore,
        userId: 'user-1',
        clock: clock,
        identifiers: identifiers,
      );

      deviceB = await _ProgressTestDevice.create(
        remoteDocStore: remoteDocStore,
        remoteProgressStore: remoteProgressStore,
        userId: 'user-1',
        clock: clock,
        identifiers: identifiers,
      );
    });

    tearDown(() async {
      await deviceA.dispose();
      await deviceB.dispose();
    });

    test(
        'mandatory test 1: applying the same progress batch twice is idempotent',
        () async {
      final t1 = DateTime(2026, 9, 1, 10, 0);
      final batch = [
        ProgressEntry(
          contentId: 'mod-idempotent',
          visited: true,
          completed: false,
          firstVisitedAt: t1,
        ),
      ];

      final res1 = await remoteProgressStore.pushProgress(batch);
      final res2 = await remoteProgressStore.pushProgress(batch);

      expect(res1, isA<dynamic>());
      expect(res2, isA<dynamic>());

      final remoteEntries = remoteProgressStore.activeUserEntries;
      expect(remoteEntries.length, equals(1));
      expect(remoteEntries.first.contentId, equals('mod-idempotent'));
      expect(remoteEntries.first.visited, isTrue);
      expect(remoteEntries.first.completed, isFalse);
      expect(remoteEntries.first.firstVisitedAt, equals(t1));

      await deviceA.localStore.markModuleVisited('mod-local');
      final outcome1 = await deviceA.drainer.drain();
      final outcome2 = await deviceA.drainer.drain();

      expect(outcome1, equals(SyncDrainOutcome.success));
      expect(outcome2, equals(SyncDrainOutcome.success));

      final dirty = await deviceA.syncStore.readDirtyProgress();
      expect(dirty, isEmpty);
    });

    test(
        'mandatory test 2: progress on two distinct devices converges to true/true without intervention',
        () async {
      await deviceA.localStore.markModuleVisited('con-a1');
      await deviceA.localStore.markExerciseCompleted('con-a1');

      await deviceB.localStore.markModuleVisited('con-a1');

      final outcomeA1 = await deviceA.drainer.drain();
      expect(outcomeA1, equals(SyncDrainOutcome.success));

      final outcomeB1 = await deviceB.drainer.drain();
      expect(outcomeB1, equals(SyncDrainOutcome.success));

      final outcomeA2 = await deviceA.drainer.drain();
      expect(outcomeA2, equals(SyncDrainOutcome.success));

      final progressA = await deviceA.localStore.readProgress();
      final progressB = await deviceB.localStore.readProgress();

      expect(progressA.isModuleVisited('con-a1'), isTrue);
      expect(progressA.isExerciseCompleted('con-a1'), isTrue);

      expect(progressB.isModuleVisited('con-a1'), isTrue);
      expect(progressB.isExerciseCompleted('con-a1'), isTrue);

      expect(await deviceA.syncStore.readDirtyProgress(), isEmpty);
      expect(await deviceB.syncStore.readDirtyProgress(), isEmpty);
    });

    test(
        'disjoint progress across devices converges so both hold the complete union',
        () async {
      await deviceA.localStore.markExerciseCompleted('ex-from-device-a');
      await deviceB.localStore.markExerciseCompleted('ex-from-device-b');

      await deviceA.drainer.drain();
      await deviceB.drainer.drain();
      await deviceA.drainer.drain();

      final progressA = await deviceA.localStore.readProgress();
      final progressB = await deviceB.localStore.readProgress();

      expect(progressA.isExerciseCompleted('ex-from-device-a'), isTrue);
      expect(progressA.isExerciseCompleted('ex-from-device-b'), isTrue);

      expect(progressB.isExerciseCompleted('ex-from-device-a'), isTrue);
      expect(progressB.isExerciseCompleted('ex-from-device-b'), isTrue);
    });
  });
}
