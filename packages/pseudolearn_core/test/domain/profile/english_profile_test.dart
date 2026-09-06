import 'package:pseudolearn_core/src/domain/primitive_type.dart';
import 'package:pseudolearn_core/src/domain/profile/accent_policy.dart';
import 'package:pseudolearn_core/src/domain/profile/builtin_function.dart';
import 'package:pseudolearn_core/src/domain/profile/case_policy.dart';
import 'package:pseudolearn_core/src/domain/profile/identifier_alphabet.dart';
import 'package:pseudolearn_core/src/domain/profile/profile_normalizer.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/english_profile.dart';
import 'package:pseudolearn_core/src/domain/token_type.dart';
import 'package:test/test.dart';

void main() {
  group('EnglishProfile', () {
    const profileStrict = EnglishProfile.strict();
    const profileFlexible = EnglishProfile.flexible();

    test('every reserved token has a canonical lexeme defined', () {
      for (final token in TokenType.values) {
        if (token.isReserved) {
          final entry = profileStrict.reservedLexemes[token];
          expect(
            entry,
            isNotNull,
            reason:
                'EnglishProfile must define an entry for reserved token $token',
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
      expect(profileStrict.name, contains('strict'));
      expect(profileStrict.accentPolicy, equals(AccentPolicy.sensitive));
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
      expect(profileFlexible.accentPolicy, equals(AccentPolicy.sensitive));
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
        accentPolicy: AccentPolicy.sensitive,
      );

      final lookupMap = <String, TokenType>{};
      for (final entry in profileStrict.reservedLexemes.entries) {
        for (final form in entry.value.allForms) {
          lookupMap[normalizer.normalize(form)] = entry.key;
        }
      }

      expect(lookupMap['algorithm'], equals(TokenType.algorithm));
      expect(lookupMap['define'], equals(TokenType.declare));
      expect(lookupMap['declare'], equals(TokenType.declare));
      expect(lookupMap['<-'], equals(TokenType.assignment));
      expect(lookupMap[':='], equals(TokenType.assignment));
      expect(lookupMap['write'], equals(TokenType.write));
      expect(lookupMap['print'], equals(TokenType.write));
      expect(lookupMap['otherwise'], equals(TokenType.defaultCase));
      expect(lookupMap['default'], equals(TokenType.defaultCase));
      expect(lookupMap['end algorithm'], equals(TokenType.endAlgorithm));
      expect(lookupMap['endalgorithm'], equals(TokenType.endAlgorithm));
    });

    test('all 18 builtin functions are defined with appropriate names', () {
      expect(profileStrict.builtinFunctions.length, equals(18));
      for (final builtin in BuiltinFunction.values) {
        final entry = profileStrict.builtinFunctions[builtin];
        expect(
          entry,
          isNotNull,
          reason: 'Builtin $builtin must have an entry in English profile',
        );
        expect(entry!.canonicalName, isNotEmpty);
      }
    });

    test(
        'formatTokenType formats reserved tokens to canonical lexeme and open to descriptive English',
        () {
      expect(
          profileStrict.formatTokenType(TokenType.algorithm), equals('algorithm'));
      expect(profileStrict.formatTokenType(TokenType.ifKeyword), equals('if'));
      expect(profileStrict.formatTokenType(TokenType.assignment), equals('<-'));
      expect(profileStrict.formatTokenType(TokenType.identifier),
          equals('identifier'));
      expect(
          profileStrict.formatTokenType(TokenType.stringLiteral), equals('string'));
    });

    test('formatPrimitiveType formats primitive types to English names', () {
      expect(profileStrict.formatPrimitiveType(PrimitiveType.integer),
          equals('integer'));
      expect(profileStrict.formatPrimitiveType(PrimitiveType.real),
          equals('real'));
      expect(profileStrict.formatPrimitiveType(PrimitiveType.boolean),
          equals('boolean'));
      expect(profileStrict.formatPrimitiveType(PrimitiveType.character),
          equals('character'));
      expect(profileStrict.formatPrimitiveType(PrimitiveType.string),
          equals('string'));
    });
  });
}
