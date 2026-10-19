import '../../domain/model/knowledge/content_block.dart';
import '../../domain/model/knowledge/content_marker.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/marker_resolution.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/syntax_reference_source.dart';
import '../knowledge/reference_entries.dart';
import 'rust_marker_resolver.dart';
import 'rust_reference_signatures.dart';
import 'rust_reference_vocabulary.dart';
import 'rust_transport.dart';

final class RustSyntaxReferenceSource implements SyntaxReferenceSource {
  final RustReferenceVocabulary _vocabulary;
  final RustMarkerResolver _markers;

  RustSyntaxReferenceSource(RustTransport transport)
    : _vocabulary = RustReferenceVocabulary(transport),
      _markers = RustMarkerResolver(transport);

  @override
  List<KnowledgeEntry> getReferenceEntries() => referenceEntries;

  @override
  List<ContentBlock> getBlocksForProfile(SyntaxProfileId profileId) {
    final isEnglish = profileId == SyntaxProfileId.english;
    final RustReferenceData data;
    try {
      data = _vocabulary.forProfile(profileId);
    } on RustBridgeFailure {
      return const [];
    }
    return [
      HeadingBlock(
        level: 1,
        text: isEnglish ? 'Syntax Reference' : 'Referencia de sintaxis',
      ),
      HeadingBlock(
        level: 2,
        text: isEnglish ? 'Primitive Types' : 'Tipos primitivos',
      ),
      ListBlock(items: primitiveTypeLexemes(data)),
      HeadingBlock(
        level: 2,
        text: isEnglish ? 'Reserved Keywords' : 'Palabras reservadas',
      ),
      ListBlock(items: data.keywords.values.toList()),
      HeadingBlock(
        level: 2,
        text: isEnglish ? 'Built-in Functions' : 'Funciones integradas',
      ),
      ListBlock(items: [for (final entry in data.builtins) entry.lexeme]),
    ];
  }

  @override
  MarkerResolution? resolveMarker({
    required ContentMarker marker,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) => _markers.resolve(
    marker: marker,
    profileId: profileId,
    languageId: languageId,
  );
}
