import '../../domain/model/knowledge/content_block.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/knowledge/exercise.dart';
import '../../domain/model/knowledge/knowledge_detail_content.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../domain/model/knowledge/learning_module.dart';
import '../../domain/model/knowledge/module_section.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/knowledge_repository.dart';
import '../../domain/ports/local_progress_store.dart';
import '../../domain/ports/syntax_reference_source.dart';
import 'knowledge_content_enricher.dart';

final class KnowledgeDetailLoader {
  final KnowledgeRepository _repository;
  final SyntaxReferenceSource _referenceSource;
  final LocalProgressStore _progressStore;
  final KnowledgeContentEnricher _enricher;

  const KnowledgeDetailLoader({
    required KnowledgeRepository repository,
    required SyntaxReferenceSource referenceSource,
    required LocalProgressStore progressStore,
    required KnowledgeContentEnricher enricher,
  })  : _repository = repository,
        _referenceSource = referenceSource,
        _progressStore = progressStore,
        _enricher = enricher;

  Future<KnowledgeEntry?> resolveEntry(
      String entryId, UiLanguageId language) async {
    for (final ref in _referenceSource.getReferenceEntries()) {
      if (ref.id == entryId) return ref;
    }
    final loaded = await _repository.getEntries(language);
    if (loaded is! ContentLoaded<List<KnowledgeEntry>>) return null;
    for (final e in loaded.value) {
      if (e.id == entryId) return e;
    }
    return null;
  }

  Future<KnowledgeDetailContent?> buildContent({
    required KnowledgeEntry entry,
    required UiLanguageId language,
    required SyntaxProfileId profile,
    String? anchor,
    String? fromModuleId,
    required double scrollOffset,
  }) {
    return switch (entry.type) {
      KnowledgeEntryType.module => _loadModule(
          entry: entry,
          language: language,
          profile: profile,
          scrollOffset: scrollOffset),
      KnowledgeEntryType.specificationSection => _loadSpecification(
          entry: entry,
          language: language,
          profile: profile,
          anchor: anchor,
          fromModuleId: fromModuleId,
          scrollOffset: scrollOffset,
        ),
      KnowledgeEntryType.contact => _loadDocument(
          entry: entry,
          language: language,
          profile: profile,
          scrollOffset: scrollOffset),
      KnowledgeEntryType.reference => Future.value(
          _loadReference(
              entry: entry,
              language: language,
              profile: profile,
              scrollOffset: scrollOffset),
        ),
      KnowledgeEntryType.exercise =>
        _loadExercise(entry: entry, scrollOffset: scrollOffset),
      _ => Future.value(),
    };
  }

  Future<ModuleDetailContent?> _loadModule({
    required KnowledgeEntry entry,
    required UiLanguageId language,
    required SyntaxProfileId profile,
    required double scrollOffset,
  }) async {
    final moduleResult = await _repository.getModule(
      entry: entry,
      profileId: profile,
      languageId: language,
    );
    if (moduleResult is! ContentLoaded<LearningModule>) return null;
    final module = moduleResult.value;
    final resolvedSections =
        _resolveSections(module.sections, profile, language);

    final resolvedModule = LearningModule(
      id: module.id,
      track: module.track,
      order: module.order,
      title: module.title,
      sections: resolvedSections,
      exerciseIds: module.exerciseIds,
      anchorIds: module.anchorIds,
    );

    final allEntries = await _loadAllEntries(language);
    await _progressStore.markModuleVisited(entry.id);

    return ModuleDetailContent(
      module: resolvedModule,
      headings: _enricher.extractModuleHeadings(resolvedSections),
      specificationEntries:
          _enricher.filterEntriesByIds(allEntries, module.anchorIds),
      exerciseEntries:
          _enricher.filterEntriesByIds(allEntries, module.exerciseIds),
      scrollOffset: scrollOffset,
    );
  }

  Future<SpecificationDetailContent?> _loadSpecification({
    required KnowledgeEntry entry,
    required UiLanguageId language,
    required SyntaxProfileId profile,
    String? anchor,
    String? fromModuleId,
    required double scrollOffset,
  }) async {
    final loaded = await _repository.getDocumentBlocks(
      path: entry.path ?? '',
      profileId: profile,
      languageId: language,
    );
    if (loaded is! ContentLoaded<List<ContentBlock>>) return null;
    final blocks = _enricher.enrichBlocks(loaded.value, profile, language);
    final fromModuleTitle = await _resolveModuleTitle(fromModuleId, language);

    return SpecificationDetailContent(
      entry: entry,
      blocks: blocks,
      headings: _enricher.extractHeadings(blocks),
      selectedAnchor: anchor ?? entry.anchor,
      fromModuleId: fromModuleId,
      fromModuleTitle: fromModuleTitle,
      scrollOffset: scrollOffset,
    );
  }

  Future<ExerciseDetailContent?> _loadExercise({
    required KnowledgeEntry entry,
    required double scrollOffset,
  }) async {
    final loaded = await _repository.getExercise(entry.path ?? '');
    if (loaded is! ContentLoaded<Exercise>) return null;
    final exercise = loaded.value;
    final isCompleted = await _progressStore.isExerciseCompleted(exercise.id);
    return ExerciseDetailContent(
      exercise: exercise,
      isCompleted: isCompleted,
      scrollOffset: scrollOffset,
    );
  }

  Future<DocumentDetailContent?> _loadDocument({
    required KnowledgeEntry entry,
    required UiLanguageId language,
    required SyntaxProfileId profile,
    required double scrollOffset,
  }) async {
    final loaded = await _repository.getDocumentBlocks(
      path: entry.path ?? '',
      profileId: profile,
      languageId: language,
    );
    if (loaded is! ContentLoaded<List<ContentBlock>>) return null;
    final blocks = _enricher.enrichBlocks(loaded.value, profile, language);
    return DocumentDetailContent(
      blocks: blocks,
      headings: _enricher.extractHeadings(blocks),
      scrollOffset: scrollOffset,
    );
  }

  DocumentDetailContent _loadReference({
    required KnowledgeEntry entry,
    required UiLanguageId language,
    required SyntaxProfileId profile,
    required double scrollOffset,
  }) {
    final rawBlocks = _referenceSource.getBlocksForProfile(profile);
    final blocks = _enricher.enrichBlocks(rawBlocks, profile, language);
    return DocumentDetailContent(
      blocks: blocks,
      headings: _enricher.extractHeadings(blocks),
      scrollOffset: scrollOffset,
    );
  }

  List<ModuleSection> _resolveSections(
    List<ModuleSection> sections,
    SyntaxProfileId profile,
    UiLanguageId language,
  ) {
    final resolved = <ModuleSection>[];
    for (final section in sections) {
      final blocks = _enricher.enrichBlocks(section.blocks, profile, language);
      resolved.add(ModuleSection(part: section.part, blocks: blocks));
    }
    return resolved;
  }

  Future<String?> _resolveModuleTitle(
      String? fromModuleId, UiLanguageId language) async {
    if (fromModuleId == null) return null;
    final entries = await _loadAllEntries(language);
    for (final e in entries) {
      if (e.id == fromModuleId) return e.title;
    }
    return null;
  }

  Future<List<KnowledgeEntry>> _loadAllEntries(UiLanguageId language) async {
    final entriesResult = await _repository.getEntries(language);
    return entriesResult is ContentLoaded<List<KnowledgeEntry>>
        ? entriesResult.value
        : const <KnowledgeEntry>[];
  }
}
