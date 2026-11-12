import '../route/route_kinds.dart';

final class RoutePartHighlight {
  final String number;
  final String title;
  final int lessonCount;

  const RoutePartHighlight({
    required this.number,
    required this.title,
    required this.lessonCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutePartHighlight &&
          number == other.number &&
          title == other.title &&
          lessonCount == other.lessonCount;

  @override
  int get hashCode => Object.hash(number, title, lessonCount);
}

final class ExerciseLevelHighlight {
  final RouteLevel level;
  final int count;

  const ExerciseLevelHighlight({required this.level, required this.count});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseLevelHighlight &&
          level == other.level &&
          count == other.count;

  @override
  int get hashCode => Object.hash(level, count);
}

final class KnowledgeHighlights {
  final List<RoutePartHighlight> parts;
  final List<ExerciseLevelHighlight> exerciseLevels;
  final int lessonCount;
  final int specificationCount;
  final int exerciseCount;

  const KnowledgeHighlights({
    required this.parts,
    required this.exerciseLevels,
    required this.lessonCount,
    required this.specificationCount,
    required this.exerciseCount,
  });

  const KnowledgeHighlights.empty()
    : parts = const [],
      exerciseLevels = const [],
      lessonCount = 0,
      specificationCount = 0,
      exerciseCount = 0;

  bool get hasRoute => lessonCount > 0;

  bool get hasSpecification => specificationCount > 0;

  bool get hasExercises => exerciseCount > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeHighlights &&
          lessonCount == other.lessonCount &&
          specificationCount == other.specificationCount &&
          exerciseCount == other.exerciseCount &&
          Object.hashAll(parts) == Object.hashAll(other.parts) &&
          Object.hashAll(exerciseLevels) == Object.hashAll(other.exerciseLevels);

  @override
  int get hashCode => Object.hash(
    lessonCount,
    specificationCount,
    exerciseCount,
    Object.hashAll(parts),
    Object.hashAll(exerciseLevels),
  );
}
