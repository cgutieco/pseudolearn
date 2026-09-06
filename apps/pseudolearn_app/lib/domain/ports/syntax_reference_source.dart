import '../model/knowledge/content_block.dart';
import '../model/knowledge/content_marker.dart';
import '../model/knowledge/knowledge_entry.dart';
import '../model/knowledge/marker_resolution.dart';
import '../model/profiles/syntax_profile_id.dart';
import '../model/settings/ui_language_id.dart';

abstract interface class SyntaxReferenceSource {
  List<KnowledgeEntry> getReferenceEntries();

  List<ContentBlock> getBlocksForProfile(SyntaxProfileId profileId);

  MarkerResolution? resolveMarker({
    required ContentMarker marker,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  });
}
