sealed class SyncState {
  final DateTime? lastSyncAt;
  final int pendingCount;
  final int conflictCount;

  const SyncState({
    this.lastSyncAt,
    this.pendingCount = 0,
    this.conflictCount = 0,
  });
}

final class SyncIdle extends SyncState {
  const SyncIdle({
    super.lastSyncAt,
    super.pendingCount,
    super.conflictCount,
  });
}

final class SyncInProgress extends SyncState {
  const SyncInProgress({
    super.lastSyncAt,
    super.pendingCount,
    super.conflictCount,
  });
}

final class SyncConflictDetected extends SyncState {
  const SyncConflictDetected({
    required super.conflictCount,
    super.lastSyncAt,
    super.pendingCount,
  });
}

final class SyncError extends SyncState {
  final String message;

  const SyncError({
    required this.message,
    super.lastSyncAt,
    super.pendingCount,
    super.conflictCount,
  });
}
