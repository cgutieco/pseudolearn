import '../../domain/model/onboarding/knowledge_highlights.dart';
import '../../domain/model/reference/reference_index.dart';
import '../../domain/model/route/route_kinds.dart';
import '../../domain/model/route/route_toc.dart';

final class KnowledgeHighlightsProjection {
  const KnowledgeHighlightsProjection();

  KnowledgeHighlights of({required RouteToc toc, required ReferenceIndex? index}) {
    final exercises = toc.exercises;
    return KnowledgeHighlights(
      parts: [
        for (final part in toc.parts)
          if (part.lessons.isNotEmpty)
            RoutePartHighlight(
              number: part.number,
              title: part.title,
              lessonCount: part.lessons.length,
            ),
      ],
      exerciseLevels: [
        for (final level in RouteLevel.values)
          if (_count(exercises, level) > 0)
            ExerciseLevelHighlight(level: level, count: _count(exercises, level)),
      ],
      lessonCount: toc.lessons.length,
      specificationCount: index?.sections.length ?? 0,
      exerciseCount: exercises.length,
    );
  }

  int _count(List<RouteExerciseEntry> exercises, RouteLevel level) =>
      exercises.where((exercise) => exercise.level == level).length;
}
