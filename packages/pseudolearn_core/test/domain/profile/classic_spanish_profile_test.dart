import 'package:pseudolearn_core/src/domain/primitive_type.dart';
import 'package:pseudolearn_core/src/domain/profile/accent_policy.dart';
import 'package:pseudolearn_core/src/domain/profile/builtin_function.dart';
import 'package:pseudolearn_core/src/domain/profile/case_policy.dart';
import 'package:pseudolearn_core/src/domain/profile/identifier_alphabet.dart';
import 'package:pseudolearn_core/src/domain/profile/profile_normalizer.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/token_type.dart';
import 'package:test/test.dart';

void main() {
  group('ClassicSpanishProfile', () {
    const profileStrict = ClassicSpanishProfile.strict();
    const profileFlexible = ClassicSpanishProfile.flexible();

    test('every reserved token has a canonical lexeme defined', () {
      for (final token in TokenType.values) {
        if (token.isReserved) {
          final entry = profileStrict.reservedLexemes[token];
          expect(
            entry,
            isNotNull,
            reason:
                'ClassicSpanishProfile must define an entry for reserved token $token',
          );
          expect(
            entry!.canonicalLexeme.trim(),
            isNotEmpty,
            reason: 'Canonical lexeme for token $token cannot be empty',
          );
        }
      }
    });

    test('strict profile configures all 7 rigor flags as specified', () {
      expect(profileStrict.name, contains('estricto'));
      expect(profileStrict.accentPolicy, equals(AccentPolicy.insensitive));
      expect(profileStrict.casePolicy, equals(CasePolicy.insensitive));
      expect(profileStrict.identifierAlphabet,
          equals(IdentifierAlphabet.standard));
      expect(profileStrict.mandatoryStatementTerminator, isTrue);
      expect(profileStrict.mandatoryStepInCountedLoop, isTrue);
      expect(profileStrict.mandatoryVariableDeclaration, isTrue);
      expect(profileStrict.mandatoryInitialization, isTrue);
      expect(profileStrict.numericSwitchCases, isTrue);
      expect(profileStrict.constantArrayDimension, isTrue);
    });

    test('flexible profile configures all 7 rigor flags as specified', () {
      expect(profileFlexible.name, contains('flexible'));
      expect(profileFlexible.accentPolicy, equals(AccentPolicy.insensitive));
      expect(profileFlexible.casePolicy, equals(CasePolicy.insensitive));
      expect(profileFlexible.identifierAlphabet,
          equals(IdentifierAlphabet.extended));
      expect(profileFlexible.mandatoryStatementTerminator, isFalse);
      expect(profileFlexible.mandatoryStepInCountedLoop, isFalse);
      expect(profileFlexible.mandatoryVariableDeclaration, isFalse);
      expect(profileFlexible.mandatoryInitialization, isFalse);
      expect(profileFlexible.numericSwitchCases, isFalse);
      expect(profileFlexible.constantArrayDimension, isFalse);
    });

    test('alias forms resolve correctly under profile normalizer', () {
      const normalizer = ProfileNormalizer(
        casePolicy: CasePolicy.insensitive,
        accentPolicy: AccentPolicy.insensitive,
      );

      final lookupMap = <String, TokenType>{};
      for (final entry in profileStrict.reservedLexemes.entries) {
        for (final form in entry.value.allForms) {
          lookupMap[normalizer.normalize(form)] = entry.key;
        }
      }

      expect(lookupMap['algoritmo'], equals(TokenType.algorithm));
      expect(lookupMap['proceso'], equals(TokenType.algorithm));
      expect(lookupMap[':= '], isNull);
      expect(lookupMap[':='], equals(TokenType.assignment));
      expect(lookupMap['<-'], equals(TokenType.assignment));
      expect(lookupMap['mostrar'], equals(TokenType.write));
      expect(lookupMap['escribir'], equals(TokenType.write));
      expect(lookupMap['sino'], equals(TokenType.elseKeyword));
      expect(lookupMap['si no'], equals(TokenType.elseKeyword));
      expect(lookupMap['sin saltar'], equals(TokenType.withoutNewline));
      expect(lookupMap['sinsaltar'], equals(TokenType.withoutNewline));
      expect(lookupMap['de otro modo'], equals(TokenType.defaultCase));
      expect(lookupMap['deotromodo'], equals(TokenType.defaultCase));
    });

    test('all 18 builtin functions are defined with appropriate names', () {
      expect(profileStrict.builtinFunctions.length, equals(18));
      for (final builtin in BuiltinFunction.values) {
        final entry = profileStrict.builtinFunctions[builtin];
        expect(
          entry,
          isNotNull,
          reason: 'Builtin $builtin must have an entry in Spanish profile',
        );
        expect(entry!.canonicalName, isNotEmpty);
      }
    });

    test(
        'formatTokenType formats reserved tokens to canonical lexeme and open to descriptive Spanish',
        () {
      expect(profileStrict.formatTokenType(TokenType.algorithm),
          equals('Proceso'));
      expect(profileStrict.formatTokenType(TokenType.ifKeyword), equals('Si'));
      expect(profileStrict.formatTokenType(TokenType.assignment), equals('<-'));
      expect(profileStrict.formatTokenType(TokenType.identifier),
          equals('identificador'));
      expect(profileStrict.formatTokenType(TokenType.stringLiteral),
          equals('cadena'));
    });

    test('formatPrimitiveType formats primitive types to Spanish names', () {
      expect(profileStrict.formatPrimitiveType(PrimitiveType.integer),
          equals('entero'));
      expect(profileStrict.formatPrimitiveType(PrimitiveType.real),
          equals('real'));
      expect(profileStrict.formatPrimitiveType(PrimitiveType.boolean),
          equals('lógico'));
      expect(profileStrict.formatPrimitiveType(PrimitiveType.character),
          equals('carácter'));
      expect(profileStrict.formatPrimitiveType(PrimitiveType.string),
          equals('cadena'));
    });
  });
}
