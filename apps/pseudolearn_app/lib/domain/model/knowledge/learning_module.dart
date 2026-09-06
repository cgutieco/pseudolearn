import 'learning_track.dart';
import 'list_equality.dart';
import 'module_part.dart';
import 'module_section.dart';
import 'prediction_activity.dart';

final class LearningModule {
  final String id;
  final LearningTrack track;
  final int order;
  final String title;
  final List<ModuleSection> sections;
  final List<String> exerciseIds;
  final List<String> anchorIds;
  final PredictionActivity? predictionActivity;

  const LearningModule({
    required this.id,
    required this.track,
    required this.order,
    required this.title,
    required this.sections,
    this.exerciseIds = const [],
    this.anchorIds = const [],
    this.predictionActivity,
  });

  ModuleSection? sectionOf(ModulePart part) {
    for (final section in sections) {
      if (section.part == part) return section;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningModule &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          track == other.track &&
          order == other.order &&
          title == other.title &&
          predictionActivity == other.predictionActivity &&
          listEquals(sections, other.sections) &&
          listEquals(exerciseIds, other.exerciseIds) &&
          listEquals(anchorIds, other.anchorIds);

  @override
  int get hashCode => Object.hash(
        id,
        track,
        order,
        title,
        predictionActivity,
        Object.hashAll(sections),
        Object.hashAll(exerciseIds),
        Object.hashAll(anchorIds),
      );
}
