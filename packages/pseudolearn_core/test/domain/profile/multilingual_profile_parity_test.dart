import 'package:pseudolearn_core/src/domain/profile/builtin_function.dart';
import 'package:pseudolearn_core/src/domain/profile/language_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profile_normalizer.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/english_profile.dart';
import 'package:pseudolearn_core/src/domain/token_type.dart';
import 'package:test/test.dart';

void main() {
  group('Multilingual profile parity', () {
    const spanishProfile = ClassicSpanishProfile.strict();
    const englishProfile = EnglishProfile.strict();

    test('both profiles cover the exact same set of reserved tokens', () {
      final spanishKeys = spanishProfile.reservedLexemes.keys.toSet();
      final englishKeys = englishProfile.reservedLexemes.keys.toSet();

      expect(spanishKeys, equals(englishKeys));
      expect(spanishKeys.length, equals(73));
    });

    test('both profiles cover the exact same set of builtin functions', () {
      final spanishBuiltins = spanishProfile.builtinFunctions.keys.toSet();
      final englishBuiltins = englishProfile.builtinFunctions.keys.toSet();

      expect(spanishBuiltins, equals(englishBuiltins));
      expect(spanishBuiltins.length, equals(18));
    });

    test(
        'same abstract token sequence renders correctly in Spanish and English',
        () {
      final tokenSequence = <TokenType>[
        TokenType.algorithm,
        TokenType.declare,
        TokenType.typeConnector,
        TokenType.integerType,
        TokenType.ifKeyword,
        TokenType.then,
        TokenType.write,
        TokenType.endIf,
        TokenType.endAlgorithm,
      ];

      final spanishRendered = tokenSequence
          .map((type) => spanishProfile.formatTokenType(type))
          .toList();
      final englishRendered = tokenSequence
          .map((type) => englishProfile.formatTokenType(type))
          .toList();

      expect(
        spanishRendered,
        equals([
          'Proceso',
          'Definir',
          'Como',
          'Entero',
          'Si',
          'Entonces',
          'Escribir',
          'FinSi',
          'FinProceso',
        ]),
      );

      expect(
        englishRendered,
        equals([
          'algorithm',
          'define',
          'as',
          'integer',
          'if',
          'then',
          'write',
          'endIf',
          'endAlgorithm',
        ]),
      );
    });

    void verifyLexicalIntegrity(LanguageProfile profile) {
      final normalizer = ProfileNormalizer(
        casePolicy: profile.casePolicy,
        accentPolicy: profile.accentPolicy,
      );

      final seenTokens = <String, TokenType>{};
      for (final entry in profile.reservedLexemes.entries) {
        for (final form in entry.value.allForms) {
          final normalized = normalizer.normalize(form);
          final existing = seenTokens[normalized];
          expect(
            existing == null || existing == entry.key,
            isTrue,
            reason: 'Token ${entry.key} form "$form" collides with $existing',
          );
          seenTokens[normalized] = entry.key;
        }
      }

      final seenBuiltins = <String, BuiltinFunction>{};
      for (final entry in profile.builtinFunctions.entries) {
        final allForms = [entry.value.canonicalName, ...entry.value.aliases];
        for (final form in allForms) {
          final normalized = normalizer.normalize(form);
          expect(
            seenTokens.containsKey(normalized),
            isFalse,
            reason:
                'Builtin ${entry.key} form "$form" collides with token ${seenTokens[normalized]}',
          );
          final existing = seenBuiltins[normalized];
          expect(
            existing == null || existing == entry.key,
            isTrue,
            reason: 'Builtin ${entry.key} form "$form" collides with $existing',
          );
          seenBuiltins[normalized] = entry.key;
        }
      }

      for (final entry in profile.reservedLexemes.entries) {
        if (entry.key != TokenType.quote) {
          for (final form in entry.value.allForms) {
            expect(
              form == profile.quoteDelimiter,
              isFalse,
              reason:
                  'Token ${entry.key} lexeme "$form" conflicts with quote delimiter',
            );
          }
        }
        for (final form in entry.value.allForms) {
          expect(
            form.startsWith(profile.commentMarker),
            isFalse,
            reason: 'Lexeme "$form" conflicts with comment marker',
          );
        }
      }
    }

    test('both official profiles satisfy lexical integrity and non-collision',
        () {
      verifyLexicalIntegrity(const ClassicSpanishProfile.strict());
      verifyLexicalIntegrity(const ClassicSpanishProfile.flexible());
      verifyLexicalIntegrity(const EnglishProfile.strict());
      verifyLexicalIntegrity(const EnglishProfile.flexible());
    });
  });
}
