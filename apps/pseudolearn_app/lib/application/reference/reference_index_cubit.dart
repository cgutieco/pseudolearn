import 'package:bloc/bloc.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/reference/reference_index.dart';
import '../../domain/model/reference/reference_links.dart';
import '../../domain/model/reference/reference_search_entry.dart';
import '../../domain/ports/reference_repository.dart';
import 'reference_index_state.dart';

final class ReferenceIndexCubit extends Cubit<ReferenceIndexState> {
  final ReferenceRepository _repository;

  ReferenceIndexCubit({required this._repository})
    : super(const ReferenceIndexState());

  Future<void> load(ReferenceEdition edition) async {
    if (state.edition == edition &&
        state.status == ReferenceIndexStatus.success) {
      return;
    }
    emit(
      state.copyWith(status: ReferenceIndexStatus.loading, edition: edition),
    );
    final index = await _repository.loadIndex(edition);
    final search = await _repository.loadSearch(edition);
    final links = await _repository.loadLinks(edition);
    if (isClosed) return;
    if (index is! ContentLoaded<ReferenceIndex> ||
        search is! ContentLoaded<List<ReferenceSearchEntry>> ||
        links is! ContentLoaded<ReferenceLinks>) {
      emit(state.copyWith(status: ReferenceIndexStatus.error));
      return;
    }
    emit(
      state.copyWith(
        status: ReferenceIndexStatus.success,
        index: index.value,
        searchEntries: search.value,
        links: links.value,
      ),
    );
  }

  void search(String query) => emit(state.copyWith(query: query));
}
