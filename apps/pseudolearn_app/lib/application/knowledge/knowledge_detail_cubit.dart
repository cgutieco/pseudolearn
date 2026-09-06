import 'package:bloc/bloc.dart';
import '../../domain/model/knowledge/knowledge_detail_content.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/profiles/syntax_profile_for_language.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/knowledge_repository.dart';
import '../../domain/ports/local_progress_store.dart';
import '../../domain/ports/program_analyzer.dart';
import '../../domain/ports/syntax_reference_source.dart';
import 'diagram_block_resolver.dart';
import 'knowledge_content_enricher.dart';
import 'knowledge_detail_loader.dart';
import 'knowledge_detail_state.dart';

final class KnowledgeDetailCubit extends Cubit<KnowledgeDetailState> {
  final KnowledgeDetailLoader _loader;
  final Map<String, double> _scrollOffsets = {};

  KnowledgeDetailCubit({
    required KnowledgeRepository repository,
    required SyntaxReferenceSource referenceSource,
    required ProgramAnalyzer analyzer,
    required LocalProgressStore progressStore,
    required DiagramBlockResolver diagramResolver,
  })  : _loader = KnowledgeDetailLoader(
          repository: repository,
          referenceSource: referenceSource,
          progressStore: progressStore,
          enricher: KnowledgeContentEnricher(
            diagrams: diagramResolver,
            analyzer: analyzer,
          ),
        ),
        super(const KnowledgeDetailState());

  Future<void> loadEntry(
    String entryId,
    UiLanguageId language, {
    SyntaxProfileId? profileId,
    String? anchor,
    String? fromModuleId,
  }) async {
    _emitLoading(entryId);
    try {
      final entry = await _loader.resolveEntry(entryId, language);
      if (entry == null) return _emitNotFound(entryId);
      final profile =
          profileId ?? entry.profileId ?? syntaxProfileForLanguage(language);
      final content = await _loader.buildContent(
        entry: entry,
        language: language,
        profile: profile,
        anchor: anchor,
        fromModuleId: fromModuleId,
        scrollOffset: _scrollOffsets[entry.id] ?? 0.0,
      );
      if (content == null) return _emitNotFound(entryId);
      _emitSuccess(entryId, entry, content);
    } catch (e) {
      _emitError(entryId, e.toString());
    }
  }

  void _emitLoading(String entryId) {
    emit(state.copyWithEntry(
      entryId,
      (current) => current.copyWith(status: KnowledgeDetailStatus.loading),
    ));
  }

  void _emitError(String entryId, String message) {
    emit(state.copyWithEntry(
      entryId,
      (current) => current.copyWith(
        status: KnowledgeDetailStatus.error,
        errorMessage: () => message,
      ),
    ));
  }

  void _emitSuccess(
    String entryId,
    KnowledgeEntry entry,
    KnowledgeDetailContent content,
  ) {
    emit(state.copyWithEntry(
      entryId,
      (current) => current.copyWith(
        status: KnowledgeDetailStatus.success,
        entry: () => entry,
        content: () => content,
        errorMessage: () => null,
      ),
    ));
  }

  void _emitNotFound(String entryId) {
    emit(state.copyWithEntry(
      entryId,
      (current) => current.copyWith(
        status: KnowledgeDetailStatus.notFound,
        entry: () => null,
        content: () => null,
      ),
    ));
  }

  void saveScrollOffset(String entryId, double offset) {
    _scrollOffsets[entryId] = offset;
    final currentEntryState = state.forEntry(entryId);
    final current = currentEntryState.content;
    if (currentEntryState.entry?.id == entryId && current != null) {
      final updated = switch (current) {
        final DocumentDetailContent doc => doc.copyWith(scrollOffset: offset),
        final ModuleDetailContent mod => mod.copyWith(scrollOffset: offset),
        final SpecificationDetailContent spec =>
          spec.copyWith(scrollOffset: offset),
        final ExerciseDetailContent exercise =>
          exercise.copyWith(scrollOffset: offset),
      };
      emit(state.copyWithEntry(
        entryId,
        (curr) => curr.copyWith(content: () => updated),
      ));
    }
  }

  double getScrollOffset(String entryId) => _scrollOffsets[entryId] ?? 0.0;
}
