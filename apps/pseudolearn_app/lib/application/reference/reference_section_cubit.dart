import 'package:bloc/bloc.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/reference/reference_section.dart';
import '../../domain/ports/reference_repository.dart';
import 'reference_section_state.dart';

final class ReferenceSectionCubit extends Cubit<ReferenceSectionState> {
  final ReferenceRepository _repository;

  ReferenceSectionCubit({required this._repository})
    : super(const ReferenceSectionState());

  Future<void> load(ReferenceEdition edition, String sectionId) async {
    final current = state.edition == edition
        ? state
        : ReferenceSectionState(edition: edition);
    if (current.sections.containsKey(sectionId)) {
      if (current != state) emit(current);
      return;
    }
    emit(
      ReferenceSectionState(
        edition: edition,
        sections: current.sections,
        loading: {...current.loading, sectionId},
        missing: current.missing,
      ),
    );
    final loaded = await _repository.loadSection(edition, sectionId);
    if (isClosed || state.edition != edition) return;
    _settle(sectionId, loaded);
  }

  void _settle(String sectionId, ContentLoadResult<ReferenceSection> loaded) {
    final loading = {...state.loading}..remove(sectionId);
    emit(switch (loaded) {
      ContentLoaded<ReferenceSection>(:final value) => ReferenceSectionState(
        edition: state.edition,
        sections: {...state.sections, sectionId: value},
        loading: loading,
        missing: state.missing,
      ),
      ContentLoadFailed<ReferenceSection>() => ReferenceSectionState(
        edition: state.edition,
        sections: state.sections,
        loading: loading,
        missing: {...state.missing, sectionId},
      ),
    });
  }
}
