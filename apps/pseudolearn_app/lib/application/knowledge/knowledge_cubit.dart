import 'package:bloc/bloc.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/knowledge_repository.dart';
import '../../domain/ports/syntax_reference_source.dart';
import 'knowledge_state.dart';

final class KnowledgeCubit extends Cubit<KnowledgeState> {
  final KnowledgeRepository _repository;
  final SyntaxReferenceSource _referenceSource;

  KnowledgeCubit({
    required KnowledgeRepository repository,
    required SyntaxReferenceSource referenceSource,
  })  : _repository = repository,
        _referenceSource = referenceSource,
        super(const KnowledgeState());

  Future<void> load(UiLanguageId language) async {
    emit(state.copyWith(status: KnowledgeStatus.loading));
    try {
      final loaded = await _repository.getEntries(language);
      if (loaded is ContentLoadFailed<List<KnowledgeEntry>>) {
        emit(state.copyWith(
          status: KnowledgeStatus.error,
          errorMessage: () => '${loaded.failure.name}: ${loaded.detail}',
        ));
        return;
      }
      final entries = (loaded as ContentLoaded<List<KnowledgeEntry>>).value;
      final specification = [
        ...entries.where((e) => e.type == KnowledgeEntryType.specificationSection),
        ..._referenceSource.getReferenceEntries(),
      ];
      final exercises = entries.where((e) => e.type == KnowledgeEntryType.exercise).toList();

      emit(state.copyWith(
        status: KnowledgeStatus.success,
        specificationEntries: specification,
        filteredSpecificationEntries: _filtered(specification, state.searchQuery),
        exerciseEntries: exercises,
        filteredExerciseEntries: _filtered(exercises, state.searchQuery),
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: KnowledgeStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  void search(String query) {
    emit(state.copyWith(
      searchQuery: query,
      filteredSpecificationEntries: _filtered(state.specificationEntries, query),
      filteredExerciseEntries: _filtered(state.exerciseEntries, query),
    ));
  }

  List<KnowledgeEntry> _filtered(List<KnowledgeEntry> entries, String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return entries;
    return entries.where((entry) {
      return entry.title.toLowerCase().contains(trimmed) ||
          entry.summary.toLowerCase().contains(trimmed);
    }).toList();
  }
}
