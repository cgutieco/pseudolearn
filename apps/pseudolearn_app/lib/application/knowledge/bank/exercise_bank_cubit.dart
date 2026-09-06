import 'package:bloc/bloc.dart';
import '../../../domain/model/knowledge/ast_construct.dart';
import '../../../domain/model/knowledge/content_load_result.dart';
import '../../../domain/model/knowledge/exercise.dart';
import '../../../domain/model/knowledge/exercise_level.dart';
import '../../../domain/model/knowledge/knowledge_entry.dart';
import '../../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../../domain/model/knowledge/structural_assertion.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/knowledge_repository.dart';
import '../../../domain/ports/local_progress_store.dart';
import 'exercise_bank_state.dart';

final class ExerciseBankCubit extends Cubit<ExerciseBankState> {
  final KnowledgeRepository _repository;
  final LocalProgressStore _progressStore;

  ExerciseBankCubit({
    required KnowledgeRepository repository,
    required LocalProgressStore progressStore,
  })  : _repository = repository,
        _progressStore = progressStore,
        super(const ExerciseBankState());

  Future<void> loadExercises(UiLanguageId language) async {
    emit(state.copyWith(status: ExerciseBankStatus.loading));
    try {
      final entriesResult = await _repository.getEntries(language);
      if (entriesResult is ContentLoadFailed<List<KnowledgeEntry>>) {
        emit(state.copyWith(
          status: ExerciseBankStatus.error,
          errorMessage: () => entriesResult.detail,
        ));
        return;
      }
      final entries = (entriesResult as ContentLoaded<List<KnowledgeEntry>>).value;
      await _populateSuccessState(entries);
    } catch (e) {
      emit(state.copyWith(
        status: ExerciseBankStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  void search(String query) {
    final filtered = _deriveFiltered(
      state.allExercises,
      level: state.selectedLevel,
      moduleId: state.selectedModuleId,
      construct: state.selectedConstruct,
      query: query,
    );
    emit(state.copyWith(
      searchQuery: query,
      filteredExercises: filtered,
    ));
  }

  void setFilter({
    ExerciseLevel? level,
    bool clearLevel = false,
    String? moduleId,
    bool clearModule = false,
    AstConstruct? construct,
    bool clearConstruct = false,
  }) {
    final nextLevel = clearLevel ? null : (level ?? state.selectedLevel);
    final nextModuleId = clearModule ? null : (moduleId ?? state.selectedModuleId);
    final nextConstruct = clearConstruct ? null : (construct ?? state.selectedConstruct);
    final filtered = _deriveFiltered(
      state.allExercises,
      level: nextLevel,
      moduleId: nextModuleId,
      construct: nextConstruct,
      query: state.searchQuery,
    );
    emit(state.copyWith(
      selectedLevel: () => nextLevel,
      selectedModuleId: () => nextModuleId,
      selectedConstruct: () => nextConstruct,
      filteredExercises: filtered,
    ));
  }

  void clearFilters() {
    final filtered = _deriveFiltered(
      state.allExercises,
      level: null,
      moduleId: null,
      construct: null,
      query: '',
    );
    emit(state.copyWith(
      selectedLevel: () => null,
      selectedModuleId: () => null,
      selectedConstruct: () => null,
      searchQuery: '',
      filteredExercises: filtered,
    ));
  }

  Future<void> _populateSuccessState(List<KnowledgeEntry> entries) async {
    final exerciseEntries = entries.where((e) => e.type == KnowledgeEntryType.exercise).toList();
    final rawExercises = await _loadAllExercises(exerciseEntries);
    final sorted = _sortExercises(rawExercises);
    final progress = await _progressStore.readProgress();
    final filtered = _deriveFiltered(
      sorted,
      level: state.selectedLevel,
      moduleId: state.selectedModuleId,
      construct: state.selectedConstruct,
      query: state.searchQuery,
    );
    emit(state.copyWith(
      status: ExerciseBankStatus.success,
      allExercises: sorted,
      filteredExercises: filtered,
      completedExerciseIds: progress.completedExerciseIds,
      availableModuleIds: _extractModuleIds(sorted),
      availableConstructs: _extractConstructs(sorted),
      errorMessage: () => null,
    ));
  }

  Future<List<Exercise>> _loadAllExercises(List<KnowledgeEntry> entries) async {
    final exercises = <Exercise>[];
    for (final entry in entries) {
      final path = entry.path;
      if (path != null) {
        final res = await _repository.getExercise(path);
        if (res is ContentLoaded<Exercise>) {
          exercises.add(res.value);
        }
      }
    }
    return exercises;
  }

  List<Exercise> _sortExercises(List<Exercise> exercises) {
    final copy = List<Exercise>.from(exercises);
    copy.sort((a, b) {
      final diff = a.level.number.compareTo(b.level.number);
      if (diff != 0) return diff;
      final modComp = (a.moduleId ?? 'zzz').compareTo(b.moduleId ?? 'zzz');
      if (modComp != 0) return modComp;
      return a.id.compareTo(b.id);
    });
    return copy;
  }

  List<String> _extractModuleIds(List<Exercise> exercises) {
    final result = <String>[];
    for (final e in exercises) {
      final mod = e.moduleId;
      if (mod != null && !result.contains(mod)) {
        result.add(mod);
      }
    }
    return result;
  }

  List<AstConstruct> _extractConstructs(List<Exercise> exercises) {
    final result = <AstConstruct>[];
    for (final e in exercises) {
      for (final a in e.assertions) {
        if (a is ContainsConstructAssertion && !result.contains(a.construct)) {
          result.add(a.construct);
        }
      }
    }
    return result;
  }

  List<Exercise> _deriveFiltered(
    List<Exercise> exercises, {
    required ExerciseLevel? level,
    required String? moduleId,
    required AstConstruct? construct,
    required String query,
  }) {
    final trimmedQuery = query.trim().toLowerCase();
    return exercises.where((e) {
      if (level != null && e.level != level) return false;
      if (moduleId != null && e.moduleId != moduleId) return false;
      if (construct != null) {
        final hasConstruct = e.assertions
            .whereType<ContainsConstructAssertion>()
            .any((a) => a.construct == construct);
        if (!hasConstruct) return false;
      }
      if (trimmedQuery.isNotEmpty) {
        final matches = e.title.toLowerCase().contains(trimmedQuery) ||
            e.statement.toLowerCase().contains(trimmedQuery) ||
            e.id.toLowerCase().contains(trimmedQuery);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }
}
