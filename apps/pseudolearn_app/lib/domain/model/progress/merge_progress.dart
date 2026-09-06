import 'progress_entry.dart';

ProgressEntry mergeProgress({
  required ProgressEntry? local,
  required ProgressEntry remote,
}) {
  if (local == null) return remote;

  return ProgressEntry(
    contentId: remote.contentId,
    visited: local.visited || remote.visited,
    completed: local.completed || remote.completed,
    firstVisitedAt: _earliest(local.firstVisitedAt, remote.firstVisitedAt),
    firstCompletedAt: _earliest(local.firstCompletedAt, remote.firstCompletedAt),
  );
}

DateTime? _earliest(DateTime? a, DateTime? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.isBefore(b) ? a : b;
}
