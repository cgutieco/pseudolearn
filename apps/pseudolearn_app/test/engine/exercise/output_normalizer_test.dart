import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/engine/exercise/output_normalizer.dart';

void main() {
  const normalizer = OutputNormalizer();

  bool matchesNumeric(List<String> expected, List<String> actual) =>
      normalizer.matches(
        expected: expected,
        actual: actual,
        kind: ExpectedValueKind.numeric,
      );

  bool matchesText(List<String> expected, List<String> actual) =>
      normalizer.matches(
        expected: expected,
        actual: actual,
        kind: ExpectedValueKind.text,
      );

  group('normalize', () {
    test('trims each line and collapses internal runs of spaces to one', () {
      expect(
        normalizer.normalize(['  el   resultado   es  ', '\tdos\t\tvalores\t']),
        ['el resultado es', 'dos valores'],
      );
    });

    test('drops trailing empty lines and keeps the ones in between', () {
      expect(
        normalizer.normalize(['uno', '', 'dos', '', '   ']),
        ['uno', '', 'dos'],
      );
    });

    test('an empty output normalizes to an empty output', () {
      expect(normalizer.normalize(const []), isEmpty);
      expect(normalizer.normalize(['', '  ']), isEmpty);
    });
  });

  group('matches', () {
    test('identical output passes', () {
      expect(matchesText(['hola'], ['hola']), isTrue);
    });

    test('spacing differences do not fail a comparison', () {
      expect(matchesText(['el resultado es 4'], ['  el   resultado es 4 ']), isTrue);
    });

    test('a numeric value written as a real matches the same integer', () {
      expect(matchesNumeric(['10'], ['10.0']), isTrue);
      expect(matchesNumeric(['10.0'], ['10']), isTrue);
    });

    test('a real within the relative tolerance matches, and one outside does not', () {
      expect(matchesNumeric(['1.0000000001'], ['1.0']), isTrue);
      expect(matchesNumeric(['1.001'], ['1.0']), isFalse);
    });

    test('integers are compared exactly', () {
      expect(matchesNumeric(['10'], ['11']), isFalse);
    });

    test('a numeric case still compares non numeric lines as text', () {
      expect(matchesNumeric(['listo'], ['listo']), isTrue);
      expect(matchesNumeric(['listo'], ['Listo']), isFalse);
    });

    test('text differing only in case fails, and so it should', () {
      expect(matchesText(['Hola'], ['hola']), isFalse);
    });

    test('accents are part of the text and are compared', () {
      expect(matchesText(['año'], ['ano']), isFalse);
      expect(matchesText(['año'], ['año']), isTrue);
    });

    test('more lines than expected, and fewer, both fail', () {
      expect(matchesText(['uno'], ['uno', 'dos']), isFalse);
      expect(matchesText(['uno', 'dos'], ['uno']), isFalse);
    });

    test('a case with no expected output is met by a program that writes nothing', () {
      expect(matchesText(const [], const []), isTrue);
      expect(matchesText(const [], ['algo']), isFalse);
    });
  });
}
