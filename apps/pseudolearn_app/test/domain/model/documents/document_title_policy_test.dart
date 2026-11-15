import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/documents/document_title_policy.dart';

void main() {
  group('DocumentTitlePolicy', () {
    group('normalizeDocumentTitle and comparison normalization', () {
      test('trims leading and trailing whitespace', () {
        expect(normalizeDocumentTitle('  hello world  '), 'hello world');
      });

      test(
          'collapses multiple internal whitespace characters into single space',
          () {
        expect(normalizeDocumentTitle('hello \t\n  world   test'),
            'hello world test');
      });

      test(
          'comparison normalisation is case-insensitive and preserves diacritics',
          () {
        expect(
          normalizeDocumentTitleForComparison('  Área   Triángulo  '),
          'área triángulo',
        );
        expect(
          normalizeDocumentTitleForComparison('Area Triangulo'),
          'area triangulo',
        );
        expect(
          normalizeDocumentTitleForComparison('Área'),
          isNot(equals(normalizeDocumentTitleForComparison('Area'))),
        );
      });
    });

    group('suggestNextDocumentTitle - RFC 008 §10 table', () {
      test('empty existing list suggests base title as-is', () {
        final suggested = suggestNextDocumentTitle('Ejemplo suma', []);
        expect(suggested, 'Ejemplo suma');
      });

      test('existing bare title suggests title 2', () {
        final suggested =
            suggestNextDocumentTitle('Ejemplo suma', ['Ejemplo suma']);
        expect(suggested, 'Ejemplo suma 2');
      });

      test('existing title 1 suggests title 2', () {
        final suggested =
            suggestNextDocumentTitle('Ejemplo suma', ['Ejemplo suma 1']);
        expect(suggested, 'Ejemplo suma 2');
      });

      test('existing title 1 and title 2 suggests title 3', () {
        final suggested = suggestNextDocumentTitle('Ejemplo suma', [
          'Ejemplo suma 1',
          'Ejemplo suma 2',
        ]);
        expect(suggested, 'Ejemplo suma 3');
      });

      test(
          'existing bare title and title 4 suggests title 5 (next after max, no filling gaps)',
          () {
        final suggested = suggestNextDocumentTitle('Ejemplo suma', [
          'Ejemplo suma',
          'Ejemplo suma 4',
        ]);
        expect(suggested, 'Ejemplo suma 5');
      });
    });

    group('suggestNextDocumentTitle - edge cases and robustness', () {
      test('matches family case-insensitively and with collapsed spaces', () {
        final suggested = suggestNextDocumentTitle('Ejemplo suma', [
          'ejemplo   SUMA',
          'EJEMPLO SUMA 2',
        ]);
        expect(suggested, 'Ejemplo suma 3');
      });

      test('distinguishes accents in family matching', () {
        final suggested = suggestNextDocumentTitle('Area', ['Área', 'Área 2']);
        expect(suggested, 'Area');

        final suggestedWithAccent = suggestNextDocumentTitle('Área', ['Área']);
        expect(suggestedWithAccent, 'Área 2');
      });

      test('handles empty base title', () {
        expect(suggestNextDocumentTitle('   ', ['Ejemplo']), '');
      });

      test('handles 100 documents of the same family', () {
        final existing = List.generate(
            100, (i) => i == 0 ? 'Documento' : 'Documento ${i + 1}');
        final suggested = suggestNextDocumentTitle('Documento', existing);
        expect(suggested, 'Documento 101');
      });

      test('handles large family numbers', () {
        final suggested = suggestNextDocumentTitle('Test', ['Test 999999']);
        expect(suggested, 'Test 1000000');
      });

      test('handles base titles that already end in numbers', () {
        final suggestedForNew = suggestNextDocumentTitle('Ejercicio 2024', []);
        expect(suggestedForNew, 'Ejercicio 2024');

        final suggestedForExisting =
            suggestNextDocumentTitle('Ejercicio 2024', ['Ejercicio 2024']);
        expect(suggestedForExisting, 'Ejercicio 2024 2');

        final suggestedWithBasePrefix =
            suggestNextDocumentTitle('Ejercicio', ['Ejercicio 2024']);
        expect(suggestedWithBasePrefix, 'Ejercicio 2025');
      });

      test(
          'ignores invalid family suffixes like zero, negative numbers, or alphanumeric tags',
          () {
        final suggested = suggestNextDocumentTitle('Ejemplo', [
          'Ejemplo 0',
          'Ejemplo -5',
          'Ejemplo 02',
          'Ejemplo 2b',
          'Ejemplo abc',
        ]);
        expect(suggested, 'Ejemplo');
      });

      test(
          'accepts (conflicto) base title and increments family numbers without breaking parser',
          () {
        const base = 'Algoritmo (conflicto)';

        expect(suggestNextDocumentTitle(base, []), 'Algoritmo (conflicto)');

        expect(
          suggestNextDocumentTitle(base, ['Algoritmo (conflicto)']),
          'Algoritmo (conflicto) 2',
        );

        expect(
          suggestNextDocumentTitle(base, [
            'Algoritmo (conflicto)',
            'Algoritmo (conflicto) 2',
          ]),
          'Algoritmo (conflicto) 3',
        );

        const multiParenBase = 'Ejercicio (v1) (conflicto)';
        expect(
          suggestNextDocumentTitle(
              multiParenBase, ['Ejercicio (v1) (conflicto)']),
          'Ejercicio (v1) (conflicto) 2',
        );
      });
    });

    group('validateDocumentTitle and isDocumentTitleAvailable', () {
      test('rejects empty title or whitespace only', () {
        expect(validateDocumentTitle('', []), DocumentTitleValidation.empty);
        expect(validateDocumentTitle('   ', []), DocumentTitleValidation.empty);
        expect(isDocumentTitleAvailable('   ', []), isFalse);
      });

      test('accepts single character title if not duplicate', () {
        expect(validateDocumentTitle('A', []), DocumentTitleValidation.valid);
        expect(isDocumentTitleAvailable('A', []), isTrue);
      });

      test('rejects duplicate title regardless of casing or extra spaces', () {
        final existing = ['Algoritmo Principal', 'Segundo Algoritmo'];

        expect(
          validateDocumentTitle('algoritmo   principal', existing),
          DocumentTitleValidation.duplicate,
        );
        expect(
          isDocumentTitleAvailable('ALGORITMO PRINCIPAL', existing),
          isFalse,
        );
      });

      test('does not reject title that differs only by accent/diacritic', () {
        final existing = ['Area'];
        expect(
          validateDocumentTitle('Área', existing),
          DocumentTitleValidation.valid,
        );
        expect(isDocumentTitleAvailable('Área', existing), isTrue);
      });

      test('allows keeping own title when renaming', () {
        final existing = ['Mi Documento', 'Otro Documento'];

        expect(
          validateDocumentTitle(
            'mi documento',
            existing,
            currentTitle: 'Mi Documento',
          ),
          DocumentTitleValidation.valid,
        );
        expect(
          isDocumentTitleAvailable(
            'Mi Documento',
            existing,
            currentTitle: 'Mi Documento',
          ),
          isTrue,
        );
      });

      test('rejects renaming to another existing document title', () {
        final existing = ['Mi Documento', 'Otro Documento'];

        expect(
          validateDocumentTitle(
            'Otro Documento',
            existing,
            currentTitle: 'Mi Documento',
          ),
          DocumentTitleValidation.duplicate,
        );
        expect(
          isDocumentTitleAvailable(
            'OTRO DOCUMENTO',
            existing,
            currentTitle: 'Mi Documento',
          ),
          isFalse,
        );
      });
    });
  });
}
