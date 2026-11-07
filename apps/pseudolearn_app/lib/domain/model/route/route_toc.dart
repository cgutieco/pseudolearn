import '../reference/reference_run.dart';
import 'route_kinds.dart';

final class RouteExerciseEntry {
  final String id;
  final String lessonId;
  final RouteExerciseKind kind;
  final RouteLevel level;
  final bool required;
  final List<ReferenceRun> title;

  const RouteExerciseEntry({
    required this.id,
    required this.lessonId,
    required this.kind,
    required this.level,
    required this.required,
    required this.title,
  });
}

final class RouteLessonEntry {
  final String id;
  final String number;
  final RouteLessonKind kind;
  final List<ReferenceRun> title;
  final String briefProblem;
  final int minutes;
  final List<RouteLevel> levels;
  final List<String> needs;
  final List<RouteExerciseEntry> exercises;

  const RouteLessonEntry({
    required this.id,
    required this.number,
    required this.kind,
    required this.title,
    required this.briefProblem,
    required this.minutes,
    required this.levels,
    required this.needs,
    required this.exercises,
  });

  Iterable<RouteExerciseEntry> get requiredExercises =>
      exercises.where((exercise) => exercise.required);
}

final class RoutePartEntry {
  final String id;
  final String number;
  final String title;
  final String motto;
  final String summary;
  final List<RouteLessonEntry> lessons;

  const RoutePartEntry({
    required this.id,
    required this.number,
    required this.title,
    required this.motto,
    required this.summary,
    required this.lessons,
  });
}

final class RouteToc {
  final List<RoutePartEntry> parts;

  const RouteToc(this.parts);

  const RouteToc.empty() : parts = const [];

  List<RouteLessonEntry> get lessons => [
    for (final part in parts) ...part.lessons,
  ];

  List<RouteExerciseEntry> get exercises => [
    for (final lesson in lessons) ...lesson.exercises,
  ];

  RouteLessonEntry? lesson(String id) {
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  RoutePartEntry? partOf(String lessonId) {
    for (final part in parts) {
      for (final lesson in part.lessons) {
        if (lesson.id == lessonId) return part;
      }
    }
    return null;
  }
}
