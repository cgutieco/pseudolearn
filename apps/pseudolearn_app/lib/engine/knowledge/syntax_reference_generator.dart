import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/knowledge/content_block.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/knowledge/content_marker.dart';
import '../../domain/model/knowledge/marker_resolution.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/syntax_reference_source.dart';
import '../mapping/profile_catalog.dart';
import 'engine_marker_resolver.dart';

final class SyntaxReferenceGenerator implements SyntaxReferenceSource {
  final EngineMarkerResolver _markers;

  const SyntaxReferenceGenerator({
    EngineMarkerResolver markers = const EngineMarkerResolver(),
  }) : _markers = markers;

  @override
  MarkerResolution? resolveMarker({
    required ContentMarker marker,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    return _markers.resolve(
      marker: marker,
      profileId: profileId,
      languageId: languageId,
    );
  }

  @override
  List<KnowledgeEntry> getReferenceEntries() {
    return [
      const KnowledgeEntry(
        id: 'reference-classic-spanish',
        type: KnowledgeEntryType.reference,
        title: 'Referencia de sintaxis (Español)',
        summary: 'Resumen completo de palabras reservadas, tipos y operadores del perfil español clásico.',
        profileId: SyntaxProfileId.classicSpanish,
      ),
      const KnowledgeEntry(
        id: 'reference-english',
        type: KnowledgeEntryType.reference,
        title: 'Syntax Reference (English)',
        summary: 'Comprehensive summary of reserved keywords, types, and operators for the English profile.',
        profileId: SyntaxProfileId.english,
      ),
    ];
  }

  @override
  List<ContentBlock> getBlocksForProfile(SyntaxProfileId profileId) {
    final profile = ProfileCatalog.toLanguageProfile(profileId);
    final isEnglish = profileId == SyntaxProfileId.english;

    final title = isEnglish ? 'Syntax Reference' : 'Referencia de sintaxis';
    final typesSectionTitle = isEnglish ? 'Primitive Types' : 'Tipos primitivos';
    final keywordsSectionTitle = isEnglish ? 'Reserved Keywords' : 'Palabras reservadas';
    final functionsSectionTitle = isEnglish ? 'Built-in Functions' : 'Funciones integradas';

    final blocks = <ContentBlock>[
      HeadingBlock(level: 1, text: title),
      HeadingBlock(level: 2, text: typesSectionTitle),
      ListBlock(
        items: PrimitiveType.values.map(profile.formatPrimitiveType).toList(),
      ),
      HeadingBlock(level: 2, text: keywordsSectionTitle),
      ListBlock(
        items: profile.reservedLexemes.values
            .map((entry) => entry.canonicalLexeme)
            .toList(),
      ),
      HeadingBlock(level: 2, text: functionsSectionTitle),
      ListBlock(
        items: profile.builtinFunctions.values
            .map((entry) => entry.canonicalName)
            .toList(),
      ),
    ];

    return blocks;
  }
}
