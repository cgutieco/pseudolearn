import '../../domain/model/documents/document.dart';
import '../../domain/model/documents/document_title_policy.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/sync/document_snapshot.dart';
import '../../domain/model/sync/outbox_entry.dart';
import '../../domain/model/sync/pull_batch_result.dart';
import '../../domain/model/sync/push_batch_result.dart';
import '../../domain/model/sync/reconcile_document.dart';
import '../../domain/model/sync/reconciliation_outcome.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/document_repository.dart';
import '../../domain/ports/identifier_generator.dart';
import '../../domain/ports/remote_document_store.dart';
import '../../domain/ports/sync_queue.dart';
import 'sync_metadata_store.dart';

final class DocumentSyncDrainer {
  final RemoteDocumentStore _remoteStore;
  final SyncQueue _queue;
  final SyncMetadataStore _metadataStore;
  final DocumentRepository _repository;
  final IdentifierGenerator _identifiers;
  final Clock _clock;

  const DocumentSyncDrainer({
    required RemoteDocumentStore remoteStore,
    required SyncQueue queue,
    required SyncMetadataStore metadataStore,
    required DocumentRepository repository,
    required IdentifierGenerator identifiers,
    required Clock clock,
  })  : _remoteStore = remoteStore,
        _queue = queue,
        _metadataStore = metadataStore,
        _repository = repository,
        _identifiers = identifiers,
        _clock = clock;

  Future<bool> drainPull() async {
    final state = await _metadataStore.getGlobalState();
    final pullResult = await _remoteStore.pullChangesSince(state.cursor);

    return switch (pullResult) {
      PullBatchFailure() => false,
      PullBatchSuccess(:final documents, :final nextCursor) =>
        await _applyPulledDocuments(documents, nextCursor),
    };
  }

  Future<bool> drainPush() async {
    final entries = await _queue.pendingEntries();
    if (entries.isEmpty) return true;

    final batch = <DocumentSnapshot>[];
    for (final entry in entries) {
      final snapshot = await _buildSnapshotForEntry(entry);
      if (snapshot != null) batch.add(snapshot);
    }
    if (batch.isEmpty) return true;

    final result = await _remoteStore.pushDocuments(batch);
    return switch (result) {
      PushBatchSuccess(:final serverRevision) =>
        await _onPushSuccess(entries, batch, serverRevision),
      PushBatchFailure(:final error) => await _onPushFailure(entries, error),
    };
  }

  Future<bool> _applyPulledDocuments(
    List<DocumentSnapshot> documents,
    int nextCursor,
  ) async {
    for (final remote in documents) {
      final local = await _repository.loadDocument(remote.id);
      final revisions = await _metadataStore.getDocumentRevisions(remote.id);
      final localSnapshot =
          local != null ? DocumentSnapshot.fromDocument(local) : null;

      final outcome = reconcileDocument(
        local: localSnapshot,
        remote: remote,
        lastSyncedRevision: revisions?.lastSyncedRevision,
      );

      await _applyReconciliation(remote, local, outcome);
    }
    await _metadataStore.setGlobalState(cursor: nextCursor);
    return true;
  }

  Future<void> _applyReconciliation(
    DocumentSnapshot remote,
    Document? local,
    ReconciliationOutcome outcome,
  ) async {
    switch (outcome) {
      case NoChange():
        await _metadataStore.updateDocumentRevisions(
          remote.id,
          serverRevision: remote.revision,
          lastSyncedRevision: remote.revision,
        );
      case PushLocal():
        break;
      case AdoptRemote():
        await _adoptRemote(remote);
      case KeepBoth(:final loser):
        await _handleConflict(remote, loser);
    }
  }

  Future<void> _adoptRemote(DocumentSnapshot remote) async {
    if (remote.isDeleted) {
      await _repository.deleteDocument(remote.id);
    } else {
      final adopted = Document(
        id: remote.id,
        title: remote.title,
        content: remote.content,
        profileId: remote.profileId,
        revision: remote.revision,
        createdAt: remote.updatedAt,
        updatedAt: remote.updatedAt,
        exerciseId: remote.exerciseId,
      );
      await _repository.saveDocument(adopted);
    }
    await _metadataStore.updateDocumentRevisions(
      remote.id,
      serverRevision: remote.revision,
      lastSyncedRevision: remote.revision,
    );
  }

  Future<void> _handleConflict(
    DocumentSnapshot remote,
    DocumentSnapshot loser,
  ) async {
    final summaries = await _repository.listDocuments();
    final existingTitles = summaries.map((d) => d.title);
    final conflictTitle = suggestNextDocumentTitle(
      '${loser.title} (conflicto)',
      existingTitles,
    );

    final conflictId = _identifiers.generate();
    final conflictCopy = Document(
      id: conflictId,
      title: conflictTitle,
      content: loser.content,
      profileId: loser.profileId,
      revision: 1,
      createdAt: _clock.now(),
      updatedAt: _clock.now(),
      exerciseId: loser.exerciseId,
    );

    await _repository.saveDocument(conflictCopy);
    await _queue.enqueue(OutboxEntry(
      entryId: _identifiers.generate(),
      entityType: 'document',
      entityId: conflictId,
      operation: 'upsert',
      enqueuedAt: _clock.now(),
    ));

    await _adoptRemote(remote);
  }

  Future<DocumentSnapshot?> _buildSnapshotForEntry(OutboxEntry entry) async {
    if (entry.operation == 'delete') {
      return DocumentSnapshot(
        id: entry.entityId,
        revision: 0,
        updatedAt: _clock.now(),
        deletedAt: _clock.now(),
        content: '',
        title: '',
        profileId: SyntaxProfileId.classicSpanish,
      );
    }
    final doc = await _repository.loadDocument(entry.entityId);
    return doc != null ? DocumentSnapshot.fromDocument(doc) : null;
  }

  Future<bool> _onPushSuccess(
    List<OutboxEntry> entries,
    List<DocumentSnapshot> batch,
    int serverRevision,
  ) async {
    for (final doc in batch) {
      await _metadataStore.updateDocumentRevisions(
        doc.id,
        serverRevision: serverRevision,
        lastSyncedRevision: serverRevision,
      );
    }
    for (final entry in entries) {
      await _queue.markSent(entry.entryId);
    }
    return true;
  }

  Future<bool> _onPushFailure(List<OutboxEntry> entries, String error) async {
    for (final entry in entries) {
      await _queue.markFailed(entry.entryId, error);
    }
    return false;
  }
}
