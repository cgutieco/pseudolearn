import '../../domain/model/knowledge/exercise_level.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../domain/model/knowledge/learning_track.dart';
import '../../domain/model/onboarding/knowledge_highlights.dart';

final class KnowledgeHighlightsProjection {
  const KnowledgeHighlightsProjection();

  KnowledgeHighlights of(List<KnowledgeEntry> entries) {
    final modulesByTrack = <LearningTrack, List<KnowledgeEntry>>{};
    final exercisesByLevel = <ExerciseLevel, int>{};
    var moduleCount = 0;
    var specificationCount = 0;
    var exerciseCount = 0;

    for (final entry in entries) {
      switch (entry.type) {
        case KnowledgeEntryType.module:
          moduleCount++;
          _collectModule(modulesByTrack, entry);
        case KnowledgeEntryType.specificationSection:
          specificationCount++;
        case KnowledgeEntryType.exercise:
          exerciseCount++;
          _collectExercise(exercisesByLevel, entry);
        default:
          break;
      }
    }

    return KnowledgeHighlights(
      tracks: _trackHighlights(modulesByTrack),
      exerciseLevels: _levelHighlights(exercisesByLevel),
      moduleCount: moduleCount,
      specificationCount: specificationCount,
      exerciseCount: exerciseCount,
    );
  }

  void _collectModule(
    Map<LearningTrack, List<KnowledgeEntry>> modulesByTrack,
    KnowledgeEntry entry,
  ) {
    final track = entry.track;
    if (track == null) return;
    modulesByTrack.putIfAbsent(track, () => <KnowledgeEntry>[]).add(entry);
  }

  void _collectExercise(
    Map<ExerciseLevel, int> exercisesByLevel,
    KnowledgeEntry entry,
  ) {
    final level = entry.level;
    if (level == null) return;
    exercisesByLevel[level] = (exercisesByLevel[level] ?? 0) + 1;
  }

  List<LearningTrackHighlight> _trackHighlights(
    Map<LearningTrack, List<KnowledgeEntry>> modulesByTrack,
  ) {
    final highlights = <LearningTrackHighlight>[];
    for (final track in LearningTrack.values) {
      final modules = modulesByTrack[track];
      if (modules == null || modules.isEmpty) continue;
      highlights.add(LearningTrackHighlight(
        track: track,
        moduleCount: modules.length,
        firstModuleTitle: _lowestOrdered(modules).title,
      ));
    }
    return highlights;
  }

  KnowledgeEntry _lowestOrdered(List<KnowledgeEntry> modules) {
    var lowest = modules.first;
    for (final module in modules) {
      if (module.order < lowest.order) lowest = module;
    }
    return lowest;
  }

  List<ExerciseLevelHighlight> _levelHighlights(
    Map<ExerciseLevel, int> exercisesByLevel,
  ) {
    final highlights = <ExerciseLevelHighlight>[];
    for (final level in ExerciseLevel.values) {
      final count = exercisesByLevel[level];
      if (count == null || count == 0) continue;
      highlights.add(ExerciseLevelHighlight(level: level, count: count));
    }
    return highlights;
  }
}
