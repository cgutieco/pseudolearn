import '../../domain/model/dashboard/activity_timeline.dart';
import '../../domain/model/dashboard/concept_coverage.dart';
import '../../domain/model/dashboard/coverage_count.dart';
import '../../domain/model/dashboard/exercise_coverage.dart';
import '../../domain/model/dashboard/library_metrics.dart';
import '../../domain/model/dashboard/next_lesson.dart';
import '../../domain/model/dashboard/part_coverage.dart';
import '../../domain/model/dashboard/specification_coverage.dart';
import '../../domain/model/dashboard/sync_health.dart';

enum DashboardStatus { initial, loading, success, error }

final class DashboardState {
  final DashboardStatus status;
  final LibraryMetrics library;
  final List<PartCoverage> route;
  final ExerciseCoverage exercises;
  final NextLesson? nextLesson;
  final SyncHealth sync;
  final ConceptCoverage concepts;
  final SpecificationCoverage specification;
  final ActivityTimeline activity;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.library = const LibraryMetrics.empty(),
    this.route = const [],
    this.exercises = const ExerciseCoverage.empty(),
    this.nextLesson,
    this.sync = const SyncHealth.empty(),
    this.concepts = const ConceptCoverage.empty(),
    this.specification = const SpecificationCoverage.empty(),
    this.activity = const ActivityTimeline.empty(),
    this.errorMessage,
  });

  bool get isReady => status == DashboardStatus.success;

  bool get hasNothingRecorded =>
      library.total == 0 &&
      exercises.overall.done == 0 &&
      _touchedLessons == 0;

  CoverageCount get lessons {
    var done = 0;
    var total = 0;
    for (final part in route) {
      done += part.lessons.done;
      total += part.lessons.total;
    }
    return CoverageCount(done: done, total: total);
  }

  int get _touchedLessons {
    var touched = 0;
    for (final part in route) {
      touched += part.touchedLessons;
    }
    return touched;
  }
}
