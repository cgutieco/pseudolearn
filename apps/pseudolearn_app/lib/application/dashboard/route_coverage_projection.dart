import '../../domain/model/dashboard/coverage_count.dart';
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
      ),
  ];
}

NextLesson? projectNextLesson({
  required RouteToc toc,
  required ContentProgress progress,
}) {
  final lesson = RouteProgress(progress).nextLesson(toc);
  if (lesson == null) return null;
  return NextLesson(
    id: lesson.id,
    number: lesson.number,
    title: plainTextOf(lesson.title),
    partTitle: toc.partOf(lesson.id)?.title ?? '',
  );
}
