import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/sync/document_snapshot.dart';
import 'package:pseudolearn_app/domain/model/sync/reconcile_document.dart';
import 'package:pseudolearn_app/domain/model/sync/reconciliation_outcome.dart';

void main() {
  DocumentSnapshot createSnapshot({
    String id = 'doc-1',
    int revision = 1,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String title = 'Algoritmo',
    String content = 'algoritmo Test fin',
    SyntaxProfileId profileId = SyntaxProfileId.classicSpanish,
    String? exerciseId,
  }) {
    return DocumentSnapshot(
      id: id,
      revision: revision,
      updatedAt: updatedAt ?? DateTime(2026, 8, 15, 10, 0),
      deletedAt: deletedAt,
      title: title,
      content: content,
      profileId: profileId,
      exerciseId: exerciseId,
    );
  }

  group('reconcileDocument', () {
    test('only local changed yields PushLocal', () {
      final local = createSnapshot(revision: 2, content: 'local edits');
      final remote = createSnapshot(revision: 1);

      final outcome = reconcileDocument(
        local: local,
        remote: remote,
        lastSyncedRevision: 1,
      );

      expect(outcome, isA<PushLocal>());
    });

    test('only remote changed yields AdoptRemote', () {
      final local = createSnapshot(revision: 1);
      final remote = createSnapshot(revision: 2, content: 'remote edits');

      final outcome = reconcileDocument(
        local: local,
        remote: remote,
        lastSyncedRevision: 1,
      );

      expect(outcome, isA<AdoptRemote>());
    });

    test('both changed (edit/edit) yields KeepBoth with local as loser', () {
      final local = createSnapshot(revision: 2, content: 'local concurrent edit');
      final remote = createSnapshot(revision: 2, content: 'remote concurrent edit');

      final outcome = reconcileDocument(
        local: local,
        remote: remote,
        lastSyncedRevision: 1,
      );

      expect(outcome, isA<KeepBoth>());
      expect((outcome as KeepBoth).loser, same(local));
    });

    test('local edited and remote with tombstone yields KeepBoth (local edit survives)', () {
      final local = createSnapshot(revision: 2, content: 'local surviving edits');
      final remote = createSnapshot(
        revision: 2,
        deletedAt: DateTime(2026, 8, 15, 11, 0),
      );

      final outcome = reconcileDocument(
        local: local,
        remote: remote,
        lastSyncedRevision: 1,
      );

      expect(outcome, isA<KeepBoth>());
      expect((outcome as KeepBoth).loser, same(local));
    });

    test('local unchanged and remote with tombstone yields AdoptRemote (local deleted)', () {
      final local = createSnapshot(revision: 1);
      final remote = createSnapshot(
        revision: 2,
        deletedAt: DateTime(2026, 8, 15, 11, 0),
      );

      final outcome = reconcileDocument(
        local: local,
        remote: remote,
        lastSyncedRevision: 1,
      );

      expect(outcome, isA<AdoptRemote>());
    });

    test('local with tombstone and remote edited yields KeepBoth (remote edit survives)', () {
      final local = createSnapshot(
        revision: 2,
        deletedAt: DateTime(2026, 8, 15, 11, 0),
      );
      final remote = createSnapshot(revision: 2, content: 'remote edit survives');

      final outcome = reconcileDocument(
        local: local,
        remote: remote,
        lastSyncedRevision: 1,
      );

      expect(outcome, isA<KeepBoth>());
      expect((outcome as KeepBoth).loser, same(local));
    });

    test('both with tombstone yields NoChange', () {
      final local = createSnapshot(
        revision: 2,
        deletedAt: DateTime(2026, 8, 15, 11, 0),
      );
      final remote = createSnapshot(
        revision: 3,
        deletedAt: DateTime(2026, 8, 15, 12, 0),
      );

      final outcome = reconcileDocument(
        local: local,
        remote: remote,
        lastSyncedRevision: 1,
      );

      expect(outcome, isA<NoChange>());
    });

    test('document never synced and only exists locally yields PushLocal', () {
      final local = createSnapshot(revision: 1);

      final outcome = reconcileDocument(
        local: local,
        remote: null,
        lastSyncedRevision: null,
      );

      expect(outcome, isA<PushLocal>());
    });

    test('document never synced and only exists remotely yields AdoptRemote', () {
      final remote = createSnapshot(revision: 1);

      final outcome = reconcileDocument(
        local: null,
        remote: remote,
        lastSyncedRevision: null,
      );

      expect(outcome, isA<AdoptRemote>());
    });

    test('false conflict: identical payload with different revisions yields NoChange', () {
      final local = createSnapshot(
        revision: 2,
        content: 'identical content',
        title: 'Title',
      );
      final remote = createSnapshot(
        revision: 3,
        content: 'identical content',
        title: 'Title',
      );

      final outcome = reconcileDocument(
        local: local,
        remote: remote,
        lastSyncedRevision: 1,
      );

      expect(outcome, isA<NoChange>());
    });

    test('edge case: neither local nor remote exists yields NoChange', () {
      final outcome = reconcileDocument(
        local: null,
        remote: null,
        lastSyncedRevision: null,
      );

      expect(outcome, isA<NoChange>());
    });

    test('edge case: neither local nor remote changed yields NoChange', () {
      final local = createSnapshot(revision: 1);
      final remote = createSnapshot(revision: 1);

      final outcome = reconcileDocument(
        local: local,
        remote: remote,
        lastSyncedRevision: 1,
      );

      expect(outcome, isA<NoChange>());
    });

    test('edge case: never synced with identical payload yields NoChange', () {
      final local = createSnapshot(revision: 1, content: 'same');
      final remote = createSnapshot(revision: 2, content: 'same');

      final outcome = reconcileDocument(
        local: local,
        remote: remote,
        lastSyncedRevision: null,
      );

      expect(outcome, isA<NoChange>());
    });

    test('edge case: never synced with different payload yields KeepBoth', () {
      final local = createSnapshot(revision: 1, content: 'local');
      final remote = createSnapshot(revision: 1, content: 'remote');

      final outcome = reconcileDocument(
        local: local,
        remote: remote,
        lastSyncedRevision: null,
      );

      expect(outcome, isA<KeepBoth>());
      expect((outcome as KeepBoth).loser, same(local));
    });

    test('edge case: local null when synced, remote tombstone yields NoChange', () {
      final remote = createSnapshot(
        revision: 2,
        deletedAt: DateTime.now(),
      );

      final outcome = reconcileDocument(
        local: null,
        remote: remote,
        lastSyncedRevision: 1,
      );

      expect(outcome, isA<NoChange>());
    });

    test('edge case: remote null when synced, local changed yields PushLocal', () {
      final local = createSnapshot(revision: 2);

      final outcome = reconcileDocument(
        local: local,
        remote: null,
        lastSyncedRevision: 1,
      );

      expect(outcome, isA<PushLocal>());
    });
  });
}
