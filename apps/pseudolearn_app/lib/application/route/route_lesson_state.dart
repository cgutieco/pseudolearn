import '../../domain/model/route/route_lesson.dart';
import '../../domain/model/route/route_toc.dart';

enum RouteLessonStatus { initial, loading, success, notFound }

final class RouteLessonState {
  final RouteLessonStatus status;
  final RouteLesson? lesson;
  final List<RouteExerciseEntry> exercises;
  final Set<String> completedExerciseIds;

  const RouteLessonState({
    this.status = RouteLessonStatus.initial,
    this.lesson,
    this.exercises = const [],
    this.completedExerciseIds = const {},
  });

  RouteExerciseEntry? exercise(String id) {
    for (final entry in exercises) {
      if (entry.id == id) return entry;
    }
    return null;
  }
}
