import 'dart:convert';
import '../../domain/model/knowledge/content_load_failure.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/knowledge/exercise_kind.dart';
import '../../domain/model/knowledge/exercise_level.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../domain/model/knowledge/learning_track.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';

const int supportedManifestVersion = 2;

const Map<String, KnowledgeEntryType> _sectionTypes = {
  'modules': KnowledgeEntryType.module,
  'specification': KnowledgeEntryType.specificationSection,
  'exercises': KnowledgeEntryType.exercise,
  'predictions': KnowledgeEntryType.predictionActivity,
  'illustrations': KnowledgeEntryType.illustration,
  'examples': KnowledgeEntryType.example,
  'support': KnowledgeEntryType.contact,
};

final class KnowledgeManifestReader {
  const KnowledgeManifestReader();

  ContentLoadResult<List<KnowledgeEntry>> read(String source) {
    final Map<String, dynamic> manifest;
    try {
      manifest = jsonDecode(source) as Map<String, dynamic>;
    } catch (error) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.malformedManifest,
        detail: '$error',
      );
    }
    if (manifest['manifestVersion'] != supportedManifestVersion) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.unsupportedManifestVersion,
        detail: '${manifest['manifestVersion']}',
      );
    }
    return _entriesOf(manifest);
  }

  ContentLoadResult<List<KnowledgeEntry>> _entriesOf(
    Map<String, dynamic> manifest,
  ) {
    final entries = <KnowledgeEntry>[];
    for (final section in _sectionTypes.entries) {
      final declared = manifest[section.key];
      if (declared == null) continue;
      if (declared is! List) {
        return ContentLoadFailed(
          failure: ContentLoadFailure.malformedManifest,
          detail: section.key,
        );
      }
      for (final raw in declared) {
        if (raw is! Map<String, dynamic>) {
          return ContentLoadFailed(
            failure: ContentLoadFailure.malformedManifest,
            detail: section.key,
          );
        }
        entries.add(_entryOf(raw, section.value));
      }
    }
    return ContentLoaded(entries);
  }

  KnowledgeEntry _entryOf(Map<String, dynamic> raw, KnowledgeEntryType type) {
    final level = raw['level'] as int?;
    return KnowledgeEntry(
      id: raw['id'] as String? ?? '',
      type: type,
      title: raw['title'] as String? ?? '',
      summary: raw['summary'] as String? ?? '',
      path: raw['path'] as String?,
      profileId: _profileOf(raw['profile'] as String?),
      track: LearningTrack.fromCode(raw['track'] as String? ?? ''),
      order: raw['order'] as int? ?? 0,
      level: level == null ? null : ExerciseLevel.fromNumber(level),
      kind: ExerciseKind.fromSlug(raw['kind'] as String? ?? ''),
      moduleId: raw['module'] as String?,
      anchor: raw['anchor'] as String?,
    );
  }

  SyntaxProfileId? _profileOf(String? raw) {
    return switch (raw) {
      'classic_spanish' => SyntaxProfileId.classicSpanish,
      'english' => SyntaxProfileId.english,
      _ => null,
    };
  }
}
