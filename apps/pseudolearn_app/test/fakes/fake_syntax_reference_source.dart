import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_marker.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/marker_resolution.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/syntax_reference_source.dart';

final class FakeSyntaxReferenceSource implements SyntaxReferenceSource {
  List<KnowledgeEntry> referenceEntries;
  Map<SyntaxProfileId, List<ContentBlock>> blocksByProfile;
  Map<ContentMarker, MarkerResolution> resolutionsByMarker;

  FakeSyntaxReferenceSource({
    this.referenceEntries = const [],
    this.blocksByProfile = const {},
    this.resolutionsByMarker = const {},
  });

  @override
  List<KnowledgeEntry> getReferenceEntries() => referenceEntries;

  @override
  List<ContentBlock> getBlocksForProfile(SyntaxProfileId profileId) =>
      blocksByProfile[profileId] ?? const [];

  @override
  MarkerResolution? resolveMarker({
    required ContentMarker marker,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    return resolutionsByMarker[marker];
  }
}
