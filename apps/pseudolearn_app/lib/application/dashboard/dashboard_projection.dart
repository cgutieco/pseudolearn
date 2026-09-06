import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../domain/model/knowledge/learning_track.dart';
import '../../domain/model/progress/progress_entry.dart';
import '../sync/conflict_projection.dart';
import 'activity_projection.dart';
import 'concept_usage_projection.dart';
import 'dashboard_inputs.dart';
import 'dashboard_state.dart';
import 'exercise_coverage_projection.dart';
import 'library_metrics_projection.dart';
import 'next_module_projection.dart';
import 'specification_coverage_projection.dart';
import 'sync_health_projection.dart';
import 'track_coverage_projection.dart';

final class DashboardProjection {
  final ConflictProjection _conflicts;

  const DashboardProjection({
    ConflictProjection conflicts = const ConflictProjection(),
  }) : _conflicts = conflicts;

  DashboardState project(DashboardInputs inputs) {
    final modules = _entriesOfType(inputs.entries, KnowledgeEntryType.module);
    final exercises = _entriesOfType(inputs.entries, KnowledgeEntryType.exercise);
    final sections =
        _entriesOfType(inputs.entries, KnowledgeEntryType.specificationSection);
    final visitedIds = _visitedIds(inputs.progress);
    final exercised = exercisedConstructsOf(inputs.constructsByDocument);

    return DashboardState(
      status: DashboardStatus.success,
      library: projectLibraryMetrics(inputs.documents),
      route: projectTrackCoverage(modules: modules, visitedIds: visitedIds),
      exercises: projectExerciseCoverage(
        exercises: exercises,
        trackByModuleId: _tracksOf(modules),
        completedIds: _completedIds(inputs.progress),
      ),
      nextModule: projectNextModule(modules: modules, visitedIds: visitedIds),
      sync: projectSyncHealth(
        pending: inputs.pending,
        conflictCount: _conflicts.countConflicts(inputs.documents),
        now: inputs.now,
      ),
      concepts: projectConceptUsage(inputs.constructsByDocument),
      specification: projectSpecificationCoverage(
        sections: sections,
        exercisedConstructs: exercised,
      ),
      activity: projectActivityWeeks(
        progress: inputs.progress,
        moduleIds: _idsOf(modules),
        documents: inputs.documents,
        now: inputs.now,
      ),
    );
  }

  List<KnowledgeEntry> _entriesOfType(
    List<KnowledgeEntry> entries,
    KnowledgeEntryType type,
  ) {
    return entries.where((entry) => entry.type == type).toList();
  }

  Map<String, LearningTrack> _tracksOf(List<KnowledgeEntry> modules) {
    final tracks = <String, LearningTrack>{};
    for (final module in modules) {
      final track = module.track;
      if (track != null) tracks[module.id] = track;
    }
    return tracks;
  }

  Set<String> _idsOf(List<KnowledgeEntry> entries) =>
      entries.map((entry) => entry.id).toSet();

  Set<String> _visitedIds(List<ProgressEntry> progress) => progress
      .where((entry) => entry.visited)
      .map((entry) => entry.contentId)
      .toSet();

  Set<String> _completedIds(List<ProgressEntry> progress) => progress
      .where((entry) => entry.completed)
      .map((entry) => entry.contentId)
      .toSet();
}
