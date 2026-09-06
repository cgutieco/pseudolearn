import '../../domain/model/progress/progress_entry.dart';
import '../../domain/model/progress/pull_progress_result.dart';
import '../../domain/model/progress/push_progress_result.dart';
import '../../domain/ports/progress_sync_store.dart';
import '../../domain/ports/remote_progress_store.dart';
import 'sync_metadata_store.dart';

final class ProgressSyncDrainer {
  final RemoteProgressStore _remoteStore;
  final ProgressSyncStore _syncStore;
  final SyncMetadataStore _metadataStore;

  const ProgressSyncDrainer({
    required RemoteProgressStore remoteStore,
    required ProgressSyncStore syncStore,
    required SyncMetadataStore metadataStore,
  })  : _remoteStore = remoteStore,
        _syncStore = syncStore,
        _metadataStore = metadataStore;

  Future<bool> drainPull() async {
    final state = await _metadataStore.getGlobalState();
    final pullResult =
        await _remoteStore.pullProgressSince(state.progressCursor);

    return switch (pullResult) {
      PullProgressFailure() => false,
      PullProgressSuccess(:final entries, :final nextCursor) =>
        await _applyPulledProgress(entries, nextCursor),
    };
  }

  Future<bool> drainPush() async {
    final dirty = await _syncStore.readDirtyProgress();
    if (dirty.isEmpty) return true;

    final result = await _remoteStore.pushProgress(dirty);
    return switch (result) {
      PushProgressSuccess() => await _onPushSuccess(dirty),
      PushProgressFailure() => false,
    };
  }

  Future<bool> _applyPulledProgress(
    List<ProgressEntry> entries,
    int nextCursor,
  ) async {
    await _syncStore.mergeRemoteProgress(entries);
    await _metadataStore.setGlobalState(progressCursor: nextCursor);
    return true;
  }

  Future<bool> _onPushSuccess(List<ProgressEntry> dirty) async {
    final ids = dirty.map((e) => e.contentId).toList();
    await _syncStore.markClean(ids);
    return true;
  }
}
