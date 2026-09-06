final class SyncHealth {
  final int pendingCount;
  final int conflictCount;
  final int? oldestPendingAgeInDays;

  const SyncHealth({
    required this.pendingCount,
    required this.conflictCount,
    this.oldestPendingAgeInDays,
  });

  const SyncHealth.empty()
      : pendingCount = 0,
        conflictCount = 0,
        oldestPendingAgeInDays = null;

  bool get hasPendingWork => pendingCount > 0;
}
