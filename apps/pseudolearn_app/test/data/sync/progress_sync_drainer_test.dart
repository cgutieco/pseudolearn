import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/sync/progress_sync_drainer.dart';
import 'package:pseudolearn_app/data/sync/sync_metadata_store.dart';
import 'package:pseudolearn_app/domain/model/progress/progress_entry.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../fakes/fake_progress_sync_store.dart';
import '../../fakes/fake_remote_progress_store.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('ProgressSyncDrainer', () {
    late Database db;
    late SyncMetadataStore metadataStore;
    late FakeRemoteProgressStore remoteStore;
    late FakeProgressSyncStore syncStore;
    late ProgressSyncDrainer drainer;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await IndexSchema.createAllTables(db);
      metadataStore = SyncMetadataStore(db);
      remoteStore = FakeRemoteProgressStore();
      syncStore = FakeProgressSyncStore();
      drainer = ProgressSyncDrainer(
        remoteStore: remoteStore,
        syncStore: syncStore,
        metadataStore: metadataStore,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('drainPull adopts remote progress and advances progress_cursor', () async {
      final t1 = DateTime(2026, 9, 1, 10, 0);
      final remoteEntry = ProgressEntry(
        contentId: 'mod-rem',
        visited: true,
        completed: false,
        firstVisitedAt: t1,
      );
      await remoteStore.pushProgress([remoteEntry]);

      final success = await drainer.drainPull();
      expect(success, isTrue);

      final state = await metadataStore.getGlobalState();
      expect(state.progressCursor, equals(1));

      final localRecord = syncStore.entries['mod-rem'];
      expect(localRecord, isNotNull);
      expect(localRecord!.entry.visited, isTrue);
      expect(localRecord.dirty, isFalse);
    });

    test('drainPull returns false when remote pull fails', () async {
      remoteStore.shouldFailPull = true;

      final success = await drainer.drainPull();
      expect(success, isFalse);
    });

    test('drainPush pushes dirty progress and marks clean on success', () async {
      final t1 = DateTime(2026, 9, 1, 10, 0);
      final dirtyEntry = ProgressEntry(
        contentId: 'mod-loc',
        visited: true,
        completed: true,
        firstVisitedAt: t1,
        firstCompletedAt: t1,
      );
      syncStore.seedEntry(dirtyEntry, dirty: true);

      final success = await drainer.drainPush();
      expect(success, isTrue);

      final localRecord = syncStore.entries['mod-loc'];
      expect(localRecord!.dirty, isFalse);

      final remoteEntries = remoteStore.activeUserEntries;
      expect(remoteEntries.length, equals(1));
      expect(remoteEntries.first.contentId, equals('mod-loc'));
    });

    test('drainPush returns false and does not clear dirty on remote failure', () async {
      remoteStore.shouldFailPush = true;
      const dirtyEntry = ProgressEntry(
        contentId: 'mod-fail',
        visited: true,
        completed: false,
      );
      syncStore.seedEntry(dirtyEntry, dirty: true);

      final success = await drainer.drainPush();
      expect(success, isFalse);

      final localRecord = syncStore.entries['mod-fail'];
      expect(localRecord!.dirty, isTrue);
    });

    test('drainPush succeeds as a no-op when there are no dirty entries', () async {
      final success = await drainer.drainPush();
      expect(success, isTrue);
      expect(remoteStore.activeUserEntries, isEmpty);
    });
  });
}
