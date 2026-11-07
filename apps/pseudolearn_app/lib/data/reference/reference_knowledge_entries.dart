import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../domain/model/profiles/syntax_profile_for_language.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/reference/reference_index.dart';
import '../../domain/model/reference/reference_run.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/reference_repository.dart';

List<KnowledgeEntry> specificationEntriesOf(ReferenceIndex index) {
  return [
    for (final (position, section) in index.sections.indexed)
      KnowledgeEntry(
        id: section.id,
        type: KnowledgeEntryType.specificationSection,
        title: '${section.number} ${plainTextOf(section.title)}',
        summary: plainTextOf(section.phrase),
        order: position + 1,
      ),
  ];
}

Future<List<KnowledgeEntry>> specificationEntriesFor(
  ReferenceRepository repository,
  UiLanguageId language,
) async {
  final edition = ReferenceEdition(
    language: language,
    profile: syntaxProfileForLanguage(language),
  );
  final index = await repository.loadIndex(edition);
  return index is ContentLoaded<ReferenceIndex>
      ? specificationEntriesOf(index.value)
      : const [];
}

Future<ContentLoadResult<List<KnowledgeEntry>>> withSpecificationEntries(
  ContentLoadResult<List<KnowledgeEntry>> manifest,
  ({ReferenceRepository reference, UiLanguageId language}) source,
) async {
  if (manifest is! ContentLoaded<List<KnowledgeEntry>>) return manifest;
  return ContentLoaded([
    ...manifest.value,
    ...await specificationEntriesFor(source.reference, source.language),
  ]);
}
