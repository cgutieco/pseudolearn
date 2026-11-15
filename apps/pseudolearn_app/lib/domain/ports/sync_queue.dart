import '../model/sync/outbox_entry.dart';

abstract interface class SyncQueue {
  Future<void> enqueue(OutboxEntry entry);
  Future<List<OutboxEntry>> pendingEntries({int limit = 50});
  Future<void> markSent(String entryId);
  Future<void> markFailed(String entryId, String error);
}
