import 'package:pseudolearn_app/domain/model/progress/merge_progress.dart';
import 'package:pseudolearn_app/domain/model/progress/progress_entry.dart';
import 'package:pseudolearn_app/domain/ports/progress_sync_store.dart';

final class FakeProgressSyncStore implements ProgressSyncStore {
  final Map<String, ({ProgressEntry entry, bool dirty})> entries = {};

  void seedEntry(ProgressEntry entry, {bool dirty = false}) {
    entries[entry.contentId] = (entry: entry, dirty: dirty);
  }

  @override
  Future<List<ProgressEntry>> readDirtyProgress() async {
    return entries.values
        .where((record) => record.dirty)
        .map((record) => record.entry)
        .toList();
  }

  @override
  Future<void> markClean(List<String> contentIds) async {
    for (final id in contentIds) {
      final existing = entries[id];
      if (existing != null) {
        entries[id] = (entry: existing.entry, dirty: false);
      }
    }
  }

  @override
  Future<void> mergeRemoteProgress(List<ProgressEntry> remoteEntries) async {
    for (final remote in remoteEntries) {
      final existing = entries[remote.contentId];
      final merged = mergeProgress(local: existing?.entry, remote: remote);
      entries[remote.contentId] = (
        entry: merged,
        dirty: existing?.dirty ?? false,
      );
    }
  }
}
