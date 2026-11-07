import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_index.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_links.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_run.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_search_entry.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_section_kind.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

void main() {
  test('search ignores case and accents', () {
    const entry = ReferenceSearchEntry(text: 'La decisión Sí', kind: 'title', sectionId: 'control.si');
    expect(entry.matches(foldSearchText('DECISION')), isTrue);
    expect(entry.matches(foldSearchText('bucle')), isFalse);
    expect(foldSearchText(''), '');
  });

  test('an edition names its bundle directory', () {
    const spanish = ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish);
    const mixed = ReferenceEdition(language: UiLanguageId.english, profile: SyntaxProfileId.classicSpanish);
    expect(spanish.directory, 'es/es');
    expect(mixed.directory, 'en/es');
    expect(spanish, const ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish));
    expect(spanish == mixed, isFalse);
  });

  test('an index finds its sections across parts', () {
    const index = ReferenceIndex([
      ReferencePart(id: 'p', number: 'VI', title: 'Control', summary: '', sections: [
        ReferenceIndexEntry(id: 'control.si', number: '6.1', kind: ReferenceSectionKind.construction, title: [ReferenceCodeRun([])], phrase: []),
      ]),
    ]);
    expect(index.entry('control.si')?.number, '6.1');
    expect(index.entry('nada'), isNull);
    expect(const ReferenceIndex.empty().sections, isEmpty);
  });

  test('links resolve cards and diagnostics', () {
    const links = ReferenceLinks(cards: {'help.conditional': 'control.si'}, diagnostics: {'divisionByZero': 'expresiones.division'});
    expect(links.sectionForCard('help.conditional'), 'control.si');
    expect(links.sectionForDiagnostic('divisionByZero'), 'expresiones.division');
    expect(const ReferenceLinks.empty().sectionForCard('x'), isNull);
    expect(plainTextOf(const [ReferenceTextRun('a'), ReferenceSlotRun('b')]), 'ab');
  });
}
