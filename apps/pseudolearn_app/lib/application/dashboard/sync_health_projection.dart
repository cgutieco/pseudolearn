import '../../domain/model/dashboard/sync_health.dart';
import '../../domain/model/sync/outbox_entry.dart';

SyncHealth projectSyncHealth({
  required List<OutboxEntry> pending,
  required int conflictCount,
  required DateTime now,
}) {
  return SyncHealth(
    pendingCount: pending.length,
    conflictCount: conflictCount,
    oldestPendingAgeInDays: _oldestAgeInDays(pending, now),
  );
}

int? _oldestAgeInDays(List<OutboxEntry> pending, DateTime now) {
  DateTime? oldest;
  for (final entry in pending) {
    if (oldest == null || entry.enqueuedAt.isBefore(oldest)) {
      oldest = entry.enqueuedAt;
    }
  }
  if (oldest == null) return null;
  final age = now.difference(oldest).inDays;
  return age < 0 ? 0 : age;
}
