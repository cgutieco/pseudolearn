import '../../domain/model/dashboard/coverage_count.dart';
import '../../domain/model/dashboard/exercise_coverage.dart';
import '../../domain/model/knowledge/content_progress.dart';
import '../../domain/model/route/route_kinds.dart';
import '../../domain/model/route/route_toc.dart';
import '../route/route_progress.dart';

ExerciseCoverage projectExerciseCoverage({
  required RouteToc toc,
  required ContentProgress progress,
  Set<String> assistedIds = const {},
}) {
  final route = RouteProgress(progress);
  final byPart = <String, CoverageCount>{};
  final byLevel = <RouteLevel, CoverageCount>{};
  final byKind = <RouteExerciseKind, CoverageCount>{};
  var done = 0;
  var assisted = 0;
  final exercises = toc.exercises;
  for (final exercise in exercises) {
    final isDone = route.isExerciseDone(exercise.id);
    if (isDone) done++;
    if (isDone && assistedIds.contains(routeExerciseProgressId(exercise.id))) assisted++;
    final part = toc.partOf(exercise.lessonId);
    if (part != null) _accumulate(byPart, part.id, isDone);
    _accumulate(byLevel, exercise.level, isDone);
    _accumulate(byKind, exercise.kind, isDone);
  }
  return ExerciseCoverage(
    overall: CoverageCount(done: done, total: exercises.length),
    byPart: byPart,
    byLevel: byLevel,
    byKind: byKind,
    assisted: assisted,
  );
}

void _accumulate<K>(Map<K, CoverageCount> counts, K key, bool isDone) {
  final current = counts[key] ?? const CoverageCount.empty();
  counts[key] = CoverageCount(
    done: current.done + (isDone ? 1 : 0),
    total: current.total + 1,
  );
}
