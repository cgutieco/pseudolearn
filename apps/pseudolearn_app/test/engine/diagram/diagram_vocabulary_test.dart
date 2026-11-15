import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/diagram/diagram_vocabulary.dart';

void main() {
  group('DiagramVocabulary', () {
    test('spanish and english differ in the terminal terms', () {
      final spanish = DiagramVocabulary.forLanguage(UiLanguageId.spanish);
      final english = DiagramVocabulary.forLanguage(UiLanguageId.english);
      expect(spanish.start, isNot(english.start));
      expect(spanish.end, isNot(english.end));
    });

    test('the system language falls back to spanish', () {
      expect(
        DiagramVocabulary.forLanguage(UiLanguageId.system).start,
        DiagramVocabulary.forLanguage(UiLanguageId.spanish).start,
      );
    });

    test('no term is empty in either language', () {
      for (final language in UiLanguageId.values) {
        final vocabulary = DiagramVocabulary.forLanguage(language);
        expect(vocabulary.start, isNotEmpty);
        expect(vocabulary.end, isNotEmpty);
        expect(vocabulary.affirmative, isNotEmpty);
        expect(vocabulary.negative, isNotEmpty);
      }
    });

    test('spanish questions carry the opening mark and english do not', () {
      expect(DiagramVocabulary.forLanguage(UiLanguageId.spanish).asQuestion('a > b'), '¿a > b?');
      expect(DiagramVocabulary.forLanguage(UiLanguageId.english).asQuestion('a > b'), 'a > b?');
    });
  });

  group('ExitVocabulary', () {
    final spanish = DiagramVocabulary.forLanguage(UiLanguageId.spanish).exits;
    final english = DiagramVocabulary.forLanguage(UiLanguageId.english).exits;

    test('names the end of a loop by its line in both languages', () {
      expect(spanish.loopExit(6), 'Fin del bucle (línea 6)');
      expect(english.loopExit(6), 'Loop end (line 6)');
    });

    test('lists one line in singular and several in plural', () {
      expect(spanish.cleanupsAtEndOf([3]), 'Limpiezas al terminar: línea 3');
      expect(english.cleanupsAtEndOf([5, 2]), 'Cleanups at end: lines 5, 2');
    });

    test('leaves a caption untouched when no cleanup runs', () {
      expect(spanish.withCleanups('Salir', const []), 'Salir');
      expect(english.withCleanups('break', [4]), 'break — cleanups: line 4');
    });
  });
}
