import '../../domain/model/route/route_kinds.dart';
import '../sync/conflict_projection.dart';
import 'activity_projection.dart';
import 'concept_usage_projection.dart';
import 'dashboard_inputs.dart';
import 'dashboard_state.dart';
import 'exercise_coverage_projection.dart';
import 'library_metrics_projection.dart';
import 'route_coverage_projection.dart';
import 'specification_coverage_projection.dart';
import 'sync_health_projection.dart';

final class DashboardProjection {
  final ConflictProjection _conflicts;

  const DashboardProjection({
    ConflictProjection conflicts = const ConflictProjection(),
  }) : _conflicts = conflicts;

  DashboardState project(DashboardInputs inputs) {
    final progress = inputs.contentProgress;
    final exercised = exercisedConstructsOf(inputs.constructsByDocument);
    return DashboardState(
      status: DashboardStatus.success,
      library: projectLibraryMetrics(inputs.documents),
      route: projectPartCoverage(toc: inputs.toc, progress: progress),
      exercises: projectExerciseCoverage(toc: inputs.toc, progress: progress),
      nextLesson: projectNextLesson(toc: inputs.toc, progress: progress),
      sync: projectSyncHealth(
        pending: inputs.pending,
        conflictCount: _conflicts.countConflicts(inputs.documents),
        now: inputs.now,
      ),
      concepts: projectConceptUsage(inputs.constructsByDocument),
      specification: projectSpecificationCoverage(
        sections: inputs.specificationSections,
        exercisedConstructs: exercised,
      ),
      activity: projectActivityWeeks(
        progress: inputs.progress,
        moduleIds: {
          for (final lesson in inputs.toc.lessons) routeLessonProgressId(lesson.id),
        },
        documents: inputs.documents,
        now: inputs.now,
      ),
    );
  }
}
