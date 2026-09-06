import '../../domain/model/dashboard/coverage_count.dart';
import '../../domain/model/dashboard/exercise_coverage.dart';
import '../../domain/model/knowledge/exercise_kind.dart';
import '../../domain/model/knowledge/exercise_level.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/learning_track.dart';

ExerciseCoverage projectExerciseCoverage({
  required List<KnowledgeEntry> exercises,
  required Map<String, LearningTrack> trackByModuleId,
  required Set<String> completedIds,
}) {
  final byTrack = <LearningTrack, CoverageCount>{};
  final byLevel = <ExerciseLevel, CoverageCount>{};
  final byKind = <ExerciseKind, CoverageCount>{};

  for (final exercise in exercises) {
    final isDone = completedIds.contains(exercise.id);
    final track = trackByModuleId[exercise.moduleId];
    if (track != null) _accumulate(byTrack, track, isDone);
    final level = exercise.level;
    if (level != null) _accumulate(byLevel, level, isDone);
    final kind = exercise.kind;
    if (kind != null) _accumulate(byKind, kind, isDone);
  }

  final done = exercises.where((e) => completedIds.contains(e.id)).length;
  return ExerciseCoverage(
    overall: CoverageCount(done: done, total: exercises.length),
    byTrack: byTrack,
    byLevel: byLevel,
    byKind: byKind,
  );
}

void _accumulate<K>(Map<K, CoverageCount> counts, K key, bool isDone) {
  final current = counts[key] ?? const CoverageCount.empty();
  counts[key] = CoverageCount(
    done: current.done + (isDone ? 1 : 0),
    total: current.total + 1,
  );
}
