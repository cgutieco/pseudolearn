import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/reference/reference_section_cubit.dart';
import 'package:pseudolearn_app/application/reference/reference_section_state.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_section.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_section_kind.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_reference_repository.dart';

const _spanish = ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish);
const _english = ReferenceEdition(language: UiLanguageId.english, profile: SyntaxProfileId.english);

const _section = ReferenceSection(
  id: 'control.si',
  number: '6.1',
  kind: ReferenceSectionKind.construction,
  title: [],
  phrase: [],
  blocks: [],
);

void main() {
  test('keeps every loaded section of the edition', () async {
    final cubit = ReferenceSectionCubit(repository: FakeReferenceRepository(sections: {'control.si': _section}));
    expect(cubit.state.statusOf('control.si'), ReferenceSectionStatus.initial);
    await cubit.load(_spanish, 'control.si');
    await cubit.load(_spanish, 'nada');
    expect(cubit.state.statusOf('control.si'), ReferenceSectionStatus.success);
    expect(cubit.state.sectionOf('control.si'), same(_section));
    expect(cubit.state.statusOf('nada'), ReferenceSectionStatus.notFound);
  });

  test('forgets sections of another edition', () async {
    final cubit = ReferenceSectionCubit(repository: FakeReferenceRepository(sections: {'control.si': _section}));
    await cubit.load(_spanish, 'control.si');
    await cubit.load(_english, 'nada');
    expect(cubit.state.edition, _english);
    expect(cubit.state.sectionOf('control.si'), isNull);
  });
}
