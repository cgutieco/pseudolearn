import '../profiles/syntax_profile_id.dart';
import 'exercise_kind.dart';
import 'exercise_level.dart';
import 'knowledge_entry_type.dart';
import 'learning_track.dart';

final class KnowledgeEntry {
  final String id;
  final KnowledgeEntryType type;
  final String title;
  final String summary;
  final String? path;
  final SyntaxProfileId? profileId;
  final LearningTrack? track;
  final int order;
  final ExerciseLevel? level;
  final ExerciseKind? kind;
  final String? moduleId;
  final String? anchor;

  const KnowledgeEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    this.path,
    this.profileId,
    this.track,
    this.order = 0,
    this.level,
    this.kind,
    this.moduleId,
    this.anchor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          title == other.title &&
          summary == other.summary &&
          path == other.path &&
          profileId == other.profileId &&
          track == other.track &&
          order == other.order &&
          level == other.level &&
          kind == other.kind &&
          moduleId == other.moduleId &&
          anchor == other.anchor;

  @override
  int get hashCode => Object.hash(
        id,
        type,
        title,
        summary,
        path,
        profileId,
        track,
        order,
        level,
        kind,
        moduleId,
        anchor,
      );
}
