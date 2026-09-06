import 'document_snapshot.dart';
import 'reconciliation_outcome.dart';

ReconciliationOutcome reconcileDocument({
  required DocumentSnapshot? local,
  required DocumentSnapshot? remote,
  required int? lastSyncedRevision,
}) {
  if (local == null && remote == null) return const NoChange();

  if (lastSyncedRevision == null) {
    return _reconcileUnsynced(local, remote);
  }
  if (local == null) {
    return remote!.deletedAt != null ? const NoChange() : const AdoptRemote();
  }
  if (remote == null) {
    return local.revision > lastSyncedRevision ? const PushLocal() : const NoChange();
  }
  return _reconcileBothPresent(local, remote, lastSyncedRevision);
}

ReconciliationOutcome _reconcileUnsynced(
  DocumentSnapshot? local,
  DocumentSnapshot? remote,
) {
  if (local != null && remote == null) return const PushLocal();
  if (local == null && remote != null) return const AdoptRemote();
  if (_hasSamePayload(local!, remote!)) return const NoChange();
  return KeepBoth(loser: local);
}

ReconciliationOutcome _reconcileBothPresent(
  DocumentSnapshot local,
  DocumentSnapshot remote,
  int lastSyncedRevision,
) {
  if (local.deletedAt != null && remote.deletedAt != null) {
    return const NoChange();
  }

  final localChanged = local.revision > lastSyncedRevision;
  final remoteChanged = remote.revision > lastSyncedRevision;

  if (localChanged && remoteChanged) {
    if (_hasSamePayload(local, remote)) return const NoChange();
    return KeepBoth(loser: local);
  }
  if (localChanged) return const PushLocal();
  if (remoteChanged) return const AdoptRemote();
  return const NoChange();
}

bool _hasSamePayload(DocumentSnapshot a, DocumentSnapshot b) {
  return a.content == b.content &&
      a.title == b.title &&
      a.profileId == b.profileId &&
      a.exerciseId == b.exerciseId &&
      (a.deletedAt != null) == (b.deletedAt != null);
}
