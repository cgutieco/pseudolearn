import '../../domain/ports/auth_gateway.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/document_repository.dart';
import '../../domain/ports/identifier_generator.dart';
import '../../domain/ports/progress_sync_store.dart';
import '../../domain/ports/remote_document_store.dart';
import '../../domain/ports/remote_progress_store.dart';
import '../../domain/model/sync/sync_drain_outcome.dart';
import '../../domain/ports/sync_coordinator.dart';
import '../../domain/ports/sync_queue.dart';
import 'document_sync_drainer.dart';
import 'progress_sync_drainer.dart';
import 'sync_metadata_store.dart';

final class SyncDrainer implements SyncCoordinator {
  final AuthGateway _authGateway;
  final DocumentSyncDrainer _documentDrainer;
  final ProgressSyncDrainer? _progressDrainer;
  final SyncMetadataStore _metadataStore;
  final Clock _clock;

  SyncDrainer({
    required AuthGateway authGateway,
    required RemoteDocumentStore remoteStore,
    required SyncQueue queue,
    required SyncMetadataStore metadataStore,
    required DocumentRepository repository,
    required IdentifierGenerator identifiers,
    required Clock clock,
    RemoteProgressStore? remoteProgressStore,
    ProgressSyncStore? progressSyncStore,
  })  : _authGateway = authGateway,
        _metadataStore = metadataStore,
        _clock = clock,
        _documentDrainer = DocumentSyncDrainer(
          remoteStore: remoteStore,
          queue: queue,
          metadataStore: metadataStore,
          repository: repository,
          identifiers: identifiers,
          clock: clock,
        ),
        _progressDrainer =
            (remoteProgressStore != null && progressSyncStore != null)
                ? ProgressSyncDrainer(
                    remoteStore: remoteProgressStore,
                    syncStore: progressSyncStore,
                    metadataStore: metadataStore,
                  )
                : null;

  @override
  Future<SyncDrainOutcome> drain() async {
    final session = await _authGateway.restoreSession();
    if (session == null) return SyncDrainOutcome.unauthenticated;

    final docPullOk = await _documentDrainer.drainPull();
    if (!docPullOk) return SyncDrainOutcome.failure;

    if (_progressDrainer != null) {
      final progressPullOk = await _progressDrainer.drainPull();
      if (!progressPullOk) return SyncDrainOutcome.failure;
    }

    final docPushOk = await _documentDrainer.drainPush();
    if (!docPushOk) return SyncDrainOutcome.failure;

    if (_progressDrainer != null) {
      final progressPushOk = await _progressDrainer.drainPush();
      if (!progressPushOk) return SyncDrainOutcome.failure;
    }

    await _metadataStore.setGlobalState(lastSyncAt: _clock.now());
    return SyncDrainOutcome.success;
  }
}
