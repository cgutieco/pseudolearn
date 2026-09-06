import '../model/progress/progress_entry.dart';
import '../model/progress/pull_progress_result.dart';
import '../model/progress/push_progress_result.dart';

abstract interface class RemoteProgressStore {
  Future<PushProgressResult> pushProgress(List<ProgressEntry> entries);
  Future<PullProgressResult> pullProgressSince(int cursor);
}
