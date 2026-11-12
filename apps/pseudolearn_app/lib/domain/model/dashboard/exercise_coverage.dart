import '../route/route_kinds.dart';
import 'coverage_count.dart';

final class ExerciseCoverage {
  final CoverageCount overall;
  final Map<String, CoverageCount> byPart;
  final Map<RouteLevel, CoverageCount> byLevel;
  final Map<RouteExerciseKind, CoverageCount> byKind;
  final int assisted;

  const ExerciseCoverage({
    required this.overall,
    required this.byPart,
    required this.byLevel,
    required this.byKind,
    this.assisted = 0,
  });

  const ExerciseCoverage.empty()
    : overall = const CoverageCount.empty(),
      byPart = const {},
      byLevel = const {},
      byKind = const {},
      assisted = 0;

  CoverageCount ofPart(String partId) =>
      byPart[partId] ?? const CoverageCount.empty();

  CoverageCount ofLevel(RouteLevel level) =>
      byLevel[level] ?? const CoverageCount.empty();

  CoverageCount ofKind(RouteExerciseKind kind) =>
      byKind[kind] ?? const CoverageCount.empty();
}
