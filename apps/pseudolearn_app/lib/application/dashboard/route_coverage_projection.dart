import '../../domain/model/dashboard/coverage_count.dart';
import '../../domain/model/dashboard/lesson_mark.dart';
import '../../domain/model/dashboard/next_lesson.dart';
import '../../domain/model/dashboard/part_coverage.dart';
import '../../domain/model/knowledge/content_progress.dart';
import '../../domain/model/reference/reference_run.dart';
import '../../domain/model/route/route_toc.dart';
import '../route/route_progress.dart';

List<PartCoverage> projectPartCoverage({
  required RouteToc toc,
  required ContentProgress progress,
}) {
  final route = RouteProgress(progress);
  final nextId = route.nextLesson(toc)?.id;
  return [
    for (final part in toc.parts)
      PartCoverage(
        partId: part.id,
        number: part.number,
        title: part.title,
        lessons: CoverageCount(
          done: part.lessons.where(route.isLessonCompleted).length,
          total: part.lessons.length,
        ),
        marks: [
          for (final lesson in part.lessons)
            LessonMark(
              lessonId: lesson.id,
              number: lesson.number,
              stage: _stageOf(route.lessonProgress(lesson)),
              isNext: lesson.id == nextId,
            ),
        ],
      ),
  ];
}

LessonStage _stageOf(LessonProgress progress) => switch (progress) {
  LessonProgress.completed => LessonStage.completed,
  LessonProgress.visited => LessonStage.inProgress,
  LessonProgress.notStarted => LessonStage.pending,
};

NextLesson? projectNextLesson({
  required RouteToc toc,
  required ContentProgress progress,
}) {
  final route = RouteProgress(progress);
  final lesson = route.nextLesson(toc);
  if (lesson == null) return null;
  return NextLesson(
    id: lesson.id,
    number: lesson.number,
    title: plainTextOf(lesson.title),
    partTitle: toc.partOf(lesson.id)?.title ?? '',
    requiredExercises: route.requiredExercisesOf(lesson),
  );
}
