import '../model/progress/progress_entry.dart';

abstract interface class ProgressSyncStore {
  Future<List<ProgressEntry>> readDirtyProgress();
  Future<void> markClean(List<String> contentIds);
  Future<void> mergeRemoteProgress(List<ProgressEntry> entries);
}
