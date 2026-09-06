import '../knowledge/exercise_level.dart';
import '../knowledge/learning_track.dart';

final class LearningTrackHighlight {
  final LearningTrack track;
  final int moduleCount;
  final String firstModuleTitle;

  const LearningTrackHighlight({
    required this.track,
    required this.moduleCount,
    required this.firstModuleTitle,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningTrackHighlight &&
          track == other.track &&
          moduleCount == other.moduleCount &&
          firstModuleTitle == other.firstModuleTitle;

  @override
  int get hashCode => Object.hash(track, moduleCount, firstModuleTitle);
}

final class ExerciseLevelHighlight {
  final ExerciseLevel level;
  final int count;

  const ExerciseLevelHighlight({
    required this.level,
    required this.count,
  });

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
  final List<LearningTrackHighlight> tracks;
  final List<ExerciseLevelHighlight> exerciseLevels;
  final int moduleCount;
  final int specificationCount;
  final int exerciseCount;

  const KnowledgeHighlights({
    required this.tracks,
    required this.exerciseLevels,
    required this.moduleCount,
    required this.specificationCount,
    required this.exerciseCount,
  });

  const KnowledgeHighlights.empty()
      : tracks = const [],
        exerciseLevels = const [],
        moduleCount = 0,
        specificationCount = 0,
        exerciseCount = 0;

  bool get hasRoute => moduleCount > 0;

  bool get hasSpecification => specificationCount > 0;

  bool get hasExercises => exerciseCount > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeHighlights &&
          moduleCount == other.moduleCount &&
          specificationCount == other.specificationCount &&
          exerciseCount == other.exerciseCount &&
          _sameTracks(other.tracks) &&
          _sameLevels(other.exerciseLevels);

  bool _sameTracks(List<LearningTrackHighlight> other) {
    if (other.length != tracks.length) return false;
    for (var index = 0; index < tracks.length; index++) {
      if (tracks[index] != other[index]) return false;
    }
    return true;
  }

  bool _sameLevels(List<ExerciseLevelHighlight> other) {
    if (other.length != exerciseLevels.length) return false;
    for (var index = 0; index < exerciseLevels.length; index++) {
      if (exerciseLevels[index] != other[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        moduleCount,
        specificationCount,
        exerciseCount,
        Object.hashAll(tracks),
        Object.hashAll(exerciseLevels),
      );
}
