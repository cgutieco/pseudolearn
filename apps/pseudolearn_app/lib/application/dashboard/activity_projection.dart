import '../../domain/model/dashboard/activity_timeline.dart';
import '../../domain/model/dashboard/activity_week.dart';
import '../../domain/model/dashboard/week_start.dart';
import '../../domain/model/documents/document.dart';
import '../../domain/model/progress/progress_entry.dart';

const int defaultActivityWeeks = 8;

final class _WeekTally {
  int modulesVisited = 0;
  int exercisesCompleted = 0;
  int documentsCreated = 0;
}

ActivityTimeline projectActivityWeeks({
  required List<ProgressEntry> progress,
  required Set<String> moduleIds,
  required List<DocumentSummary> documents,
  required DateTime now,
  int weeks = defaultActivityWeeks,
}) {
  final buckets = _emptyBuckets(now: now, weeks: weeks);
  final firstWeek = buckets.keys.first;

  for (final entry in progress) {
    _tallyProgress(buckets, firstWeek, entry, moduleIds: moduleIds);
  }
  for (final document in documents) {
    final tally = _bucketFor(buckets, firstWeek, document.createdAt);
    if (tally != null) tally.documentsCreated++;
  }

  return ActivityTimeline.of([
    for (final bucket in buckets.entries)
      ActivityWeek(
        weekStart: bucket.key,
        modulesVisited: bucket.value.modulesVisited,
        exercisesCompleted: bucket.value.exercisesCompleted,
        documentsCreated: bucket.value.documentsCreated,
      ),
  ]);
}

Map<DateTime, _WeekTally> _emptyBuckets({
  required DateTime now,
  required int weeks,
}) {
  final current = weekStartOf(now);
  final buckets = <DateTime, _WeekTally>{};
  for (var index = weeks - 1; index >= 0; index--) {
    buckets[current.subtract(Duration(days: 7 * index))] = _WeekTally();
  }
  return buckets;
}

void _tallyProgress(
  Map<DateTime, _WeekTally> buckets,
  DateTime firstWeek,
  ProgressEntry entry, {
  required Set<String> moduleIds,
}) {
  final visitedAt = entry.firstVisitedAt;
  if (visitedAt != null && moduleIds.contains(entry.contentId)) {
    _bucketFor(buckets, firstWeek, visitedAt)?.modulesVisited++;
  }
  final completedAt = entry.firstCompletedAt;
  if (completedAt != null) {
    _bucketFor(buckets, firstWeek, completedAt)?.exercisesCompleted++;
  }
}

_WeekTally? _bucketFor(
  Map<DateTime, _WeekTally> buckets,
  DateTime firstWeek,
  DateTime moment,
) {
  final week = weekStartOf(moment);
  if (week.isBefore(firstWeek)) return null;
  return buckets[week];
}
