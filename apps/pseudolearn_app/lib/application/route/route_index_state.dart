import '../../domain/model/dashboard/coverage_count.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/route/route_toc.dart';
import 'route_progress.dart';

enum RouteIndexStatus { initial, loading, success, error }

final class RouteIndexState {
  final RouteIndexStatus status;
  final ReferenceEdition? edition;
  final RouteToc toc;
  final Map<String, LessonProgress> lessonProgress;
  final Map<String, CoverageCount> requiredExercises;
  final String? nextLessonId;

  const RouteIndexState({
    this.status = RouteIndexStatus.initial,
    this.edition,
    this.toc = const RouteToc.empty(),
    this.lessonProgress = const {},
    this.requiredExercises = const {},
    this.nextLessonId,
  });

  LessonProgress progressOf(String lessonId) =>
      lessonProgress[lessonId] ?? LessonProgress.notStarted;

  CoverageCount requiredOf(String lessonId) =>
      requiredExercises[lessonId] ?? const CoverageCount.empty();
}
