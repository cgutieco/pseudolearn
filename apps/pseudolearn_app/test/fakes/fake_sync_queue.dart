import 'package:pseudolearn_app/domain/model/sync/outbox_entry.dart';
import 'package:pseudolearn_app/domain/ports/sync_queue.dart';

final class FakeSyncQueue implements SyncQueue {
  final List<OutboxEntry> _entries = [];

  @override
  Future<void> enqueue(OutboxEntry entry) async {
    _entries.removeWhere((e) => e.entityId == entry.entityId);
    _entries.add(entry);
  }

  @override
  Future<List<OutboxEntry>> pendingEntries({int limit = 50}) async {
    return _entries.take(limit).toList();
  }

  @override
  Future<void> markSent(String entryId) async {
    _entries.removeWhere((e) => e.entryId == entryId);
  }

  @override
  Future<void> markFailed(String entryId, String error) async {
    final index = _entries.indexWhere((e) => e.entryId == entryId);
    if (index >= 0) {
      final old = _entries[index];
      _entries[index] = old.copyWith(
        attempts: old.attempts + 1,
        lastError: error,
      );
    }
  }

  List<OutboxEntry> get entries => List.unmodifiable(_entries);
}
