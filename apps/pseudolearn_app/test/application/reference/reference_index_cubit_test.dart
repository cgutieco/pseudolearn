import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/reference/reference_index_cubit.dart';
import 'package:pseudolearn_app/application/reference/reference_index_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_index.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_search_entry.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_section_kind.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_reference_repository.dart';

const _edition = ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish);

ReferenceIndexEntry _entry(String id) => ReferenceIndexEntry(
  id: id,
  number: id,
  kind: ReferenceSectionKind.construction,
  title: const [],
  phrase: const [],
);

final _index = ReferenceIndex([
  ReferencePart(id: 'vi', number: 'VI', title: 'Control', summary: '', sections: [_entry('control.si'), _entry('control.para')]),
  ReferencePart(id: 'iii', number: 'III', title: 'Tipos', summary: '', sections: [_entry('tipos.primitivos')]),
]);

const _search = [
  ReferenceSearchEntry(text: 'La decisión Si', kind: 'title', sectionId: 'control.si'),
  ReferenceSearchEntry(text: 'rama', kind: 'term', sectionId: 'control.si'),
  ReferenceSearchEntry(text: 'Entero', kind: 'title', sectionId: 'tipos.primitivos'),
];

final class _FailingRepository extends FakeReferenceRepository {
  @override
  Future<ContentLoadResult<ReferenceIndex>> loadIndex(ReferenceEdition edition) async =>
      const ContentLoadFailed(failure: ContentLoadFailure.assetMissing, detail: 'toc');
}

void main() {
  test('loads the index once per edition', () async {
    final repository = FakeReferenceRepository(index: _index, search: _search);
    final cubit = ReferenceIndexCubit(repository: repository);
    await cubit.load(_edition);
    await cubit.load(_edition);
    expect(cubit.state.status, ReferenceIndexStatus.success);
    expect(repository.requestedEditions.length, 1);
    expect(cubit.state.visibleParts.length, 2);
  });

  test('filters parts and sections by the search query', () async {
    final cubit = ReferenceIndexCubit(repository: FakeReferenceRepository(index: _index, search: _search));
    await cubit.load(_edition);
    cubit.search('RAMA');
    expect(cubit.state.visibleParts.single.sections.single.id, 'control.si');
    cubit.search('nada');
    expect(cubit.state.visibleParts, isEmpty);
    cubit.search('  ');
    expect(cubit.state.visibleParts.length, 2);
  });

  test('reports a missing bundle as an error', () async {
    final cubit = ReferenceIndexCubit(repository: _FailingRepository());
    await cubit.load(_edition);
    expect(cubit.state.status, ReferenceIndexStatus.error);
  });
}
