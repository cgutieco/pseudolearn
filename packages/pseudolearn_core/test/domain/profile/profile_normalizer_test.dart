import 'package:pseudolearn_core/src/domain/profile/accent_policy.dart';
import 'package:pseudolearn_core/src/domain/profile/case_policy.dart';
import 'package:pseudolearn_core/src/domain/profile/profile_normalizer.dart';
import 'package:test/test.dart';

void main() {
  group('ProfileNormalizer', () {
    test('normalizes case and accents when both policies are insensitive', () {
      const normalizer = ProfileNormalizer(
        casePolicy: CasePolicy.insensitive,
        accentPolicy: AccentPolicy.insensitive,
      );

      expect(normalizer.normalize('Según'), equals('segun'));
      expect(normalizer.normalize('MÉTODO'), equals('metodo'));
      expect(normalizer.normalize('LÓGICO'), equals('logico'));
      expect(normalizer.normalize('Dimensión'), equals('dimension'));
      expect(normalizer.normalize('Hacer'), equals('hacer'));
    });

    test('preserves case when casePolicy is sensitive', () {
      const normalizer = ProfileNormalizer(
        casePolicy: CasePolicy.sensitive,
        accentPolicy: AccentPolicy.insensitive,
      );

      expect(normalizer.normalize('Según'), equals('Segun'));
      expect(normalizer.normalize('MÉTODO'), equals('METODO'));
    });

    test('preserves accents when accentPolicy is sensitive', () {
      const normalizer = ProfileNormalizer(
        casePolicy: CasePolicy.insensitive,
        accentPolicy: AccentPolicy.sensitive,
      );

      expect(normalizer.normalize('Según'), equals('según'));
      expect(normalizer.normalize('MÉTODO'), equals('método'));
    });

    test('collapses multiple whitespace and tabs inside multi-word lexemes',
        () {
      const normalizer = ProfileNormalizer(
        casePolicy: CasePolicy.insensitive,
        accentPolicy: AccentPolicy.insensitive,
      );

      expect(normalizer.normalize('De   Otro \t Modo'), equals('de otro modo'));
      expect(normalizer.normalize('Sin\t\tSaltar'), equals('sin saltar'));
      expect(normalizer.normalize('  Hasta   Que  '), equals('hasta que'));
    });

    test('preserves non-alphabetic symbols unaltered', () {
      const normalizer = ProfileNormalizer(
        casePolicy: CasePolicy.insensitive,
        accentPolicy: AccentPolicy.insensitive,
      );

      expect(normalizer.normalize('<-'), equals('<-'));
      expect(normalizer.normalize('<='), equals('<='));
      expect(normalizer.normalize('//'), equals('//'));
    });
  });
}
