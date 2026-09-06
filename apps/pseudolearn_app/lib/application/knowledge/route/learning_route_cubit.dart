import 'package:bloc/bloc.dart';
import '../../../domain/model/knowledge/content_load_result.dart';
import '../../../domain/model/knowledge/knowledge_entry.dart';
import '../../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../../domain/model/knowledge/learning_module.dart';
import '../../../domain/model/knowledge/learning_track.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/knowledge_repository.dart';
import '../../../domain/ports/local_progress_store.dart';
import 'learning_route_state.dart';

final class LearningRouteCubit extends Cubit<LearningRouteState> {
  final KnowledgeRepository _repository;
  final LocalProgressStore _progressStore;

  LearningRouteCubit({
    required KnowledgeRepository repository,
    required LocalProgressStore progressStore,
  })  : _repository = repository,
        _progressStore = progressStore,
        super(const LearningRouteState());

  Future<void> loadRoute(UiLanguageId languageId) async {
    emit(state.copyWith(status: LearningRouteStatus.loading));
    try {
      final entriesResult = await _repository.getEntries(languageId);
      if (entriesResult is ContentLoadFailed<List<KnowledgeEntry>>) {
        emit(state.copyWith(
          status: LearningRouteStatus.error,
          errorMessage: () => entriesResult.detail,
        ));
        return;
      }
      final entries = (entriesResult as ContentLoaded<List<KnowledgeEntry>>).value;
      final moduleEntries = entries.where((e) => e.type == KnowledgeEntryType.module).toList();

      final foundations = _filterAndSortTrack(moduleEntries, LearningTrack.foundations);
      final imperative = _filterAndSortTrack(moduleEntries, LearningTrack.imperative);
      final oop = _filterAndSortTrack(moduleEntries, LearningTrack.objectOriented);

      final progress = await _progressStore.readProgress();

      emit(state.copyWith(
        status: LearningRouteStatus.success,
        trackA: foundations,
        trackB: imperative,
        trackC: oop,
        filteredTrackA: _searchWithin(foundations, state.searchQuery),
        filteredTrackB: _searchWithin(imperative, state.searchQuery),
        filteredTrackC: _searchWithin(oop, state.searchQuery),
        visitedModuleIds: progress.visitedModuleIds,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LearningRouteStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> loadModule({
    required String moduleId,
    required UiLanguageId languageId,
    required SyntaxProfileId profileId,
  }) async {
    emit(state.copyWith(status: LearningRouteStatus.loading));
    try {
      final entry = await _resolveModuleEntry(languageId, moduleId);
      if (entry == null) {
        emit(state.copyWith(
          status: LearningRouteStatus.moduleNotFound,
          activeModule: () => null,
        ));
        return;
      }

      final moduleResult = await _repository.getModule(
        entry: entry,
        profileId: profileId,
        languageId: languageId,
      );
      if (moduleResult is ContentLoadFailed<LearningModule>) {
        emit(state.copyWith(
          status: LearningRouteStatus.error,
          errorMessage: () => moduleResult.detail,
        ));
        return;
      }

      final module = (moduleResult as ContentLoaded<LearningModule>).value;
      await _emitLoadedModule(moduleId, module);
    } catch (e) {
      emit(state.copyWith(
        status: LearningRouteStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  void closeModule() {
    emit(state.copyWith(activeModule: () => null));
  }

  void search(String query) {
    emit(state.copyWith(
      searchQuery: query,
      filteredTrackA: _searchWithin(state.trackA, query),
      filteredTrackB: _searchWithin(state.trackB, query),
      filteredTrackC: _searchWithin(state.trackC, query),
    ));
  }

  List<KnowledgeEntry> _searchWithin(List<KnowledgeEntry> entries, String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return entries;
    return entries.where((entry) {
      return entry.title.toLowerCase().contains(trimmed) ||
          entry.summary.toLowerCase().contains(trimmed);
    }).toList();
  }

  Future<void> _emitLoadedModule(String moduleId, LearningModule module) async {
    await _progressStore.markModuleVisited(moduleId);
    final updatedProgress = await _progressStore.readProgress();
    emit(state.copyWith(
      status: LearningRouteStatus.success,
      activeModule: () => module,
      visitedModuleIds: updatedProgress.visitedModuleIds,
      errorMessage: () => null,
    ));
  }

  Future<KnowledgeEntry?> _resolveModuleEntry(
    UiLanguageId languageId,
    String moduleId,
  ) async {
    final entriesResult = await _repository.getEntries(languageId);
    if (entriesResult is! ContentLoaded<List<KnowledgeEntry>>) {
      return null;
    }
    return entriesResult.value.cast<KnowledgeEntry?>().firstWhere(
          (e) => e?.id == moduleId,
          orElse: () => null,
        );
  }

  List<KnowledgeEntry> _filterAndSortTrack(
    List<KnowledgeEntry> entries,
    LearningTrack track,
  ) {
    return entries.where((e) => e.track == track).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
}
