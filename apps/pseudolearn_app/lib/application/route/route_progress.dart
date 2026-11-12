import '../../domain/model/dashboard/coverage_count.dart';
import '../../domain/model/knowledge/content_progress.dart';
import '../../domain/model/route/route_kinds.dart';
import '../../domain/model/route/route_toc.dart';

enum LessonProgress { notStarted, visited, completed }

final class RouteProgress {
  final ContentProgress _progress;

  const RouteProgress(this._progress);

  bool isExerciseDone(String exerciseId) =>
      _progress.isExerciseCompleted(routeExerciseProgressId(exerciseId));

  bool _isLessonVisited(String lessonId) =>
      _progress.isModuleVisited(routeLessonProgressId(lessonId));

  LessonProgress lessonProgress(RouteLessonEntry lesson) {
    if (isLessonCompleted(lesson)) return LessonProgress.completed;
    if (_isLessonVisited(lesson.id)) return LessonProgress.visited;
    return LessonProgress.notStarted;
  }

  CoverageCount requiredExercisesOf(RouteLessonEntry lesson) {
    final required = lesson.requiredExercises.toList();
    return CoverageCount(
      done: required.where((exercise) => isExerciseDone(exercise.id)).length,
      total: required.length,
    );
  }

  bool isLessonCompleted(RouteLessonEntry lesson) {
    final required = lesson.requiredExercises.toList();
    if (required.isEmpty) return _isLessonVisited(lesson.id);
    return required.every((exercise) => isExerciseDone(exercise.id));
  }

  RouteLessonEntry? nextLesson(RouteToc toc) {
    final completed = {
      for (final lesson in toc.lessons)
        if (isLessonCompleted(lesson)) lesson.id,
    };
    for (final lesson in toc.lessons) {
      if (completed.contains(lesson.id)) continue;
      if (lesson.needs.every(completed.contains)) return lesson;
    }
    return null;
  }
}
