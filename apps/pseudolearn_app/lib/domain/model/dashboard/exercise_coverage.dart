import '../knowledge/exercise_kind.dart';
import '../knowledge/exercise_level.dart';
import '../knowledge/learning_track.dart';
import 'coverage_count.dart';

final class ExerciseCoverage {
  final CoverageCount overall;
  final Map<LearningTrack, CoverageCount> byTrack;
  final Map<ExerciseLevel, CoverageCount> byLevel;
  final Map<ExerciseKind, CoverageCount> byKind;

  const ExerciseCoverage({
    required this.overall,
    required this.byTrack,
    required this.byLevel,
    required this.byKind,
  });

  const ExerciseCoverage.empty()
      : overall = const CoverageCount.empty(),
        byTrack = const {},
        byLevel = const {},
        byKind = const {};

  CoverageCount ofTrack(LearningTrack track) =>
      byTrack[track] ?? const CoverageCount.empty();

  CoverageCount ofLevel(ExerciseLevel level) =>
      byLevel[level] ?? const CoverageCount.empty();

  CoverageCount ofKind(ExerciseKind kind) =>
      byKind[kind] ?? const CoverageCount.empty();
}
