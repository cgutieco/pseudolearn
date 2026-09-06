import '../../domain/model/dashboard/activity_timeline.dart';
import '../../domain/model/dashboard/concept_coverage.dart';
import '../../domain/model/dashboard/exercise_coverage.dart';
import '../../domain/model/dashboard/library_metrics.dart';
import '../../domain/model/dashboard/next_module.dart';
import '../../domain/model/dashboard/specification_coverage.dart';
import '../../domain/model/dashboard/sync_health.dart';
import '../../domain/model/dashboard/track_coverage.dart';

enum DashboardStatus { initial, loading, success, error }

final class DashboardState {
  final DashboardStatus status;
  final LibraryMetrics library;
  final List<TrackCoverage> route;
  final ExerciseCoverage exercises;
  final NextModule? nextModule;
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
    this.nextModule,
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
      _visitedModules == 0;

  int get _visitedModules {
    var visited = 0;
    for (final track in route) {
      visited += track.modules.done;
    }
    return visited;
  }
}
